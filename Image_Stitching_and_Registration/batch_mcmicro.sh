#!/bin/bash
#SBATCH -c 1                               # Request one core
#SBATCH -t 2-12:00                         # Runtime in D-HH:MM format
#SBATCH -p medium                           # Partition to run in
#SBATCH --mem=3G                        # Memory total in GB (for all cores)

#USER INPUTS
user_name='ccr13'
data_dir=/n/scratch3/users/c/ccr13/Chi_CyCIF/DATA/


gen_text="#!/bin/bash\n#SBATCH%1s-c%1s1\n#SBATCH%1s-t%1s0-48:00\n#SBATCH%1s-p%1smedium\n#SBATCH%1s--mem=20G\nmodule%1sload%1sjava%1smatlab%1sconda2\nnextflow%1spull%1scritch3/mcmicro\n"

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
	printf -- "/home/"$user_name"/bin/nextflow%1srun%1scritch3/mcmicro%1s-r%1smaster%1s--in%1s'$data_dir$folder_name'%1s-profile%1sO2massive%1s--start-at%1sregistration%1s--stop-at%1sregistration%1s-w%1s./work" >> $filename"_"$folder_name"_.sh"
	sbatch $filename"_"$folder_name"_.sh"
done

