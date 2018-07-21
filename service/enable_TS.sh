#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    enable_TS.sh
# Purpose: inversion of disabling script: renames gcc testcases to normal state.
#          Comment not-needed lines, if needed.
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

mv $TS_dir/gcc.c-torture/compile/compileEXP $TS_dir/gcc.c-torture/compile/compile.exp
mv $TS_dir/gcc.c-torture/execute/builtins/builtinsEXP $TS_dir/gcc.c-torture/execute/builtins/builtins.exp
mv $TS_dir/gcc.c-torture/execute/executeEXP $TS_dir/gcc.c-torture/execute/execute.exp
mv $TS_dir/gcc.c-torture/execute/ieee/ieeeEXP $TS_dir/gcc.c-torture/execute/ieee/ieee.exp
mv $TS_dir/gcc.c-torture/unsorted/unsortedEXP $TS_dir/gcc.c-torture/unsorted/unsorted.exp
mv $TS_dir/gcc.dg/autopar/autoparEXP $TS_dir/gcc.dg/autopar/autopar.exp
mv $TS_dir/gcc.dg/charset/charsetEXP $TS_dir/gcc.dg/charset/charset.exp
mv $TS_dir/gcc.dg/compat/compatEXP $TS_dir/gcc.dg/compat/compat.exp
mv $TS_dir/gcc.dg/compat/struct-layout-1EXP $TS_dir/gcc.dg/compat/struct-layout-1.exp
mv $TS_dir/gcc.dg/cpp/cppEXP $TS_dir/gcc.dg/cpp/cpp.exp
mv $TS_dir/gcc.dg/debug/debugEXP $TS_dir/gcc.dg/debug/debug.exp
mv $TS_dir/gcc.dg/dfp/dfpEXP $TS_dir/gcc.dg/dfp/dfp.exp
mv $TS_dir/gcc.dg/dgEXP $TS_dir/gcc.dg/dg.exp
mv $TS_dir/gcc.dg/guality/gualityEXP $TS_dir/gcc.dg/guality/guality.exp
mv $TS_dir/gcc.dg/lto/ltoEXP $TS_dir/gcc.dg/lto/lto.exp
mv $TS_dir/gcc.dg/torture/dg-tortureEXP $TS_dir/gcc.dg/torture/dg-torture.exp
mv $TS_dir/gcc.dg/torture/stackalign/stackalignEXP $TS_dir/gcc.dg/torture/stackalign/stackalign.exp
mv $TS_dir/gcc.dg/vect/vectEXP $TS_dir/gcc.dg/vect/vect.exp
mv $TS_dir/gcc.dg/cpp/trad/tradEXP $TS_dir/gcc.dg/cpp/trad/trad.exp
mv $TS_dir/gcc.dg/matrix/matrixEXP $TS_dir/gcc.dg/matrix/matrix.exp
mv $TS_dir/g++.dg/plugin/pluginEXP $TS_dir/g++.dg/plugin/plugin.exp
mv $TS_dir/g++.dg/dgEXP $TS_dir/g++.dg/dg.exp
mv $TS_dir/g++.dg/graphite/graphiteEXP  $TS_dir/g++.dg/graphite/graphite.exp
mv $TS_dir/g++.dg/vect/vectEXP $TS_dir/g++.dg/vect/vect.exp
mv $TS_dir/g++.dg/charset/charsetEXP $TS_dir/g++.dg/charset/charset.exp
mv $TS_dir/g++.dg/lto/ltoEXP $TS_dir/g++.dg/lto/lto.exp
mv $TS_dir/g++.dg/guality/gualityEXP  $TS_dir/g++.dg/guality/guality.exp
mv $TS_dir/g++.dg/pch/pchEXP $TS_dir/g++.dg/pch/pch.exp
mv $TS_dir/g++.dg/gomp/gompEXP $TS_dir/g++.dg/gomp/gomp.exp
mv $TS_dir/g++.dg/gcov/gcovEXP $TS_dir/g++.dg/gcov/gcov.exp
mv $TS_dir/g++.dg/tls/tlsEXP $TS_dir/g++.dg/tls/tls.exp
mv $TS_dir/g++.dg/torture/dg-tortureEXP $TS_dir/g++.dg/torture/dg-torture.exp
mv $TS_dir/g++.dg/torture/stackalign/stackalignEXP $TS_dir/g++.dg/torture/stackalign/stackalign.exp
mv $TS_dir/g++.dg/bprob/bprobEXP $TS_dir/g++.dg/bprob/bprob.exp
mv $TS_dir/g++.dg/compat/compatEXP $TS_dir/g++.dg/compat/compat.exp
mv $TS_dir/g++.dg/compat/struct-layout-1EXP $TS_dir/g++.dg/compat/struct-layout-1.exp
mv $TS_dir/g++.dg/debug/dwarf2/dwarf2EXP $TS_dir/g++.dg/debug/dwarf2/dwarf2.exp
mv $TS_dir/g++.dg/debug/debugEXP $TS_dir/g++.dg/debug/debug.exp
mv $TS_dir/g++.dg/dfp/dfpEXP $TS_dir/g++.dg/dfp/dfp.exp
mv $TS_dir/g++.dg/special/ecosEXP  $TS_dir/g++.dg/special/ecos.exp
mv $TS_dir/g++.dg/tree-prof/tree-profEXP  $TS_dir/g++.dg/tree-prof/tree-prof.exp
mv $TS_dir/gcc.dg/debug/dwarf2/dwarf2EXP $TS_dir/gcc.dg/debug/dwarf2/dwarf2.exp
mv $TS_dir/gcc.dg/graphite/graphiteEXP $TS_dir/gcc.dg/graphite/graphite.exp
mv $TS_dir/gcc.dg/torture/tls/tlsEXP $TS_dir/gcc.dg/torture/tls/tls.exp
mv $TS_dir/gcc.target/i386/i386EXP $TS_dir/gcc.target/i386/i386.exp
mv $TS_dir/gcc.dg/tree-ssa/tree-ssaEXP $TS_dir/gcc.dg/tree-ssa/tree-ssa.exp
mv $TS_dir/g++.old-deja/old-dejaEXP $TS_dir/g++.old-deja/old-deja.exp

exit 0
