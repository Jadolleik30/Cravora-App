<?php
require 'config.php';
require_cli_or_admin($conn);

function column_exists($conn, $table, $column) {
    $stmt = $conn->prepare("SHOW COLUMNS FROM `$table` LIKE ?");
    $stmt->bind_param("s", $column);
    $stmt->execute();
    $result = $stmt->get_result();
    $exists = $result && $result->num_rows > 0;
    $stmt->close();
    return $exists;
}

if (!column_exists($conn, "users", "verification_code")) {
    $conn->query("ALTER TABLE users ADD COLUMN verification_code VARCHAR(10) DEFAULT NULL");
}

if (!column_exists($conn, "users", "is_verified")) {
    $conn->query("ALTER TABLE users ADD COLUMN is_verified TINYINT(1) DEFAULT 1");
}

if (!column_exists($conn, "users", "profile_completed")) {
    $conn->query("ALTER TABLE users ADD COLUMN profile_completed TINYINT(1) DEFAULT 0");
}

$conn->query("UPDATE users SET is_verified = 1 WHERE is_verified IS NULL");
$conn->query("
    UPDATE users
    SET profile_completed = 1
    WHERE role = 'admin'
       OR (
            name IS NOT NULL AND name <> ''
            AND phone IS NOT NULL AND phone <> ''
            AND address IS NOT NULL AND address <> ''
            AND gender IS NOT NULL AND gender <> ''
       )
");

echo json_encode(["status" => "success", "message" => "Users table migration completed"]);
$conn->close();
