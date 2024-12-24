import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

import { db, auth } from "../firebase-config.js";
import { createUserWithEmailAndPassword } from "firebase/auth";

const router = express.Router();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// /login/email
router.get('/email', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/html/login-email.html'));
});

// /login/password
router.get('/password', (req, res) => {
    const email = req.query.email;
    res.sendFile(path.join(__dirname, '../public/html/login-password.html'));
});

router.post('/login', async (req, res) => {
    const { email, password } = req.body;
    console.log(`email: ${email}, password: ${password}`);
    
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

export default router;