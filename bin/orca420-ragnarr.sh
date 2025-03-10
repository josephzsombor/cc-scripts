#!/bin/bash

#SBATCH --ntasks=setcpu            # cpus, the nprocs defined in the input file
#SBATCH --mem-per-cpu=setmem       # memory per cpu
#SBATCH --time=settime             # time (DD-HH:MM)

# Usage of this script:
#sbatch -J jobname job-orca-SLURM.sh , where jobname is the name of your ORCA inputfile (jobname.inp).

# Jobname below is set automatically when submitting like this: sbatch -J jobname job-orca.sh
#Can alternatively be set manually below. job variable should be the name of the inputfile without extension (.inp)
job=${SLURM_JOB_NAME}
job=$(echo ${job%%.*})

#Setting OPENMPI paths here:
#export PATH=/users/home/user/openmpi/bin:$PATH
#export LD_LIBRARY_PATH=/users/home/user/openmpi/lib:$LD_LIBRARY_PATH
module load nixpkgs/16.09
#module load gcc/5.4.0
#module load openmpi/2.1.1
module load gcc/7.3.0
module load openmpi/3.1.2

# Here giving the path to the ORCA binaries and giving communication protocol
#You can also load module here.
#export orcadir=/path/to/orca
#export RSH_COMMAND="/usr/bin/ssh -x"
#export PATH=$orcadir:$PATH
#export LD_LIBRARY_PATH=$orcadir:$LD_LIBRARY_PATH
module load orca/4.2.0

# Creating local scratch folder for the user on the computing node. 
#Set the scratchlocation variable to the location of the local scratch, e.g. /scratch or /localscratch 
export scratchlocation=$SLURM_TMPDIR
if [ ! -d $scratchlocation ]
then
  mkdir -p $scratchlocation
fi
tdir=$(mktemp -d $scratchlocation/orcajob__$SLURM_JOB_ID-XXXX)

# Copy only the necessary stuff in submit directory to scratch directory. Add more here if needed.
cp  $SLURM_SUBMIT_DIR/*.inp $tdir/
cp  $SLURM_SUBMIT_DIR/*.gbw $tdir/
cp  $SLURM_SUBMIT_DIR/*.xyz $tdir/

# Creating nodefile in scratch
echo $SLURM_NODELIST > $tdir/$job.nodes

# cd to scratch
cd $tdir

# Copy job and node info to beginning of outputfile
echo "Job execution start: $(date)" >>  $SLURM_SUBMIT_DIR/$job.out
echo "Shared library path: $LD_LIBRARY_PATH" >>  $SLURM_SUBMIT_DIR/$job.out
echo "Slurm Job ID is: ${SLURM_JOB_ID}" >>  $SLURM_SUBMIT_DIR/$job.out
echo "Slurm Job name is: ${SLURM_JOB_NAME}" >>  $SLURM_SUBMIT_DIR/$job.out
echo $SLURM_NODELIST >> $SLURM_SUBMIT_DIR/$job.out

#Start ORCA job. ORCA is started using full pathname (necessary for parallel execution). Output file is written directly to submit directory on frontnode.
#$orcadir/orca $tdir/$job.inp >>  $SLURM_SUBMIT_DIR/$job.out
$EBROOTORCA/orca $tdir/$job.inp >>  $SLURM_SUBMIT_DIR/$job.out

# ORCA has finished here. Now copy important stuff back (xyz files, GBW files etc.). Add more here if needed.
cp $tdir/*.gbw $SLURM_SUBMIT_DIR
cp $tdir/*.engrad $SLURM_SUBMIT_DIR
cp $tdir/*.xyz $SLURM_SUBMIT_DIR
cp $tdir/*.loc $SLURM_SUBMIT_DIR
cp $tdir/*.qro $SLURM_SUBMIT_DIR
cp $tdir/*.uno $SLURM_SUBMIT_DIR
cp $tdir/*.unso $SLURM_SUBMIT_DIR
cp $tdir/*.uco $SLURM_SUBMIT_DIR
cp $tdir/*.hess $SLURM_SUBMIT_DIR
cp $tdir/*.cis $SLURM_SUBMIT_DIR
cp $tdir/*.dat $SLURM_SUBMIT_DIR
cp $tdir/*.mp2nat $SLURM_SUBMIT_DIR
cp $tdir/*.nat $SLURM_SUBMIT_DIR
cp $tdir/*.scfp_fod $SLURM_SUBMIT_DIR
cp $tdir/*.scfp $SLURM_SUBMIT_DIR
cp $tdir/*.scfr $SLURM_SUBMIT_DIR
cp $tdir/*.nbo $SLURM_SUBMIT_DIR
cp $tdir/FILE.47 $SLURM_SUBMIT_DIR
cp $tdir/*_property.txt $SLURM_SUBMIT_DIR
cp $tdir/*spin* $SLURM_SUBMIT_DIR


