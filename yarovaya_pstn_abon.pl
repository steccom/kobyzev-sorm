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




my $from=$ARGV[0];
if ($from eq ''){
$from='sysdate()-1';
}
my $dbh=get_handle_billing7();

my $dsn = 'DBI:ODBC:DSN=crmdb';
my $host = '10.30.32.9,1433';
#my $database = 'bpmonline';
my $user = 'bpm';
my $auth = 'bpm';
my $bpm = DBI->connect($dsn,  $user,  $auth ) || die "Database connection not made: $DBI::errstr";
#



my ($y,$m,$d,$h,$mi,$s)= Today_and_Now();

my $fnameutf="abutf_pstn-t_$y$m$d$h$mi$s.csv";
my $fnamecp="abonents_pstn_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";


my @a;

for (my $i=1;$i<=75;$i++){
push @a,"";
}

$a[1-1]=1;
$a[9-1]=1; # yuridicheskoe lico
$a[10-1]=1;
$a[16-1]=1;
$a[32-1]=1;
$a[43-1]=1;
$a[54-1]=1;
$a[65-1]=1;

my $cmd=<<EOF;
select a.customer_id,a.account_id,a.description,a.group_id
from accounts a,outer_ids ext where 
EXISTS ( select service_id from services where account_id=a.account_id and type_id in (50) and status>0 and not open_date is NULL and stop_date is NULL and open_date>'$from' )
and a.account_id = ext.id and ext.tbl='accounts'
EOF


my $sth=$dbh->prepare($cmd);
$sth->execute();
while (my $r=$sth->fetchrow_hashref()){
my $cust_id=$r->{customer_id};

$a[24-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=11");  # b_name
$a[24-1]=~s/\"//g;
my $inn=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=16");  # inn
($inn,undef)=split("/",$inn);
$inn="-" unless $inn>0;
$a[25-1]=$inn;
$a[27-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=6");  # phone
$a[30-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=12");  # bank_name
$a[31-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=32");  # rasacc
$a[42-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=10");  # paddress
$a[53-1]=$a[42-1];
$a[64-1]=$a[42-1];
$a[75-1]=$a[42-1];
$a[9-1]=0 if $r->{group_id}==370;
$a[21-1]=1 if $r->{group_id}==370;
$a[9-1]=1 if $r->{group_id}!=370;
$a[21-1]="" if $r->{group_id}!=370;
$a[14-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=23");  # fio
#$a[11-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=1");  # imya
#$a[12-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=4");  # otch
#$a[13-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=3");  # familya

$a[20-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=5");  # familya
$a[20-1]="-" unless $a[20-1];

my $des=$r->{'description'};
my $ot=decode_utf8(" от ");
($a[5-1],undef)=split($ot,$des);

my ($start_date)=$bpm->selectrow_array("select Date from Document where OutgoingNumber='$r->{description}'");
my ($yy,$mm,$dd)=split('-',$start_date);
#$yy=substr($yy,2,2);
$start_date="$dd.$mm.$yy";
$a[4-1]=$start_date;

my $srvcmd=<<EOF;
select se.value,to_char(s.open_date,'YYYY-MM-DD'),to_char(s.close_date,'YYYY-MM-DD'),s.service_id
from services s,services_ext se where 
se.service_id=s.service_id 
and s.account_id=$r->{account_id}
and not s.open_date is null and open_date>'$from'
and se.date_end is NULL
and se.dict_id=19001
EOF

my $hst=$dbh->prepare($srvcmd);
$hst->execute();
while (my ($telall,$open_date,$stop_date,$service_id)=$hst->fetchrow_array()){
$a[2-1]=$dbh->selectrow_array("select value from services_ext where service_id=$service_id and dict_id=19016 and date_end is NULL");  # paddress
$a[2-1]="7495".$a[2-1] if $a[2-1] ne '';
print STDERR "SERVICE_ID= $service_id MSK===$a[2-1]";
my ($yy,$mm,$dd)=split('-',$open_date);
#$yy=substr($yy,2,2);
$open_date="$dd.$mm.$yy";

$a[7-1]=$open_date;
if ($stop_date ne ''){
($yy,$mm,$dd)=split('-',$stop_date);
#$yy=substr($yy,2,2);
$stop_date="$dd.$mm.$yy";
}

$a[6-1]=0 unless $stop_date;
$a[6-1]=1 if $stop_date ne '';
$a[8-1]=$stop_date if $stop_date ne '';
#$a[12-1]=0; # phyzi lico

my @tels=split("or",$telall);
foreach my $tel (@tels){
$tel=~s/\"//gi;
$tel=~s/phone//gi;
$tel=~s/trunk//gi;
$tel=~s/src//gi;
$tel=~s/8495380/7495380/gi;
$tel=~s/\s+//gi;
$a[3-1]=$tel;
$a[2-1]=$tel unless $a[2-1];
my $s=join("\";\"",@a);
$s="\"".$s."\"";
print OUT $s."\r\n";
}

}

}

close OUT;

#my $cm="iconv -f utf8 -t cp1251 $fnameutf > pstn/$fnamecp;rm -f $fnameutf";
my $cm="iconv -f utf8 -t cp1251 $fnameutf > pstn/$fnamecp";
my @res=`$cm`;

exit 0;

