import path from 'path';
import { fileURLToPath } from 'url';
import { db, auth } from "../public/firebase-config.js";
import { collection, doc, getDocs, orderBy, setDoc, getDoc, query, deleteDoc, where } from "firebase/firestore";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 프로젝트 가져오기 - 전체
export const getAllProjects = async (req, res) => {
    var projectList = [];

    try {
        const pjtQuery = query(collection(db, "projects"), orderBy("date", "desc"));
        const snapshot = await getDocs(pjtQuery);
        snapshot.forEach((doc) => {
            projectList.push( { docId: doc.id, ...doc.data() });
        });

        if (projectList.length === 0) {
            return res.status(200).json([]);
        } 

        return res.status(200).json(projectList);
    } catch(e) {
        console.error("Error fetching projects:", e.message, e.stack);
        return res.status(500).json({ error: e.message });
    }
}

// 프로젝트 가져오기 - 접수 문의
export const getProjectsBy0 = async (req, res) => {
    var projectList = [];

    try {
        const pjtQuery = query(collection(db, "projects"), where("progress", "==", "0"), orderBy("date", "desc"));
        const snapshot = await getDocs(pjtQuery);
        snapshot.forEach((doc) => {
            projectList.push( { docId: doc.id, ...doc.data() });
        });

        if (projectList.length === 0) {
            return res.status(200).json([]);
        } 

        return res.status(200).json(projectList);
    } catch(e) {
        console.error("Error fetching projects:", e.message, e.stack);
        return res.status(500).json({ error: e.message });
    }
}

// 프로젝트 가져오기 - 작업 중
export const getProjectsBy1 = async (req, res) => {
    var projectList = [];

    try {
        const pjtQuery = query(collection(db, "projects"), where("progress", "==", "1"), orderBy("date", "desc"));
        const snapshot = await getDocs(pjtQuery);
        snapshot.forEach((doc) => {
            projectList.push( { docId: doc.id, ...doc.data() });
        });

        if (projectList.length === 0) {
            return res.status(200).json([]);
        } 

        return res.status(200).json(projectList);
    } catch(e) {
        console.error("Error fetching projects:", e.message, e.stack);
        return res.status(500).json({ error: e.message });
    }
}

// 프로젝트 가져오기 - 작업 완료
export const getProjectsBy2 = async (req, res) => {
    var projectList = [];

    try {
        const pjtQuery = query(collection(db, "projects"), where("progress", "==", "2"), orderBy("date", "desc"));
        const snapshot = await getDocs(pjtQuery);
        snapshot.forEach((doc) => {
            projectList.push( { docId: doc.id, ...doc.data() });
        });

        if (projectList.length === 0) {
            return res.status(200).json([]);
        } 

        return res.status(200).json(projectList);
    } catch(e) {
        console.error("Error fetching projects:", e.message, e.stack);
        return res.status(500).json({ error: e.message });
    }
}

// 프로젝트 가져오기 - 결제 완료
export const getProjectsBy3 = async (req, res) => {
    var projectList = [];

    try {
        const pjtQuery = query(collection(db, "projects"), where("progress", "==", "3"), orderBy("date", "desc"));
        const snapshot = await getDocs(pjtQuery);
        snapshot.forEach((doc) => {
            projectList.push( { docId: doc.id, ...doc.data() });
        });

        if (projectList.length === 0) {
            return res.status(200).json([]);
        } 

        return res.status(200).json(projectList);
    } catch(e) {
        console.error("Error fetching projects:", e.message, e.stack);
        return res.status(500).json({ error: e.message });
    }
}


// 프로젝트 progress 업데이트 : 작업 거부
// 프로젝트 삭제
export const dismissProject = async (req, res) => {
    const { docId } = req.body;

    if (!docId) {
        return res.status(400).json({ error: 'docId is required' });
    }

    try {
        const docRef = doc(db, 'projects', docId);
        await deleteDoc(docRef);
        return res.status(200).send({msg: "The project was dismissed."});
    } catch(e) {
        return res.status(500).send({error: e.message});
    }
};

// 프로젝트 progress 업데이트 : 작업 수락
// 문의 접수(0) -> 작업 중(1)
export const acceptProject = async (req, res) => {
    const { docId } = req.body;

    if (!docId) {
        return res.status(400).json({ error: 'docId is required' });
    }

    try {
        const docRef = doc(db, 'projects', docId);
        const docSnap = await getDoc(docRef);
        if(docSnap.exists()) {
            await setDoc(docRef, {
                allprice: docSnap.data().allprice,
                date: docSnap.data().date,
                details: docSnap.data().details,
                email: docSnap.data().email,
                name: docSnap.data().name,
                organization: docSnap.data().organization,
                phone: docSnap.data().phone,
                progress: "1",
                rank: docSnap.data().rank,
                size: docSnap.data().size,
                title: docSnap.data().title,
                uid: docSnap.data().uid,
                userEmail: docSnap.data().userEmail,
            });
        }
       
        return res.status(200).send({msg: "A project was accepted."});
    } catch(e) {
        return res.status(500).send({ error: e.message });
    }
};

// 프로젝트 progress 업데이트 : 결제 요청
// 작업 중 (1) -> 작업완료, 결재중(2)
export const requestPayment = async (req, res) => {
    const { docId, price } = req.body;

    if (!docId) {
        return res.status(400).json({ error: 'docId is required' });
    }

    try {
        const docRef = doc(db, 'projects', docId);
        const docSnap = await getDoc(docRef);
        if(docSnap.exists()) {
            await setDoc(docRef, {
                allprice: price,
                date: docSnap.data().date,
                details: docSnap.data().details,
                email: docSnap.data().email,
                name: docSnap.data().name,
                organization: docSnap.data().organization,
                phone: docSnap.data().phone,
                progress: "2",
                rank: docSnap.data().rank,
                size: docSnap.data().size,
                title: docSnap.data().title,
                uid: docSnap.data().uid,
                userEmail: docSnap.data().userEmail,
            });
        }
       
        return res.status(200).send({msg: "A payment request was sented."});
    } catch(e) {
        return res.status(500).send({ error: e.message });
    }
};

// 프로젝트 progress 업데이트 : 결제 완료 
// 작업완료, 결제중(2) -> 결제완료(3)