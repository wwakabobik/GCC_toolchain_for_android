#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    renew_regressions.sh
# Purpose: script actualizes status of active fails of compiler/devices
#
# Author:      Iliya Vereshchagin
#
# Created:     21.06.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

path_to_results=/users/$USER/MC_Daily/Make_Check_Adb_Results
bits=32
type_of_testing=0
MFLD_Image=MCG_eng
CTP_Image=MCG_eng
GN_Image=vanilla
N4_Image=AOSP

tmp_dir=./temp_dir

mkdir $tmp_dir
touch $tmp_dir/gcc.log
touch $tmp_dir/g++.log

#Medfield
sqlite3 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions_Medfield.db "UPDATE BadTests SET activefail=0;"
./get_excel_summary.sh $path_to_results/x86/Medfield/Android_4.4.3_Patched $path_to_results/x86/Medfield/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_Medfield  0  ndk_regressions_Medfield.db  4.4.3  $bits $type_of_testing $MFLD_Image
./check_stable_regression.sh cleanup ndk443_Medfield ndk_regressions_Medfield.db 4.4.3 $bits $type_of_testing $MFLD_Image #1>stable_regression_Medfield_443.log 2>>stable_regression_Medfield_443.log
./get_excel_summary.sh $path_to_results/x86/Medfield/Android_4.6.2_Patched $path_to_results/x86/Medfield/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_Medfield  0  ndk_regressions_Medfield.db  4.6.2  $bits $type_of_testing $MFLD_Image
./check_stable_regression.sh cleanup ndk462_Medfield ndk_regressions_Medfield.db 4.6.2 $bits $type_of_testing $MFLD_Image #1>stable_regression_Medfield_462.log 2>>stable_regression_Medfield_462.log
./get_excel_summary.sh $path_to_results/x86/Medfield/Android_4.7.2_Patched $path_to_results/x86/Medfield/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_Medfield  0  ndk_regressions_Medfield.db  4.7.2  $bits $type_of_testing $MFLD_Image
./check_stable_regression.sh cleanup ndk472_Medfield ndk_regressions_Medfield.db 4.7.2 $bits $type_of_testing $MFLD_Image #1>stable_regression_Medfield_472.log 2>>stable_regression_Medfield_472.log
./get_excel_summary.sh $path_to_results/x86/Medfield/Android_4.8.0_Patched $path_to_results/x86/Medfield/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_Medfield  0  ndk_regressions_Medfield.db  4.8.0  $bits $type_of_testing $MFLD_Image
./check_stable_regression.sh cleanup ndk480_Medfield ndk_regressions_Medfield.db 4.8.0 $bits $type_of_testing $MFLD_Image #1>stable_regression_Medfield_480.log 2>>stable_regression_Medfield_480.log
./get_excel_summary.sh $path_to_results/x86/Medfield/Android_4.9.0_Patched $path_to_results/x86/Medfield/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_Medfield  0  ndk_regressions_Medfield.db  4.9.0  $bits $type_of_testing $MFLD_Image
./check_stable_regression.sh cleanup ndk490_Medfield ndk_regressions_Medfield.db 4.9.0 $bits $type_of_testing $MFLD_Image #1>stable_regression_Medfield_490.log 2>>stable_regression_Medfield_490.log
#CTP
sqlite3 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions_CloverTrail.db "UPDATE BadTests SET activefail=0;"
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.4.3_Patched $path_to_results/x86/CloverTrail/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_CloverTrail  0  ndk_regressions_CloverTrail.db  4.4.3  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk443_CloverTrail ndk_regressions_CloverTrail.db 4.4.3 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_443.log 2>>stable_regression_CloverTrail_443.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.6.2_Patched $path_to_results/x86/CloverTrail/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_CloverTrail  0  ndk_regressions_CloverTrail.db  4.6.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk462_CloverTrail ndk_regressions_CloverTrail.db 4.6.2 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_462.log 2>>stable_regression_CloverTrail_462.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.7.2_Patched $path_to_results/x86/CloverTrail/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_CloverTrail  0  ndk_regressions_CloverTrail.db  4.7.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk472_CloverTrail ndk_regressions_CloverTrail.db 4.7.2 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_472.log 2>>stable_regression_CloverTrail_472.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.8.0_Patched $path_to_results/x86/CloverTrail/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_CloverTrail  0  ndk_regressions_CloverTrail.db  4.8.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk480_CloverTrail ndk_regressions_CloverTrail.db 4.8.0 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_480.log 2>>stable_regression_CloverTrail_480.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.9.0_Patched $path_to_results/x86/CloverTrail/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_CloverTrail  0  ndk_regressions_CloverTrail.db  4.9.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk490_CloverTrail ndk_regressions_CloverTrail.db 4.9.0 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_490.log 2>>stable_regression_CloverTrail_490.log
#Merrifield
sqlite3 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions_Merrifield.db "UPDATE BadTests SET activefail=0;"
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.4.3_Patched $path_to_results/x86/Merrifield/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_Merrifield  0  ndk_regressions_Merrifield.db  4.4.3  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk443_Merrifield ndk_regressions_Merrifield.db 4.4.3 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_443.log 2>>stable_regression_Merrifield_443.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.6.2_Patched $path_to_results/x86/Merrifield/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_Merrifield  0  ndk_regressions_Merrifield.db  4.6.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk462_Merrifield ndk_regressions_Merrifield.db 4.6.2 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_462.log 2>>stable_regression_Merrifield_462.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.7.2_Patched $path_to_results/x86/Merrifield/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_Merrifield  0  ndk_regressions_Merrifield.db  4.7.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk472_Merrifield ndk_regressions_Merrifield.db 4.7.2 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_472.log 2>>stable_regression_Merrifield_472.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.8.0_Patched $path_to_results/x86/Merrifield/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_Merrifield  0  ndk_regressions_Merrifield.db  4.8.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk480_Merrifield ndk_regressions_Merrifield.db 4.8.0 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_480.log 2>>stable_regression_Merrifield_480.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.9.0_Patched $path_to_results/x86/Merrifield/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_Merrifield  0  ndk_regressions_Merrifield.db  4.9.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk490_Merrifield ndk_regressions_Merrifield.db 4.9.0 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_490.log 2>>stable_regression_Merrifield_490.log
#GalaxyNexus
sqlite3 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions_GalaxyNexus.db "UPDATE BadTests SET activefail=0;"
./get_excel_summary.sh $path_to_results/arm/GalaxyNexus/Android_4.4.3_Patched $path_to_results/arm/GalaxyNexus/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_GalaxyNexus  0  ndk_regressions_GalaxyNexus.db  4.4.3  $bits $type_of_testing $GN_Image
./check_stable_regression.sh cleanup ndk443_GalaxyNexus ndk_regressions_GalaxyNexus.db 4.4.3 $bits $type_of_testing $GN_Image #1>stable_regression_GalaxyNexus_443.log 2>>stable_regression_GalaxyNexus_443.log
./get_excel_summary.sh $path_to_results/arm/GalaxyNexus/Android_4.6.2_Patched $path_to_results/arm/GalaxyNexus/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_GalaxyNexus  0  ndk_regressions_GalaxyNexus.db  4.6.2  $bits $type_of_testing $GN_Image
./check_stable_regression.sh cleanup ndk462_GalaxyNexus ndk_regressions_GalaxyNexus.db 4.6.2 $bits $type_of_testing $GN_Image #1>stable_regression_GalaxyNexus_462.log 2>>stable_regression_GalaxyNexus_462.log
./get_excel_summary.sh $path_to_results/arm/GalaxyNexus/Android_4.7.2_Patched $path_to_results/arm/GalaxyNexus/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_GalaxyNexus  0  ndk_regressions_GalaxyNexus.db  4.7.2  $bits $type_of_testing $GN_Image
./check_stable_regression.sh cleanup ndk472_GalaxyNexus ndk_regressions_GalaxyNexus.db 4.7.2 $bits $type_of_testing $GN_Image #1>stable_regression_GalaxyNexus_472.log 2>>stable_regression_GalaxyNexus_472.log
./get_excel_summary.sh $path_to_results/arm/GalaxyNexus/Android_4.8.0_Patched $path_to_results/arm/GalaxyNexus/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_GalaxyNexus  0  ndk_regressions_GalaxyNexus.db  4.8.0  $bits $type_of_testing $GN_Image
./check_stable_regression.sh cleanup ndk480_GalaxyNexus ndk_regressions_GalaxyNexus.db 4.8.0 $bits $type_of_testing $GN_Image #1>stable_regression_GalaxyNexus_480.log 2>>stable_regression_GalaxyNexus_480.log
./get_excel_summary.sh $path_to_results/arm/GalaxyNexus/Android_4.9.0_Patched $path_to_results/arm/GalaxyNexus/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_GalaxyNexus  0  ndk_regressions_GalaxyNexus.db  4.9.0  $bits $type_of_testing $GN_Image
./check_stable_regression.sh cleanup ndk490_GalaxyNexus ndk_regressions_GalaxyNexus.db 4.9.0 $bits $type_of_testing $GN_Image #1>stable_regression_GalaxyNexus_490.log 2>>stable_regression_GalaxyNexus_490.log
#Nexus4
sqlite3 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions_Nexus4.db "UPDATE BadTests SET activefail=0;"
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.4.3_Patched $path_to_results/arm/Nexus4/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_Nexus4  0  ndk_regressions_Nexus4.db  4.4.3  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk443_Nexus4 ndk_regressions_Nexus4.db 4.4.3 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_443.log 2>>stable_regression_Nexus4_443.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.6.2_Patched $path_to_results/arm/Nexus4/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_Nexus4  0  ndk_regressions_Nexus4.db  4.6.2  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk462_Nexus4 ndk_regressions_Nexus4.db 4.6.2 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_462.log 2>>stable_regression_Nexus4_462.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.7.2_Patched $path_to_results/arm/Nexus4/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_Nexus4  0  ndk_regressions_Nexus4.db  4.7.2  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk480_Nexus4 ndk_regressions_Nexus4.db 4.7.2 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_472.log 2>>stable_regression_Nexus4_472.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.8.0_Patched $path_to_results/arm/Nexus4/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_Nexus4  0  ndk_regressions_Nexus4.db  4.8.0  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk480_Nexus4 ndk_regressions_GalaxyNexus.db 4.8.0 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_480.log 2>>stable_regression_Nexus4_480.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.9.0_Patched $path_to_results/arm/Nexus4/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_Nexus4  0  ndk_regressions_Nexus4.db  4.9.0  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk490_Nexus4 ndk_regressions_Nexus4.db 4.9.0 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_490.log 2>>stable_regression_Nexus4_490.log

