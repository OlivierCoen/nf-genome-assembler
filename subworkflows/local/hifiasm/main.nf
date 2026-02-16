include { HIFIASM                              } from '../../../modules/local/hifiasm'
include { GFATOOLS_GFA2FA                      } from '../../../modules/nf-core/gfatools/gfa2fa'


workflow HIFIASM_WORKFLOW {

    take:
    ch_reads

    main:

    draft_assembly_versions = channel.empty()

    // TODO: parse Nanoq output to distinguish between long and ultra long reads
    HIFIASM(
        ch_reads.map { meta, reads -> [ meta, reads, [] ] },
        params.assembly_mode
    )

    /*
    HIFIASM.out.primary_contigs
        .map { meta, primary_contigs -> [ meta + [ primary: true ], primary_contigs ] }
        .set { gfa_primary_contigs }

    //HIFIASM.out.alternate_contigs.set { gfa_alternate_contigs }
    // HIFIASM.out.hap1_contigs.set { gfa_haplotig_1_contigs }
    // HIFIASM.out.hap2_contigs.set { gfa_haplotig_2_contigs }

    gfa_primary_contigs
        .mix( gfa_alternate_contigs )
        .set { gfa_assemblies }
    */

    gfa_assemblies = HIFIASM.out.primary_contigs

    GFATOOLS_GFA2FA( gfa_assemblies )

    /*
    GFATOOLS_GFA2FA.out.fasta
        .tap { draft_assembly_versions }
        .filter { meta, assembly -> meta.primary }
        .map {
            meta, assembly ->
                def new_meta = meta
                new_meta.remove('primary')
                [ new_meta, assembly ]
        }
        .set { assemblies }
    */

    assemblies = GFATOOLS_GFA2FA.out.fasta

    emit:
    assemblies
    draft_assembly_versions

}
