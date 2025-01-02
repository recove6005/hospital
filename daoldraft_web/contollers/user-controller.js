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

// 프로젝트 문의 등록 - logo
export const commissionProjectLogo = async (req, res) => {
    const formData = req.body;
    const { title, size, rank, phone, organization, name, email, details, allprice } = formData;
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
                size: size,
                rank: rank,
                phone: phone,
                organization: organization,
                name: name,
                email: email,
                details: details,
                allprice: allprice,
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

// 프로젝트 문의 등록 - draft
export const commissionProjectDraft = async (req, res) => {
    const formData = req.body;
    const { title, size, rank, phone, organization, name, email, details, allprice } = formData;
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
                date: date,
                title: title,
                size: size,
                rank: rank,
                phone: phone,
                organization: organization,
                name: name,
                email: email,
                details: details,
                allprice: allprice,
                progress: '0',
            });

            res.status(200).json({msg: "Project(draft) inserted successfully.", receivedData: formData });
        } catch(e) {
            res.status(401).send({ error : e.message});
        }
    } else {
        res.status(400).send({ error : "No firebaes user found."});
    }
}

// 프로젝트 문의 등록 - signage
export const commissionProjectSignage = async (req, res) => {
    const formData = req.body;
    const { title, size, rank, phone, organization, name, email, details, allprice } = formData;
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
                date: date,
                title: title,
                size: size,
                rank: rank,
                phone: phone,
                organization: organization,
                name: name,
                email: email,
                details: details,
                allprice: allprice,
                progress: '0',
            });

            res.status(200).json({msg: "Project(signage) inserted successfully.", receivedData: formData });
        } catch(e) {
            res.status(401).send({ error : e.message});
        }
    } else {
        res.status(400).send({ error : "No firebaes user found."});
    }
}

// 프로젝트 문의 등록 - blog
export const commissionProjectBlog = async (req, res) => {
    const formData = req.body;
    const { title, size, rank, phone, organization, name, email, details, allprice } = formData;
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
                size: size,
                rank: rank,
                phone: phone,
                organization: organization,
                name: name,
                email: email,
                details: details,
                allprice: allprice,
                progress: '0',
            });

            res.status(200).json({msg: "Project(blog) inserted successfully.", receivedData: formData });
        }  catch(e) {
            res.status(401).send({ error : e.message});
        }
    } else {
        res.status(400).send({ error : "No firebaes user found."});
    }
}

// 프로젝트 문의 등록 - hompage
export const commissionProjectHomepage = async (req, res) => {
    const formData = req.body;
    const { title, size, rank, phone, organization, name, email, details, allprice } = formData;
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
                size: size,
                rank: rank,
                phone: phone,
                organization: organization,
                name: name,
                email: email,
                details: details,
                allprice: allprice,
                progress: '0',
            });

            res.status(200).json({msg: "Project(homepage) inserted successfully.", receivedData: formData });
        }  catch(e) {
            res.status(401).send({ error : e.message});
        }
    } else {
        res.status(400).send({ error : "No firebaes user found."});
    }
}

export const periodicPurchase = async (req, res) => {
    try {
        const { name, cardNumber, expiryDate, cvv } = req.body;

        // 고객 생성
        const customer = await stripe.customers.create({
            name: name,
            email: "customer@example.com",
        });

        // 결제 수단 추가
        const paymentMethod = await stripe.paymentMethods.create({
            type: "card",
            card: {
                number: cardNumber,
                exp_month: expiryDate.split("/")[0],
                exp_year: `20${expiryDate.split("/")[1]}`,
                cvc: cvv,
            },
        });

        await stripe.paymentMethods.attach(paymentMethod.id, {
            customer: customer.id,
        });

        // 정기 결제 생성
        const subscription = await stripe.subscriptions.create({
            customer: customer.id,
            items: [{ price: "price_1N2Blh2eZvKYlo2CqMrmHRHi" }], // 가격 ID (Stripe 대시보드에서 생성)
            default_payment_method: paymentMethod.id,
        });

        res.status(200).json({ subscriptionId: subscription.id });
    } catch(e) {
        console.error("Error creating subscription:", error);
        res.status(500).json({ error: error.message });
    }
}

export const periodicWebhook = async (req, res) => {
    const event = JSON.parse(req.body);

    if (event.type === "invoice.payment_succeeded") {
        console.log("Payment succeeded for subscription:", event.data.object.subscription);
    } else if (event.type === "invoice.payment_failed") {
        console.log("Payment failed:", event.data.object);
    }

    res.sendStatus(200);
}