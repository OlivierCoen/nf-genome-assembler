process NTLINK_GAP_FILL {
    tag "${fasta.baseName}"
    label 'process_high'

    conda "${moduleDir}/spec-file.txt"
    container "${ workflow.containerEngine in ['apptainer', 'singularity'] && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/d3/d35de4e951194a26adc59644477e8f99f07bbeee0625c63d4b742261a22281b3/data' :
        'community.wave.seqera.io/library/ntlink_pigz:2473457f73127a68' }"

    input:
    tuple val(meta), path(fasta), path(reads)

    output:
    tuple val(meta), path("*.gap_filled.fa.gz") ,                                                      emit: fasta
    tuple val("${task.process}"), val('ntlink'), eval("ntLink 2>&1 | grep -oP 'v\\d+\\.\\d+\\.\\d+'"), topic: versions
    tuple val("${task.process}"), val('pigz'),   eval('pigz --version | sed "s/pigz //g"'),            topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = fasta.name.replaceFirst(/\.[^.]+\.gz$/, "") // everything before (fa/fasta/...).gz
    """
    pigz -dkf $fasta

    ntLink gap_fill \\
        target=${fasta.baseName} \\
        reads=$reads \\
        overlap=True \\
        sensitive=True

    mv "\$( readlink -f \$(find . -name *.ntLink.scaffolds.fa ) )" ${prefix}.gap_filled.fa
    pigz -n ${prefix}.gap_filled.fa
    """

    stub:
    """
    touch ${prefix}.gap_filled.fa.gz
    """
}
