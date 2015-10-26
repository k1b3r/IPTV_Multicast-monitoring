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

my $time = 10;


my %config = do 'config.pl';    
my $dbh = DBI->connect("DBI:mysql:$config{db}:$config{dbserver}:$config{portsql}" ,$config{user},$config{password}) or
print "MySQL connection error $!";
 
#$dbh = DBI->connect("DBI:mysql:$db:$host:$portsql",$user,$pass) or print "MySQL connection error $!";
$sth = $dbh->prepare("SELECT  id,iface FROM int_speed");# request
$sth->execute;

while (($id,$interface) = $sth->fetchrow_array) {
#print "$id $interface";

  
my($result,$initialrx,$initialtx,$finalrx,$finaltx,$differencetx,$differencerx);


 
#Gets a line indicating the current usage.
$result = `ifconfig $interface | grep "RX bytes"`;
 
#strip it into variables for recieved and transmitted
$result =~ /\s*RX bytes:(\d*).*TX bytes:(\d*).*/;
#This converts the bytes to bits.
$initialrx = $1 * 8;
$initialtx = $2 * 8;
 
#wait x seconds and run the command again.
sleep($time);
#Gets a line indicating the current usage.
$result = `ifconfig $interface | grep "RX bytes"`;
 
$result =~ /\s*RX bytes:(\d*).*TX bytes:(\d*).*/;
#This converts the bytes to bits.
$finalrx = $1 * 8;
$finaltx = $2 * 8;
 
#now print out the results
#print 'RX: ' . $finalrx . ' | ' . $initialrx;
#print 'TX: ' . $finaltx . ' | ' . $initialtx;
 
$differencerx = ($finalrx - $initialrx) / $time;
$differencetx = ($finaltx - $initialtx) / $time;

    my($kbitpsrx,$kbitpstx,$KBpsrx,$KBpstx,$kbitrx,$kbittx,$KBrx,$KBtx);
    $kbitpsrx = $differencerx / 1024;
    $kbitpstx = $differencetx / 1024;
    $KBpsrx = $differencerx / 1024 / 8;
    $KBpstx = $differencetx / 1024 / 8;
    $kbitrx = ($finalrx - $initialrx) / 1024;
    $kbittx = ($finaltx - $initialtx) / 1024;
    $KBrx = ($finalrx - $initialrx) / 1024 / 8;
    $KBtx = ($finaltx - $initialtx) / 1024 / 8;
#formating 
$kbitrx =sprintf("%.2f",$kbitrx);
$kbittx =sprintf("%.2f",$kbittx);
$kbitpsrx =sprintf("%.2f",$kbitpsrx);
$kbitpstx =sprintf("%.2f",$kbitpstx);

 # print "interface $interface for $time seconds:\n";
 # print "Incoming: $kbitrx kbit ($KBrx KB) Average: $kbitpsrx kbps ($KBpsrx KBps)\n";
 # print "Outgoing: $kbittx kbit ($KBtx KB) Average: $kbitpstx kbps ($KBpstx KBps)\n";


$sth1 = $dbh->prepare("UPDATE `int_speed` SET iface='$interface',kbitrx='$kbitrx',kbittx='$kbittx',kbitpsrx='$kbitpsrx',kbitpstx='$kbitpstx'  WHERE id='$id'");# request
$sth1->execute;
 
}
$rc = $sth1->finish;
$rc = $sth->finish;
$rc = $dbh->disconnect;
exit();
