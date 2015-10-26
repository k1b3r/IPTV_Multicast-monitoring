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

my $host = "127.0.0.1"; # srv
my $portsql = "3306"; # port
my $user = "root"; #  user
my $pass = "xxxxxxxxx"; # pass
my $db = "diag_mcast"; # database
my $host = "127.0.0.1"; # srv
my $portsql = "3306"; # port
my $user = "root"; #  user
my $pass = "h0d5ym4m2"; # pass
my $db = "diag_mcast"; # database
my $port = 5500;
$dbh = DBI->connect("DBI:mysql:$db:$host:$portsql",$user,$pass) or print "MySQL connection error $!";
$sth = $dbh->prepare("SELECT  id,name,link,interface FROM chan");# request
$sth->execute;

while (($id,$name,$link,$iface) = $sth->fetchrow_array) {
chomp($id,$name,$link,$iface);
warn($id ,$link);
system("/usr/bin/timeout 20s /usr/bin/ffmpeg -i udp://\@$link:$port -y -f image2 -t 0.001 -ss 00:00:4 -s 240*160 /var/www/html/scr
een/$id.jpg");
}
$rc = $sth->finish;    # закрываем
$rc = $dbh->disconnect;  # соединение
exit;
