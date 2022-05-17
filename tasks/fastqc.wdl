task fastqc {
  
  String sample
  File read1
  File read2
  
  String docker
  String cluster_config
  String disk_size

  command <<<
    set -o pipefail
    set -e
    nt=$(nproc)
    ln -s ${read1} ${sample}_R1.fastq.gz
    ln -s ${read2} ${sample}_R2.fastq.gz
    fastqc -t $nt -o ./ ${sample}_R1.fastq.gz
    fastqc -t $nt -o ./ ${sample}_R2.fastq.gz
  >>>

  runtime {
    docker:docker
    cluster: cluster_config
    systemDisk: "cloud_ssd 40"
    dataDisk: "cloud_ssd " + disk_size + " /cromwell_root/"
  }
  output {
    File read1_html="${sample}_R1_fastqc.html"
    File read1_zip="${sample}_R1_fastqc.zip"
    File read2_html="${sample}_R2_fastqc.html"
    File read2_zip="${sample}_R2_fastqc.zip"
  }
}