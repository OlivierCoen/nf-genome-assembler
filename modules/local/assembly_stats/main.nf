process ASSEMBLY_STATS {
    tag "${fasta.baseName}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['apptainer', 'singularity'] && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/83/8372f6241b480332d91bc00a88ec8c72c8f7fcc9994177a5dd67a07007cd6e32/data' :
        'community.wave.seqera.io/library/biopython:1.85--6f761292fa9881b4' }"

    input:
    tuple val(meta), path(fasta)

    output:
    path("*.nx_assembly_stats.csv"),                                                                                        topic: mqc_nx_assembly_stats
    path("*.lx_assembly_stats.csv"),                                                                                        topic: mqc_lx_assembly_stats
    tuple val("${task.process}"), val('python'),       eval("python3 --version | sed 's/Python //'"),                       topic: versions
    tuple val("${task.process}"), val('biopython'),    eval('python3 -c "import Bio; print(Bio.__version__)"'),             topic: versions

    script:
    def prefix        = task.ext.prefix ?: "${fasta.baseName}.assembly_stats"
    """
    zcat -k $fasta > "${fasta.baseName}"

    get_assembly_stats.py \\
        --fasta ${fasta.baseName}
    """
}
