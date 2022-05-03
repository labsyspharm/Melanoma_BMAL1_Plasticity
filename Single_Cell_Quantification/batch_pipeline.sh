#!/bin/bash
#SBATCH -c 1                               # Request one core
#SBATCH -t 0-12:00                         # Runtime in D-HH:MM format
#SBATCH -p short                           # Partition to run in
#SBATCH --mem=3G                        # Memory total in GB (for all cores)

#USER INPUTS
user_name='ccr13'
data_dir=/n/scratch3/users/c/ccr13/CHOP_TMA/DATA/




gen_text="#!/bin/bash\n#SBATCH%1s-c%1s1\n#SBATCH%1s-t%1s0-12:00\n#SBATCH%1s-p%1sshort\n#SBATCH%1s--mem=20G\n"

curr_dir=$(pwd)
cd $data_dir
files=$(ls -d */)
filename='batch'
cd $curr_dir

for f in $files
do
	len=${#f}
	len_folder=$((len-1))

	folder_name=${f:0:$len_folder}
	echo $folder_name
	
	printf -- $gen_text >> $filename"_"$folder_name"_.sh"
	printf -- 'module%1sload%1smatlab\n' >> $filename'_'$folder_name'_.sh'
	printf -- 'matlab%1s-nodesktop%1s-r%1s"runAll_O2('"'$folder_name'"')"' >> $filename'_'$folder_name'_.sh'
	sbatch $filename"_"$folder_name"_.sh"
done

