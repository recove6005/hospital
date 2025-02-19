import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyDG9Raho541yr9hgIyb7Ptn4t8ab_uUIR4",
  authDomain: "medivice-564b0.firebaseapp.com",
  projectId: "medivice-564b0",
  storageBucket: "medivice-564b0.firebasestorage.app",
  messagingSenderId: "761907376949",
  appId: "1:761907376949:web:239224d72949c5363d927c",
  measurementId: "G-C9WNE0RLP9"
};

// Firebase 앱 초기화
const app = initializeApp(firebaseConfig);

// Firestore 초기화
const db = getFirestore(app);

// Firebase auth 초기화
const auth = getAuth(app);

// Firebase storage 초기화
const storage = getStorage(app);

// db, auth export
export { db, auth, storage };