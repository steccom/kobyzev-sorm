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

my $fnameutf="term-causes_-t_$y$m$d$h$mi$s.csv";
my $fnamecp="term-causes_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";
open IN, "<q931";



while (my ($hex,$dec,$reason)=split('\t',<IN>)) {
chomp($reason);
print "$hex,$dec,$reason \n";
if ($dec>0){
my $code=$dec+600;
my $s='"1";"'.$code.'";"01.01.2021 00:00:00";"";"'.$reason.'";"10"';
print OUT $s."\r\n";
}
}
close OUT;
close IN;

#my $cm="iconv -f utf8 -t cp1251 $fnameutf > pd/$fnamecp;rm -f $fnameutf";
my $cm="iconv -f utf8 -t cp1251 $fnameutf > pay_types/$fnamecp";
my @res=`$cm`;

exit 0;


