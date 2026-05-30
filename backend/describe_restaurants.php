<?php
require 'config.php';
require_cli_or_admin($conn);
$result = $conn->query("DESCRIBE restaurants");
while($row = $result->fetch_assoc()) {
    echo $row['Field'] . " - " . $row['Type'] . "\n";
}
?>
