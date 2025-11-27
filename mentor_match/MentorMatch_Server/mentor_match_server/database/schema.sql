-- Schema và bảng cho MentorMatch
-- Chạy file này trong PostgreSQL để tạo database structure

-- Tạo schema nếu chưa tồn tại
CREATE SCHEMA IF NOT EXISTS mentor_match;

-- Set search_path để sử dụng schema mentor_match
SET search_path TO mentor_match;

-- Bảng Users
CREATE TABLE IF NOT EXISTS mentor_match.Users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('student', 'tutor')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Wallets
CREATE TABLE IF NOT EXISTS mentor_match.Wallets (
    wallet_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES mentor_match.Users(user_id) ON DELETE CASCADE,
    balance DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng TutorProfiles
CREATE TABLE IF NOT EXISTS mentor_match.TutorProfiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES mentor_match.Users(user_id) ON DELETE CASCADE,
    bio TEXT,
    price_per_hour DECIMAL(10, 2),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tạo indexes để tối ưu performance
CREATE INDEX IF NOT EXISTS idx_users_email ON mentor_match.Users(email);
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON mentor_match.Wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_tutor_profiles_user_id ON mentor_match.TutorProfiles(user_id);

