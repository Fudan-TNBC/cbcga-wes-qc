import "./tasks/fastqc.wdl" as fastqc
import "./tasks/fastqscreen.wdl" as fastqscreen
import "./tasks/qualimap.wdl" as qualimap
import "./tasks/mapping.wdl" as mapping
import "./tasks/Metrics.wdl" as Metrics
import "./tasks/Dedup.wdl" as Dedup
import "./tasks/deduped_Metrics.wdl" as deduped_Metrics


workflow {{ project_name }} {
  String sample_id
  File fastq_1
  File fastq_2

  File screen_ref_dir
  File fastq_screen_conf
  File ref_dir
  String fasta
  File covered_bed

  String SENTIEON_INSTALL_DIR
  String SENTIEON_LICENSE
  String sentieon_docker
  String fastqc_docker
  String fastqscreen_docker
  String qualimap_docker
  String CPU8_GB32_cluster
  String CPU4_GB16_cluster
  String CPU2_GB8_cluster
  String disk_size

  call fastqc.fastqc as fastqc {
    input:
    sample=sample_id,
    read1=fastq_1,
    read2=fastq_2,
    docker=fastqc_docker,
    disk_size=disk_size,
    cluster_config=CPU8_GB32_cluster
  }

  call fastqscreen.fastq_screen as fastqscreen {
    input:
    sample=sample_id,
    read1=fastq_1,
    read2=fastq_2,
    screen_ref_dir=screen_ref_dir,
    fastq_screen_conf=fastq_screen_conf,
    docker=fastqscreen_docker,
    disk_size=disk_size,
    cluster_config=CPU2_GB8_cluster
  }

  call mapping.mapping as mapping {
    input: 
    group=sample_id,
    sample=sample_id,
    fastq_1=fastq_1,
    fastq_2=fastq_2,
    SENTIEON_INSTALL_DIR=SENTIEON_INSTALL_DIR,
    SENTIEON_LICENSE=SENTIEON_LICENSE,
    pl="ILLUMINAL",
    fasta=fasta,
    ref_dir=ref_dir,
    docker=sentieon_docker,
    disk_size=disk_size,
    cluster_config=CPU8_GB32_cluster
  }

  call Metrics.Metrics as Metrics {
    input:
    SENTIEON_INSTALL_DIR=SENTIEON_INSTALL_DIR,
    SENTIEON_LICENSE=SENTIEON_LICENSE,
    fasta=fasta,
    ref_dir=ref_dir,
    sorted_bam=mapping.sorted_bam,
    sorted_bam_index=mapping.sorted_bam_index,
    sample=sample_id,
    regions=covered_bed,
    docker=sentieon_docker,
    disk_size=disk_size,
    cluster_config=CPU2_GB8_cluster
  }

  call Dedup.Dedup as Dedup {
    input:
    SENTIEON_INSTALL_DIR=SENTIEON_INSTALL_DIR,
    SENTIEON_LICENSE=SENTIEON_LICENSE,
    sorted_bam=mapping.sorted_bam,
    sorted_bam_index=mapping.sorted_bam_index,
    sample=sample_id,
    docker=sentieon_docker,
    disk_size=disk_size,
    cluster_config=CPU8_GB32_cluster
  }

  call deduped_Metrics.deduped_Metrics as deduped_Metrics {
    input:
    SENTIEON_INSTALL_DIR=SENTIEON_INSTALL_DIR,
    SENTIEON_LICENSE=SENTIEON_LICENSE,
    fasta=fasta,
    ref_dir=ref_dir,
    deduped_bam=Dedup.deduped_bam,
    deduped_bam_index=Dedup.deduped_bam_index,
    sample=sample_id,
    regions=covered_bed,
    docker=sentieon_docker,
    disk_size=disk_size,
    cluster_config=CPU2_GB8_cluster
  }
  
  call qualimap.qualimap as qualimap {
    input:
    sample=sample_id,
    bam=Dedup.deduped_bam,
    bai=Dedup.deduped_bam_index,
    covered_bed=covered_bed,
    docker=qualimap_docker,
    disk_size=disk_size,
    cluster_config=CPU8_GB32_cluster
  }

  output {
    File fastqc_read1_html = fastqc.read1_html
    File fastqc_read1_zip = fastqc.read1_zip
    File fastqc_read2_html = fastqc.read2_html
    File fastqc_read2_zip = fastqc.read2_zip
    File fastqscreen_png1 = fastqscreen.png1
    File fastqscreen_txt1 = fastqscreen.txt1
    File fastqscreen_html1 = fastqscreen.html1
    File fastqscreen_png2 = fastqscreen.png2
    File fastqscreen_txt2 = fastqscreen.txt2
    File fastqscreen_html2 = fastqscreen.html2
    File qualimap_tar = qualimap.tar
    File qualimap_duplication = qualimap.duplication
    File Dedup_dedup_metrics = Dedup.dedup_metrics
    File Dedup_duplication = Dedup.duplication
    File deduped_bam = Dedup.deduped_bam
    File deduped_bam_index = Dedup.deduped_bam_index
    File Metrics_aln_metrics = Metrics.aln_metrics
    File Metrics_gc_metrics = Metrics.gc_metrics
    File Metrics_gc_summary = Metrics.gc_summary
    File Metrics_is_metrics = Metrics.is_metrics
  }
}