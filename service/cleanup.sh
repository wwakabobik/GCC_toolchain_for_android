#!/bin/bash

#-------------------------------------------------------------------------------
# Name:    cleanup.sh
# Purpose: cleanup gcc for make check
#
# Author:      Iliya Vereshchagin
#
# Created:     09.07.2013
# Copyright:   Contributed by Intel Corporation (c) 2013
# Licence:     GPL
#-------------------------------------------------------------------------------

rootme=$PWD

cd 4.4.3/gcc_4_4_3_release && svn diff >ee && patch -p0 -R -i ee && rm ee && svn cleanup && svn up
cd $rootme
cd 4.6.2/gcc_4_6_2_release && svn diff >ee && patch -p0 -R -i ee && rm ee && svn cleanup && svn up
cd $rootme
cd 4.7.2/gcc_4_7_2_release && svn diff >ee && patch -p0 -R -i ee && rm ee && svn cleanup && svn up
cd $rootme
cd 4.8.0/gcc_4_8_0_release && svn diff >ee && patch -p0 -R -i ee && rm ee && svn cleanup && svn up
cd $rootme
cd 4.8.1/gcc_4_8_1_release && svn diff >ee && patch -p0 -R -i ee && rm ee && svn cleanup && svn up
cd $rootme
cd 4.9.0/trunk && svn diff >ee && patch -p0 -R -i ee && rm ee && svn cleanup && svn up
cd $rootme
