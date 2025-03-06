import path from 'path';
import { fileURLToPath } from 'url';
import { collection, doc, getDoc, setDoc, getDocs, orderBy, deleteDoc, where, query } from "firebase/firestore";
import { db } from "../config/database-config.js";
import { store } from "../config/firebase-config.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 단건 주문 - mysql
export const dbOrder = async (req, res) => {
    const { product_name, standard, quantity, hospital_name, call_num, email, details } = req.body;
    const date = new Date();
    const order_date = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
    const order_timestamp = date.getTime();
    const sql = "INSERT INTO orders (order_date, order_timestamp, product_name, standard, quantity, hospital_name, call_num, email, details) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    try {
        db.query(sql, [order_date, order_timestamp, product_name, standard, quantity, hospital_name, call_num, email, details], (err, result) => {
            if(err) {
                return res.status(500).json({ error: err.message });
            }
            return res.sendStatus(201);
        });
    } catch(e) {
        console.log(e.message);
    }
};

// 단건 주문 - firestore
export const storeOrder = async (req, res) => {
    const { product_name, standard, quantity, hospital_name, call_num, email, details } = req.body;
    const date = new Date();
    const order_date = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
    const order_timestamp = date.getTime();
    try {
        const orderRef = doc(collection(store, 'orders'));
        await setDoc(orderRef, {
            order_date: order_date,
            order_timestamp: order_timestamp,
            product_name: product_name,
            standard: standard,
            quantity: quantity,
            hospital_name: hospital_name,
            call_num: call_num,
            email: email,
            details: details,
            order_id: orderRef.id
        });
        return res.sendStatus(201);
    } catch(e) {
        console.log(e.message);
        return res.status(500).json({ error: e.message });
    }
}

// 위시리스트 주문 - mysql
export const dbOrderAll = async (req, res) => {
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
        const order_timestamp = date.getTime();
        const sql = "INSERT INTO orders (order_date, order_timestamp, product_name, standard, quantity, hospital_name, call_num, email, details) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            db.query(sql, [order_date, order_timestamp, product_name, standard, quantity, hospital_name, call_num, email, details], (err, result) => {
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

// 위시리스트 주문 - firestore
export const storeOrderAll = async (req, res) => {
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
        const order_timestamp = date.getTime();
        try {
            const orderRef = doc(collection(store, 'orders'));
            await setDoc(orderRef, {
                order_date: order_date,
                order_timestamp: order_timestamp,
                product_name: product_name,
                standard: standard,
                quantity: quantity,
                hospital_name: hospital_name,
                call_num: call_num,
                email: email,
                details: details,
                order_id: orderRef.id
            });
        } catch(e) {
            console.log(e.message);
            return res.status(500).json({ error: e.message });
        }
    }
    return res.sendStatus(201);
}

// utc - local
function convertToKoreanTime(utcDate) {
    const date = new Date(utcDate);
    return date.toLocaleString('ko-KR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        timeZone: 'Asia/Seoul'
     }).replace(/\. /g, '-').replace(',', '');
}

// 모든 주문 조회 - mysql
export const dbGetOrders = async (req, res) => {
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

// 모든 주문 조회 - firestore
export const storeGetOrders = async (req, res) => {
    const snapshot = await getDocs(collection(store, 'orders'), orderBy('order_timestamp', 'desc'));
    const orders = [];
    snapshot.forEach(doc => {
        orders.push({
            order_id: doc.id,
            ...doc.data()
        });
    });
    return res.status(200).json(orders);
}   

// 기간 조건 주문 조회
export const dbGetScopedOrders = async (req, res) => {
    const { startDate, endDate } = req.body;
    const sql = "SELECT * FROM orders WHERE order_date BETWEEN ? AND ? ORDER BY order_date DESC;";

    db.query(sql, [startDate, endDate], (err, result) => {
        if(err) {
            return res.status(500).json({ error: err.message });
        }

        result.forEach(order => {
            order.order_date = convertToKoreanTime(order.order_date);
        });

        if(result.length === 0) {
            return res.status(404).json({ error: '주문이 존재하지 않습니다.' });
        }
        return res.status(200).json(result);
    });
}

// 기간 조건 주문 조회 - firestore
export const storeGetScopedOrders = async (req, res) => {
    const { startDate, endDate } = req.body;
    const startDatetime = new Date(`${startDate}T00:00:00`);
    const endDatetime = new Date(`${endDate}T23:59:59`);
    const startTimestamp = new Date(startDatetime).getTime();
    const endTimestamp = new Date(endDatetime).getTime();

    try {
        const docRef = query(collection(store, 'orders'), where('order_timestamp', '<=', endTimestamp), where('order_timestamp', '>=', startTimestamp), orderBy('order_timestamp', 'desc'));
        const snapshot = await getDocs(docRef);
        const orders = [];
        snapshot.forEach(doc => {
            orders.push(doc.data());
        });
        return res.status(200).json(orders);
    } catch(e) {
        console.log(e.message);
        return res.status(500).json({ error: e.message });
    }
}

// 주문 삭제 - mysql
export const dbDeleteOrders = async (req, res) => {
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

// 주문 삭제 - firestore
export const storeDeleteOrders = async (req, res) => {
    const ids = req.body;
    ids.forEach(async id => {
        const orderRef = doc(collection(store, 'orders'), id.order_id);
        await deleteDoc(orderRef);
    });
    return res.sendStatus(200);
}
