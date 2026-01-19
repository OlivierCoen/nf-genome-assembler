include { NTLINK_GAP_FILL                       } from '../../../modules/local/ntlink/gap_fill'


workflow CLOSE_GAPS {

    take:
    ch_long_reads
    ch_assemblies

    main:

    ch_versions = Channel.empty()

    NTLINK_GAP_FILL (
        ch_assemblies.join ( ch_long_reads )
    )
    NTLINK_GAP_FILL.out.fasta.set { ch_gapclosed_assemblies }


    emit:
    gapclosed_assemblies       = ch_gapclosed_assemblies
    versions                   = ch_versions                     // channel: [ versions.yml ]
}
