<?php

$localConfigPath = __DIR__ . '/smtp_config.local.php';
if (file_exists($localConfigPath)) {
    return require $localConfigPath;
}

return [
    "host" => getenv("CRAVORA_SMTP_HOST") ?: "",
    "username" => getenv("CRAVORA_SMTP_USERNAME") ?: "",
    "password" => getenv("CRAVORA_SMTP_PASSWORD") ?: "",
    "port" => (int)(getenv("CRAVORA_SMTP_PORT") ?: 587),
    "secure" => getenv("CRAVORA_SMTP_SECURE") ?: "tls",
    "from_email" => getenv("CRAVORA_SMTP_FROM_EMAIL") ?: "",
    "from_name" => getenv("CRAVORA_SMTP_FROM_NAME") ?: "Cravora",
];
