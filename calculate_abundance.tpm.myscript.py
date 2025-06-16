# coding: utf-8
# %load merge_all.py
# %load merge_all.py
# %load merge_all.py
def mergeAll(dirname,sampleid):
    import glob,os
    import pandas as pd
    import math
    import sys
    sys.path.append("/home/viro/xue.peng/script/utility_python/taxonomy/")
    from NCBITaxonomy import ncbiAccTax
    tc = ncbiAccTax()
    
    files=glob.glob("%s/btalign/%s/*.idxstatstat"%(dirname,sampleid))
    #print(files)
    new_file_list=[]
    fna="%s.merged.all.fna"%sampleid
    if os.path.exists(fna): os.remove(fna)
    for singlefile in files:
        idname = singlefile.split("/")[-1].strip(".bam.idxstatstat")
        print(idname)
        d = pd.read_csv(singlefile,sep="\t").iloc[0:-1,]
        d["Sample"]=[idname]*len(d)
        d["Abundance"]=d["#mapped_read-segments"]/d["sequence_length"]
        sumAbundance=sum(d["Abundance"])
        d["Relative_abundance"]=round((d["#mapped_read-segments"]*100)/(sumAbundance*d["sequence_length"]),4)
        #print(d)
        print(sumAbundance,)

        ## merge all df into one
        new_file_list.append(d)
        finaldf = pd.concat(new_file_list)
        finaldf.to_csv("%s/%s_merged.all.abundance.csv"%(dirname,sampleid))
        #print(finaldf)


import sys
mergeAll(".",sys.argv[1])
