import expressApp from './server.js';
import { onRequest } from "firebase-functions/v2/https";

console.log("🔥 Firebase Functions API is initializing...");

export const api = onRequest(expressApp);

console.log("🚀 Firebase Functions API is ready!");