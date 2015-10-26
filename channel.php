<?php

include ("db.php");

$sens = 280;
$query='SELECT id,name,link,speed FROM chan';
$q = mysql_query($query);
if (!$q) {
    die('query error: ' . mysql_error());
}

while ($line = mysql_fetch_array($q, MYSQL_ASSOC)) {
$id = $line[id];
$name = $line[name];
$link = $line[link];
$speed = $line[speed];

if($line[speed] == 00000){
echo "$line[id] Channell <b><font color=\"yellow\">$line[name]</font></b> In use\or not works.<br>";
}
if($line[speed] < $sens and $line[speed] != 00000){
echo "$line[id] Channell <b><font color=\"red\">$line[name]</font></b>\\$line[link] speed $line[speed] Kbit\s <a href=\"../screen/
$id.jpg\" target=\"_blank\">screen</a> <br>";
}
if($line[speed] != 00000 and $line[speed] > $sens){
echo "$line[id] Channell <b><font color=\"green\">$line[name]</font></b>\\$line[link] speed $line[speed] Kbit\s <a href=\"../scree
n/$id.jpg\" target=\"_blank\">screen</a> <br>";
}

}
?>
