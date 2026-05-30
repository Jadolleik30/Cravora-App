<?php

function cravora_mail_config() {
    $configPath = __DIR__ . '/smtp_config.php';
    $config = file_exists($configPath) ? require $configPath : [];

    return [
        "host" => $config["host"] ?? "",
        "username" => $config["username"] ?? "",
        "password" => $config["password"] ?? "",
        "port" => (int)($config["port"] ?? 587),
        "secure" => strtolower($config["secure"] ?? "tls"),
        "from_email" => $config["from_email"] ?? "",
        "from_name" => $config["from_name"] ?? "Cravora",
    ];
}

function smtp_read($socket) {
    $data = "";
    while ($line = fgets($socket, 515)) {
        $data .= $line;
        if (isset($line[3]) && $line[3] === " ") {
            break;
        }
    }
    return $data;
}

function smtp_command($socket, $command, $expectedCodes) {
    fwrite($socket, $command . "\r\n");
    $response = smtp_read($socket);
    $code = (int)substr($response, 0, 3);

    if (!in_array($code, $expectedCodes, true)) {
        return ["ok" => false, "response" => trim($response)];
    }

    return ["ok" => true, "response" => trim($response)];
}

function send_smtp_mail($toEmail, $subject, $htmlBody, $textBody = "") {
    $config = cravora_mail_config();

    if (
        empty($config["host"]) ||
        empty($config["username"]) ||
        empty($config["password"]) ||
        empty($config["from_email"])
    ) {
        return ["success" => false, "message" => "SMTP is not configured"];
    }

    $host = $config["host"];
    $port = $config["port"];
    $secure = $config["secure"];
    $socketHost = $secure === "ssl" ? "ssl://" . $host : $host;

    $socket = @fsockopen($socketHost, $port, $errno, $errstr, 20);
    if (!$socket) {
        return ["success" => false, "message" => "Could not connect to SMTP server"];
    }

    stream_set_timeout($socket, 20);
    $welcome = smtp_read($socket);
    if ((int)substr($welcome, 0, 3) !== 220) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP server rejected connection"];
    }

    $serverName = $_SERVER['SERVER_NAME'] ?? 'localhost';
    $result = smtp_command($socket, "EHLO " . $serverName, [250]);
    if (!$result["ok"]) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP EHLO failed"];
    }

    if ($secure === "tls") {
        $result = smtp_command($socket, "STARTTLS", [220]);
        if (!$result["ok"] || !stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
            fclose($socket);
            return ["success" => false, "message" => "SMTP TLS failed"];
        }

        $result = smtp_command($socket, "EHLO " . $serverName, [250]);
        if (!$result["ok"]) {
            fclose($socket);
            return ["success" => false, "message" => "SMTP EHLO after TLS failed"];
        }
    }

    $result = smtp_command($socket, "AUTH LOGIN", [334]);
    if (!$result["ok"]) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP authentication failed"];
    }

    $result = smtp_command($socket, base64_encode($config["username"]), [334]);
    if (!$result["ok"]) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP username rejected"];
    }

    $result = smtp_command($socket, base64_encode($config["password"]), [235]);
    if (!$result["ok"]) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP password rejected"];
    }

    $fromEmail = $config["from_email"];
    $fromName = $config["from_name"];
    $headers = [
        "From: " . $fromName . " <" . $fromEmail . ">",
        "To: <" . $toEmail . ">",
        "Subject: " . $subject,
        "MIME-Version: 1.0",
        "Content-Type: text/html; charset=UTF-8",
    ];

    $message = implode("\r\n", $headers) . "\r\n\r\n" . $htmlBody;
    $message = str_replace("\n.", "\n..", $message);

    $result = smtp_command($socket, "MAIL FROM:<" . $fromEmail . ">", [250]);
    if (!$result["ok"]) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP sender rejected"];
    }

    $result = smtp_command($socket, "RCPT TO:<" . $toEmail . ">", [250, 251]);
    if (!$result["ok"]) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP recipient rejected"];
    }

    $result = smtp_command($socket, "DATA", [354]);
    if (!$result["ok"]) {
        fclose($socket);
        return ["success" => false, "message" => "SMTP data command failed"];
    }

    $result = smtp_command($socket, $message . "\r\n.", [250]);
    smtp_command($socket, "QUIT", [221, 250]);
    fclose($socket);

    if (!$result["ok"]) {
        return ["success" => false, "message" => "SMTP send failed"];
    }

    return ["success" => true, "message" => "Email sent"];
}

function send_verification_email($toEmail, $code) {
    $safeCode = htmlspecialchars($code, ENT_QUOTES, "UTF-8");
    $html = "
        <h2>Welcome to Cravora</h2>
        <p>Your email verification code is:</p>
        <h1 style='letter-spacing:4px;'>$safeCode</h1>
        <p>Enter this code in the Cravora app to verify your account.</p>
    ";

    return send_smtp_mail($toEmail, "Your Cravora verification code", $html);
}
