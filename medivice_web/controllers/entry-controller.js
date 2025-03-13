import path from 'path';
import { fileURLToPath } from 'url';
// import { db } from "../config/database-config.js";
import { collection, doc, getDoc } from "firebase/firestore";
import { store } from "../config/firebase-config.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// entry 키 검증 - mysql
// export const dbValidateKey = async (req, res) => {
//     const { key } = req.body;
//     const entry_name = 'orders';
//     const sql = "SELECT * FROM entryKeys WHERE entry_name = ?;";
    
//     db.query(sql, [entry_name], (err, result) => {
//         if(err) {
//             return res.status(500).json({ error: err.message });
//         }
//         if(result[0].entry_key === key) {
//             return res.sendStatus(200);
//         } else {
//             return res.sendStatus(401);
//         }
//     });
// }

// entry 키 검증 - firestore
export const storeValidateKey = async (req, res) => {
    const { key } = req.body;
    const entry_name = 'orders';
    const entryRef = doc(collection(store, 'entryKeys'), entry_name);
    const snapshot = await getDoc(entryRef);

    if(!snapshot.exists) {
        return res.sendStatus(404);
    }
    if(snapshot.data().key === key) {
        return res.redirect(`/manage/order-management.html?key=${key}`);
    }
    return res.sendStatus(401);
}

// query key 검증
export const storeQueryKey = async (req, res) => {
    const { key } = req.body;
    const entry_name = 'orders';
    const entryRef = doc(collection(store, 'entryKeys'), entry_name);
    const snapshot = await getDoc(entryRef);

    if(!snapshot.exists) {
        return res.sendStatus(404);
    }
    if(snapshot.data().key === key) {
        return res.sendStatus(200);
    }
    return res.sendStatus(401);
}