#UPDATE Image Stability Data

type_of_testing=1

#CTP
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.4.3_Patched $path_to_results/x86/CloverTrail/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_CloverTrail  0  ndk_regressions_CloverTrail.db  4.4.3  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk443_CloverTrail ndk_regressions_CloverTrail.db 4.4.3 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_443_image.log 2>>stable_regression_CloverTrail_443_image.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.6.2_Patched $path_to_results/x86/CloverTrail/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_CloverTrail  0  ndk_regressions_CloverTrail.db  4.6.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk462_CloverTrail ndk_regressions_CloverTrail.db 4.6.2 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_462_image.log 2>>stable_regression_CloverTrail_462_image.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.7.2_Patched $path_to_results/x86/CloverTrail/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_CloverTrail  0  ndk_regressions_CloverTrail.db  4.7.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk472_CloverTrail ndk_regressions_CloverTrail.db 4.7.2 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_472_image.log 2>>stable_regression_CloverTrail_472_image.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.8.0_Patched $path_to_results/x86/CloverTrail/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_CloverTrail  0  ndk_regressions_CloverTrail.db  4.8.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk480_CloverTrail ndk_regressions_CloverTrail.db 4.8.0 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_480_image.log 2>>stable_regression_CloverTrail_480_image.log
./get_excel_summary.sh $path_to_results/x86/CloverTrail/Android_4.9.0_Patched $path_to_results/x86/CloverTrail/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_CloverTrail  0  ndk_regressions_CloverTrail.db  4.9.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk490_CloverTrail ndk_regressions_CloverTrail.db 4.9.0 $bits $type_of_testing $CTP_Image #1>stable_regression_CloverTrail_490_image.log 2>>stable_regression_CloverTrail_490_image.log
#Nexus4
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.4.3_Patched $path_to_results/arm/Nexus4/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_Nexus4  0  ndk_regressions_Nexus4.db  4.4.3  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk443_Nexus4 ndk_regressions_Nexus4.db 4.4.3 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_443_image.log 2>>stable_regression_Nexus4_443_image.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.6.2_Patched $path_to_results/arm/Nexus4/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_Nexus4  0  ndk_regressions_Nexus4.db  4.6.2  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk462_Nexus4 ndk_regressions_Nexus4.db 4.6.2 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_462_image.log 2>>stable_regression_Nexus4_462_image.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.7.2_Patched $path_to_results/arm/Nexus4/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_Nexus4  0  ndk_regressions_Nexus4.db  4.7.2  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk480_Nexus4 ndk_regressions_Nexus4.db 4.7.2 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_472_image.log 2>>stable_regression_Nexus4_472_image.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.8.0_Patched $path_to_results/arm/Nexus4/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_Nexus4  0  ndk_regressions_Nexus4.db  4.8.0  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk480_Nexus4 ndk_regressions_Nexus4.db 4.8.0 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_480_image.log 2>>stable_regression_Nexus4_480_image.log
./get_excel_summary.sh $path_to_results/arm/Nexus4/Android_4.9.0_Patched $path_to_results/arm/Nexus4/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_Nexus4  0  ndk_regressions_Nexus4.db  4.9.0  $bits $type_of_testing $N4_Image
./check_stable_regression.sh cleanup ndk490_Nexus4 ndk_regressions_Nexus4.db 4.9.0 $bits $type_of_testing $N4_Image #1>stable_regression_Nexus4_490_image.log 2>>stable_regression_Nexus4_490_image.log
#Merrifield
sqlite3 /nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions_Merrifield.db "UPDATE BadTests SET activefail=0;"
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.4.3_Patched $path_to_results/x86/Merrifield/Android_4.4.3_Patched   $tmp_dir    cleanup   ndk443_Merrifield  0  ndk_regressions_Merrifield.db  4.4.3  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk443_Merrifield ndk_regressions_Merrifield.db 4.4.3 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_443.log 2>>stable_regression_Merrifield_443.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.6.2_Patched $path_to_results/x86/Merrifield/Android_4.6.2_Patched   $tmp_dir    cleanup   ndk462_Merrifield  0  ndk_regressions_Merrifield.db  4.6.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk462_Merrifield ndk_regressions_Merrifield.db 4.6.2 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_462.log 2>>stable_regression_Merrifield_462.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.7.2_Patched $path_to_results/x86/Merrifield/Android_4.7.2_Patched   $tmp_dir    cleanup   ndk472_Merrifield  0  ndk_regressions_Merrifield.db  4.7.2  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk472_Merrifield ndk_regressions_Merrifield.db 4.7.2 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_472.log 2>>stable_regression_Merrifield_472.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.8.0_Patched $path_to_results/x86/Merrifield/Android_4.8.0_Patched   $tmp_dir    cleanup   ndk480_Merrifield  0  ndk_regressions_Merrifield.db  4.8.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk480_Merrifield ndk_regressions_Merrifield.db 4.8.0 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_480.log 2>>stable_regression_Merrifield_480.log
./get_excel_summary.sh $path_to_results/x86/Merrifield/Android_4.9.0_Patched $path_to_results/x86/Merrifield/Android_4.9.0_Patched   $tmp_dir    cleanup   ndk490_Merrifield  0  ndk_regressions_Merrifield.db  4.9.0  $bits $type_of_testing $CTP_Image
./check_stable_regression.sh cleanup ndk490_Merrifield ndk_regressions_Merrifield.db 4.9.0 $bits $type_of_testing $CTP_Image #1>stable_regression_Merrifield_490.log 2>>stable_regression_Merrifield_490.log

rm -rf $tmp_dir