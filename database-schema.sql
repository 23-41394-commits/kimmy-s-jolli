-- Enhanced Database Schema for Jollibee Order System

-- Users table (for customers - registered via customer login)
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff/Admin users table (created by admin only)
CREATE TABLE IF NOT EXISTS staff_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('staff', 'admin')),
    created_by INTEGER REFERENCES staff_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Menu items table
CREATE TABLE IF NOT EXISTS menu_items (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    category VARCHAR(50),
    is_available BOOLEAN DEFAULT TRUE,
    created_by INTEGER REFERENCES staff_users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'Preparing' CHECK (status IN ('Preparing', 'Out for Delivery', 'Delivered', 'Cancelled')),
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed')),
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id INTEGER REFERENCES menu_items(id),
    item_name VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);

-- Order status history table
CREATE TABLE IF NOT EXISTS order_status_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    updated_by INTEGER REFERENCES staff_users(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default admin user (created first)
INSERT INTO staff_users (username, password, name, role, created_by) VALUES 
('admin', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: admin123
 'System Administrator', 'admin', 1);

-- Insert default staff user
INSERT INTO staff_users (username, password, name, role, created_by) VALUES 
('staff1', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: pass123
 'Staff Member', 'staff', 1);

-- Insert sample menu items
INSERT INTO menu_items (name, description, price, image_url, category, created_by) VALUES 
('1-pc Chickenjoy w/ Rice', 'Crispy fried chicken served with steamed rice', 82, 'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&h=200&fit=crop', 'Chicken', 1),
('2-pc Burger Steak', 'Two juicy burger patties with mushroom gravy', 105, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&h=200&fit=crop', 'Burgers', 1),
('Jolly Spaghetti', 'Sweet style spaghetti with hotdog and cheese', 65, 'https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=200&h=200&fit=crop', 'Pasta', 1),
('Yumburger', 'Classic Jollibee burger with special dressing', 45, 'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=200&h=200&fit=crop', 'Burgers', 1),
('Jolly Hotdog', 'Classic hotdog in a soft bun', 60, 'https://images.unsplash.com/photo-1550317138-10000687a9ef?w=200&h=200&fit=crop', 'Hotdogs', 1),
('Jolly Fries', 'Crispy golden fries', 55, 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=200&h=200&fit=crop', 'Sides', 1),
('Pineapple Juice', 'Refreshing pineapple juice', 45, 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200&h=200&fit=crop', 'Beverages', 1),
('Peach Mango Pie', 'Sweet peach and mango filling in flaky crust', 39, 'https://images.unsplash.com/photo-1603532648955-039310d9ed75?w=200&h=200&fit=crop', 'Desserts', 1);

-- Insert sample customer
INSERT INTO customers (name, email, phone, password) VALUES 
('Demo Customer', 'customer@jollibee.com', '+1234567890', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'); -- password: pass123

-- Create indexes for better performance
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_menu_items_category ON menu_items(category);
CREATE INDEX idx_customers_email ON customers(email);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_staff_users_updated_at BEFORE UPDATE ON staff_users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON menu_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();