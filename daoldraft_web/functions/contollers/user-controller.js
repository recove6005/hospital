import path from 'path';
import { fileURLToPath } from 'url';
import { db, auth } from "../public/firebase-config.js";
import { collection, doc, addDoc, getDoc, setDoc, updateDoc } from "firebase/firestore";

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
            return res.status(200).json({ subscribe: subscribeType });
        } else {
            return res.status(401).json({ error: "No data found."});
        }
    } else {
        console.log("No Firebase user session.");
        return res.status(401).json({ error: "No Firebase session found." });
    }   
}

// 구독권 정보 업데이트 0 -> 1
async function updateSubscribe(type) {
    const userEmail = auth.currentUser.email;

    const docRef = doc(db, 'users', userEmail);
    await updateDoc(docRef, { subscribe: type });
}

// 구독권 정보 가져오기
export const getSubscribeInfo = async (req, res) => {
    const userEmail = auth.currentUser.email;

    if(userEmail) {
        const docRef = doc(db, 'subscribes', userEmail);
        const docSnap = await getDoc(docRef);

        if(docSnap.exists()) {
            const subscribeInfo = docSnap.data();
            return res.status(200).json({ 
                subscribeInfo: subscribeInfo 
            });
        } else {
            return res.status(401).json({ error: 'No data found.'});
        }
    } else {
        return res.status(401).json({ error: 'No Firebase session found.'});
    }
}

// 구독권 결제
export const getPayWithSubscribe = async (req, res) => {
    const userEmail = auth.currentUser.email;
    const { title } = req.body;

    let category = '';
    switch(title) {
        case '네이버 블로그': category = 'blog'; break;
        case '원내시안': category = 'draft'; break;
        case '홈페이지 제작': category = 'homepage'; break;
        case '인스타그램': category = 'instagram'; break;
        case '로고디자인': category = 'logo'; break;
        case '네이버 플레이스': category = 'naverplace'; break;
        case '디지털 사이니지': category = 'signage'; break;
        case '홍보영상 제작/편집': category = 'video'; break;
        case '웹 배너': category = 'banner'; break;
    }

    try {
        const subscribeInfoDocRef = doc(db, 'subscribes', userEmail);
        const subscribeDocSnap = await getDoc(subscribeInfoDocRef);
    
        if(subscribeDocSnap.exists()) {
            const info = subscribeDocSnap.data();
            if(info[category] < 0) {
                return res.status(402).json({ error: `무료 회분이 남아있지 않습니다.` });
            } else {
                await updateDoc(subscribeInfoDocRef, {
                    [category] : info[category] - 1,
                });
    
                return res.status(200).json({ msg: `결제 완료` });
            }
        }
    } catch(e) {
        return res.status(500).json({ error: e.message });
    }
}


// 프로젝트 문의 등록
export const commissionProject = async (req, res) => {
    const formData = req.body;
    const { title, call, organization, name, email, details } = formData;
    const user = auth.currentUser;
    
    if(user) {
        try {
            const uid = user.uid;
            const userEmail = user.email;

            const date = Date.now();

            const docRef = await addDoc(collection(db, "projects"), {
                uid: uid,
                userEmail: userEmail,
                date: date,
                title: title,
                call: call,
                organization: organization,
                name: name,
                email: email,
                details: details,
                progress: '0',
            });
        
            res.status(200).json({ msg: "Project inserted successfully", receivedData: formData });
        } catch(e) {
            res.status(401).send({ error : e.message});
        }
    } else {
        res.status(400).send({ error : "No firebaes user found."});
    }
};


// 카카오페이 정기 결제 - basic 첫 결제
export const subscribeBasic = async (req, res) => {
    const url = "https://open-api.kakaopay.com/online/v1/payment/ready";
    const headers = {
        Authorization: `SECRET_KEY DEVAA4462268CB8B4CBB845AA51963831874373D`, // secret key(dev)
        "Content-Type": "Content-Type: application/json",
    };

    const body = new URLSearchParams({
        cid: "TCSUBSCRIP",
        partner_order_id: `order${Date.now().toString()}`,
        partner_user_id:  `user${Date.now().toString()}`,
        item_name: "음악정기결제",
        quantity: '1',
        total_amount: "9900",
        vat_amount: "900",
        tax_free_amount: "0",
        approval_url: "http://localhost:3000/html/buy-subscribe.html",
        cancel_url: "http://localhost:3000/html/buy-subscribe.html",
        fail_url: "http://localhost:3000/html/buy-subscribe.html",
    });

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: headers,
            body: body,
        });

        const data = await response.json();
        const redirectURL = data.next_redirect_pc_url;
        const tid = data.tid;

        if(response.ok) {
            // 정기 결제 구독권 정보 업데이트
            try {
                const type = "1"; // basic
                updateSubscribe(type);

                const currentDate = new Date();
                const after30 = new Date();
                after30.setDate(currentDate.getDate() + 30);

                const nextDate = `${after30.getMonth() + 1}월 ${after30.getDate()}일`;

                return res.status(200).json({ redirectURL: redirectURL, nextDate: nextDate, tid: tid });
            } catch(e) {
                return res.status(404).json({ error: e.message });
            }
        } else {
            throw new Error(`Response status: ${response.status}, Response data: ${data}`);
        }
    } catch(e) {
        console.error("Error during payment preparation:", e.message);
        return res.status(500).json({ error: e.message });
    }
}

// 첫 결제 승인 및 sid 발급 
export const getSid = async (req, res) => {
    const { tid, pgToken } = req.body;
    const url = 'https://kapi.kakao.com/v1/payment/approve';
    const headers = {
        Authorization: `KakaoAK YOUR_ADMIN_KEY`,
        'Content-Type': 'application/x-www-form-urlencoded',
    };

    const body = new URLSearchParams({
        cid: 'TCSUBSCRIP',                // 테스트용 정기결제 CID
        tid: tid,                         // 결제 고유 번호
        partner_order_id: 'order_1234',   // 파트너사 주문번호
        partner_user_id: 'user_5678',     // 파트너사 사용자 ID
        pg_token: pgToken,               // 결제 완료 시 전달받은 token
    });

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: headers,
            body: body,
        });

        const data = await response.json();
        if(data.sid) {
            return res.status(200).json({ sid: data.sid });
        } else {
            return res.status(404).json({ error: `Error approving payment: ${data}` });
        }
    } catch(e) {
        return res.status(500).json({ error: e.message });
    }
}

// 정기 결제 요청
export const subscribePeriodic = async (req, res) => {
    const { sid } = req.body;
    const url = 'https://kapi.kakao.com/v1/payment/subscription';
    const headers = {
        Authorization: `SECRET_KEY DEVAA4462268CB8B4CBB845AA51963831874373D`,
        'Content-Type': 'application/x-www-form-urlencoded',
    };

    const body = new URLSearchParams({
        cid: 'TCSUBSCRIP',                // 테스트용 정기결제 CID
        sid: sid,                         // 정기결제 Subscription ID
        partner_order_id: 'order_5678',   // 파트너사 주문번호
        partner_user_id: 'user_91011',    // 파트너사 사용자 ID
        quantity: '1',                    // 수량
        total_amount: '10000',            // 결제 금액
        tax_free_amount: '0',             // 비과세 금액
    });

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: headers,
            body: body,
        });

        const data = await response.json();
        return res.status(200).json({ data: data });
    } catch (error) {
        return res.status(500).json({ error: e.message });
    }
} 