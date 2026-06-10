-- =======================================================
-- AI Powered Object Detection System Database Schema
-- Database Name: ai_detection_db
-- Compatibility: MySQL 5.7+ / 8.0+
-- =======================================================

CREATE DATABASE IF NOT EXISTS ai_detection_db;
USE ai_detection_db;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mobile_number VARCHAR(15) NOT NULL,
    password VARCHAR(64) NOT NULL, -- SHA-256 hash (64 characters)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Admins Table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL, -- SHA-256 hash (64 characters)
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Detections Table
CREATE TABLE IF NOT EXISTS detections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    detection_type VARCHAR(20) NOT NULL, -- 'Image' or 'Video'
    description TEXT,
    confidence_threshold DOUBLE DEFAULT 0.5,
    status VARCHAR(20) DEFAULT 'Pending', -- 'Pending', 'Processing', 'Completed', 'Failed'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Detection Results Table
CREATE TABLE IF NOT EXISTS detection_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    detection_id INT NOT NULL,
    object_name VARCHAR(50) NOT NULL,
    confidence_score DOUBLE NOT NULL,
    box_x INT NOT NULL,
    box_y INT NOT NULL,
    box_width INT NOT NULL,
    box_height INT NOT NULL,
    FOREIGN KEY (detection_id) REFERENCES detections(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =======================================================
-- Seeding Initial Data
-- =======================================================

-- Admin account: admin / admin123
-- SHA-256 for 'admin123' is 240753e83949beb2c14587e7e12cf83e4d861c9c5c1a9b02b2809aef23d607e1 (hex)
INSERT INTO admins (username, password, full_name) 
VALUES ('admin', '240753e83949beb2c14587e7e12cf83e4d861c9c5c1a9b02b2809aef23d607e1', 'System Administrator')
ON DUPLICATE KEY UPDATE username=username;

