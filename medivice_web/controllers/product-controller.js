import path from 'path';
import { fileURLToPath } from 'url';
import { db } from "../public/config/database-config.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 단건 주문
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


// 위시리스트 주문
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

// utc - local
function convertToKoreanTime(utcDate) {
    const date = new Date(utcDate);
    console.log(`dates: ${utcDate}, ${date}`);
    return date.toLocaleString('ko-KR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        timeZone: 'Asia/Seoul'
     }).replace(/\. /g, '-').replace(',', '');
}

// 모든 주문 조회
export const getAllOrders = async (req, res) => {
    const sql = "SELECT * FROM orders ORDER BY order_date DESC;";
    try {
        db.query(sql, (err, result) => {
            if(err) {
                return res.status(500).json({ error: err.message });
            }

            result.forEach(order => {
                order.order_date = convertToKoreanTime(order.order_date);
            });

            console.log(result);
            return res.json(result);
        });
    } catch(e) {
        console.log(e.message);
    }
}

// 기간 조건 주문 조회
export const getScopedOrders = async (req, res) => {
    const { startDate, endDate } = req.body;
    const sql = "SELECT * FROM orders WHERE order_date BETWEEN ? AND ? ORDER BY order_date DESC;";

    db.query(sql, [startDate, endDate], (err, result) => {
        if(err) {
            return res.status(500).json({ error: err.message });
        }

        result.forEach(order => {
            order.order_date = convertToKoreanTime(order.order_date);
        });

        console.log(result);

        if(result.length === 0) {
            return res.status(404).json({ error: '주문이 존재하지 않습니다.' });
        }
        return res.status(200).json(result);
    });
}

// 주문 삭제
export const deleteOrders = async (req, res) => {
    const ids = req.body;

    ids.forEach(id => {
        const sql = "DELETE FROM orders WHERE order_id = ?";
        try {
            db.query(sql, [id.order_id], (err, result) => {
                if(err) {
                    return res.status(500).json({ error: err.message });
                }
            });
        } catch(e) {
            return res.status(500).json({ error: e.message });
        }
    });

    return res.sendStatus(200);

}
