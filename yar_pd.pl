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
use Data::Validate::IP;
use Data::Dumper;
use Encode;

my $dbh=get_handle_billing7();




my ($y,$m,$d,$h,$mi,$s)= Today_and_Now();

my $fnameutf="utf-t_$y$m$d$h$mi$s.csv";
my $fnamecp="services-t_$y$m$d$h$mi$s.csv";

open OUT,">$fnameutf";



#select se.value,se.service_id,a.description,to_char(s.open_date,'DD.MM.YY HH24:MI:SS') open_date,to_char(s.close_date,'DD.MM.YY HH24:MI:SS') close_date,s.blank
my $cmd=<<EOF;
select se.value,se.service_id,a.description,to_char(s.open_date,'DD.MM.YY') open_date,to_char(s.close_date,'DD.MM.YY') close_date,s.blank
from accounts a,services s,services_ext se,outer_ids ext where 
se.service_id=s.service_id and s.account_id=a.account_id
and a.account_id = ext.id and ext.tbl='accounts'
and s.card_id is NULL
and not open_date is null and open_date>sysdate-366*3
and se.date_end is NULL
and (se.dict_id=14009 and s.type_id=10 or se.dict_id=18044 and type_id=14)
EOF

#and close_date is null


my $sth=$dbh->prepare($cmd);
$sth->execute();
while (my $r=$sth->fetchrow_hashref()){
my $fil=1;

my $tel=$r->{value};
$tel=~s/mac/if_index/;

my $agr=$r->{description};
$agr=~s/\"//g;
$agr=~s/;//g;
my $service_id=$r->{service_id};
my $open_date=$r->{open_date};
my $close_date='';
if ($r->{close_date} ne ""){
 $close_date=$r->{close_date};
}
my $other='';
my @hosts = expand_ip($tel);

foreach my $host (@hosts){
#my $s="\"$fil\";\"$tel\";\"$agr\";\"$service_id\";\"$open_date\";\"$close_date\";\"$other\"";
my $s="\"$fil\";\"$host\";\"$agr\";\"$service_id\";\"$open_date\";\"$close_date\";\"$other\"";
print OUT $s."\r\n";
}
}

close OUT;

my $cmdc="iconv -f utf8 -t cp1251 $fnameutf > $fnamecp";
#my $cmd="iconv -f utf8 -t cp1251 $fnameutf > $fnamecp;rm -f $fnameutf";
my @res=`$cmdc`;


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
