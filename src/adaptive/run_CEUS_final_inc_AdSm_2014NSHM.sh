#!/bin/bash
# script for running spatial smoothing for CEUS
# 
 
# CHECK INPUT PARAMETERS
#reqparams=7
reqparam1=6
reqparam2=7
#if [ $# -ne $reqparams ]; then
if [ $# -lt $reqparam1 ] || [ $# -gt $reqparam2 ]; then
  echo "USAGE: $0 [base directory] [adaptive-R neighbor number (e.g., 1/2/3/4/5)] [check parameters (y/n)] [catf] [Mmin] [starting year] ( [completeness file] )"
  echo "The check parameters option allows user inspection of smoothing parameters before smoothing is run."
  echo "Optional completeness file for spatially-variable completeness. If not included completeness is spatially uniforma at the Mmin/starting year input completeness level."
  exit
fi
based=$1
#rdist=$2
nnum=$2
ck_param=$3
catf=$4
mag_min=$5
start_yr=$6
# spatially-variable completeness
if [ $# -eq $reqparam2 ]; then
  compl_file=$7
  run_variableCompl=1
else
  compl_file="NONE"
  run_variableCompl=0
fi

# SMOOTHING
run_smoothing=1

#
mag_min_pr=`echo $mag_min | sed 's/\./p/'`
end_yr=2012
nmref=adN${nnum}_incr_Mmin${mag_min_pr}_${start_yr}_${end_yr}
paramf=param_${nmref}.in
paramf_format=new
summf=summ_smooth_params.txt
cat_gaps_f=lst_catalog_gaps.txt
#nmref=adRN${nnum}_cumul_Mmin${mag_min_pr}

# write the parameter file
if (( $run_smoothing )); then
echo "# source boundaries" > param_smoothing.txt
echo "Min_Lat=23.0 " >> param_smoothing.txt
echo "Max_Lat=53.0" >> param_smoothing.txt
echo "Min_Lon=-116.0" >> param_smoothing.txt
echo "Max_Lon=-60.0" >> param_smoothing.txt
echo "Inc_Lat=0.1" >> param_smoothing.txt
echo "Inc_Lon=0.1" >> param_smoothing.txt
echo "# completeness levels - no adjusting for these calculations" >> param_smoothing.txt
echo "N_Completeness_Levels=1" >> param_smoothing.txt
echo "Completeness_Level_yr_1=$start_yr" >> param_smoothing.txt
echo "Completeness_Level_M_1=$mag_min" >> param_smoothing.txt
echo "Variable_Completeness=$run_variableCompl" >> param_smoothing.txt
echo "Completeness_File=$compl_file" >> param_smoothing.txt
echo "Catalog_Gaps=1" >> param_smoothing.txt
echo "Catalog_Gaps_File=$cat_gaps_f" >> param_smoothing.txt
echo "# catalog " >> param_smoothing.txt
echo "Catalog_Name=$catf" >> param_smoothing.txt
echo "End_yr_Catalog=$end_yr" >> param_smoothing.txt
#echo "b_Value=0.9" >> param_smoothing.txt
echo "b_Value=1.0" >> param_smoothing.txt
echo "dMag_value=0.1" >> param_smoothing.txt
echo "Min_Magnitude=$mag_min" >> param_smoothing.txt
echo "# logicals " >> param_smoothing.txt
echo "logical_Effective_Num_Eqs=0" >> param_smoothing.txt
echo "logical_Cumulative_rates=0" >> param_smoothing.txt
echo "logical_Adjust_completeness=0" >> param_smoothing.txt
echo "logical_Apply_smoothing=1" >> param_smoothing.txt
echo "logical_Adaptive_smoothing=1" >> param_smoothing.txt
echo "logical_Avg_Neighbor=0" >> param_smoothing.txt
echo "# smoothing parameters" >> param_smoothing.txt
echo "Adaptive_Neighbor_Number=$nnum" >> param_smoothing.txt
echo "Sigma_Min=3.0" >> param_smoothing.txt
echo "Sigma_Max=200.0" >> param_smoothing.txt
#echo "Sigma_Fix=50.0" >> param_smoothing.txt
echo "Gauss_PowerLaw_Kernel=gauss" >> param_smoothing.txt
echo "#Gauss_PowerLaw_Kernel=powerLaw" >> param_smoothing.txt
#echo "Output_Name=agrd_adN${nnum}_c_Mmin${mag_min_pr}_${start_yr}_${end_yr}" >> param_smoothing.txt
echo "Output_Name=agrd_${nmref}" >> param_smoothing.txt
mv param_smoothing.txt $paramf
echo "Parameter file: $paramf"

# run agrid code 
# optional check of input parameters before running smoothing 
if [ $ck_param = "Y" ] || [ $ck_param = "y" ]; then 
  stop_code=1
  echo calc_agrid_seis_rates $paramf $paramf_format $summf $stop_code
  ./src/calc_agrid_seis_rates $paramf $paramf_format $summf $stop_code
  exit
fi

# run smoothing
logf=log_${nmref}.tmp
#echo "Running... calc_agrid_seis_rates_neff $paramf $paramf_format $summf '>&' $logf"
#calc_agrid_seis_rates_neff $paramf $paramf_format $summf >& $logf
echo "Running... calc_agrid_seis_rates $paramf $paramf_format $summf"
./src/calc_agrid_seis_rates $paramf $paramf_format $summf 

# save files
outd=dir_${nmref}
mkdir $outd
mv $summf agrd*.out param_*.in selected_eqs*.dat $outd
cp $catf $outd
echo "Saved files to $outd"
fi
# end of run_smoothing

