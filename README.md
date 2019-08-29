# QC plotter for various metric plots

### usage
```
docker run -it -v </path/to/input.qcML>:</home/OpenMSuser/target.qcML>:ro -v /tmp/:/tmp/:rw -w /tmp/ mwalzer/qc_plotter:v0.1 qc_plot.sh -<metric> </home/OpenMSuser/target.qcML>
```
e.g.:
```
docker run -it -v /home/walzer/ms-tools/iPRG/qc/JD_06232014_sample1_A.qcML:/home/OpenMSuser/test.qcML:ro -v /tmp/:/tmp/:rw -w /tmp/ mwalzer/qc_plotter:v0.1 qc_plot.sh -fracmass /home/OpenMSuser/test.qcML

### currently available trough plotter script:
  * "-auctic"
  * "-charge_histogram"
  * "-dppm"
  * "-dppm_time"
  * "-dppm_percentiles"
  * "-esiinstability"
  * "-fracmass"
  * "-gravy"
  * "-idmap"
  * "-id_oversampling"
  * "-lengthdistro"
  * "-ms1peakcount"
  * "-ms1sn"
  * "-ms2peakcount"
  * "-ms2sn"
  * "-repeatid"
  * "-rt_events"
  * "-sn"
  * "-tic"
  * "-ticric"
  * "-topn"
  * "-chargehistogramidfree"
