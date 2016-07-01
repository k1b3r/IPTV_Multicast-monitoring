 <?php
$servername = "localhost";
$username = "root";
$password = "xxxxxxxxx";
$db = "diag_mcast";

// Create connection
$conn = mysql_connect($servername, $username, $password);

// Check connection
if (!$conn) {
 die('Could not connect: ' . mysql_error());
} 
$db_selected = mysql_select_db($db, $conn);
if (!$db_selected) {
    die ('Can\'t use db : ' . mysql_error());
}
//encoding
mysql_query("SET NAMES utf8");
?>
