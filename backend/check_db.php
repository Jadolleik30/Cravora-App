<?php
require 'config.php';
require_cli_or_admin($conn);
$sql = "SELECT * FROM notifications";
$res = $conn->query($sql);
while($row = $res->fetch_assoc()){
    print_r($row);
}
$conn->close();
?>
