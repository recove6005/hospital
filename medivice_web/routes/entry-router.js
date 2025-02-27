import express from 'express';
import { validateKey } from '../controllers/entry-controller.js';

const router = express.Router();

router.post('/entry/validate', validateKey);

export default router;