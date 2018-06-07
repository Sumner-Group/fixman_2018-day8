#!/usr/bin/perl -w
use Cwd;
$wd = cwd;

print "Preparing input files\n";

$name="NaCl";
$incr=0.5;
$force=10.0;

&prepare_input();

exit(0);

sub prepare_input() {
    
    $dist=0.5;
    while ($dist <= 10.0) { 
 	    print "Processing dist: $dist\n";
            system("mkdir $dist");
	    &write_mdin0();
	    &write_mdin1();
	    &write_mdin2();
	    &write_disang();
	    &write_batchfile();
	    system("cp $name.rst $name.prmtop $dist; mv mdin_min.$dist mdin_equi.$dist mdin_prod.$dist disang.$dist run.sh.$dist $dist; cd $dist; sbatch run.sh.$dist");
	$dist += $incr;
    }
}

sub write_mdin0 {
    open MDINFILE,'>', "mdin_min.$dist";
    print MDINFILE <<EOF;
2000 step minimization for $dist ang
 &cntrl
  imin = 1, 
  maxcyc=2000, ncyc = 500,
  ntpr = 100, ntwr = 1000,
  ntf = 1, ntc = 1, cut = 8.0,
  ntb = 1, ntp = 0,
  nmropt = 1,
 &end
 &wt 
  type='END',
 &end
DISANG=disang.$dist
EOF
close MDINFILE;
}
sub write_mdin1 {
    open MDINFILE,'>', "mdin_equi.$dist";
    print MDINFILE <<EOF;
50 ps NPT equilibration for $dist ang
 &cntrl
  imin = 0, ntx = 1, irest = 0,
  ntpr = 5000, ntwr = 50000, ntwx = 0,
  ntf = 2, ntc = 2, cut = 8.0,
  ntb = 2, nstlim = 50000, dt = 0.001,
  tempi=0.0, temp0 = 300, ntt = 3,
  gamma_ln = 1.0,
  ntp = 1, pres0 = 1.0, taup = 5.0,
  nmropt = 1, ioutfm=1,
 &end
 &wt 
  type='END',
 &end
DISANG=disang.$dist
EOF
close MDINFILE;
}
sub write_mdin2 {
    open MDINFILE,'>', "mdin_prod.$dist";
    print MDINFILE <<EOF;
100 ps NPT production for $dist ang
 &cntrl
  imin = 0, ntx = 5, irest = 1,
  ntpr = 10000, ntwr = 0, ntwx = 10000,
  ntf = 2, ntc = 2, cut = 8.0,
  ntb = 2, nstlim = 100000, dt = 0.001,
  temp0 = 300, ntt = 3,
  gamma_ln = 1.0,
  ntp = 1, pres0 = 1.0, taup = 5.0,
  nmropt = 1, ioutfm=1,
 &end
 &wt
  type='DUMPFREQ', istep1=50,
 &end
 &wt 
  type='END',
 &end
DISANG=disang.$dist
DUMPAVE=distance_${dist}.dat
EOF
    close MDINFILE;
}
sub write_disang {
    $left  = sprintf "%4.1f", -100;
    $min   = sprintf "%4.1f", $dist;
    $right = sprintf "%4.1f", 100;
    open DISANG,'>', "disang.$dist";
    print DISANG <<EOF;
Harmonic restraints for $dist ang
 &rst
  iat=1,2,
  r1=$left, r2=$min, r3=$min, r4=$right,
 rk2=${force}, rk3=${force},
 &end
EOF
    close DISANG;
}
sub write_batchfile {
    open BATCHFILE, '>', "run.sh.$dist";
    print BATCHFILE <<EOF;
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --time=06:00:00
#SBATCH --qos=normal
#SBATCH --partition=sgpu
#SBATCH --ntasks=1
#SBATCH --job-name=$name-$dist
#SBATCH --output=$name-$dist.log

module purge
module load cuda/9.0.176
module load gcc
#module load openmpi/2.0.1

export AMBERHOME="/projects/ptlake\@colostate.edu/amber16"
export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:\${AMBERHOME}/lib"

cd $wd/$dist

\$AMBERHOME/bin/pmemd.cuda -O \\
-i mdin_min.$dist -p ${name}.prmtop -c ${name}.rst -r ${name}_min_${dist}.rst  -o ${name}_min_${dist}.out 
\$AMBERHOME/bin/pmemd.cuda -O \\
    -i mdin_equi.$dist -p ${name}.prmtop -c ${name}_min_${dist}.rst  -r ${name}_equil_${dist}.rst -o ${name}_equil_${dist}.out 
\$AMBERHOME/bin/pmemd.cuda -O \\
    -i mdin_prod.$dist -p ${name}.prmtop -c ${name}_equil_${dist}.rst -r ${name}_prod_${dist}.rst -o ${name}_prod_${dist}.out -x ${name}_prod_${dist}.mdcrd
EOF

print BATCHFILE "\necho \"Execution finished\"\n";
    close BATCHFILE;
}
