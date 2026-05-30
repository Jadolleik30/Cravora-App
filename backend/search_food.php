<?php
require 'config.php';

$query = $_GET['q'] ?? '';

if (empty($query)) {
    echo json_encode([]);
    exit;
}

$sql = "SELECT * FROM food_items WHERE name LIKE ? OR description LIKE ?";
$stmt = $conn->prepare($sql);
$search = "%$query%";
$stmt->bind_param("ss", $search, $search);
$stmt->execute();
$result = $stmt->get_result();

$food = [];
while($row = $result->fetch_assoc()) {
    $food[] = $row;
}

echo json_encode($food);
$stmt->close();
$conn->close();
?>
