task qualimap {
  
  String sample
  File bam
  File bai
  File covered_bed
  
  String docker
  String cluster_config
  String disk_size

  command <<<
    set -o pipefail
    set -e
    nt=$(nproc)
    awk 'BEGIN{OFS="\t"}{sub("\r","",$3);print $1,$2,$3,"",0,"."}' ${covered_bed} > new.bed
    /opt/qualimap/qualimap bamqc -bam ${bam} -gff new.bed -outformat PDF:HTML -nt $nt -outdir ${sample} --java-mem-size=32G
    cat ${sample}/genome_results.txt | grep duplication | awk -F "= |%" '{print "'"${sample}"'""\t"$2}' > ${sample}_qualimap_duplication.txt
    tar -zcvf ${sample}_qualimap.tar ${sample}
  >>>

  runtime {
    docker:docker
    cluster:cluster_config
    systemDisk:"cloud_ssd 40"
    dataDisk:"cloud_ssd " + disk_size + " /cromwell_root/"
  }
  
  output {
    File tar = "${sample}_qualimap.tar"
    File duplication = "${sample}_qualimap_duplication.txt"
  }
}