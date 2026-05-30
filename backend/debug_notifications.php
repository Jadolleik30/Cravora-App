<?php
require 'config.php';

$sql = "SELECT * FROM notifications";
$result = $conn->query($sql);
$notes = [];
while($row = $result->fetch_assoc()) {
    $notes[] = $row;
}

echo "Total notifications: " . count($notes) . "\n";
print_r($notes);

$conn->close();
?>
