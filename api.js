// api.js - Database API integration
const API_BASE_URL = 'https://your-neon-connection.vercel.app/api'; // Replace with your actual API URL

class JollibeeAPI {
    // Customer endpoints
    static async registerCustomer(customerData) {
        const response = await fetch(`${API_BASE_URL}/customers/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(customerData)
        });
        return await response.json();
    }

    static async loginCustomer(email, password) {
        const response = await fetch(`${API_BASE_URL}/customers/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });
        return await response.json();
    }

    // Staff endpoints
    static async loginStaff(username, password, role) {
        const response = await fetch(`${API_BASE_URL}/staff/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password, role })
        });
        return await response.json();
    }

    static async createStaffUser(userData, adminToken) {
        const response = await fetch(`${API_BASE_URL}/staff/users`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${adminToken}`
            },
            body: JSON.stringify(userData)
        });
        return await response.json();
    }

    // Menu endpoints
    static async getMenuItems() {
        const response = await fetch(`${API_BASE_URL}/menu/items`);
        return await response.json();
    }

    static async createMenuItem(itemData, adminToken) {
        const response = await fetch(`${API_BASE_URL}/menu/items`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${adminToken}`
            },
            body: JSON.stringify(itemData)
        });
        return await response.json();
    }

    // Order endpoints
    static async createOrder(orderData, customerToken) {
        const response = await fetch(`${API_BASE_URL}/orders`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${customerToken}`
            },
            body: JSON.stringify(orderData)
        });
        return await response.json();
    }

    static async getCustomerOrders(customerToken) {
        const response = await fetch(`${API_BASE_URL}/orders/my-orders`, {
            headers: { 'Authorization': `Bearer ${customerToken}` }
        });
        return await response.json();
    }

    static async getAllOrders(staffToken) {
        const response = await fetch(`${API_BASE_URL}/orders`, {
            headers: { 'Authorization': `Bearer ${staffToken}` }
        });
        return await response.json();
    }

    static async updateOrderStatus(orderId, status, staffToken) {
        const response = await fetch(`${API_BASE_URL}/orders/${orderId}/status`, {
            method: 'PATCH',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${staffToken}`
            },
            body: JSON.stringify({ status })
        });
        return await response.json();
    }
}

// Local storage fallback functions
class LocalStorageManager {
    static initializeData() {
        if (!localStorage.getItem('customerUsers')) {
            const defaultCustomers = [{
                id: 1,
                name: 'Demo Customer',
                email: 'customer@jollibee.com',
                phone: '+1234567890',
                password: 'pass123',
                role: 'customer',
                createdAt: new Date().toISOString()
            }];
            localStorage.setItem('customerUsers', JSON.stringify(defaultCustomers));
        }

        if (!localStorage.getItem('staffUsers')) {
            const defaultStaff = [
                {
                    id: 1,
                    username: 'staff1',
                    password: 'pass123',
                    role: 'staff',
                    name: 'Staff Member',
                    createdAt: new Date().toISOString()
                },
                {
                    id: 2,
                    username: 'admin',
                    password: 'admin123',
                    role: 'admin',
                    name: 'System Administrator',
                    createdAt: new Date().toISOString()
                }
            ];
            localStorage.setItem('staffUsers', JSON.stringify(defaultStaff));
        }

        if (!localStorage.getItem('jollibeeMenu')) {
            const defaultMenu = [
                { id: 1, name: "1-pc Chickenjoy w/ Rice", price: 82, img: "https://images.unsplash.com/photo-1562967914-608f82629710?w=200&h=200&fit=crop" },
                { id: 2, name: "2-pc Burger Steak", price: 105, img: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&h=200&fit=crop" },
                { id: 3, name: "Jolly Spaghetti", price: 65, img: "https://images.unsplash.com/photo-1598866594230-a7c12756260f?w=200&h=200&fit=crop" },
                { id: 4, name: "Yumburger", price: 45, img: "https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=200&h=200&fit=crop" },
                { id: 5, name: "Jolly Hotdog", price: 60, img: "https://images.unsplash.com/photo-1550317138-10000687a9ef?w=200&h=200&fit=crop" },
                { id: 6, name: "Jolly Fries", price: 55, img: "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=200&h=200&fit=crop" },
                { id: 7, name: "Pineapple Juice", price: 45, img: "https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200&h=200&fit=crop" },
                { id: 8, name: "Peach Mango Pie", price: 39, img: "https://images.unsplash.com/photo-1603532648955-039310d9ed75?w=200&h=200&fit=crop" }
            ];
            localStorage.setItem('jollibeeMenu', JSON.stringify(defaultMenu));
        }
    }
}