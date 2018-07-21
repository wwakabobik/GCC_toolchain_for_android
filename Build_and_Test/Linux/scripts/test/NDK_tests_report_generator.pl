#!/bin/perl

use strict;
use warnings;
use POSIX qw(strftime);
use XML::LibXML;
sub trim($);


my $numArgs = $#ARGV + 3;
print $numArgs;
if ($numArgs != 6) {
  print "\nUsage: NDK_tests_report_generator.pl ANDROID_SERIAL bit version testerName\n";
  exit;
}

sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

my %Phones=("019270fc9908425c","Nexus4",
"00289867da111923","Nexus4",
"0146AFFC18020012","GalaxyNexus",
"0146A0CD1601301E","GalaxyNexus",
"MedfieldB12636D7","medfield",
"MedfieldE906493B","medfield",
"Medfield2D7DC688","clovertrail",
"Medfield5344EBC9","clovertrail",
"RHBEC245500390","clovertrail",
"RHBEC245500319","clovertrail",
"INV131700234","merrifield",
"INV131701015","merrifield",
"msticltz103.ims.intel.com:5555","harris_beach",
"msticltz104.ims.intel.com:5555","harris_beach");
 

my $doc = XML::LibXML::Document->new('1.0', 'utf-8');
my $root = $doc->createElement("results");
my $cur_date = strftime "%Y%m%d", localtime;
my $full_cur_date = strftime "%Y/%m/%d %I:%M:%S %p", localtime;
my $USER = $ARGV[3];
my $version = $ARGV[2];
my $bit = $ARGV[1];
my $ANDROID_SERIAL = $ARGV[0];
my $Phone;
if($ARGV[0] =~ m/emulator/i) {
    $Phone = "emulator";
} else {
    $Phone = $Phones{$ARGV[0]};
}

my $testRun = "test-run";    #'test-run' => 'test-run',
my $tests = "tests";
my $test = "test";

my $testRunElement = $doc->createElement($testRun);
my $testsElement = $doc->createElement($tests);



$root->appendChild($testRunElement);
$testRunElement->appendChild($testsElement);
$testRunElement->setAttribute("Build", "Andorid NDK $cur_date");
$testRunElement->setAttribute("BuildCreated", "$full_cur_date");
$testRunElement->setAttribute("BuildLocation", "NDK");
$testRunElement->setAttribute("Product", "NDK_test_$Phone");
$testRunElement->setAttribute("TargetOS", "Android");
$testRunElement->setAttribute("TestGroup", "GCC");
$testRunElement->setAttribute("TestSuite", "Stability");
$testRunElement->setAttribute("TestingType", "${version}_${bit}");
$testRunElement->setAttribute("TargetProcessor", "No");
$testRunElement->setAttribute("BeginTime", "$full_cur_date");
$testRunElement->setAttribute("EndTime", "$full_cur_date");
$testRunElement->setAttribute("RunDate", "$full_cur_date");

$doc->setDocumentElement($root);

open my $fh, "<",  "/users/${USER}/AndroidTesting/results/NDK/$cur_date/$version/$bit/$ANDROID_SERIAL/${cur_date}_x86_NDK_linux_tests.log"   or die "No such file";
my @lines = readline($fh);
close $fh;
chomp @lines;
my $nextLine = "";
my $prevAction = "";
my @resultLines;
foreach my $line (@lines) {
    if($line =~ m/Awk.*passed\s(.*)/) {
	push (@resultLines, "AWK $1"); 
	$prevAction="awk";
    } elsif ($line =~ m/Build.*\:(.*)/) {
	push (@resultLines, "Build $1"); 
	$prevAction="bld";
    } elsif($line =~ m/Run.*\:(.*)/g) {
	push (@resultLines, "Run $1"); 
	$prevAction="run";
    } elsif ($prevAction eq "bld") {
	if($line =~ m/Skipp.*broken.*ld\:([^\(]*)/g) {
	    my $res = trim($1);
	    push (@resultLines, "Build skipped $res"); 
	    $prevAction="skip";
	} elsif ($line =~ m/Skipp.*\s(.*):/g) {
	    pop (@resultLines);
	    push (@resultLines, "Build skipped $1"); 
	    $prevAction="skip";
	} 
    } elsif ($prevAction eq "run") {
	if($line =~ m/Skipp.*:(.*)/g) {
	push (@resultLines, "Run skipped $1"); 
	    $prevAction="skip";
	}    
    } 
    if($line =~ m/FAIL/i) { 
    	my $failed = pop(@resultLines);
    	push (@resultLines, "Failed $failed"); 
	$prevAction="fail";
    }
}

foreach my $line (@resultLines) {
    my $status = 0;
    my $comment ="";
   if($line =~ m/(.*Skipp[^\s]*|Failed.*\s\s)(.*)/i) {
	$line = "$2";
	$comment = "$1";
	if ($comment =~ m/Failed.*(build)/i) {
	    $status = 2;
	} elsif ($comment =~ m/Failed.*(run)/i) {
	    $status = 3;
	}
	else {
	    $status = 2;
	}
    } else  {
	$line =~ m/(.*\s\s|.*\s)(.*)/;
    	$line = "$2";
	$comment = "$1";
	$status = 1;
    }	
    
    my $testElement = $doc->createElement($test);
    $testsElement->appendChild($testElement);
    $testElement->setAttribute("TestName", trim($line));
    $testElement->setAttribute("SysComment", trim($comment) );
    $testElement->setAttribute("SysStatus", trim($status) );
}
 



print $doc->toString(2);

