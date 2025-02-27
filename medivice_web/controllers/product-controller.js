import path from 'path';
import { fileURLToPath } from 'url';
import { db } from "../public/config/database-config.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const order = async (req, res) => {
    const { product_name, standard, quantity, hospital_name, call_num, email, details } = req.body;
    const date = new Date();
    const order_date = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
    const sql = "INSERT INTO orders (order_date, product_name, standard, quantity, hospital_name, call_num, email, details) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    try {
        db.query(sql, [order_date, product_name, standard, quantity, hospital_name, call_num, email, details], (err, result) => {
            if(err) {
                return res.status(500).json({ error: err.message });
            }
            return res.sendStatus(201);
        });
    } catch(e) {
        console.log(e.message);
    }
};

export const orderAll = async (req, res) => {
    var cart = req.body;
    for(var product in cart) {
        const product_name = cart[product].prodName;
        const standard = cart[product].standard;
        const quantity = cart[product].quantity;
        const hospital_name = cart[product].hospName;
        const call_num = cart[product].call;
        const email = cart[product].email;
        const details = cart[product].details;
        const date = new Date();
        const order_date = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
        
        const sql = "INSERT INTO orders (order_date, product_name, standard, quantity, hospital_name, call_num, email, details) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            db.query(sql, [order_date, product_name, standard, quantity, hospital_name, call_num, email, details], (err, result) => {
                if(err) {
                    return res.status(500).json({ error: err.message });
                }
            });
        } catch(e) {
            console.log(e.message);
        }
    }
    return res.sendStatus(201);
};

export const getAllOrders = async (req, res) => {
    const sql = "SELECT * FROM orders ORDER BY order_date DESC;";
    try {
        db.query(sql, (err, result) => {
            if(err) {
                return res.status(500).json({ error: err.message });
            }
            console.log(result);
            return res.json(result);
        });
    } catch(e) {
        console.log(e.message);
    }
}

