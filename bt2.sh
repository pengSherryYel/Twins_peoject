#!/usr/bin/bash

source /project/genomics/xuePeng/software/miniconda/miniconda/etc/profile.d/conda.sh
conda activate bowtie2

echo -ne "have following function:\n"\
     "samtoolsStat\tflagstat&&isxstat&&coverage\tsamtoolsStat *.bam\n"\
     "btbuild\tbuild index\tbtbuild <reference seq> [indexPrefix] [otherPara]\n"\
     "btalign\tbowtie align\tbtalign <ref> <r1> <r2> [sampleName(default:tmpbtalign)] [otherPara] [dirname]\n"


function btbuild(){
    local refFile=$1
    local btrefPrefix=${2:-bt2Index}
    local otherPara=${3:-"--threads 3"}

    local parentDir=`dirname $btrefPrefix`
    if [ ! -e $parentDir ];then mkdir -p $parentDir;fi
    local fullpathParentDir=`realpath $btrefPrefix`
    local identifier=`basename $btrefPrefix`

    if [ -z $refFile ];then
        echo "Please provide reference file for index!"
        echo "Usage: btbuild <reference seq> [indexPrefix] [otherPara]"
    else
       local testFileType=`file $refFile|grep gzip`
       if [ -n "$testFileType" ];then
           echo "file is gzipped,zcat this file!"
           echo "run command 'zcat $refFile > ./tmp.seq && bowtie2-build ./tmp.seq $btrefPrefix'"
           zcat $refFile > ./tmp.seq
           bowtie2-build $otherPara ./tmp.seq $btrefPrefix
           rm -rf ./tmp.seq
       else
           echo "run command 'bowtie2-build $refFile $btrefPrefix'"
           bowtie2-build $otherPara $refFile $btrefPrefix
       echo -e "$identifier\t$fullpathParentDir" >$parentDir.$identifier.btbuild.index
       fi
    fi
}

function btalign(){
    local ref=$1
    local seq1=$2
    local seq2=$3
    local name=${4:-"tmpbtalign"}
    local btOtherPara=${5:-"-q -p 10 --fast-local"}
    ## where to store the results, all the results will be in outputDir/Sampleid
    local outputDir=${6:-"btalign"}


    if [[ -z $ref || -z $seq1 || -z $seq2 ]];then
        echo "Please provide reference file and PE read file for alignment"
        echo "Usage: btalign <ref> <r1> <r2> [sampleName(default:tmpbtalign)] [otherPara]"
        return 0
    fi

    local wd="$outputDir/$name"
    mkdir -p $wd
    local bamOpt="$wd/$name.bam"
    local sortbamOpt="$wd/$name.bam.sort"
    local bamStatOpt="$wd/$name.bam.stat"

    echo "run command 'bowtie2 -x $ref -1 $seq1 -2 $seq2 $btOtherPara| samtools view -bS - >$bamOpt'"
    bowtie2 -x $ref -1 $seq1 -2 $seq2 $btOtherPara| samtools view -bS - >$bamOpt
    #samtools sort -T tmp/$name -o $sortbamOpt $bamOpt
    #samtools index $sortbamOpt
    #samtools idxstats $sortbamOpt >$bamStatOpt

}

function samtoolsStat(){
    echo "Usage: samtoolsStat *.bam"
    local bamfile=$1
    local thread=${2:-10}
    if [ -z $bamfile ];then
        echo "Please provide bamfile,this function include sort,index,flagstats command."
        echo "Usage: samtoolsStat <*.bam>"
    else

        #local sortbamOpt="$bamfile.sort"
        local sortbamOpt=`echo $bamfile|sed 's/.bam$/.sort.bam/'`
        local bamStatOpt="$bamfile.idxstatstat"
        local bamflagStat="$bamfile.flagstat"
        local bamcoverage="$bamfile.coverage"
        local bamdepth="$bamfile.depth"
        #bowtie2 -x $ref -1 $seq1 -2 $seq2 --fast-local -p 10| samtools view -bS - >$bamOpt
        samtools sort -@ $thread -o $sortbamOpt $bamfile
        samtools index $sortbamOpt
        echo -ne "reference_sequence_name\tsequence_length\t#mapped_read-segments\t#unmapped_read-segments\n" >$bamStatOpt
        samtools idxstats $sortbamOpt >>$bamStatOpt
        samtools flagstat $sortbamOpt >$bamflagStat
        samtools coverage $sortbamOpt >$bamcoverage
        samtools depth -@ $thread $sortbamOpt > $bamdepth
    fi
}

##unfinish
#function extractReadsFromBam(){
#    samtools fastq -f 12 -1 sample.1.fq.gz -2 sample.2.fq.gz bam
#}

