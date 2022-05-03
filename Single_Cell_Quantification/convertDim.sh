#!/bin/bash
#SBATCH -c 1                               # Request one core
#SBATCH -t 0-12:00                        # Runtime in D-HH:MM format
#SBATCH -p short                           # Partition to run in
#SBATCH --mem=25G                       # Memory total in MB (for all cores)
module load fiji
/bin/Xvfb :13 & pid=$!; 
DISPLAY=:13 java -Xmx8g -Dplugins.dir=/n/app/fiji/2.11292018/plugins -jar /n/app/fiji/2.11292018/jars/ij-1.52i.jar -batch RUN_Step2_changetifffromZtoXhannel_yescrops_O2.ijm; 
kill -l 0 $pid;
