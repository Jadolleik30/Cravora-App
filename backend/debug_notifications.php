<?php
require 'config.php';
require_cli_or_admin($conn);

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
