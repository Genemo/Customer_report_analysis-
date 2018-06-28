#Read Me#

#Author Yuan Liu <annlyuan@genemo.com>

#By running this program, we can use TPM.txt which is generated by .fastq 
#from each sample, to compare with the cancer-related gene set.

#1. project_path is the folder will save the output files
#2. sample_path is the folder of TPM.txt file for each sample
#3. reference_path is the cancer-related gene sets of 17 types of cancer

#INPUT: TPM.txt from sample
#       *.xml frem cancer-related gene set

#OUTPUT: a folder which is name after corresponding sample, save the data we used for calculating.
#        a .txt file which contains the final results of overlapping, each group have 3 columns,
#        1 for # of cancer-related genes, 2 for # of sample genes which meet our threshold value，
#        3 for # of the overlapping genes of 1&2 
#       （the # of group could change with how many thresholds you want to check, controllsed by 
#         variate TPM_threshould）


project_path=/Users/annlyuan2018/Downloads/test
sample_path=/Users/annlyuan2018/Downloads/exp_sample
reference_path=/Users/annlyuan2018/Downloads/cancer_reference
TPM_threshould=20

for j in $(cd $sample_path;ls *.txt); do

	Name=$(basename $sample_path/$j .txt)
	 
	 mkdir $project_path/$Name
	 
  
   for i in $(cd $reference_path;ls *.xml); do

   	 Cancer=$(basename $reference_path/$i .xml)

     mkdir $project_path/$Name/$Cancer

     for n in $(seq 0 $TPM_threshould); do

     #awk '$2!='0\n' {print $1}' $sample_path/$j> $project_path/$Name/$Cancer/exp.txt
     #awk '$2>='$n' {print $1}' $sample_path/$j> $project_path/$Name/$Cancer/exp.txt
     awk '$2>'$n' {print $1}' $sample_path/$j> $project_path/$Name/$Cancer/exp.txt

     grep "<identifier" $reference_path/$i | awk '{print $2}' > $project_path/$Name/$Cancer/$Cancer.txt
     sed -i '' 's/^.\{4\}//g' $project_path/$Name/$Cancer/$Cancer.txt
     sed -i '' 's/.\{1\}$//g' $project_path/$Name/$Cancer/$Cancer.txt

     grep -F -f $project_path/$Name/$Cancer/$Cancer.txt $project_path/$Name/$Cancer/exp.txt > $project_path/$Name/$Cancer/same_$Cancer.txt
     wc -l $project_path/$Name/$Cancer/$Cancer.txt $project_path/$Name/$Cancer/exp.txt $project_path/$Name/$Cancer/same_$Cancer.txt > $project_path/$Name/$Cancer/results_$Cancer.txt

     awk '{print $1}' $project_path/$Name/$Cancer/results_$Cancer.txt | xargs |awk -v t=$n '{print t,$1,$2,$3}'>> $project_path/$Name/$Cancer/total_$Cancer.txt

     done
     
     awk -v t=$Cancer '{print}BEGIN{print t}' $project_path/$Name/$Cancer/total_$Cancer.txt >>$project_path/total_$Name.txt  
     
   done
     
done






