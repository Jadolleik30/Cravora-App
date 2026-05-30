<?php
require 'config.php';

$sql = "SELECT * FROM restaurants ORDER BY rating DESC";
$result = $conn->query($sql);

$restaurants = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $restaurants[] = $row;
    }
}

echo json_encode($restaurants);
$conn->close();
?>
