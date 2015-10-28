#!/usr/bin/perl
#use strict ;
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

my $id;
my $name;
my $link;
my $port = 5500;
my $sock;
my $time = 3;
my $interface;
my $mode = 0;
my $file = "ch.txt";
my $help;

my %config = do 'config.pl';


use Getopt::Long;
GetOptions("m"=> \$mode,
"f"=> \$file,
"h"=> \$help);
sub usage(){
    print "Multicast traffic checker\n";
    print "==================================n";
    print "Flags:n";
    print "-m 0 is default  1 is writing to database\n";
    print "-f file with data   data type is  name,ipaddr by default ch.txt\n";
    print "-h Print this pagen";
    exit();
}

if($help){
    usage();
    exit;
}
elsif($mode==1 ){
    my $i=0;
    open(DATA, "./$file") or die "Couldn't open file ch.txt, $!";
    while(<DATA>){
        ($name,$link) = split(',');
        my $dbh = DBI->connect("DBI:mysql:$config{db}:$config{dbserver}:$config{portsql}" ,$config{user},$config{password}) or
        print "MySQL connection error $!";
        $sth = $dbh->prepare("INSERT  INTO chan (id,name,link) VALUES ('$i','$name','$link')");# request
        $sth->execute;
        $i++;
    }
    $rc = $sth->finish;    # закрываем
    exit;
}
if($mode==0){
    my $dbh = DBI->connect("DBI:mysql:$config{db}:$config{dbserver}:$config{portsql}" ,$config{user},$config{password}) or
    print "MySQL connection error $!";
    $sth = $dbh->prepare("SELECT  id,name,link,interface FROM chan");# request
    $sth->execute;
    
    while (($id,$name,$link,$interface) = $sth->fetchrow_array) {
        #----------start from require id
        if($id > 1000){
            goto ERROR;
            }else{
            warn "$name";
            #-----------------------------------
            
            $sock = IO::Socket::Multicast->new(Proto=>'udp',LocalAddr=> $link,LocalPort => $port,ReuseAddr => 1,ReusePort => 1,TimeOut => 7) or print "Error Open Socket"
            ;
            $sock->mcast_add($link,$interface) or print "Couldn't set group: $!\n";
            alarm(5);
            $sock->recv($data,4096) or print "Couldn't receive data $!\n";
            $SIG{ALRM} = sub {close($sock);};
            
            my $start = time;
            for (;;) {
                $data .= <$sock>;
                if ((time - $start) > $time) {
                    last;
                }
            }
            close($sock);
            my $size = length($data);
            my $v = (($size/$time)*8)/10**3;
            $v =sprintf("%.2f",$v);
            #------------------------------------
            #------------------------------------
            $epoc = time();
            $sth1 = $dbh->prepare("UPDATE  `chan` SET speed='$v',last_check='$epoc' WHERE id='$id' ");# request
            $sth1->execute;
            
        }
        ERROR:
    }
    $rc = $sth1->finish;
    $rc = $sth->finish;    # закрываем
    $rc = $dbh->disconnect;  # соединение
    exit;
}
