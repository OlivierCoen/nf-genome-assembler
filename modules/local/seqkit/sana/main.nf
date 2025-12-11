process SEQKIT_SANA {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/85/85b40b925e4d4a62f9b833bbb0646d7ea6cf53d8a875e3055f90da757d7ccd27/data' :
        'community.wave.seqera.io/library/seqkit:2.12.0--5e60eb93d3a59212' }"

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*.sanitised.fq.gz"), emit: fastq
    tuple val("${task.process}"), val('seqkit'), eval("seqkit | sed '3!d; s/Version: //'"), topic: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}.sanitised"

    """
    seqkit \\
        sana \\
        $fastq \\
        $args \\
        -j $task.cpus \\
        -o ${prefix}.fq.gz
    """

}
