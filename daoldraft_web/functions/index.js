import { onRequest } from "firebase-functions/v2/https";
import expressApp from './server.js';

export const api = onRequest(expressApp);