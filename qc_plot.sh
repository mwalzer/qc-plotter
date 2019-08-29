#!/usr/bin/env bash
tic_func ()  { QCExtractor -in $1 -qp QC:0000022 -out_csv ${1%.*}_QCTIC.csv; } 
ric_func ()  { QCExtractor -in $1 -qp QC:0000056 -out_csv ${1%.*}_QCRIC.csv; }
id_func ()   { QCExtractor -in $1 -qp QC:0000038 -out_csv ${1%.*}_QCID.csv; }
prec_func () { QCExtractor -in $1 -qp QC:0000044 -out_csv ${1%.*}_QCPREC.csv; }

case "$1" in
  "-dppm_time")
    id_func $2
    prec_func $2
    Rscript /scripts/ProduceQCFigures_dppm_time.R ${2%.*}_QCID.csv ${2%.*}_QCPREC.csv $(basename ${2%.*}_dppm_time.png)
    ;;
  "-dppm")
    id_func $2
    Rscript /scripts/ProduceQCFigures_dppm.R ${2%.*}_QCID.csv $(basename ${2%.*}_dppm.png)
    ;;
  "-topn")
    id_func $2
    prec_func $2
    Rscript /scripts/ProduceQCFigures_topn.R ${2%.*}_QCID.csv ${2%.*}_QCPREC.csv $(basename ${2%.*}_topn.png)
    ;;
  "-auctic")
    tic_func $2
    Rscript /scripts/ProduceQCFigures_auctic.R ${2%.*}_QCTIC.csv $(basename ${2%.*}_auctic.png)
    ;;
  "-charge_histogram")
    id_func $2
    prec_func $2
    Rscript /scripts/ProduceQCFigures_charge_histogram.R ${2%.*}_QCID.csv ${2%.*}_QCPREC.csv $(basename ${2%.*}_charge_histogram.png)
    ;;
  "-dppm_percentiles")
    id_func $2
    Rscript /scripts/ProduceQCFigures_dppm_percentiles.R ${2%.*}_QCID.csv $(basename ${2%.*}_dppm_percentiles.png)
    ;;
  "-esiinstability")
    ric_func $2
    Rscript /scripts/ProduceQCFigures_esiinstability.R ${2%.*}_QCRIC.csv $(basename ${2%.*}_esiinstability.png)
    ;;
  "-fracmass")
    id_func $2
    prec_func $2
    Rscript /scripts/ProduceQCFigures_fracmass.R ${2%.*}_QCID.csv ${2%.*}_QCPREC.csv /aux/theoretical_masses.tsv.gz $(basename ${2%.*}_fracmass.png)
    ;;
  "-gravy")
    id_func $2
    Rscript /scripts/ProduceQCFigures_gravy.R ${2%.*}_QCID.csv $(basename ${2%.*}_gravy.png)
    ;;
  "-idmap")
    id_func $2
    prec_func $2
    Rscript /scripts/ProduceQCFigures_idmap.R ${2%.*}_QCID.csv ${2%.*}_QCPREC.csv $(basename ${2%.*}_idmap.png)
    ;;
  "-id_oversampling")
    id_func $2
    Rscript /scripts/ProduceQCFigures_id_oversampling.R ${2%.*}_QCID.csv $(basename ${2%.*}_id_oversampling.png)
    ;;
  "-lengthdistro")
    id_func $2
    Rscript /scripts/ProduceQCFigures_lengthdistro.R ${2%.*}_QCID.csv $(basename ${2%.*}_lengthdistro.png)
    ;;
  "-ms1peakcount")
    ric_func $2
    Rscript /scripts/ProduceQCFigures_ms1peakcount.R ${2%.*}_QCRIC.csv $(basename ${2%.*}_ms1peakcount.png)
    ;;
  "-ms1sn")
    ric_func $2
    Rscript /scripts/ProduceQCFigures_ms1sn.R ${2%.*}_QCRIC.csv $(basename ${2%.*}_ms1sn.png)
    ;;
  "-ms2peakcount")
    prec_func $2
    Rscript /scripts/ProduceQCFigures_ms2peakcount.R ${2%.*}_QCPREC.csv $(basename ${2%.*}_ms2peakcount.png)
    ;;
  "-ms2sn")
    prec_func $2
    Rscript /scripts/ProduceQCFigures_ms2sn.R ${2%.*}_QCPREC.csv $(basename ${2%.*}_ms2sn.png)
    ;;
  "-repeatid")
    id_func $2
    prec_func $2
    Rscript /scripts/ProduceQCFigures_repeatid.R ${2%.*}_QCID.csv ${2%.*}_QCPREC.csv $(basename ${2%.*}_repeatid.png)
    ;;
  "-rt_events")
    id_func $2
    prec_func $2
    ric_func $2
    tic_func $2
    Rscript /scripts/ProduceQCFigures_rt_events.R ${2%.*}_QCID.csv ${2%.*}_QCPREC.csv ${2%.*}_QCTIC.csv ${2%.*}_QCRIC.csv $(basename ${2%.*}_rt_events.png)
    ;;
  "-sn")
    prec_func $2
    Rscript /scripts/ProduceQCFigures_sn.R ${2%.*}_QCPREC.csv $(basename ${2%.*}_sn.png)
    ;;
  "-tic")
    tic_func $2
    Rscript /scripts/ProduceQCFigures_tic.R ${2%.*}_QCTIC.csv $(basename ${2%.*}_tic.png)
    ;;
  "-ticric")
    tic_func $2
    ric_func $2
    Rscript /scripts/ProduceQCFigures_ticric.R ${2%.*}_QCTIC.csv ${2%.*}_QCRIC.csv $(basename ${2%.*}_ticric.png)
    ;;
  "-topn")
    tic_func $2
    prec_func $2
    Rscript /scripts/ProduceQCFigures_tic.R ${2%.*}_QCRIC.csv ${2%.*}_QCPREC.csv $(basename ${2%.*}_topn.png)
    ;;
  "-chargehistogramidfree")
    prec_func $2
    Rscript /scripts/ProduceQCFigures_idfree_charge_histogram.R ${2%.*}_QCPREC.csv $(basename ${2%.*}_charge_histogram_idfree.png)
    ;;
  # No feature based metric plots for now - you have to extract the qc_cv table and plot them with the respective feature rscript manually
  *)
    echo "No such plot available. (Did you spell it right?)"
    exit 1
    ;;
esac

