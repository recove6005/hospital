import { db, auth } from "./firebase-config.js";
import { getAuth, onAuthStateChanged } from "firebase/auth";

onAuthStateChanged(auth, (user) => {
    if(user) {
        const uid = user.uid;
        console.log(`Logged in as ${uid}`);
    } else {
        console.log(`No user logged in.`);
    }
});