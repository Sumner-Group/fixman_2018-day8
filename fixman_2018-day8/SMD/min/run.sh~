
#SBATCH --qos=normal
#SBATCH --partition=sgpu

module purge
module load cuda/9.0.176
module load gcc
#module load openmpi/2.0.1

export AMBERHOME="/projects/ptlake@colostate.edu/amber16"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${AMBERHOME}/lib"

$AMBERHOME/bin/pmemd.cuda -O -i equil.1.in -o equil.1.out -p ../M10.prmtop -c ../heat/heat.2.rst7 -ref ../heat/heat.2.rst7 -r equil.1.rst7 -x equil.1.nc

for i in `seq 2 6`;
do
     j=$(($i-1))
     $AMBERHOME/bin/pmemd.cuda -O -i equil.$i.in -o equil.$i.out -p ../M10.prmtop -c equil.$j.rst7 -ref equil.$j.rst7 -r equil.$i.rst7 -x equil.$i.nc
done

