import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import { db, auth } from "./firebase-config.js";
import { collection, addDoc, getDocs } from "firebase/firestore";
import { createUserWithEmailAndPassword } from "firebase/auth";

const app = express();
const PORT = 3000;

// middleware
app.use(express.json());
app.use(cors());
app.use(bodyParser.json());
app.use(express.static("public"));

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

// sign in & sign up with eamil/password
app.post("/signinsignup", async (req, res) => {
    const { email, password } = req.body;
    console.log(`${email} and ${password} is arrived to server.`);
    
    await createUserWithEmailAndPassword(auth, email, password)
    .then((userCredential) => {
            const user = userCredential.user;
            res.status(200).send({
                message: "User account successfully created.",
                uid: user.uid,
            });
    })
    .catch((e) => {
        res.status(400).send({error: e.code});
    });
});

// server excute
app.listen(PORT, () => {
    console.log(`server is running on http://localhost:${PORT}`);
});

