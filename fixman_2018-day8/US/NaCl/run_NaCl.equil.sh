#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=06:00:00
#SBATCH --qos=normal
#SBATCH --partition=sgpu
#SBATCH --ntasks=1
#SBATCH --job-name=NaCl
#SBATCH --output=NaCl.liquid.log

module purge
module load cuda/9.0.176
module load gcc
#module load openmpi/2.0.1

export AMBERHOME="/projects/ptlake@colostate.edu/amber16"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${AMBERHOME}/lib"

MFP=NaCl

time $AMBERHOME/bin/pmemd.cuda -O -i $MFP.min.in -o $MFP.min.log -p $MFP.prmtop -c $MFP.inpcrd -r $MFP.min.rst7 -x $MFP.min.xyz.nc -inf $MFP.min.inf
time $AMBERHOME/bin/pmemd.cuda -O -i $MFP.equil.in -o $MFP.equil.log -p $MFP.prmtop -c $MFP.min.rst7 -r $MFP.equil.rst7 -x $MFP.equil.xyz.nc -inf $MFP.equil.inf

