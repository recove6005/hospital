import path from 'path';
import { fileURLToPath } from 'url';
import { db } from "../public/firebase-config.js";
import { collection, addDoc, getDocs } from "firebase/firestore";

// __dirname 설정
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getHomePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../public/html/index.html'));
};

export const addUser = async (req, res) => {
    try {
        const { name } = req.body;
        const docRef = await addDoc(collection(db, "users"), { name });
        res.status(201).send({ id: docRef.id });
    } catch(e) {
        res.status(500).json({ error: e.message });
    }
};

export const readUsers = async (req, res) => {
    try {
        const querySnapshot = await getDocs(collection(db, "users"));
        const data = querySnapshot.docs.map((doc) => doc.data());
        res.status(200).json(data);
    } catch(e) {
        res.status(500).send({ error: e.message });
    }
};