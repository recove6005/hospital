import path from 'path';
import { fileURLToPath } from 'url';
import { db, auth } from "../config/firebase-config.js";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { createUserWithEmailAndPassword, sendPasswordResetEmail, signInWithEmailAndPassword, signOut } from "firebase/auth";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const moveToLoginEmail = (req, res) => {
    res.sendFile(path.join(__dirname, '../public/html/login-email.html'));
};

// 로그인
export const login = async (req, res) => {
    const { email, password } = req.body;

    try {
        // 로그인 시도
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        req.session.user = { email } // 세션 저장

        req.session.save(async (err) => {
            if (err) {
                console.error("Failed to save session:", err);
                return res.status(500).json({ error: "Failed to save session" });
            }

            return res.status(200).json({
                message: "User account successfully created.",
                email: user.email,
                uid: user.uid,
            });
        });
    } catch (e) {
        if(e.code === 'auth/invalid-credential') {
            // 유저 없음
            return res.status(404).json({code: '0'});
        }
        if(e.code === 'auth/wrong-password') {
            // 유저 없음 또는 잘못된 비밀번호
            console.log(`${e.code}: ${e.message}`);
            return res.status(404).json({code: '1'});
        }
        console.log(`${e.code}: ${e.message}`);
        return res.status(400).json({code: e.code});
    }
};

// 회원가입
export const register = async (req, res) => {
    const { email, password } = req.body;

    await createUserWithEmailAndPassword(auth, email, password)
    .then(async (userCredential) => {
        const user = userCredential.user;

        // 계정 데이터셋 생성
        await setDoc(doc(db, "users", email), {
            email: email,
            uid: user.uid,
            subscribe: '0',
            admin: false,
        });

        // 구독 정보 데이터셋 생성
        await setDoc(doc(db, "subscribes", email), {
            email: email,
            uid: user.uid,
            type: '0',
            blog: 0,
            discount: 0,
            draft: 0,
            homepage: 0,
            logo: 0,
            signage: 0,
            instagram: 0,
            naverplace: 0,
            banner: 0,
            video: 0,
        });

        // await sendEmailVerification(user);

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

// 현재 유저 로그인 세션 정보 가져오기
export const getCurrentUser = async (req, res) => {
    if(req.session.user) {
        res.status(200).send(req.session.user);
    } else {
        res.status(401).send({ error: "No user is logged in."});
    }
};

// 로그아웃 
export const logout = async (req, res) => {
    console.log(`server logout.`);
    if(!req.session.user) {
        return res.status(401).send({ msg: "No session exist."});
    }

    try {
        req.session.destroy((e) => {
            if(e) {
                console.error("Session destroy error: ", err);
                return res.status(500)({ error: "Failed to destroy session."});
            }
        })

        res.clearCookie("connect.sid"); // 쿠키 삭제
        console.log("Session destroyed and cookie cleared.");

        const user = auth.currentUser;
        if(user) {
            signOut(auth)
            .then(() => {
                console.log("Firebase user signed out.");
                return res.status(200).send({ msg: "User logout successful." });
            })
            .catch((e) => {
                console.error("Firebase logout error:", e.message);
                return res.status(500).send({ error: e.message });
            });
        } else {
            console.log("No Firebase user session.");
            return res.status(200).send({ msg: "No Firebase session found, but logged out." });
        }
    } catch(e) {
        console.error("Logout error:", e.message);
        return res.status(500).send({ error: e.message });
    }
}

// admin check
export const checkAdmin = async (req, res) => {
    const user = auth.currentUser;
    if(user) {
        const docRef = doc(db, 'users', user.email);
        const docSnap = await getDoc(docRef);

        if(docSnap.exists()) {
            const admin = docSnap.data().admin;
            return res.status(200).send({ admin: admin });
        } else {
            return res.status(401).send({ error: "No admin data found. "});
        }
    } else {
        return res.status(400).send({ error: "No firebase user found. "});
    }
    
}

// password 재설정
export const updatePassword = async (req, res) => {
    if(req.session.user) {
        const user = auth.currentUser;
        if(user) {      
            const email = user.email;

            try {
                await sendPasswordResetEmail(auth, email)
                .then(() => {
                    return res.status(200).end();
                })
                .catch((error) => {
                    return res.status(500).json({ error: error.message });
                });
            } catch(e) {
                res.status(500).json({ error: e.message });
            }
        } else {
            return res.status(500).json({ error: 'No auth found.'});
        }
    }
}