'''
Takes a multiple sequence alignment nucleotide fasta and slices it for the nuycleotide and [glycoprotein] sequence of 
hantavirus aligned to the reference. Slicing modifieable with start_pos/end_pos for other proteins.
Checks that sequences are divisible by 3. If so, translates sequences and outputs them to an aligned protein FASTA.

---NEED TO ADD---
'N' fillers where sequences are not divisible by 3.
'''
import os
import shutil
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

# Set working directory (change to run directory)
os.chdir("HOME/PATH")

# Set file paths. INPUT MUST BE ALIGNED AND SAME SEQ LENGTH!
input_fasta = "data/al_compare_andesense.fasta"
prot_fasta = "data/prot_compare_andesense.fasta"
nuc_fasta = "data/outbreaks/hondius/test.fasta"

# Based on official ANDV REF sequences. 
# Base 0 slicing positions, exclusive end pos. (hondius ref slice in parentheses)
# L segment based on ANDV ref seq - 35:6497 (34:6496)
# M segment based on ANDV ref seq - 51:3468 (43:3460)
# S segment based on ANDV ref seq - 42:1329 (30:1317)
# nonstructural protein ref seq   - 121:313 (109:313)
start_pos = 42
end_pos = 1329

protein_records = []
nuc_records = []

# Parse input sequences from FASTA.
for record in SeqIO.parse(input_fasta, "fasta"):
    print(f'slicing {record.id} from {start_pos} to {end_pos}...')

    # Slices record based on hard-coded start/end position above.
    sliced_record = record[start_pos:end_pos]

    # Codon triplet length check.
    if len(sliced_record) % 3 != 0:
        print(f'{sliced_record.id} length is: {len(sliced_record)}')
        print("This sequence is not divisible by 3!")

    # Replaces gaps ("-") with "N" so it translates to "X"
    mod_seq = sliced_record.seq.replace("-", "n")

    # Stop codon is not considered for this protein. End of slice is protein end.
    translated_seq = mod_seq.translate(to_stop=False)

    # Create new seq record for sliced protein sequence
    prot_record = SeqRecord(
        translated_seq,
        id=sliced_record.id,
        description=""
    )
    
    # Append outputs to sliced nucleotide and protein lists.
    nuc_records.append(sliced_record)
    protein_records.append(prot_record)


# Write all sliced records to the output file at once
SeqIO.write(protein_records, prot_fasta, "fasta")
SeqIO.write(nuc_records, nuc_fasta, "fasta")

print(f'Sequence slicing and protein translation complete!')
print(f'{nuc_fasta} and {prot_fasta} records output to dissertation/...')

export = "/mnt/c/Users/zhiva/Files/UoG Courses/BIOL 5173P - MSc Thesis Project/cured_data/"

shutil.copy(nuc_fasta, export)
shutil.copy(prot_fasta, export)

print(f'{nuc_fasta} and {prot_fasta} records exported to dissertation/...')