SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS `scudb` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `status` (
	`Id` bigint(20) NOT NULL AUTO_INCREMENT,
	`Game` text CHARACTER SET utf8mb4,
	`Status` bigint(20),
	`Timestamp` bigint(20),
	`FingerprintSha` text CHARACTER SET utf8mb4,
	`FingerprintVersion` text CHARACTER SET utf8mb4,
	PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `fingerprint` (
	`Id` bigint(20) NOT NULL AUTO_INCREMENT,
	`Game` text CHARACTER SET utf8mb4,
	`Sha` text CHARACTER SET utf8mb4,
	`Version` text CHARACTER SET utf8mb4,
	`Timestamp` bigint(20),
	PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;