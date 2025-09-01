include { NTLINK_GAP_FILL                       } from '../../../modules/local/ntlink/gap_fill'
include { MASURCA_SAMBA                         } from '../../../modules/local/masurca/samba'
include { SEQKIT_FQ2FA                          } from '../../../modules/nf-core/seqkit/fq2fa'
include { TGSGAPCLOSER                          } from '../../../modules/local/tgsgapcloser'


workflow CLOSE_GAPS {

    take:
    ch_long_reads
    ch_assemblies

    main:

    ch_versions = Channel.empty()

    if ( params.gap_closer == "ntlink" ) {

        NTLINK_GAP_FILL (
            ch_assemblies.join ( ch_long_reads )
        )
        NTLINK_GAP_FILL.out.fasta.set { ch_gap_filled_assemblies }

    } else if ( params.gap_closer == "samba" ) {

        MASURCA_SAMBA (
            ch_assemblies.join ( ch_long_reads )
        )
        MASURCA_SAMBA.out.scaffolds_fasta.set { ch_gap_filled_assemblies }

    } else if ( params.gap_closer == "tgsgapcloser" ) {

        // we need reads in Fasta format for TGS Gap Closer
        SEQKIT_FQ2FA ( ch_long_reads )
        ch_versions = ch_versions.mix ( SEQKIT_FQ2FA.out.versions )

        TGSGAPCLOSER(
            ch_assemblies.join ( SEQKIT_FQ2FA.out.fasta )
        )
        TGSGAPCLOSER.out.assembly.set { ch_gap_filled_assemblies }
    }


    emit:
    assemblies                 = ch_gap_filled_assemblies
    versions                   = ch_versions                     // channel: [ versions.yml ]
}

