import express from 'express';
import { dbValidateKey, storeValidateKey } from '../controllers/entry-controller.js';

const router = express.Router();

router.post('/entry/db-validate', dbValidateKey);
router.post('/entry/store-validate', storeValidateKey);

export default router;