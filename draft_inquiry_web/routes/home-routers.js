import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const router = express.Router();

// __dirname 설정
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// HOME 라우트
router.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/html/index.html'));
});

export default router;