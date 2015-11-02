#!/usr/bin/perl
use 5.014;
use IO::Socket::Multicast;
use DBI;
use Data::Dumper;
use Time::HiRes;

my $port = 5500;
my $time = 3;
my $file;
my $help;
my $max_forks = 3;
my $sock;

my %config = do 'config.pl';

use Getopt::Long;
GetOptions(
    "f" => \$file,
    "h" => \$help
);


usage() if $help;

my $dbh = DBI->connect(
    "DBI:mysql:$config{db}:$config{dbserver}:$config{portsql}",
    $config{user},
    $config{password},
    {
        RaiseError             => 1,
        AutoCommit             => 1,
        mysql_multi_statements => 1,
        mysql_init_command     => q{SET NAMES 'utf8'; SET CHARSET 'utf8'},
        mysql_auto_reconnect   => 1,
        AutoInactiveDestroy    => 1,
    }
) or die $DBI::errstr;


if ( $file ) {
    my $i = 0;
    open( DATA, "./$file" ) or die "Couldn't open file $file, $!";
    while (<DATA>) {
        chomp; my ( $name, $link ) = split(',');
        $dbh->do('INSERT  INTO chan (id,name,link) VALUES (?,?,?)',
            undef, $i++, $name, $link);
    }
    exit;
}

########
my ($count) = $dbh->selectrow_array('SELECT count(*) FROM chan');

$SIG{CHLD} = 'IGNORE';
my $pid;
my $process_num = 0;
for (1..$max_forks) {
    $pid = fork();
    #warn "$pid ::pid";
    die "System is oveloaded" if ! defined $pid;
    $process_num = $_;
    last if ! $pid;
} 
exit(0) if $pid;
$dbh = $dbh->clone;
#my $limit  = $process_num == $max_forks ? '' : int($count/$max_forks);
my $ost = $count % $max_forks;
my $limit = int($count/$max_forks);
my $offset =  int($count/$max_forks) * ($process_num - 1);
if ($process_num == $max_forks) {
#$offset+=$ost;
$limit+=$ost;
}
$dbh->{InactiveDestroy} = 1;
my $sql = "SELECT id,name,link,interface FROM chan ORDER BY id LIMIT $limit OFFSET $offset";
warn "$sql";
my $sth = $dbh->prepare($sql);
$sth->execute();
while ( my ( $id, $name, $link, $interface ) = $sth->fetchrow_array ) {
    warn "$id :: $name";

     $sock = IO::Socket::Multicast->new(
        Proto     => 'udp',
        LocalAddr => $link,
        LocalPort => $port,
        ReuseAddr => 1,
        ReusePort => 1,
        TimeOut   => 7
    ) or print "Error Open Socket: $!\n";
    $sock->mcast_add( $link, $interface )
        or die "Couldn't set group: $!\n";
my $data;
my $epoc;
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
    # hope you'll not get division by 0 here
    my $v = ( ( $size / $time ) * 8 ) / 10**3;
    $v    = sprintf( "%.2f", $v );
    $epoc = time();
    $dbh->do("UPDATE  chan SET speed=?,last_check=? WHERE id=?",
        undef, $v, $epoc, $id);
}

sub usage() {
    print "Multicast traffic checker\n";
    print "==================================n";
    print "Flags:n";
    print "-f file with data   data type is  name,ipaddr by default ch.txt\n";
    print "-h Print this pagen";
    exit();
}
