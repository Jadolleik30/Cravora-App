<?php

function cravora_mail_log($event, $context = []) {
    if (function_exists('cravora_log')) {
        cravora_log($event, $context);
        return;
    }

    unset($context['password'], $context['verification_code'], $context['code']);
    error_log('[Cravora] ' . $event . ' ' . json_encode($context));
}

function cravora_mail_public_error() {
    if (function_exists('cravora_public_email_error')) {
        return cravora_public_email_error();
    }

    return 'Email could not be sent. Please contact support or try resend.';
}

function cravora_mail_config() {
    $configPath = __DIR__ . '/smtp_config.php';
    $config = file_exists($configPath) ? require $configPath : [];

    if (!is_array($config)) {
        $config = [];
    }

    $secure = strtolower(trim((string)($config['secure'] ?? 'tls')));
    if ($secure === 'starttls') {
        $secure = 'tls';
    }
    if (!in_array($secure, ['tls', 'ssl', 'none'], true)) {
        $secure = 'tls';
    }

    return [
        'host' => trim((string)($config['host'] ?? '')),
        'username' => trim((string)($config['username'] ?? '')),
        'password' => (string)($config['password'] ?? ''),
        'port' => (int)($config['port'] ?? 587),
        'secure' => $secure,
        'from_email' => trim((string)($config['from_email'] ?? '')),
        'from_name' => trim((string)($config['from_name'] ?? 'Cravora')),
    ];
}

function cravora_missing_mail_config($config) {
    $missing = [];

    foreach (['host', 'username', 'password', 'from_email'] as $key) {
        if (empty($config[$key])) {
            $missing[] = $key;
        }
    }

    if (empty($config['port']) || (int)$config['port'] < 1) {
        $missing[] = 'port';
    }

    return $missing;
}

function cravora_mail_error($message, $logEvent, $context = []) {
    cravora_mail_log($logEvent, $context);

    return [
        'success' => false,
        'message' => $message,
        'public_message' => cravora_mail_public_error(),
    ];
}

function cravora_header_value($value) {
    return trim(str_replace(["\r", "\n"], '', (string)$value));
}

