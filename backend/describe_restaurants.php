<?php
require 'config.php';
$result = $conn->query("DESCRIBE restaurants");
while($row = $result->fetch_assoc()) {
    echo $row['Field'] . " - " . $row['Type'] . "\n";
}
?>
