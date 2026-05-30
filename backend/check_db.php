<?php
require 'config.php';
$sql = "SELECT * FROM notifications";
$res = $conn->query($sql);
while($row = $res->fetch_assoc()){
    print_r($row);
}
$conn->close();
?>
