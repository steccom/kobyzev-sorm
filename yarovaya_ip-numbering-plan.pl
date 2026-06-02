#!/usr/bin/perl -w

use strict;
use lib '..';
use Data::Validate::IP;
use bmhead;
use Text::Iconv;
use Data::Dumper;
use BM::DBI;
use DBHManager qw(get_handle_billing7);
use dbase qw(insertid);
use Date::Calc qw( Today_and_Now );
use Encode;

my $dbh=get_handle_billing7();

my ($y,$m,$d,$h,$mi,$s)= Today_and_Now();

my $fnameutf="ip-numbering-plan_-t_$y$m$d$h$mi$s.csv";
my $fnamecp="ip-numbering-plan_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";

my $s='"1";"STECCOM_PUBLIC";"82.114.0.0";"19";"21.06.2011 00:00:00";""';
print OUT $s."\r\n";
my $s='"1";"STECCOM_PRIVATE1";"10.0.0.0";"8";"21.06.2011 00:00:00";""';
print OUT $s."\r\n";
my $s='"1";"STECCOM_PRIVATE2";"172.16.0.0";"12";"21.06.2011 00:00:00";""';
print OUT $s."\r\n";
my $s='"1";"STECCOM_PRIVATE3";"192.168.0.0";"16";"21.06.2011 00:00:00";""';
print OUT $s."\r\n";


close OUT;

#my $cm="iconv -f utf8 -t cp1251 $fnameutf > pd/$fnamecp;rm -f $fnameutf";
my $cm="iconv -f utf8 -t cp1251 $fnameutf > pay_types/$fnamecp";
my @res=`$cm`;

exit 0;


