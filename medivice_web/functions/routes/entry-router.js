import express from 'express';
import { storeValidateKey, storeQueryKey } from '../controllers/entry-controller.js';

const router = express.Router();

router.post('/entry/store-validate', storeValidateKey); 
router.post('/entry/store-query-key', storeQueryKey);

export default router;