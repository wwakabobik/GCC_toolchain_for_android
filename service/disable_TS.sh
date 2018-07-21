#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    disable_TS.sh
# Purpose: this script renames common gcc testcases to disable them for make 
#          check. Comment some lines to run needed testcases.
#
# Author:      Iliya Vereshchagin
#
# Created:     25.09.2012
# Copyright:   Contributed by Intel Corporation (c) 2012
# Licence:     GPL
#-------------------------------------------------------------------------------

testsuite_path="gcc/testsuite"

if [ -z $1 ]; then
    gcc_release="gcc_4_6_2_release"
else
    gcc_release=$1
fi

if [ -z $2 ]; then
    prefix_dir=$PWD
else
    prefix_dir=$2
fi

TS_dir=$prefix_dir/$gcc_release/$testsuite_path

mv $TS_dir/gcc.c-torture/compile/compile.exp $TS_dir/gcc.c-torture/compile/compileEXP
mv $TS_dir/gcc.c-torture/execute/builtins/builtins.exp $TS_dir/gcc.c-torture/execute/builtins/builtinsEXP
mv $TS_dir/gcc.c-torture/execute/execute.exp $TS_dir/gcc.c-torture/execute/executeEXP
mv $TS_dir/gcc.c-torture/execute/ieee/ieee.exp $TS_dir/gcc.c-torture/execute/ieee/ieeeEXP
mv $TS_dir/gcc.c-torture/unsorted/unsorted.exp $TS_dir/gcc.c-torture/unsorted/unsortedEXP
mv $TS_dir/gcc.dg/autopar/autopar.exp $TS_dir/gcc.dg/autopar/autoparEXP
mv $TS_dir/gcc.dg/charset/charset.exp $TS_dir/gcc.dg/charset/charsetEXP
mv $TS_dir/gcc.dg/compat/compat.exp $TS_dir/gcc.dg/compat/compatEXP
mv $TS_dir/gcc.dg/compat/struct-layout-1.exp $TS_dir/gcc.dg/compat/struct-layout-1EXP
mv $TS_dir/gcc.dg/cpp/cpp.exp $TS_dir/gcc.dg/cpp/cppEXP
mv $TS_dir/gcc.dg/debug/debug.exp $TS_dir/gcc.dg/debug/debugEXP
mv $TS_dir/gcc.dg/dfp/dfp.exp $TS_dir/gcc.dg/dfp/dfpEXP
mv $TS_dir/gcc.dg/dg.exp $TS_dir/gcc.dg/dgEXP
mv $TS_dir/gcc.dg/debug/dwarf2/dwarf2.exp $TS_dir/gcc.dg/debug/dwarf2/dwarf2EXP
mv $TS_dir/gcc.dg/graphite/graphite.exp $TS_dir/gcc.dg/graphite/graphiteEXP
mv $TS_dir/gcc.dg/torture/tls/tls.exp $TS_dir/gcc.dg/torture/tls/tlsEXP
mv $TS_dir/gcc.target/i386/i386.exp $TS_dir/gcc.target/i386/i386EXP
mv $TS_dir/gcc.dg/guality/guality.exp $TS_dir/gcc.dg/guality/gualityEXP
mv $TS_dir/gcc.dg/lto/lto.exp $TS_dir/gcc.dg/lto/ltoEXP
mv $TS_dir/gcc.dg/torture/dg-torture.exp $TS_dir/gcc.dg/torture/dg-tortureEXP
mv $TS_dir/gcc.dg/torture/stackalign/stackalign.exp $TS_dir/gcc.dg/torture/stackalign/stackalignEXP
mv $TS_dir/gcc.dg/tree-ssa/tree-ssa.exp $TS_dir/gcc.dg/tree-ssa/tree-ssaEXP
mv $TS_dir/gcc.dg/vect/vect.exp $TS_dir/gcc.dg/vect/vectEXP 
mv $TS_dir/gcc.dg/cpp/trad/trad.exp $TS_dir/gcc.dg/cpp/trad/tradEXP
mv $TS_dir/gcc.dg/matrix/matrix.exp $TS_dir/gcc.dg/matrix/matrixEXP
mv $TS_dir/g++.dg/plugin/plugin.exp $TS_dir/g++.dg/plugin/pluginEXP
mv $TS_dir/g++.dg/dg.exp  $TS_dir/g++.dg/dgEXP
mv $TS_dir/g++.dg/graphite/graphite.exp  $TS_dir/g++.dg/graphite/graphiteEXP
mv $TS_dir/g++.dg/vect/vect.exp  $TS_dir/g++.dg/vect/vectEXP
mv $TS_dir/g++.dg/charset/charset.exp  $TS_dir/g++.dg/charset/charsetEXP
mv $TS_dir/g++.dg/lto/lto.exp  $TS_dir/g++.dg/lto/ltoEXP
mv $TS_dir/g++.dg/guality/guality.exp  $TS_dir/g++.dg/guality/gualityEXP
mv $TS_dir/g++.dg/pch/pch.exp  $TS_dir/g++.dg/pch/pchEXP
mv $TS_dir/g++.dg/gomp/gomp.exp  $TS_dir/g++.dg/gomp/gompEXP
mv $TS_dir/g++.dg/gcov/gcov.exp  $TS_dir/g++.dg/gcov/gcovEXP
mv $TS_dir/g++.dg/tls/tls.exp  $TS_dir/g++.dg/tls/tlsEXP
mv $TS_dir/g++.old-deja/old-deja.exp $TS_dir/g++.old-deja/old-dejaEXP
mv $TS_dir/g++.dg/torture/dg-torture.exp  $TS_dir/g++.dg/torture/dg-tortureEXP
mv $TS_dir/g++.dg/torture/stackalign/stackalign.exp  $TS_dir/g++.dg/torture/stackalign/stackalignEXP
mv $TS_dir/g++.dg/bprob/bprob.exp  $TS_dir/g++.dg/bprob/bprobEXP
mv $TS_dir/g++.dg/compat/compat.exp  $TS_dir/g++.dg/compat/compatEXP
mv $TS_dir/g++.dg/compat/struct-layout-1.exp  $TS_dir/g++.dg/compat/struct-layout-1EXP
mv $TS_dir/g++.dg/debug/dwarf2/dwarf2.exp  $TS_dir/g++.dg/debug/dwarf2/dwarf2EXP
mv $TS_dir/g++.dg/debug/debug.exp  $TS_dir/g++.dg/debug/debugEXP
mv $TS_dir/g++.dg/dfp/dfp.exp  $TS_dir/g++.dg/dfp/dfpEXP
mv $TS_dir/g++.dg/special/ecos.exp  $TS_dir/g++.dg/special/ecosEXP
mv $TS_dir/g++.dg/tree-prof/tree-prof.exp  $TS_dir/g++.dg/tree-prof/tree-profEXP

exit 0
