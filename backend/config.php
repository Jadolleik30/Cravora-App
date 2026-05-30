<?php
ini_set('display_errors', '0');
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    exit;
}

$host = "localhost";
$user = "root";
$pass = "";
$dbname = "jad_olleik";

mysqli_report(MYSQLI_REPORT_OFF);
$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Database connection failed"]);
    exit;
}

$conn->set_charset("utf8mb4");

function request_int($key) {
    $value = $_POST[$key] ?? $_GET[$key] ?? null;
    if ($value === null || $value === '') {
        return null;
    }

    $intValue = filter_var($value, FILTER_VALIDATE_INT);
    return $intValue === false ? null : $intValue;
}

function is_admin_request($conn) {
    $admin_id = request_int('admin_id');
    if (!$admin_id || $admin_id < 1) {
        return false;
    }

    $stmt = $conn->prepare("SELECT id FROM users WHERE id = ? AND role = 'admin' LIMIT 1");
    if (!$stmt) {
        return false;
    }

    $stmt->bind_param("i", $admin_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $isAdmin = $result && $result->num_rows > 0;
    $stmt->close();

    return $isAdmin;
}

function require_admin($conn) {
    if (!is_admin_request($conn)) {
        echo json_encode(["status" => "error", "message" => "Admin access required"]);
        $conn->close();
        exit;
    }
}

function require_cli_or_admin($conn) {
    if (php_sapi_name() === 'cli') {
        return;
    }

    require_admin($conn);
}
?>
