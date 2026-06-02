#!/usr/bin/perl -w

use strict;
use lib '..';
use Data::Validate::IP;
use bmhead;
use Text::Iconv;
use Data::Dumper;
use BM::DBI;
use DBHManager qw(get_handle_billing7 get_handle);
use dbase qw(insertid);
use Date::Calc qw( Today_and_Now );
use Encode;

my $from=$ARGV[0];
if ($from eq '') {
 $from = '2021-01-01';
}

my $dbh=get_handle_billing7();

my $hd=get_handle();
my $ot=decode_utf8("Услуги");

my $cmd=<<EOF;
select a.customer_id,a.account_id,a.description,a.group_id,ext.parent
from accounts a,outer_ids ext where 
EXISTS ( select service_id from services where account_id=a.account_id and type_id in (50,10,14) and status>0 and not open_date is NULL and stop_date is NULL and open_date>sysdate-3*366 )
and a.account_id = ext.id and ext.tbl='accounts'
EOF


my $sth=$dbh->prepare($cmd);
$sth->execute();


my ($y,$m,$d,$h,$mi,$s)= Today_and_Now();

my $fnameutf="balance-t_$y$m$d$h$mi$s.csv";
my $fnamecp="balance_fillup_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";



while (my $r=$sth->fetchrow_hashref()){
my $pcmd=<<EOF;
select summa,to_char(bill_pay,'DD.MM.YYYY HH24:MI:SS') bill_pay,pay_type,letter from bill where customer in (select customer from cust_staff where ext_id='$r->{parent}' 
and pay_type='$ot' and not bill_pay is NULL and bill_pay>'$from' and contract_id='$r->{description}')
EOF

print $pcmd;


my $tsth=$hd->prepare($pcmd);
$tsth->execute();

while (my $p=$tsth->fetchrow_hashref()){
my $s='"1";"1";"'.$r->{description}.'";"";"'.$p->{bill_pay}.'";"'.$p->{summa}.'";""';
print OUT $s."\r\n";
print $s."\r\n";

}
}

close OUT;

#my $cm="iconv -f utf8 -t cp1251 $fnameutf > pd/$fnamecp;rm -f $fnameutf";
my $cm="iconv -f utf8 -t cp1251 $fnameutf > balance/$fnamecp";
my @res=`$cm`;

exit 0;


