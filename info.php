<?php
include ("db.php");
$pid = shell_exec('pidof perl');
 echo "<b><font color=\"green\">PIDs = $pid</font></b><br>";

/*
$lines = file('band.txt');
if($lines){
 foreach ($lines as $num => $line){
 list($interface,$kbitrx,$kbittx,$kbitpsrx,$kbitpstx) = split (',', $line);
*/

$query='SELECT id,iface,kbitrx,kbittx,kbitpsrx,kbitpstx,last_check,use_int FROM int_speed';
$q = mysql_query($query);
if (!$q) {
    die('query error: ' . mysql_error());
}

while ($line = mysql_fetch_array($q, MYSQL_ASSOC)) {
$id = $line[id]; 
$interface = $line[iface]; 
$kbitrx = $line[kbitrx];
$kbittx= $line[kbittx];
$kbitpsrx = $line[kbitpsrx];
$kbitpstx = $line[kbitpstx];
$use_int = $line[use_int];
$epoc = $line[last_check];
if($use_int==1){
if($interface){
$utime = time();
$time = $utime-$epoc;
  echo "Int <b><font color=\"green\">$interface</font></b>";
  echo "In(Rx)\Out(Tx)<b><font color=\"red\">=$kbitrx\\$kbittx</font></b> Kbit ";
  echo "Average In(Rx)\Out(Tx) <b><font color=\"green\">=$kbitpsrx\\$kbitpstx</font></b> Kbit\s<br>";
  echo "Last Checked $time seconds ago <br>";
}else{
  echo "Int <b><font color=\"green\">eth1</font></b>  ";
  echo "In(Rx)\Out(Tx)<b><font color=\"red\">=updating\\updating</font></b> Kbit ";
  echo "Average In(Rx)\Out(Tx) <b><font color=\"green\">=updating\\updating</font></b> Kbit\s<br>";
  echo "Last Checked $time seconds ago <br>";
 }
}else{
null;
 }
}
?>
