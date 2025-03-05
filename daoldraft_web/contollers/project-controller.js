import path from 'path';
import { fileURLToPath } from 'url';
import { db, auth, storage } from "../config/firebase-config.js";
import { collection, doc, getDocs, orderBy, setDoc, getDoc, query, deleteDoc, where, updateDoc } from "firebase/firestore";
import { ref, getDownloadURL, getMetadata, uploadBytes } from "firebase/storage";
import archiver from 'archiver';
import { parseFormData } from "../config/busboy-config.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 프로젝트 결제 가격 가져오기 - 결제 확인된 내역만
export const getPayedPrices = async (req, res) => {
    let priceList = [];
    if(req.session.user) {
        const user = auth.currentUser;
        const uid = user.uid;
        let deposit = '-';
        
        const q = query(collection(db, 'price'), where('uid', '==', uid), where('payed', '==', true), orderBy('date', 'desc'));
        const snapshots = await getDocs(q);
    
        if(snapshots.empty) {
            return res.status(500).json({error: `snapshot's empty.`});
        } else {
            try {
                // if(paytype == '무통장 입금') {
                //     const depositDocRef = doc(db, 'deposit', data.docId);
                //     const depositSnap = await getDoc(depositDocRef);

                //     deposit = depositSnap.owner
                // } 

                snapshots.forEach(doc => {
                    const data = doc.data();
                    priceList.push({
                        title: data.title,
                        price: data.price,
                        date: data.date,
                        paytype: data.paytype,
                        deposit: deposit,
                    });
                });

                return res.status(200).json({ priceList: priceList});
            } catch(e) {
                return res.status(500).json({error: e.message});
            }
        }
    } else {
        return res.status(401).json({error: `no session found`});
    }
};


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

