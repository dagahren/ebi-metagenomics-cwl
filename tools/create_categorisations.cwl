#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: categorise sequences

hints:
  - class: SoftwareRequirement
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  seqs:
    type: File
    streamable: true
    format: edam:format_1929  # FASTA
  ipr_idset:
    type: File
    streamable: true
    format: iana:application/json
  cds_idset:
    type: File
    streamable: true
    format: iana:application/json

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      import json
      from Bio import SeqIO
      ipr_idset = frozenset(json.load(open("$(inputs.ipr_idset.path)", "r")))
      cds_idset = frozenset(json.load(open("$(inputs.cds_idset.path)", "r")))
      ipr_output = open("interproscan.fasta", "w")
      cds_output = open("pCDS.fasta", "w")
      nof_output = open("noFunction.fasta", "w")
      for seq in SeqIO.parse("$(inputs.seqs.path)", "fasta"):
          if seq.name in ipr_idset:
              SeqIO.write(seq, ipr_output, "fasta")
          if seq.name in cds_idset:
              SeqIO.write(seq, cds_output, "fasta")
              if seq.name not in ipr_idset:
                   SeqIO.write(seq, nof_output, "fasta")
outputs:
  interproscan:
    type: File
    format: edam:format_1929  # FASTA
    streamable: true
    outputBinding:
      glob: interproscan.fasta
  pCDS_seqs:
    type: File
    format: edam:format_1929  # FASTA
    streamable: true
    outputBinding:
      glob: pCDS.fasta
  no_functions_seqs:
    type: File
    format: edam:format_1929  # FASTA
    streamable: true
    outputBinding:
      glob: noFunction.fasta

$namespaces:
 iana: https://www.iana.org/assignments/media-types/
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
