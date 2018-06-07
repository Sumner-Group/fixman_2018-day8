#!/bin/bash
#SBATCH --job-name=heat 
#SBATCH --output=job.log
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

$AMBERHOME/bin/pmemd.cuda -O -i heat.1.in -o heat.1.out -p ../M10.prmtop -c ../min/min.rst7 -ref ../min/min.rst7 -r heat.1.rst7 -x heat.1.nc
$AMBERHOME/bin/pmemd.cuda -O -i heat.2.in -o heat.2.out -p ../M10.prmtop -c heat.1.rst7 -ref heat.1.rst7 -r heat.2.rst7 -x heat.2.nc

