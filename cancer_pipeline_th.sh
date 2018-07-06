#Read Me#

#Author Yuan Liu <annlyuan@genemo.com>

#By running this program, we can use TPM.txt which is generated by .fastq 
#from each sample, to compare with the cancer-related gene set.

#1. project_path is the folder will save the output files
#2. sample_path is the folder of TPM.txt file for each sample
#3. reference_path is the cancer-related gene sets of 17 types of cancer

#INPUT: TPM.txt from sample
#       *.xml frem cancer-related gene set

#OUTPUT: a folder which is Nam after corresponding sample, save the data we used for calculating.
#        a .txt file which contains the final results of overlapping, each group have 3 columns,
#        1 for # of cancer-related genes, 2 for # of sample genes which meet our threshold value，
#        3 for # of the overlapping genes of 1&2 
#       （the # of group could change with how many thresholds you want to check, controllsed by 
#         variate TPM_threshould）


project_path=/Users/annlyuan2018/Downloads/test
sample_path=/Users/annlyuan2018/Downloads/exp_sample
reference_path=/Users/annlyuan2018/Downloads/cancer_reference
code_path=/Users/annlyuan2018/Downloads/R_code

#sample_num=$(ls $sample_path/*.counts|wc -l)
TPM_threshould=20


for j in $(cd $sample_path;ls *.counts); do

	Nam=$(basename $sample_path/$j .counts)
	 
	 mkdir $project_path/$Nam

     awk '{print $1,$6,$7}' $sample_path/$j|tail -n +3 > $project_path/$Nam/union.txt


     Rscript $code_path/counts_to_TPM0.R $project_path/$Nam/union.txt $project_path/$Nam/unionTPM.txt


	 #touch $result_path/$Nam/total_$Nam.txt
  
   for i in $(cd $reference_path;ls *.xml); do

   	 Cancer=$(basename $reference_path/$i .xml)

     mkdir $project_path/$Nam/$Cancer

     for n in $(seq 0 $TPM_threshould); do

     #awk '$2!='0\n' {print $1}' $sample_path/$j> $project_path/$Nam/$Cancer/exp.txt
     awk '$2>'$n' {print $1}' $project_path/$Nam/unionTPM.txt> $project_path/$Nam/$Cancer/exp.txt

     grep "<identifier" $reference_path/$i | awk '{print $2}' > $project_path/$Nam/$Cancer/$Cancer.txt
     sed -i '' 's/^.\{4\}//g' $project_path/$Nam/$Cancer/$Cancer.txt
     sed -i '' 's/.\{1\}$//g' $project_path/$Nam/$Cancer/$Cancer.txt

     grep -F -f $project_path/$Nam/$Cancer/$Cancer.txt $project_path/$Nam/$Cancer/exp.txt > $project_path/$Nam/$Cancer/same_$Cancer.txt
     wc -l $project_path/$Nam/$Cancer/$Cancer.txt $project_path/$Nam/$Cancer/exp.txt $project_path/$Nam/$Cancer/same_$Cancer.txt > $project_path/$Nam/$Cancer/results_$Cancer.txt
     

     awk '{print $1}' $project_path/$Nam/$Cancer/results_$Cancer.txt | xargs |awk -v t=$n '{print t,$1,$2,$3}'>> $project_path/$Nam/$Cancer/total_$Cancer.txt

     done
     #sed -i '' 's/^/$(echo $Cancer)\n/' $project_path/total_$Nam.txt
     awk -v t=$Cancer '{print}BEGIN{print t}' $project_path/$Nam/$Cancer/total_$Cancer.txt >>$project_path/total_$Nam.txt  
     #awk 'BEGIN{a=$Cancer}{printf "%s\t",a}for (m=1;m<=NF;M++){Printf($m);Print("\t")}print("%s","\n")}'>> $project_path/total_$Nam.txt
   
   done
     #awk -v t=$Cancer '{print}BEGIN{print t}' $project_path/$Nam/$Cancer/total_$Cancer.txt >>$project_path/total_$Nam.txt  
     #awk -v r=$(seq 1 $(ls $reference_path/*.xml|wc -l)) '{print r}' $project_path/total_$Nam.txt>> $project_path/total_$Nam.txt

done
