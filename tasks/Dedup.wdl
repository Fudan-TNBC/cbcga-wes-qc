task Dedup {

  String SENTIEON_INSTALL_DIR
  String SENTIEON_LICENSE
  String sample
  File sorted_bam
  File sorted_bam_index
  
  String docker
  String cluster_config
  String disk_size

  command <<<
    set -o pipefail
    set -e
    export SENTIEON_LICENSE=${SENTIEON_LICENSE}
    nt=$(nproc)
    ${SENTIEON_INSTALL_DIR}/bin/sentieon driver -t $nt -i ${sorted_bam} --algo LocusCollector --fun score_info ${sample}_score.txt
    ${SENTIEON_INSTALL_DIR}/bin/sentieon driver -t $nt -i ${sorted_bam} --algo Dedup --rmdup --score_info ${sample}_score.txt --metrics ${sample}_dedup_metrics.txt ${sample}.sorted.deduped.bam
    sed -n '3p' ${sample}_dedup_metrics.txt | awk -F'\t' '{print "'"${sample}"'""\t"$9*100}' > ${sample}_picard_duplication.txt
    # ${sample}_marked_dup_metrics.txt can be recognized as the picard output
    sed '1i\#DuplicationMetrics' ${sample}_dedup_metrics.txt > ${sample}_marked_dup_metrics.txt
  >>>
  
  runtime {
    docker: docker
    cluster: cluster_config
    systemDisk: "cloud_ssd 40"
    dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
  }

  output {
    File score = "${sample}_score.txt"
    File dedup_metrics = "${sample}_marked_dup_metrics.txt"
    File duplication = "${sample}_picard_duplication.txt"
    File deduped_bam = "${sample}.sorted.deduped.bam"
    File deduped_bam_index = "${sample}.sorted.deduped.bam.bai"
  }
}