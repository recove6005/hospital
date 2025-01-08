import path from 'path';
import { fileURLToPath } from 'url';
import { db, auth, storage } from "../public/firebase-config.js";
import { collection, doc, getDocs, orderBy, setDoc, getDoc, addDoc, query, deleteDoc, where, updateDoc } from "firebase/firestore";
import { ref, uploadBytes, getDownloadURL } from "firebase/storage";
import axios from 'axios';

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
        const pjtQuery = query(collection(db, "projects"), where("progress", "in", ["2", "11"]), orderBy("date", "desc"));
        const snapshot = await getDocs(pjtQuery);
        
        snapshot.forEach((doc) => {
            projectList.push( { docId: doc.id, ...doc.data() });
        });
        
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
    const files = req.files;

    if (!docId) {
        return res.status(400).json({ error: 'docId is required' });
    }

    try {
        // 상태 업데이트
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

        // 파일 업로드
        if(files.length > 0) {
            try {
                for(let index = 0; index < files.length; index++) {
                    const file = files[index];
                    const fileName = `${docSnap.data().uid}_${docId}_${index}.png`;
                    const stroageRef = ref(storage, fileName);
                    await uploadBytes(stroageRef, file.buffer);
                };
            } catch(e) {
                return res.status(500).send({ error: e.message });
            }
        } 
        
        return res.status(200).send({msg: "A payment request was sented."});
    } catch(e) {
        return res.status(500).send({ error: e.message });
    }
};

// 프로젝트 progress 업데이트 : 결제 완료 
// 작업완료, 결제중(2) -> 결제완료(3)
// 카카오페이
export const getpayKakaopay = async (req, res) => {
    const { docId, userEmail, title, allprice } = req.body;
    // 카카오페이 결제 요청
    const url = "https://open-api.kakaopay.com/online/v1/payment/ready";
    const headers = {
        "Authorization": `SECRET_KEY DEVAA4462268CB8B4CBB845AA51963831874373D`,
        "Content-Type" : "application/json"
    };

    const body = new URLSearchParams({
        cid: "TC0ONETIME",
        partner_order_id: "order",
        partner_user_id: "user",
        item_name: "테스트 상품",
        quantity: "1",
        total_amount: "10000",
        tax_free_amount: "0",
        approval_url: "http://localhost:3000/html/mypage.html",
        cancel_url: "http://localhost:3000/html/mypage.html",
        fail_url: "http://localhost:3000/html/mypage.html"
    });

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: headers,
            body: body,
        });

        const data = await response.json();
        const redirectURL = data.next_redirect_pc_url;

        try {
            const docRef = doc(db, 'projects', docId);
            await updateDoc(docRef, { progress: "3" });

            return res.status(200).json({ redirectURL: redirectURL });
        } catch(e) {
            return res.status(500).json({ error: e.message });
        }
    } catch(e) {
        return res.status(500).json({ error: e.message });
    }

}

// 프로젝트 progress 업데이트 : 결제 완료 
// 작업완료, 결제중(2) -> 결제완료(3)
// 무통장 입금
export const getpayDeposit = async (req, res) => {
    const { docId } = req.body;
    try {
        const docRef = doc(db, 'projects', docId);
        await updateDoc(docRef, { progress: "11", });
        return res.status(200).send({msg: 'success.'});
    } catch(e) {
        return res.status(500).send({error: e.message});
    }
}

// 무통장 입금 예금주 등록
export const uploadDepositOwner = async (req, res) => {
    const { owner, docId } = req.body;
    try {
      await setDoc(doc(db, 'deposit', docId), {
        owner: owner,
        docId: docId,
      });

      return res.status(200).send({msg: 'succes'});
    } catch(e) {
        return res.status(500).send({error: e.message});
    }
}

// 무통장 입금 예금주 정보 가져오기
export const downloadDepositOwner = async (req, res) => {
    const { docId } = req.body;

    if(!docId) {
        return res.status(400).send( { error: 'docId is required. '});
    }

    try {
        const docRef = doc(db, 'deposit', docId);
        const docSnap = await getDoc(docRef);

        let owner = docSnap.data().owner;

        if(docSnap.exists()) {
            return res.status(200).json({ owner: `${owner}` });
        }

        return res.status(404).json({ error: 'Document does not exist.'});
    } catch(e) {
        return res.status(500).json({ error: e.message });
    }
}

// 무통장 입금 확인
export const checkDeposit = async (req, res) => {
    const { docId } = req.body;

    try {
        const docRef = doc(db, 'projects', docId);
        await updateDoc(docRef, { progress: "3", });
        return res.status(200).send({msg: 'success'});
    } catch(e) {
        return res.status(500).send({error: e.message});
    }
}

// 프로젝트 가져오기 - 회원
export const getProjectsByUid = async (req, res) => {
    const uid = auth.currentUser.uid;

    if(uid) {
        var userProjects = [];

        try {
            const userQuery = query(collection(db, "projects"), where("uid", "==", uid), orderBy('date', 'desc'));
            const snapshot = await getDocs(userQuery);       
        
            snapshot.forEach((doc) => {
                userProjects.push({ docId: doc.id, ...doc.data() });
            });
    
            res.status(200).json(userProjects);
            
        } catch(e) {
            console.error("Error fetching projects:", e.message, e.stack);
            res.status(500).send({ error: e.message });
        }
    } else {
        console.log('no user found.');
        res.status(404).send({ error: e.message });
    }
};

// 파일 다운로드
export const getDownload = async (req, res) => {
    const uid = auth.currentUser.uid;
    const { docId } = req.body;

    if (!docId) {
        return res.status(400).json({ error: 'docId is required' });
    }

    if(uid) {
        let index = 0;
        let files = [];
        while(true) {
            const fileName = `${uid}_${docId}_${index}.png`;
            const fileRef = ref(storage, fileName);

            try {
                // 파일의 메타데이터 가져오기 (존재 여부 확인)
                await getMetadata(fileRef);    

                // 파일 URL 가져오기
                const downloadURL = await getDownloadURL(fileRef);
                files.push({ fileName, downloadURL });

                index++;

                // const response = await axios({
                //     url: downloadURL,
                //     method: 'GET',
                //     responseType: 'stream', // 스트리밍 방식
                // });
    
                // if(response.data) {
                //     const contentType = response.headers['content-type'];
                //     res.setHeader('Content-Type', contentType);
                //     response.data.pipe(res);
                // } else {
                //     throw new Error("Response data is undefined or null.");
                // }
    
            } catch(e) {
                console.log(`File not found: ${fileName}`);
                break;
            }
        }

        // 파일 다운로드 URLs 전송
        return res.status(200).json(files);

    } else {
        res.status(404).send({ error: e.message });
    }
};