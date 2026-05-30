<?php
require 'config.php';
$res = $conn->query("SELECT * FROM food_items LIMIT 1");
print_r($res->fetch_assoc());
$conn->close();
?>
