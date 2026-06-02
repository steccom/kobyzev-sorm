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

my $dsn = 'DBI:ODBC:DSN=crmdb';
my $host = '10.30.32.9,1433';
#my $database = 'bpmonline';
my $user = 'bpm';
my $auth = 'bpm';
my $bpm = DBI->connect($dsn,  $user,  $auth ) || die "Database connection not made: $DBI::errstr";
#


my $from=$ARGV[0];
if ($from eq ''){
$from="sysdate-1";
}
my ($y,$m,$d,$h,$mi,$s)= Today_and_Now();
my $ts="$y$m$d$h$mi$s";


my $fnameutf="abutf-t_$y$m$d$h$mi$s.csv";
my $fnamecp="abonents_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";


my @a;

for (my $i=1;$i<=76;$i++){
push @a,"";
}

$a[1-1]=1;
$a[13-1]=1;
$a[19-1]=1;
$a[33-1]=1;
$a[44-1]=1;
$a[55-1]=1;
$a[66-1]=1;
$a[12-1]=1; # yuridicheskoe lico

my $cmd=<<EOF;
select a.customer_id,a.account_id,a.description,a.group_id
from accounts a,outer_ids ext where 
EXISTS ( select service_id from services where account_id=a.account_id and type_id in (10,14) and status>0 and not open_date is NULL and stop_date is NULL and open_date>'$from' )
and a.account_id = ext.id and ext.tbl='accounts'
EOF


my $ot=decode_utf8(" от ");
my $sth=$dbh->prepare($cmd);
$sth->execute();
while (my $r=$sth->fetchrow_hashref()){
my $cust_id=$r->{customer_id};

$a[27-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=11");  # b_name
$a[27-1]=~s/\"//g;
my $inn=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=16");  # inn
($inn,undef)=split("/",$inn);
$a[28-1]=$inn;
$a[30-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=6");  # phone
$a[31-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=12");  # bank_name
$a[32-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=32");  # rasacc
$a[43-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=10");  # paddress
$a[54-1]=$a[43-1];
$a[65-1]=$a[43-1];
$a[76-1]=$a[43-1];

$a[19-1]=0 if $r->{group_id}==370;
$a[19-1]=1 if $r->{group_id}!=370;
$a[17-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=23");  # fio
$a[13-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=1");  # imya
$a[14-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=4");  # otch
$a[15-1]=$dbh->selectrow_array("select value from bm_customer_contact where customer_id=$cust_id and contact_dict_id=3");  # familya

my $des=$r->{'description'};
($a[8-1],undef)=split($ot,$des);

my ($start_date)=$bpm->selectrow_array("select Date from Document where OutgoingNumber='$r->{description}'");
my ($yy,$mm,$dd)=split('-',$start_date);
#$yy=substr($yy,2,2);
$start_date="$dd.$mm.$yy 00:00:00";
$a[7-1]=$start_date;

my $srvcmd=<<EOF;
select se.value,to_char(s.open_date,'YYYY-MM-DD'),to_char(s.close_date,'YYYY-MM-DD'),s.login,se.services_ext_id
from services s,services_ext se where 
se.service_id=s.service_id 
and s.account_id=$r->{account_id}
and not s.open_date is null and open_date>'$from'
and se.date_end is NULL
and (se.dict_id=14009 and s.type_id=10 or se.dict_id=18044 and type_id=14)
EOF

my $hst=$dbh->prepare($srvcmd);
$hst->execute();
while (my ($tel,$open_date,$stop_date,$login)=$hst->fetchrow_array()){

my ($yy,$mm,$dd)=split('-',$open_date);
#$yy=substr($yy,2,2);
$open_date="$dd.$mm.$yy 00:00:00";

$a[2-1]=$login;
$a[10-1]=$open_date;
if ($stop_date ne ''){
($yy,$mm,$dd)=split('-',$stop_date);
#$yy=substr($yy,2,2);
$stop_date="$dd.$mm.$yy 00:00:00";
}


$a[9-1]=0 unless $stop_date;
$a[9-1]=1 if $stop_date ne '';
$a[11-1]=$stop_date if $stop_date ne '';


my @hosts = expand_ip($tel);

foreach my $host (@hosts){
$a[3-1]=$host; # ip static address
my $s=join("\";\"",@a);
$s="\"".$s."\"";
print OUT $s."\r\n";
}

}

}

close OUT;

#my $cm="iconv -f utf8 -t cp1251 $fnameutf > pd/$fnamecp;rm -f $fnameutf";
my $cm="iconv -f utf8 -t cp1251 $fnameutf > pd/$fnamecp";
my @res=`$cm`;

exit 0;


sub expand_ip{
my $net=shift;

my %netlen=("32" => 1,"31" => 2,"30" => 4,"29" => 8,"28" => 16,"27" => 32,"26" => 64,"25" => 128,"24" => 256);
my $validator=Data::Validate::IP->new;
my @a=split(" ",$net);

my @nets;
my @masks;
my @hosts;

my $ho;
my $no;

foreach my $chunk (@a){
$chunk=~s/\)//g;
$chunk=~s/\(//g;
if ($chunk eq 'not'){
$no=1;
}

if ($chunk eq 'host'){
$ho=1;
}

my ($ip,$mask)=split("\/",$chunk);
if ($validator->is_ipv4($ip) and $no eq ''){
print "NET:".$net."\n";
print "mask:".$mask."\n";
$no='';
if ($ho){
$ho='';
push @hosts,$ip;
}else{
push @nets,$ip;
push @masks,$mask;

}


}
print $chunk;
print "================================\n";
}

print "hosts: ".Dumper(\@hosts);
print "nets:  ".Dumper(\@nets);
print "masks: ".Dumper(\@masks);


for (my $i=0;$i<scalar(@nets);$i++){
my $ip=$nets[$i];
print "ip=$ip\n";
my $mask=$masks[$i];
my ($a,$b,$c,$d)=split('\.',$ip);
for (my $n=0;$n<$netlen{$mask};$n++){
push @hosts,"$a.$b.$c.$d";
$d++;
}
}

return @hosts;

}
