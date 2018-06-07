#!/bin/bash
#SBATCH --job-name=prod 
#SBATCH --output=job.log
#SBATCH --time=48:00:00
#SBATCH --nodes=1 
#SBATCH --time=06:00:00
#SBATCH --qos=normal
#SBATCH --partition=sgpu

module purge
module load cuda/9.0.176
module load gcc
#module load openmpi/2.0.1

export AMBERHOME="/projects/ptlake@colostate.edu/amber16"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${AMBERHOME}/lib"

$AMBERHOME/bin/pmemd.cuda -O -i smd.in -o prod.1.out -p ../M10.prmtop -c ../equil/equil.6.rst7 -r prod.1.rst7 -x prod.1.nc

