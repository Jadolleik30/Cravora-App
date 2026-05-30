<?php
require 'config.php';
require_cli_or_admin($conn);
$res = $conn->query("SELECT * FROM food_items LIMIT 1");
print_r($res->fetch_assoc());
$conn->close();
?>
