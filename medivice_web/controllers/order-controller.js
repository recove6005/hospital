import path from 'path';
import { fileURLToPath } from 'url';
import { collection, doc, getDoc, setDoc, getDocs, orderBy, deleteDoc, where, query } from "firebase/firestore";
import { store } from "../config/firebase-config.js";
import nodemailer from 'nodemailer';
import { prodNameExchange } from './constants.js';    
import { googleEmail, googlePassword } from './keys.js';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 주문, 주문서 발송
export const order = async (req, res) => {
    const { products, hospName, call, email, address, price } = req.body;
    const date = new Date();
    const order_date = date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
    const order_timestamp = date.getTime(order_date);
    var order_id = '';

    try {
        const orderRef = doc(collection(store, 'orders'));
        order_id = orderRef.id;
        const orderBackupRef = doc(collection(store, 'orders-backup'));
        await setDoc(orderRef, {
            products: products,
            order_date: order_date,
            order_timestamp: order_timestamp,
            hospital_name: hospName,
            call: call,
            email: email,
            address: address,
            order_id: order_id,
            price: price
        });

        await setDoc(orderBackupRef, {
            products: products,
            order_date: order_date,
            order_timestamp: order_timestamp,
            hospital_name: hospName,
            call: call,
            email: email,
            address: address,
            order_id: order_id,
            price: price
        })

        sendOrderMail(products, email, order_id, price);

        return res.redirect(`/order/ref-result.html?order_id=${order_id}&email=${email}&products=${JSON.stringify(products)}&hospName=${hospName}&call=${call}&address=${address}`);
    } catch(e) {
        console.log(e.message);
        return res.status(500).json({ error: e.message });
    }
}

// 주문서 메일 발송
const sendOrderMail = async (products, email, order_id, price) => {
// 메일 전송
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: googleEmail,
        pass: googlePassword
    }
});

const mailOptions = {
    from: googleEmail,
    to: email,
    subject: '[MEDIVICE] 주문서',
    text: `
        주문 번호: ${order_id}
        
        주문 제품
        ${
            products.map((product) => {
                return `
                    제품명: ${prodNameExchange(product.prodName)}
                    규격: ${product.standard}
                    수량: ${product.quantity}
                `
            }).join('\n')
        }
        
        주문 금액: ${price} 원
    `,
};

transporter.sendMail(mailOptions, (err, info) => {
    if(err) {
        console.log(err);
    } else {
        console.log('Email sent: ' + info.response);
    }
});
}

// 모든 주문 조회 - firestore
export const storeGetOrders = async (req, res) => {
    try {
        const snapshot = await getDocs(collection(store, 'orders'), orderBy('order_timestamp', 'asc'));
        const orders = [];
        snapshot.forEach(doc => {
            orders.push({
                order_id: doc.id,
                ...doc.data()
            });
        });
        return res.status(200).json(orders);
    } catch(e) {
        console.log(e.message);
        return res.status(500).json({ error: e.message });
    }
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

// 주문 삭제 - firestore
export const storeDeleteOrders = async (req, res) => {
    const ids = req.body;
    ids.forEach(async id => {
        const orderRef = doc(collection(store, 'orders'), id.order_id);
        await deleteDoc(orderRef);
    });
    return res.sendStatus(200);
}

// 주문 조회 - firestore
export const storeOrderRef = async (req, res) => {
    const { order_id, email } = req.body;
    const orderRef = query(collection(store, 'orders'), where('order_id', '==', order_id), where('email', '==', email));
    const snapshot = await getDocs(orderRef);
    if(snapshot.empty) {
        return res.status(404).json({ error: '해당 주문 내역을 찾을 수 없습니다. 주문번호와 이메일을 확인해 주세요.' });
    }

    const orderData = snapshot.docs[0].data();
    return res.redirect(`/order/ref-result.html?order_id=${order_id}&email=${email}&products=${JSON.stringify(orderData.products)}&hospName=${orderData.hospital_name}&call=${orderData.call}&address=${orderData.address}`);
}