function smtp_read($socket) {
    $data = '';

    while ($line = fgets($socket, 515)) {
        $data .= $line;
        if (isset($line[3]) && $line[3] === ' ') {
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
        return ['ok' => false, 'code' => $code, 'response' => trim($response)];
    }

    return ['ok' => true, 'code' => $code, 'response' => trim($response)];
}

function send_smtp_mail($toEmail, $subject, $htmlBody, $textBody = '') {
    $toEmail = trim((string)$toEmail);

    if (!filter_var($toEmail, FILTER_VALIDATE_EMAIL)) {
        return cravora_mail_error(
            'Invalid recipient email',
            'smtp_invalid_recipient',
            ['to_email' => $toEmail]
        );
    }

    $config = cravora_mail_config();
    $missing = cravora_missing_mail_config($config);

    if (!empty($missing)) {
        return cravora_mail_error(
            'SMTP is not configured',
            'smtp_config_missing',
            [
                'missing' => $missing,
                'host' => $config['host'],
                'port' => $config['port'],
                'secure' => $config['secure'],
                'from_email' => $config['from_email'],
            ]
        );
    }

    if (!filter_var($config['from_email'], FILTER_VALIDATE_EMAIL)) {
        return cravora_mail_error(
            'SMTP from email is invalid',
            'smtp_invalid_from_email',
            ['from_email' => $config['from_email']]
        );
    }

    $host = $config['host'];
    $port = (int)$config['port'];
    $secure = $config['secure'];
    $socketHost = $secure === 'ssl' ? 'ssl://' . $host : $host;

    $socket = @fsockopen($socketHost, $port, $errno, $errstr, 20);
    if (!$socket) {
        return cravora_mail_error(
            'Could not connect to SMTP server',
            'smtp_connection_failed',
            [
                'host' => $host,
                'port' => $port,
                'secure' => $secure,
                'error_number' => $errno,
                'error' => $errstr,
            ]
        );
    }

    stream_set_timeout($socket, 20);
    $welcome = smtp_read($socket);
    if ((int)substr($welcome, 0, 3) !== 220) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP server rejected connection',
            'smtp_welcome_rejected',
            ['host' => $host, 'port' => $port, 'response' => trim($welcome)]
        );
    }

    $serverName = preg_replace('/[^A-Za-z0-9.-]/', '', $_SERVER['SERVER_NAME'] ?? 'localhost');
    if ($serverName === '') {
        $serverName = 'localhost';
    }

    $result = smtp_command($socket, 'EHLO ' . $serverName, [250]);
    if (!$result['ok']) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP EHLO failed',
            'smtp_ehlo_failed',
            ['host' => $host, 'port' => $port, 'response' => $result['response']]
        );
    }

    if ($secure === 'tls') {
        $result = smtp_command($socket, 'STARTTLS', [220]);
        $cryptoEnabled = $result['ok']
            && stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);

        if (!$cryptoEnabled) {
            fclose($socket);
            return cravora_mail_error(
                'SMTP TLS failed',
                'smtp_tls_failed',
                ['host' => $host, 'port' => $port, 'response' => $result['response']]
            );
        }

        $result = smtp_command($socket, 'EHLO ' . $serverName, [250]);
        if (!$result['ok']) {
            fclose($socket);
            return cravora_mail_error(
                'SMTP EHLO after TLS failed',
                'smtp_ehlo_after_tls_failed',
                ['host' => $host, 'port' => $port, 'response' => $result['response']]
            );
        }
    }

    $result = smtp_command($socket, 'AUTH LOGIN', [334]);
    if (!$result['ok']) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP authentication failed',
            'smtp_auth_failed',
            ['host' => $host, 'port' => $port, 'response' => $result['response']]
        );
    }

    $result = smtp_command($socket, base64_encode($config['username']), [334]);
    if (!$result['ok']) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP username rejected',
            'smtp_username_rejected',
            ['host' => $host, 'port' => $port, 'response' => $result['response']]
        );
    }

    $result = smtp_command($socket, base64_encode($config['password']), [235]);
    if (!$result['ok']) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP password rejected',
            'smtp_password_rejected',
            ['host' => $host, 'port' => $port, 'response' => $result['response']]
        );
    }

    $fromEmail = $config['from_email'];
    $fromName = cravora_header_value($config['from_name'] ?: 'Cravora');
    $subject = cravora_header_value($subject);
    $messageIdHost = preg_replace('/[^A-Za-z0-9.-]/', '', explode('@', $fromEmail)[1] ?? 'localhost');
    $messageId = bin2hex(random_bytes(12)) . '@' . ($messageIdHost ?: 'localhost');

    $headers = [
        'Date: ' . date(DATE_RFC2822),
        'From: ' . $fromName . ' <' . $fromEmail . '>',
        'To: <' . $toEmail . '>',
        'Subject: ' . $subject,
        'Message-ID: <' . $messageId . '>',
        'MIME-Version: 1.0',
        'Content-Type: text/html; charset=UTF-8',
        'Content-Transfer-Encoding: 8bit',
    ];

    $message = implode("\r\n", $headers) . "\r\n\r\n" . $htmlBody;
    $message = str_replace("\n.", "\n..", $message);

    $result = smtp_command($socket, 'MAIL FROM:<' . $fromEmail . '>', [250]);
    if (!$result['ok']) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP sender rejected',
            'smtp_sender_rejected',
            ['from_email' => $fromEmail, 'response' => $result['response']]
        );
    }

    $result = smtp_command($socket, 'RCPT TO:<' . $toEmail . '>', [250, 251]);
    if (!$result['ok']) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP recipient rejected',
            'smtp_recipient_rejected',
            ['to_email' => $toEmail, 'response' => $result['response']]
        );
    }

    $result = smtp_command($socket, 'DATA', [354]);
    if (!$result['ok']) {
        fclose($socket);
        return cravora_mail_error(
            'SMTP data command failed',
            'smtp_data_failed',
            ['response' => $result['response']]
        );
    }

    $result = smtp_command($socket, $message . "\r\n.", [250]);
    smtp_command($socket, 'QUIT', [221, 250]);
    fclose($socket);

    if (!$result['ok']) {
        return cravora_mail_error(
            'SMTP send failed',
            'smtp_send_failed',
            ['to_email' => $toEmail, 'response' => $result['response']]
        );
    }

    cravora_mail_log('verification_email_sent', ['to_email' => $toEmail]);

    return [
        'success' => true,
        'message' => 'Email sent',
        'public_message' => 'Email sent',
    ];
}

function send_verification_email($toEmail, $code) {
    $safeCode = htmlspecialchars((string)$code, ENT_QUOTES, 'UTF-8');
    $html = "
        <h2>Welcome to Cravora</h2>
        <p>Your email verification code is:</p>
        <h1 style='letter-spacing:4px;'>$safeCode</h1>
        <p>Enter this code in the Cravora app to verify your account.</p>
        <p>If you did not create a Cravora account, you can ignore this email.</p>
    ";

    return send_smtp_mail($toEmail, 'Your Cravora verification code', $html);
}
