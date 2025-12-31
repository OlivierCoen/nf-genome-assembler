include { PRETEXTMAP                             } from '../../../modules/local/pretextmap'
include { PRETEXTSNAPSHOT                        } from '../../../modules/local/pretextsnapshot'


workflow HIC_CONTACT_MAP {

    take:
    ch_hic_bam // channel containing alignments of HI-C reads mapped to genome, as produced by the Arima mapping pipeline
    ch_assemblies
    export_to_multiqc

    main:

    PRETEXTMAP (
        ch_hic_bam.join( ch_assemblies )
    )

    PRETEXTSNAPSHOT (
        PRETEXTMAP.out.pretext,
        export_to_multiqc
    )

}
