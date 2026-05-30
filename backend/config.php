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

function cravora_profile_fields_complete($user) {
    return trim((string)($user['name'] ?? '')) !== ''
        && trim((string)($user['phone'] ?? '')) !== ''
        && trim((string)($user['address'] ?? '')) !== ''
        && trim((string)($user['gender'] ?? '')) !== '';
}

function cravora_user_payload($user) {
    $profileCompleted = (int)($user['profile_completed'] ?? 0);
    if ($profileCompleted !== 1 && cravora_profile_fields_complete($user)) {
        $profileCompleted = 1;
    }

    return [
        "id" => $user['id'] ?? null,
        "name" => $user['name'] ?? "",
        "email" => $user['email'] ?? "",
        "role" => $user['role'] ?? "user",
        "phone" => $user['phone'] ?? "",
        "address" => $user['address'] ?? "",
        "dob" => $user['dob'] ?? "",
        "gender" => $user['gender'] ?? "",
        "points" => $user['points'] ?? 0,
        "is_verified" => isset($user['is_verified']) ? (int)$user['is_verified'] : 1,
        "profile_completed" => $profileCompleted
    ];
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
