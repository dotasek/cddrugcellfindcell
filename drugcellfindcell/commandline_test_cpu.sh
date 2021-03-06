#!/bin/bash
# argument: directory where all the results will be stored

date +"%T"

##### pre-processing ##################################################################################
scriptdir="/cellar/users/jpark/Data2/DrugCell_web/case3_drug/script/"
outputdir=$1
if [ ! -d "$outputdir" ]
then
	mkdir $outputdir
fi

source activate pytorch3drugcell_rlipp
python $scriptdir/1_build_input.py $outputdir/input_drug.txt $outputdir

inputdrugfile=$outputdir"/input_drug_fingerprint.txt"
inputdrug2id=$outputdir"/input_drug2id.txt"
inputfile=$outputdir"/input.txt"

######################################################################################################


##### run DrugCell prediction #########################################################################
inputdir="/cellar/users/jpark/Data2/DrugCell_web/case3_drug/data/"
gene2idfile=$inputdir"gene2ind.txt"
cell2idfile=$inputdir"cell2ind.txt"
cellmutationfile=$inputdir"cell2mutation.txt"

modelfile=$inputdir"pretrained_model/drugcell_v1.pt"

python -u -W ignore $scriptdir/code/predict_drugcell_rlipp_cpu.py -gene2id $gene2idfile -cell2id $cell2idfile -drug2id $inputdrug2id -genotype $cellmutationfile -fingerprint $inputdrugfile -result $outputdir -predict $inputfile -load $modelfile -ont $inputdir/drugcell_ont.txt -rlipp $outputdir/rlipp.txt 

paste -d "\t" <(cat $outputdir/input.txt) <(cat $outputdir/drugcell.predict) > $outputdir/output.txt
rm $outputdir/drugcell.predict

#######################################################################################################


##### map drug names to SMILES and generate .json file ################################################

python $scriptdir/2_generate_output.py $outputdir/output.txt $outputdir/rlipp.txt

#######################################################################################################

date +"%T"
