import { onRequest } from "firebase-functions/v2/https";
import expressApp from './server.js';

export const appFunctions = onRequest(
    { secrets: ['DAOLKEY'] },
    expressApp
);