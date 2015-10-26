<?php

include ("db.php");
$sens = 280;
$query='SELECT id,name,link,speed,last_check FROM chan';
$q = mysql_query($query);
if (!$q) {
    die('query error: ' . mysql_error());
}
while ($line = mysql_fetch_array($q, MYSQL_ASSOC)) {

$time = round(((($utime=time()) - $line[last_check])/60),1) ;

if($line[speed] == 00000){
echo "$line[id] Chan <b><font color=\"yellow\">$line[name]</font></b> In use\or not works | <b>$time</b> min ago. <br>";
}
if($line[speed] < $sens and $line[speed] != 00000){
echo "$line[id] Chan <b><font color=\"red\">$line[name]</font></b>\\$line[link] speed <b>$line[speed]</b> Kbit\s <a href=\"../screen/$line[id].jpg\" target=\"_blank\">screen</a>|<b>$time</b> min ago. <br>";
}
if($line[speed] != 00000 and $line[speed] > $sens){
echo "$line[id] Chan <b><font color=\"green\">$line[name]</font></b>\\$line[link] speed <b>$line[speed]</b> Kbit\s <a href=\"../screen/$line[id].jpg\" target=\"_blank\">screen</a>|<b>$time</b> min ago.<br>";
 }
}
?>
