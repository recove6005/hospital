import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
    apiKey: "AIzaSyDIPggHg9BG7-Wx5srvNXXdFNaM9vKsN9k",
    authDomain: "draft-inquiry-web.firebaseapp.com",
    projectId: "draft-inquiry-web",
    storageBucket: "draft-inquiry-web.firebasestorage.app",
    messagingSenderId: "987226711059",
    appId: "1:987226711059:web:44006b37b9b73eb8078be6",
    measurementId: "G-3YCQWC349G"
};

// Firebase 엡 초기화
const app = initializeApp(firebaseConfig);

// Firebase 및 Auth 초기화
const db = getFirestore(app);
const auth = getAuth(app);

// db, auth export
export { db, auth };