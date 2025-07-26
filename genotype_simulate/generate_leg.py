import os
# Define file paths for the input .bim and .leg files and the output .leg file
bim_file = os.getenv("bim_file")
leg_file = os.getenv("leg_file")
haps_file = os.getenv("haps_file")
output_leg_file = os.getenv("output_leg_file")
output_haps_file = os.getenv("output_haps_file")
temp_file = os.getenv("temp_file")

# Read the .bim file and store the positions in a dictionary
bim_positions = {}
bim_idices = {}
line_counter = 0
with open(bim_file, 'r') as bim:
    for line in bim:
        fields = line.strip().split()
        snp_position = fields[3]  # 4th column in .bim is the position
        bim_positions[snp_position] = fields
        bim_idices[snp_position] = line_counter
        line_counter += 1
        
# get the content of original .haps
with open(haps_file, 'r') as haps:
    haps_lines = haps.readlines()

is_dl_defined = False

# Open the output .leg file
with open(output_leg_file, 'w') as out_leg:
    with open(output_haps_file, 'w') as out_haps:
        # Open and read the .leg file
        with open(leg_file, 'r') as leg:
            # Write header (optional: adjust depending on your .leg file format)
            out_leg.write('rs position X0 X1\n')  # Modify the header as needed
            
            for line in leg:
                fields = line.strip().split()
                snp_id = fields[0]  # SNP ID
                snp_position = fields[1]  # SNP position
                
                # Check if the position exists in .bim and SNP ID starts with "rs"
                if snp_position in bim_positions and snp_id.startswith("rs"):
                    # Write the matching line to the output .leg file
                    out_leg.write(line)
                    if not is_dl_defined:
                        with open(temp_file, 'w') as temp_pos:
                            temp_pos.write(snp_position)
                        is_dl_defined = True
                    # extract corresponding line out of .haps
                    fields_haps = haps_lines[bim_idices[snp_position]].strip().split()
                    genotype_info = ' '.join(fields_haps[5:])
                    out_haps.write(f"{genotype_info}\n")

print("Filtered .leg file has been created!")