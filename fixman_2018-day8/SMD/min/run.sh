#SBATCH --qos=normal
#SBATCH --partition=sgpu

module purge
module load cuda/9.0.176
module load gcc
#module load openmpi/2.0.1

export AMBERHOME="/projects/ptlake@colostate.edu/amber16"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${AMBERHOME}/lib"

$AMBERHOME/bin/pmemd.cuda -O -i mdin.in -o mdin.out -p ../M10.prmtop -c ../M10.inpcrd  -r min.rst7 -x min.nc


