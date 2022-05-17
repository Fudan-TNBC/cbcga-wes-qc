# README.md

> Author: Yaqing Liu
>
> Email: [yaqing.liu@outlook.com](mailto:yaqing.liu@outlook.com)
> 
> Last Updates: 23/04/2021

#### Requirements

- choppy
- Ali-Cloud
- Linux

#### Introduction
This APP is used to 
* convert a FASTQ file to an aligned BAM file.
* QC the data at the level of FASTQ and BAM, based on FastQC, FastQ Screen and Qualimap.

**Please carefully check the reference genome, bed file, etc.**
#### Usage
```
open-choppy-env

choppy install YaqingLiu/cbcga-wes-qc-latest

choppy samples YaqingLiu/cbcga-wes-qc-latest --no-default
# sample_id,fastq_1,fastq_2

choppy batch YaqingLiu/cbcga-wes-qc-latest samples.csv -p Project -l Label

# Query the status of all tasks in the project
choppy query -L Label | grep "status"
```