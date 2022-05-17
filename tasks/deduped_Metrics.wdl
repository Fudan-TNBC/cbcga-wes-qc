task deduped_Metrics {

  File ref_dir
  String SENTIEON_INSTALL_DIR
  String SENTIEON_LICENSE
  String sample
  String fasta
  File deduped_bam
  File deduped_bam_index
  String docker
  String cluster_config
  String disk_size

  File? regions

  command <<<
    set -o pipefail
    set -e
    export SENTIEON_LICENSE=${SENTIEON_LICENSE}
    nt=$(nproc)

    if [ ${regions} ]; then
      INTERVAL="--interval ${regions}"
    else
      INTERVAL=""
    fi

    ${SENTIEON_INSTALL_DIR}/bin/sentieon driver -t $nt \
    -r ${ref_dir}/${fasta} $INTERVAL \
    -i ${deduped_bam} \
    --algo CoverageMetrics --omit_base_output ${sample}_deduped_coverage_metrics \
    --algo MeanQualityByCycle ${sample}_deduped_mq_metrics.txt \
    --algo QualDistribution ${sample}_deduped_qd_metrics.txt \
    --algo GCBias --summary ${sample}_deduped_gc_summary.txt ${sample}_deduped_gc_metrics.txt \
    --algo AlignmentStat ${sample}_deduped_aln_metrics.txt \
    --algo InsertSizeMetricAlgo ${sample}_deduped_is_metrics.txt \
    --algo QualityYield ${sample}_deduped_QualityYield.txt \
    --algo WgsMetricsAlgo ${sample}_deduped_WgsMetricsAlgo.txt
  >>>

  runtime {
    docker: docker
    cluster: cluster_config
    systemDisk: "cloud_ssd 40"
    dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/" 
  }

  output {
    File deduped_coverage_metrics_sample_summary = "${sample}_deduped_coverage_metrics.sample_summary"
    File deduped_coverage_metrics_sample_statistics = "${sample}_deduped_coverage_metrics.sample_statistics"
    File deduped_coverage_metrics_sample_interval_statistics = "${sample}_deduped_coverage_metrics.sample_interval_statistics"
    File deduped_coverage_metrics_sample_cumulative_coverage_proportions = "${sample}_deduped_coverage_metrics.sample_cumulative_coverage_proportions"
    File deduped_coverage_metrics_sample_cumulative_coverage_counts = "${sample}_deduped_coverage_metrics.sample_cumulative_coverage_counts"
    File deduped_mean_quality = "${sample}_deduped_mq_metrics.txt"
    File deduped_qd_metrics = "${sample}_deduped_qd_metrics.txt"
    File deduped_gc_summary = "${sample}_deduped_gc_summary.txt"
    File deduped_gc_metrics = "${sample}_deduped_gc_metrics.txt"
    File dedeuped_aln_metrics = "${sample}_deduped_aln_metrics.txt"
    File deduped_is_metrics = "${sample}_deduped_is_metrics.txt"
    File deduped_QualityYield = "${sample}_deduped_QualityYield.txt"
    File deduped_wgsmetrics = "${sample}_deduped_WgsMetricsAlgo.txt"
  }
}