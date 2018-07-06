#Read Me#

#By running this program, we can use TPM.txt which is generated by .fastq 
#from each sample, to compare with the cancer-related gene set.

#1. project_path is the folder will save the output files
#2. sample_path is the folder of TPM.txt file for each sample
#3. reference_path is the cancer-related gene sets of 17 types of cancer

#INPUT: TPM.txt from sample
#       *.xml frem cancer-related gene set



project_path=/Users/annlyuan2018/Downloads/test
sample_path=/Users/annlyuan2018/Downloads/exp_sample
reference_path=/Users/annlyuan2018/Downloads/cancer_reference
code_path=/Users/annlyuan2018/Downloads/R_code

for j in $(cd $sample_path;ls *.txt); do

	Nam=$(basename $sample_path/$j .txt)
	 
	mkdir $project_path/$Nam
	 
	awk '{print $1,$6,$7}' $sample_path/$j|tail -n +3 > $project_path/$Nam/union.txt

        Rscript $code_path/counts_to_TPM0.R $project_path/$Nam/union.txt $project_path/$Nam/unionTPM.txt
  
   for i in $(cd $reference_path;ls *.xml); do

   	 Cancer=$(basename $reference_path/$i .xml)

         mkdir $project_path/$Nam/$Cancer

         awk '$2>10 {print $1}' $sample_path/$j> $project_path/$Nam/$Cancer/exp1.txt

         grep "<identifier" $reference_path/$i | awk '{print $2}' > $project_path/$Nam/$Cancer/$Cancer.txt
         sed -i '' 's/^.\{4\}//g' $project_path/$Nam/$Cancer/$Cancer.txt
         sed -i '' 's/.\{1\}$//g' $project_path/$Nam/$Cancer/$Cancer.txt

         grep -F -f $project_path/$Nam/$Cancer/$Cancer.txt $project_path/$Nam/$Cancer/exp.txt > $project_path/$Nam/$Cancer/same_$Cancer.txt
         wc -l $project_path/$Nam/$Cancer/$Cancer.txt $project_path/$Nam/$Cancer/exp.txt $project_path/$Nam/$Cancer/same_$Cancer.txt > $project_path/$Nam/$Cancer/results_$Cancer.txt
     
         awk '{print $1}' $project_path/$Nam/$Cancer/results_$Cancer.txt | xargs |awk -v t=$Cancer '{print t,$1,$2,$3}'>> $project_path/total_$Nam.txt

   done

     #awk -v r=$(seq 1 $(ls $reference_path/*.xml|wc -l)) '{print r}' $project_path/total_$Nam.txt>> $project_path/total_$Nam.txt

done






