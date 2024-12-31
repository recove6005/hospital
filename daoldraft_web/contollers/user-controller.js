import path from 'path';
import { fileURLToPath } from 'url';
import { db, auth } from "../public/firebase-config.js";
import { doc, getDoc, setDoc, updateDoc } from "firebase/firestore";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 구독권 유형 데이터 0, 1, 2, 3 가져오기
export const getSubscribeType = async (req, res) => {
    const user = auth.currentUser;
    if(user) {
        const docRef = doc(db, 'users', user.email);
        const docSnap = await getDoc(docRef);

        if(docSnap.exists()) {
            const subscribeType = docSnap.data().subscribe;
            console.log(`${user.email}'s subscribe: ${subscribeType}`);
            return res.status(200).send({ subscribe: subscribeType });
        } else {
            return res.status(401).send({ error: "No data found."});
        }

    } else {
        console.log("No Firebase user session.");
        return res.status(401).send({ error: "No Firebase session found." });
    }   
}

// 구독권 구매
export const subscribe = async (req, res) => {

}

// 구독권 정보 가져오기
export const getSubscribeInfo = async (req, res) => {
    
}