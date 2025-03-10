#!/bin/bash
#SBATCH -N 1
#SBATCH --tasks-per-node=8
#SBATCH --mem-per-cpu=4G
#SBATCH --time=00-03:00 
#SBATCH --error="%x.e%j"
#SBATCH --output="%x.o%j"

# Usage of this script:
#sbatch -J jobname orca_sub.sh , where jobname is the name of your ORCA inputfile (jobname.inp).
#Jobname below is set automatically when submitting like this: sbatch -J jobname job-orca.sh
#Can alternatively be set manually below. job variable should be the name of the inputfile without extension (.inp)

job=${SLURM_JOB_NAME}
#job=$(echo ${job%%.*}) #or should it be like below?
#job=$(echo ${job%%.inp}) 

#load modules
module load openblas
module load StdEnv/2020 gcc/10.3.0  openmpi/4.1.1
module load orca/5.0.4

# Creating local scratch folder for the user on the computing node. 

#Set the scratchlocation variable to the location of the local scratch, e.g. /scratch or /localscratch 

export scratchlocation=/scratch

if [ ! -d $scratchlocation/$USER ]

then

  mkdir -p $scratchlocation/$USER

fi

tdir=$(mktemp -d $scratchlocation/$USER/orcajob__$SLURM_JOB_ID-XXXX)

# Copy only the necessary stuff in submit directory to scratch directory. Add more here if needed.

cp  $SLURM_SUBMIT_DIR/*.inp $tdir/

cp  $SLURM_SUBMIT_DIR/*.gbw $tdir/

cp  $SLURM_SUBMIT_DIR/*.xyz $tdir/

cp  $SLURM_SUBMIT_DIR/*.cmp $tdir/

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

$EBROOTORCA/orca $job.inp >> $SLURM_SUBMIT_DIR/$job.out

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
cp $tdir/*.ndo $SLURM_SUBMIT_DIR
cp $tdir/*.nto $SLURM_SUBMIT_DIR
