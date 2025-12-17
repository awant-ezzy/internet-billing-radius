-- Database: billing_radius
USE billing_radius;

-- Table users (admin)
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('admin', 'operator') DEFAULT 'operator',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table packages (paket internet)
CREATE TABLE IF NOT EXISTS packages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    speed_up INT NOT NULL, -- in Mbps
    speed_down INT NOT NULL, -- in Mbps
    price DECIMAL(10,2) NOT NULL,
    quota_limit BIGINT DEFAULT NULL, -- in bytes, NULL for unlimited
    validity_days INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table customers
CREATE TABLE IF NOT EXISTS customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    package_id INT NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL, -- for RADIUS auth
    password VARCHAR(50) NOT NULL, -- for RADIUS auth
    ip_address VARCHAR(15),
    mac_address VARCHAR(17),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    registration_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    last_payment_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (package_id) REFERENCES packages(id) ON DELETE RESTRICT
);

-- Table payments
CREATE TABLE IF NOT EXISTS payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('cash', 'transfer', 'qris') DEFAULT 'cash',
    period_month TINYINT NOT NULL,
    period_year YEAR NOT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

-- Table radius_logs (sinkronisasi dengan radius)
CREATE TABLE IF NOT EXISTS radius_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    username VARCHAR(50) NOT NULL,
    bytes_in BIGINT DEFAULT 0,
    bytes_out BIGINT DEFAULT 0,
    session_time INT DEFAULT 0,
    session_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username_session (username, session_date)
);

-- Table system_settings
CREATE TABLE IF NOT EXISTS system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(50) UNIQUE NOT NULL,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default admin user (password: Admin123!)
INSERT INTO users (username, password, full_name, email, role) 
VALUES (
    'admin', 
    '$2a$12$YourHashedPasswordHere', -- Replace with actual bcrypt hash
    'Administrator', 
    'admin@billing.local', 
    'admin'
);

-- Insert default packages
INSERT INTO packages (name, speed_up, speed_down, price, validity_days) VALUES
('Basic 10Mbps', 10, 10, 150000, 30),
('Standard 20Mbps', 20, 20, 250000, 30),
('Premium 50Mbps', 50, 50, 350000, 30),
('Business 100Mbps', 100, 100, 500000, 30);

-- Insert system settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('company_name', 'PT Internet Billing', 'Nama perusahaan'),
('currency', 'IDR', 'Mata uang'),
('tax_rate', '10', 'Persentase pajak'),
('due_date_days', '7', 'Jumlah hari jatuh tempo');