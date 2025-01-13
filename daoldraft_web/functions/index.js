import { onRequest } from "firebase-functions/v2/https";

import expressApp from './server.js';

export const app = onRequest(
    { secrets: ['DAOLKEY'] },
    (req, res) => {
        expressApp(req, res);
    }
);