#!/usr/bin/perl -w

use strict;
use lib '..';
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
my $fnameutf="utf-t_$y$m$d$h$mi$s.csv";
my $fnamecp="services-t_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";


my $cmd=<<EOF;
select se.value,se.service_id,a.description,to_char(s.open_date,'DD.MM.YY HH24:MI:SS') open_date,to_char(s.close_date,'DD.MM.YY HH24:MI:SS') close_date,s.blank
from accounts a,services s,services_ext se,outer_ids ext where 
se.service_id=s.service_id and s.account_id=a.account_id
and a.account_id = ext.id and ext.tbl='accounts'
and s.type_id in (50)
and s.card_id is NULL
and not open_date is null
and close_date is null
and se.date_end is NULL
and se.dict_id=19001
EOF



my $sth=$dbh->prepare($cmd);
$sth->execute();
while (my $r=$sth->fetchrow_hashref()){
my $fil=1;
my $tel=$r->{value};
$tel=~s/\"//g;
$tel=~s/;//g;
my $agr=$r->{description};
$agr=~s/\"//g;
$agr=~s/;//g;
my $service_id=$r->{service_id};
my $open_date=$r->{open_date};
my $close_date='';
if ($r->{close_date} ne ''){
 $close_date=$r->{close_date};
}
my $other='';
my $s="\"$fil\";\"$tel\";\"$agr\";\"$service_id\";\"$open_date\";\"$close_date\";\"$other\"";
print OUT $s."\r\n";
}

close OUT;


my $cmd="iconv -f utf8 -t cp1251 $fnameutf > $fnamecp;rm -f $fnameutf";
my @res=`$cmd`;

