process PRETEXTSNAPSHOT {
    tag "${pretext_map.baseName}"
    label 'process_single'

    errorStrategy = 'ignore'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine in ['apptainer', 'singularity'] && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/d4/d45a21691a46e7c4cb441377774522fb1b093631e4ca973daa0020ff5893d953/data':
        'community.wave.seqera.io/library/pretextsnapshot_samtools:4647aca739f78355' }"

    input:
    tuple val(meta), path(pretext_map)
    val export_to_multiqc

    output:
    tuple val(meta), path('*.FullMap.{jpeg,png,bmp}'),                                                                                              emit: image
    path('*.pretextsnapshot.{jpeg,png,bmp}'), optional: true,                                                                                       topic: mqc_pretextsnapshot
    tuple val("${task.process}"), val('pretextsnapshot'), eval("echo \$(PretextSnapshot --version 2>&1) | sed 's/^.*PretextSnapshot Version //'"),  topic: versions
    tuple val("${task.process}"), val('samtools'), eval("samtools --version | sed '1!d; s/samtools //'"),                                           topic: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${pretext_map.baseName}."
    """
    PretextSnapshot \\
        $args \\
        --map $pretext_map \\
        --prefix $prefix \\
        --sequences "=full" \\
        --folder .

    if [[ $export_to_multiqc == true ]]; then
        cp ${prefix}FullMap.png ${prefix}pretextsnapshot.png
    fi
    """
    stub:
    def prefix = task.ext.prefix ?: "${pretext_map.baseName}"
    """
    touch ${prefix}.FullMap.png
    """
}
