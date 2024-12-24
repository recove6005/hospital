import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import { db, auth } from "./firebase-config.js";
import { collection, addDoc, getDocs } from "firebase/firestore";

import homeRouter from './routes/home-routers.js'
import loginRouter from './routes/login-routers.js'

const app = express();
const PORT = 3000;

// middleware
app.use(express.json());
app.use(cors());
app.use(bodyParser.json());

// 정적 파일 제공
app.use(express.static('public'));

// 라우터 등록
app.use('/', homeRouter);
app.use('/login', loginRouter);

// route : add data
app.post("/add", async (req, res) => {
    try {
        const { name } = req.body;
        const docRef = await addDoc(collection(db, "users"), {name});
        res.status(201).send({id:docRef.id});
    } catch(e) {
        res.status(500).send({error: e.message});
    }
});
// route : read data
app.get("/read", async (req, res) => {
    try {
        const querySnapshot = await getDocs(collection(db, "users"));
        const data = querySnapshot.docs.map((doc) => doc.data());
        res.status(200).json(data);
    } catch(e) {
        res.status(500).send({error: e.message});
    }
});

// server excute
app.listen(PORT, () => {
    console.log(`server is running on http://localhost:${PORT}`);
});