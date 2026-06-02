USE `jad_olleik`;

SET @schema_name = DATABASE();

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `users` ADD COLUMN `verification_code` VARCHAR(6) DEFAULT NULL',
        'SELECT ''verification_code already exists'' AS message'
    )
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'users'
      AND COLUMN_NAME = 'verification_code'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `users` ADD COLUMN `is_verified` TINYINT(1) DEFAULT 1',
        'SELECT ''is_verified already exists'' AS message'
    )
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'users'
      AND COLUMN_NAME = 'is_verified'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
    SELECT IF(
        COUNT(*) = 0,
        'ALTER TABLE `users` ADD COLUMN `profile_completed` TINYINT(1) DEFAULT 0',
        'SELECT ''profile_completed already exists'' AS message'
    )
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'users'
      AND COLUMN_NAME = 'profile_completed'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `users`
SET `is_verified` = 1
WHERE `is_verified` IS NULL;

ALTER TABLE `users`
  MODIFY COLUMN `verification_code` VARCHAR(6) DEFAULT NULL,
  MODIFY COLUMN `is_verified` TINYINT(1) NOT NULL DEFAULT 0,
  MODIFY COLUMN `profile_completed` TINYINT(1) NOT NULL DEFAULT 0;

UPDATE `users`
SET `profile_completed` = 1
WHERE `role` = 'admin'
   OR (
        `name` IS NOT NULL AND `name` <> ''
        AND `phone` IS NOT NULL AND `phone` <> ''
        AND `address` IS NOT NULL AND `address` <> ''
        AND `gender` IS NOT NULL AND `gender` <> ''
   );
