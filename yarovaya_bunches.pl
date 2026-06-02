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

my $fnameutf="bunches_-t_$y$m$d$h$mi$s.csv";
my $fnamecp="bunches_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";

my $s='"1";"1";"1";"1";"01.01.2015";"";"rostelecom"';
print OUT $s."\r\n";
my $s='"1";"2";"1";"0";"01.01.2015";"";"Абоненты СТЭККОМ"';
print OUT $s."\r\n";
close OUT;

#my $cm="iconv -f utf8 -t cp1251 $fnameutf > pd/$fnamecp;rm -f $fnameutf";
my $cm="iconv -f utf8 -t cp1251 $fnameutf > pay_types/$fnamecp";
my @res=`$cm`;

exit 0;


