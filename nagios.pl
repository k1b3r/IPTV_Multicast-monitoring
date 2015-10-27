#!/usr/bin/perl
use warnings;
use utf8;
use Socket;
use List::Util qw(sum);
use IO::Socket;
use IO::Socket::INET;
use IO::Socket::Multicast;
use Time::HiRes;
use DBI;
use Data::Dumper;


my $port = 5500;
my $sens = 280;

#clear api files;
open (BAD, ">api/bad.txt");
open (STAT,">api/stat.txt");
close STAT;
close BAD;

my %config = do 'config.pl';
my $dbh = DBI->connect("DBI:mysql:$config{db}:$config{dbserver}:$config{portsql}" ,$config{user},$config{password}) or
print "MySQL connection error $!";

$sth = $dbh->prepare("SELECT  id,name,link,interface,speed FROM chan");# request
$sth->execute;

my $count1=0;
my $count2=0;

my $z2 = 0;

while (($id,$name,$link,$iface,$speed) = $sth->fetchrow_array){
chomp($id,$name,$link,$iface,$speed);
if($speed < $sens){
$z2++;
 }
}
print $z2;


$sth->execute;
my $z1=0;
while (($id,$name,$link,$iface,$speed) = $sth->fetchrow_array) {
chomp($id,$name,$link,$iface,$speed);
#warn($id ,$link);
if($speed < $sens){
$count1++;
$z1++;
	if($z1 != $z2){

	open(BAD, ">>api/bad.txt");
	print (BAD "$name,");
	close BAD;
        }elsif($z1 == $z2)
	{
        open(BAD, ">>api/bad.txt");
        print (BAD "$name");
        close BAD;
	}
}
if($speed > $sens){
$count2++;
}

}
$rc = $sth->finish;    # закрываем
$rc = $dbh->disconnect;  # соединение

$a= qx/pidof  astra/;
$b= qx/pidof msd_lite/;
$c= qx/netstat -atpnu | wc -l/;
$d= $count1;
$e= $count2;
chomp($a,$b,$c,$d,$e);
$abcde="$a,"."$b,"."$c,"."$d,"."$e";
open(STAT, ">>api/stat.txt");
print (STAT "$abcde");
close STAT;

#print $abcde;
exit;

