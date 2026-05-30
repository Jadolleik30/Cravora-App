<?php
require 'config.php';

$sql = "SELECT f.*, r.name as restaurant_name FROM food_items f LEFT JOIN restaurants r ON f.restaurant_id = r.id";
$result = $conn->query($sql);

$food = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $food[] = $row;
    }
}

echo json_encode($food);
$conn->close();
?>
