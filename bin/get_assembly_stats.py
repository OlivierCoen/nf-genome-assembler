#!/usr/bin/env python3

# Written by Olivier Coen. Released under the MIT license.

import argparse
from pathlib import Path

from Bio import SeqIO

NX_OUTFILE_SUFFIX = ".nx_assembly_stats.csv"
LX_OUTFILE_SUFFIX = ".lx_assembly_stats.csv"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compute assembly stats for a fasta file"
    )
    parser.add_argument("--fasta", type=Path, required=True)
    return parser.parse_args()


def get_contig_lengths(assembly_file: str):
    lengths = [len(record.seq) for record in SeqIO.parse(assembly_file, "fasta")]
    return sorted(lengths, reverse=True)


def calculate_nx_stats(lengths):
    total_length = sum(lengths)
    nx_stats = {}
    for n in range(101):
        cumulative_length = 0
        for i, length in enumerate(lengths):
            cumulative_length += length
            if cumulative_length >= total_length * n / 100:
                nx_stats[n] = dict(N=length, L=i + 1)
                break
    return nx_stats


if __name__ == "__main__":
    args = parse_args()
    contig_lengths = get_contig_lengths(args.fasta)
    nx_stats = calculate_nx_stats(contig_lengths)

    nx_outfile = args.fasta.with_suffix(NX_OUTFILE_SUFFIX)
    lx_outfile = args.fasta.with_suffix(LX_OUTFILE_SUFFIX)

    with open(nx_outfile, "w") as nx_fout, open(lx_outfile, "w") as lx_fout:
        for n, stats in nx_stats.items():
            nx_fout.write(f"{n},{stats['N']}\n")
            lx_fout.write(f"{n},{stats['L']}\n")
