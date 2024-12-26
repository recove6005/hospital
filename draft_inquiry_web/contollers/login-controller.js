import path from 'path';
import { fileURLToPath } from 'url';
import { auth } from "../public/firebase-config.js";
import { createUserWithEmailAndPassword, sendEmailVerification, signInWithEmailAndPassword } from "firebase/auth";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const checkUserVerify = async (req, res) => {
    if(req.session.user) {
        const user = auth.currentUser;
        if(!user.emailVerified) {
            try {
                await sendEmailVerification(user);
                req.session.destroy((err) => {
                    if (err) {
                        console.error("Failed to destroy session:", err);
                        // 에러 응답
                        if (!res.headersSent) {
                            return res.status(500).send({ error: "Failed to destroy session" });
                        }
                    }

                    // 세션 쿠키 삭제 및 응답 전송
                    if (!res.headersSent) {
                        res.clearCookie("connect.sid");
                        return res.status(200).send({ msg: "verify0"});
                    }
                });
            } catch(e) {
                console.error("Error sending verification email:", e);
                // 에러 응답
                if (!res.headersSent) {
                    return res.status(500).send({ error: "Failed to send verification email" });
                }
            }
        } else {
            // 이메일 인증이 이미 완료된 경우
            if (!res.headersSent) {
                return res.status(200).send({ msg: "verify1" });
            }
        } 
    } else {
        // 세션이 존재하지 않을 경우
        if (!res.headersSent) {
            return res.status(400).send({ msg: "세션이 존재하지 않습니다." });
        }
    }
}

export const moveToLoginEmail = (req, res) => {
    res.sendFile(path.join(__dirname, '../public/html/login-email.html'));
};

export const moveToLoginPassword = (req, res) => {
    const email = req.query.email;
    res.sendFile(path.join(__dirname, '../public/html/login-password.html'));
};

export const login = async (req, res) => {
    const { email, password } = req.body;

    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        req.session.user = { email } // 세션 저장

        req.session.save((err) => {
            if (err) {
                console.error("Failed to save session:", err);
                return res.status(500).send({ error: "Failed to save session" });
            }

            res.status(200).send({
                message: "User account successfully created.",
                email: user.email,
                uid: user.uid,
             });
        });
    } catch (e) {
        if(e.code === 'auth/user-not-found') {
            // 유저 정보가 없음
            res.status(404).send({code: e.code});
        }
        else if(e.code === 'auth/wrong-password') {
            // 잘못된 비밀번호
            res.status(401).send({code: e.code});
        }
        else if(e.code === 'auth/too-many-requests') {
            // 여러 번의 로그인 실패로 요청이 차단됨
            res.status(429).send({code: e.code});
        }
        else {
            res.status(400).send({code: e.code});
        }
    }
};


let tempData = {};
export const saveToRegister = (req, res) => {
    tempData = req.body;
}

export const getToRegister = (req, res) => {
    res.status(200).send(tempData);
    tempData = {};
}

export const register = async (req, res) => {
    const { email, password } = req.body;

    await createUserWithEmailAndPassword(auth, email, password)
    .then((userCredential) => {
        const user = userCredential.user;

        req.session.user = { email } // 세션 저장

        req.session.save((err) => {
            if (err) {
                console.error("Failed to save session:", err);
                return res.status(500).send({ error: "Failed to save session" });
            }

            res.status(200).send({
                message: "User account successfully created.",
                email: user.email,
             });
        });
    })
    .catch(async (e) => {
        res.status(400).send({ error: e.code });
    });
}

export const getCurrentUser = async (req, res) => {
    if(req.session.user) {
        res.status(200).send(req.session.user);
    } else {
        res.status(401).send({ error: "No user is logged in."});
    }
};