#!/usr/bin/bash
##input
name=$1
fq1=$2
fq2=$3
filter_length=${4:-10000} ## this is used for filter scaffolds length above this

##fastpOutput
qcDir="qc/$name"
fastpfq1="$qcDir/$name.1.fastq.gz"
fastpfq2="$qcDir/$name.2.fastq.gz"

##spadesOutput
assembleDir="assemble_spades/$name"
scaffolds="$assembleDir/scaffolds.fasta"
scaffolds_limit_length="$assembleDir/scaffolds.gt${filter_length}.fasta"


##software
fastp="/home/viro/xue.peng/software_home/fastp/fastp"
spades="/home/viro/xue.peng/software_home/SPAdes-3.15.2-Linux/bin/spades.py"
bowtie2=""

## function
echo $name
function mkdirs(){
    dir_name=$1
    clean=${2:-1}
    if [[ -e $dir_name && $clean == 1 ]];then
        rm -rf $dir_name  && mkdir -p $dir_name
    elif [[ -e $dir_name && $clean == 0 ]];then
        echo "dir exist and not clean!!"
    else
        mkdir -p $dir_name
    fi
}

###qc
mkdir -p $qcDir
$fastp -i $fq1 -I $fq2 -o $fastpfq1 -O $fastpfq2 -q 20 -h $qcDir/$name.fastp.html -j $qcDir/$name.fastp.json -z 4 -n 10 -l 60 -5 -3 -W 4 -M 20 -c -g -x

####assemble
#mkdirs $assembleDir
#$spades --meta -1 $fastpfq1 -2 $fastpfq2 -o $assembleDir
#
#
#### filter length
#seqkit seq -m $filter_length $scaffolds >$scaffolds_limit_length
#
#### checkv
#checkv_opt="./checkv/$name/proviruses_virus_all.level_2.fna"
#sh /home/viro/xue.peng/script/run_checkv.sh $name $scaffolds_limit_length "checkv"

### bt alignment
. /home/viro/xue.peng/script/bt2.sh
#btbuild $checkv_opt bt2Index/$name "--threads 3"
#btbuild $scaffolds_limit_length bt2Index/$name "--threads 3"
bamopt="./btalign/$name/$name.bam"
if [ -s $bamopt ];then
    echo "EXIST $name"
    python3.9 /home/viro/xue.peng/workplace_2023/twins_uk/src/calculate_abundance.tpm.myscript.py $name 
else
    echo "NO EXIST $name"
    btalign /home/viro/xue.peng/publicData/GPD/GPD_sequences_btindex/GPD_sequences_bt2 $fastpfq1 $fastpfq2 $name "--sensitive-local -q -p 30"
    samtoolsStat ./btalign/$name/$name.bam
    python3.9 /home/viro/xue.peng/workplace_2023/twins_uk/src/calculate_abundance.tpm.myscript.py $name
fi


