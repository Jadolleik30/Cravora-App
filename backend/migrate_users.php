<?php
require 'config.php';
require_cli_or_admin($conn);

function column_exists($conn, $table, $column) {
    $stmt = $conn->prepare("
        SELECT COUNT(*) AS count
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND COLUMN_NAME = ?
    ");

    if (!$stmt) {
        cravora_log("migration_column_check_prepare_failed", ["db_error" => $conn->error]);
        return false;
    }

    $stmt->bind_param("ss", $table, $column);
    $stmt->execute();
    $result = $stmt->get_result();
    $row = $result ? $result->fetch_assoc() : null;
    $exists = $row && (int)$row["count"] > 0;
    $stmt->close();
    return $exists;
}

if (!column_exists($conn, "users", "verification_code")) {
    $conn->query("ALTER TABLE users ADD COLUMN verification_code VARCHAR(6) DEFAULT NULL");
}

if (!column_exists($conn, "users", "is_verified")) {
    $conn->query("ALTER TABLE users ADD COLUMN is_verified TINYINT(1) DEFAULT 1");
}

if (!column_exists($conn, "users", "profile_completed")) {
    $conn->query("ALTER TABLE users ADD COLUMN profile_completed TINYINT(1) DEFAULT 0");
}

$conn->query("UPDATE users SET is_verified = 1 WHERE is_verified IS NULL");
$conn->query("ALTER TABLE users MODIFY COLUMN verification_code VARCHAR(6) DEFAULT NULL");
$conn->query("ALTER TABLE users MODIFY COLUMN is_verified TINYINT(1) NOT NULL DEFAULT 0");
$conn->query("ALTER TABLE users MODIFY COLUMN profile_completed TINYINT(1) NOT NULL DEFAULT 0");

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
