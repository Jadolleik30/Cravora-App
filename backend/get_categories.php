<?php
require 'config.php';

$sql = "SELECT * FROM categories";
$result = $conn->query($sql);

$categories = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $categories[] = $row;
    }
}

echo json_encode($categories);
$conn->close();
?>