// 프로젝트 가져오기 - 특정 문서값으로
export const getProjectByDocId = async (req, res) => {
    try {
        const { docId } = req.body;
        const docRef = doc(db, 'projects', docId);
        const snapshot = await getDoc(docRef);

        if(snapshot.exists()) {
            return res.status(200).json({
                title: snapshot.data().title,
                date: snapshot.data().date,
                organization: snapshot.data().organization,
                name: snapshot.data().name,
                call: snapshot.data().call,
                email: snapshot.data().email,
                details: snapshot.data().details,
                progress: snapshot.data().progress,
            });
        } else {
            return res.status(500).json({error: 'no doc ref found'});
        }
    } catch(e) {
        return res.status(500).json({error:e.message});
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
                date: docSnap.data().date,
                details: docSnap.data().details,
                email: docSnap.data().email,
                name: docSnap.data().name,
                organization: docSnap.data().organization,
                call: docSnap.data().call,
                progress: "1",
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
// 작업 중 (1) -> 작업완료, 결제중(2)
export const requestPayment = async (req, res) => {
    // const { docId, price } = req.body;
    // const files = req.files || [];
    try {
        const {fields, files} = await parseFormData(req);
        const {docId, price} = fields;

        if(!docId || !price) {
            return res.status(400).send({error: `Missing required fields docId ${docId}, price ${price}`});
        }

        if(files.length === 0) {
            console.log(`error: Missing required files`);
        }

        // 상태 업데이트
        const docRef = doc(db, 'projects', docId);
        const docSnap = await getDoc(docRef);
        if(docSnap.exists()) {
            await setDoc(docRef, {
                date: docSnap.data().date,
                details: docSnap.data().details,
                email: docSnap.data().email,
                name: docSnap.data().name,
                organization: docSnap.data().organization,
                call: docSnap.data().call,
                progress: "2",
                title: docSnap.data().title,
                uid: docSnap.data().uid,
                userEmail: docSnap.data().userEmail,
            });
        }
        console.log(`Project progress update success.`);
        
        // 가격 업로드
        const priceDocRef = doc(db, 'price', docId);
        await setDoc(priceDocRef, {
            docId: docId,
            price: price,
            payed: false,
            date: Date.now(),
            paytype: '-',
            uid: docSnap.data().uid,
            title: docSnap.data().title,
        });
        console.log(`Price upload success.`);

        // 파일 업로드 - multer
        // if(files.length > 0) {
        //     try {
        //         for(let index = 0; index < files.length; index++) {
        //             const file = files[index];
        //             const fileName = `${docSnap.data().uid}_${docId}_${index}.png`;
        //             const storageRef = ref(storage, fileName);
        //             await uploadBytes(storageRef, file.buffer);
        //         };
        //     } catch(e) {
        //         return res.status(500).send({ error: e.message });
        //     }
        // } 

        // 파일 업로드 - busboy
        if(files.length > 0) {
            try {
                for(let index = 0; index < files.length; index++) {
                    const file = files[index];
                    const fileName = `${docSnap.data().uid}_${docId}_${index}.png`;
                    const storageRef = ref(storage, fileName);
                    await uploadBytes(storageRef, file.buffer);
                }
                console.log(`File upload success.`);
            } catch(e) {
                return res.status(500).send({error: `File upload error: ${e.message}`});
            }
        }

        return res.status(200).send({msg: "A payment request was sented."});
    } catch(e) {
        return res.status(500).send({ error: e.message});
    }
};

// 프로젝트 progress 업데이트 : 결제 완료 
// 작업완료, 결제중(2) -> 결제완료(3)
// 카카오페이
export const getpayKakaopay = async (req, res) => {
    const { docId, userEmail, title, allprice } = req.body;
    // 카카오페이 결제 요청
    const url = "https://open-api.kakaopay.com/online/v1/payment/ready";
    console.log(`Kakaopay ${url}`);

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
        approval_url: "https://www.naver.com/",
        cancel_url: "https://www.naver.com/",
        fail_url: "https://www.naver.com/"
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
// 수동이체
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

// 수동이체 예금주 등록
export const uploadDepositOwner = async (req, res) => {
    const { owner, docId, actNum } = req.body;
    try {
      await setDoc(doc(db, 'deposit', docId), {
        owner: owner,
        docId: docId,
        actNum: actNum,
      });

      return res.status(200).send({msg: 'succes'});
    } catch(e) {
        return res.status(500).send({error: e.message});
    }
}

// 수동이체 예금주 정보 가져오기
export const downloadDepositOwner = async (req, res) => {
    const { docId } = req.body;

    if(!docId) {
        return res.status(400).send( { error: 'docId is required. '});
    }

    try {
        const docRef = doc(db, 'deposit', docId);
        const docSnap = await getDoc(docRef);

        let owner = docSnap.data().owner;
        let actNum = docSnap.data().actNum;

        if(docSnap.exists()) {
            return res.status(200).json({ owner: `${owner}`, actNum: `${actNum}` });
        }

        return res.status(404).json({ error: 'Document does not exist.'});
    } catch(e) {
        return res.status(500).json({ error: e.message });
    }
}

// 수동 이체 확인
export const checkDeposit = async (req, res) => {
    const { docId, price } = req.body;

    try {
        // 프로젝트 진행 현황 업데이트
        const docRef = doc(db, 'projects', docId);
        await updateDoc(docRef, { progress: "3", });

        // 가격 결제 정보 업데이트
        const priceDocRef = doc(db, 'price', docId);
        const updateData = {
            payed: true,
            date: Date.now(),
            paytype: '수동 이체',
        };
        updateDoc(priceDocRef, updateData);

        return res.status(200).send({msg: 'success'});
    } catch(e) {
        return res.status(500).send({error: e.message});
    }
}

// 구독권 결제 확인
export const checkSubscribePay = async (req, res) => {
    const { docId, price } = req.body;

    try {
        // 프로젝트 진행 현황 업데이트
        const docRef = doc(db, 'projects', docId);
        await updateDoc(docRef, { progress: "3", });

        // 가격 결제 정보 업데이트
        const priceDocRef = doc(db, 'price', docId);
        const updateData = {
            payed: true,
            date: Date.now(),
            paytype: '구독권 결제',
        };
        updateDoc(priceDocRef, updateData);

        return res.status(200).send({msg: 'success'});
    } catch(e) {
        return res.status(500).send({error: e.message});
    }
}

// 프로젝트 가져오기 - 회원 uid로
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

// 요청 가격 가져오기
export const getPriceValue = async (req, res) => {
    const { docId } = req.body;
    try {
        const docRef = doc(db, 'price', docId);
        const snapshot = await getDoc(docRef);

        if(snapshot.exists()) {
            return res.status(200).json({price: snapshot.data().price});
        } else {
            return res.status(200).json({price: '---'});
        }
    } catch(e) {
        return res.status(500).json({error: e.message});
    }
}

// 파일 다운로드
export const getDownload = async (req, res) => {
    const uid = auth.currentUser.uid;
    const { docId } = req.body;

    if (!docId) {
        return res.status(400).json({ error: 'docId is required' });
    }

    if(uid) {
        const archive = archiver("zip", { zlib: {level:9}});
        let index = 0;

        res.setHeader('Content-Type', 'application/zip');
        res.setHeader('Content-Disposition', `attachment; filename="draft_files.zip"`);
    
        archive.pipe(res);

        while(true) {
            const fileName = `${uid}_${docId}_${index}.png`;
            const fileRef = ref(storage, fileName);

            try {
                // 파일의 메타데이터 가져오기 (존재 여부 확인)
                await getMetadata(fileRef);

                // 다운로드 URL 가져오기
                const downloadUrl = await getDownloadURL(fileRef);

                 // 파일 다운로드 및 압축 추가
                const response = await fetch(downloadUrl);
                if (!response.ok) {
                    throw new Error(`Failed to fetch file: ${downloadUrl}`);
                }

                const arrayBuffer = await response.arrayBuffer();
                const fileBuffer = Buffer.from(arrayBuffer);
                archive.append(fileBuffer, { name: fileName });

                index++;
            } catch(e) {
                console.log(`File not found: ${fileName}, e: ${e.message}`);
                break;
            }
        }

        archive.finalize();
    } else {
        return res.status(404).send({ error: e.message });
    }
};