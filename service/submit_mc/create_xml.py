#!/bin/env python2.7
import sqlite3, sys, re, datetime, time
from time import localtime, strftime
import xml.etree.ElementTree as xml
from xml.dom import minidom

if len(sys.argv) != 5:
	print "Example: %s 2013/04/15 32 4.7.2 GalaxyNexus\n result in report.xml" %sys.argv[0]
	sys.exit(1)


revision = sys.argv[1]                  # 2013/04/15
target_bits = sys.argv[2]               # 32 / 64
compiler = sys.argv[3]                  # 4.6.2 / 4.7.2 / 4.8.0 / 4.8.1 / 4.8.2  / 4.9.0
device = sys.argv[4]                    # CloverTrail / Medfield / GalaxyNexus / Nexus4 / HarrisBeach / Merrifield
revision_ = re.sub(r'/','',revision)	# 20130415
revision__ = re.sub(r'/','_',revision)	# 2013_04_15
compiler_ = re.sub(r'\.','',compiler)	# 462


PathToDB = '/nfs/ims/proj/icl/gcc_cw/share/NDK_Regressions/ndk_regressions_%s.db' %device
connect = None
connect = sqlite3.connect(PathToDB)

with connect:
	connect.row_factory = sqlite3.Row
	db = connect.cursor()

	db.execute("select distinct ndk_version from ndk_timing")
	compilers = db.fetchall()

	compilers = ' ' + ' '.join(i[0] for i in compilers) + ' '
	if ' ' + compiler + ' ' not in compilers:
		print "Undeclared compiler! Available:"
		print compilers
		sys.exit(1)
	#elif compiler == "4.9.0":
	#	compiler__ = "master"
	else:
		compiler__ = re.sub(r'.[0-9]$','',compiler)

#	db.execute("select distinct device from ndk_timing")
#	devices = db.fetchall()
#	
#	devices = ' ' + ' '.join(i[0] for i in devices) + ' '
#	if ' ' + device + ' ' not in devices :
#		print "Undeclared device name! Available:"
#		print devices
#		sys.exit(1)
#	elif device == 'CloverTrail':
#		device_ = "CTP"
#	elif device == 'Medfield':
#		device_ = "MFLD"
#	else:
	device_ = device
#	print "DEVICE"
#	print device
#	print device_
#	print "EOF DEVICE"

	db.execute("select date_of_run from ndk_timing where date_of_run = '%s' and ndk_version = '%s' and target_bits = '%s'" % (revision, compiler, target_bits))	# 2013/04/15
	BeginTime = db.fetchone()
	if BeginTime is None:
		print "No such record. Available:"
		db.execute("select date_of_run, ndk_version from ndk_timing where ndk_version = '%s' and target_bits = '%s'" % (compiler, target_bits))
		res = db.fetchall()
		for i in res:
			print i[0], '\t', i[1] 
		print "Or try another compiler version or device name."
		sys.exit(1)
	db.execute("select gcc_start from ndk_timing where date_of_run = '%s' and ndk_version = '%s' and target_bits = '%s'" % (revision, compiler, target_bits))	# 13:36:29
	BeginTime = ''.join(BeginTime) + ''.join(db.fetchone())
	BeginTime = datetime.datetime.strptime(BeginTime, '%Y/%m/%d%H:%M:%S').strftime('%Y/%m/%d %r')	# 2013/04/15 01:36:29 PM
	db.execute("select total_time from ndk_timing where date_of_run = '%s' and ndk_version = '%s' and target_bits = '%s'" % (revision, compiler, target_bits))	# 04:24:29
	Duration = time.strptime(''.join(db.fetchone()), '%H:%M:%S')
	EndTime = (datetime.datetime.strptime(BeginTime, '%Y/%m/%d %I:%M:%S %p') + datetime.timedelta(hours = Duration.tm_hour, minutes = Duration.tm_min, seconds = Duration.tm_sec)).strftime('%Y/%m/%d %r')	# add 04:24:29

	db.execute("select xpass, upass, ufail, xfail, unsupported, unresolved from Summaries, ndk_timing where test_date = '%s' and type = 'total' and Summaries.ndk_version='%s' and ndk_timing.date_of_run = '%s' and ndk_timing.ndk_version = '%s' and ndk_timing.target_bits = '%s'" % (revision__, compiler, revision, compiler, target_bits))
	Rate = db.fetchone()
	TestName = Rate.keys()

	results = xml.Element('results')
	test_run = xml.SubElement(results, 'test-run')
	test_run.set('Build', revision_)
	test_run.set('BuildCreated', BeginTime)
	test_run.set('BuildLocation', 'gcc')
	test_run.set('Product', 'Android_NDK_' + compiler__)
	test_run.set('TargetOS', 'Android mainline')
	test_run.set('TestGroup', 'make_check')
	test_run.set('TestSuite', 'Performance')
	test_run.set('TestingType', 'make_check_' + target_bits)
	test_run.set('TargetProcessor', device_)
	test_run.set('RunDate', BeginTime)
	test_run.set('BeginTime', BeginTime)
	test_run.set('EndTime', EndTime)
	testcase = xml.SubElement(test_run, 'tests')
	for test in TestName:
		tests = xml.SubElement(testcase, 'test')
		tests.set('TestName', test)
		tests.set('Rate', '%s' % Rate[test])
		tests.set('CompTime', '0')
		if 'pass' in test:
			tests.set('SysComment', 'passed')
			tests.set('Reverse', '0')
		elif 'fail' in test or 'resolv' in test:
			tests.set('SysComment', 'failed')
			tests.set('Reverse', '1')
		else:
			tests.set('SysComment', 'skipped')
			tests.set('Reverse', '1')
		if Rate[test] == 0:
			tests.set('SysStatus', '3')	
		else:
			tests.set('SysStatus', '1')

	report = xml.tostring(results, "us-ascii")
	with open('report.xml', 'w') as f:
		report = minidom.parseString(report).toprettyxml(encoding = "us-ascii", indent = "  ")
		f.write(report)
		print report

