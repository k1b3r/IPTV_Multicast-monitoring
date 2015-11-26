<table width="100%">
<thead>
    <tr align="center" valign="top">
        <th>
            <a href="?orderBy=id">ID::</a>
        </th>
        <th>
            <a href="?orderBy=name">Channel Name::</a>
        </th>
        <th>
            <a href="?orderBy=speed">Speed::</a>
        </th>  
        <th>
            <a href="?orderBy=last_check">Last Check::</a>
        </th>
    </tr>
</thead>   
<!--</table>-->
<?php
include ("db.php");
$sens = 280;

$orderBy = array('id', 'name', 'speed', 'last_check');

$order = 'id';
if (isset($_GET['orderBy']) && in_array($_GET['orderBy'], $orderBy)) {
    $order = $_GET['orderBy'];
}

$query='SELECT id,name,link,speed,last_check FROM chan ORDER BY '."$order".' ASC';
$q = mysql_query($query);
if (!$q) {
    die('query error: ' . mysql_error());
}
while ($line = mysql_fetch_array($q, MYSQL_ASSOC)) {

$time = round(((($utime=time()) - $line[last_check])/60),1) ;

if($line[speed] == 00000){
echo "<tr><td>"."$line[id]</td><td> Chan <b><font color=\"yellow\">$line[name]</font></b> In use\or not works | <b>$time</b> min ago. "."</td></tr>";
}
if($line[speed] < $sens and $line[speed] != 00000){
echo "<tr><td>"."$line[id]</td><td> Chan <b><font color=\"red\">$line[name]</font></b>\\$line[link]</td><td> speed <b>$line[speed]</b> Kbit\s <a href=\"../screen/$line[id].jpg\" target=\"_blank\">screen</a>|</td><td><b>$time</b> min ago. "."</td></tr>";
}
if($line[speed] != 00000 and $line[speed] > $sens){
echo "<tr><td>"."$line[id]</td><td> Chan <b><font color=\"green\">$line[name]</font></b>\\$line[link]</td><td> speed <b>$line[speed]</b> Kbit\s <a href=\"../screen/$line[id].jpg\" target=\"_blank\">screen</a>|</td><td><b>$time</b> min ago."."</td></tr>";
 }
}
echo "</table>";
?>
