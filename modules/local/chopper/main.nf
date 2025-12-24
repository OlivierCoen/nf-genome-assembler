process CHOPPER {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/cf/cff7c36d13383fe68e1ea683dd3cb3ef885f4b579895f6d5a67646b4321af132/data':
        'community.wave.seqera.io/library/chopper_pigz:5c818cb80ca6c787' }"

    input:
    tuple val(meta), path(fastq)
    path  fasta

    output:
    tuple val(meta), path("*.fastq.gz"), emit: fastq
    tuple val("${task.process}"), val('chopper'), eval("chopper --version 2>&1 | cut -d ' ' -f 2"), topic: versions

    script:
    def args   = task.ext.args   ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}.filtered"
    def fasta_filtering = fasta ? "--contam ${fasta}" : ""

    if ("$fastq" == "${prefix}.fastq.gz") error "Input and output names are the same, set prefix in module configuration to disambiguate!"
    """
    pigz -dkc \\
        ${fastq} | \\
    chopper \\
        --threads ${task.cpus} \\
        ${fasta_filtering} \\
        ${args} | \\
    pigz -c > ${prefix}.fastq.gz
    """
}
