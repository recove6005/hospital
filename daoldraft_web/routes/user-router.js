import express from 'express';
import { getSubscribeType } from '../contollers/user-controller.js';

const router = express.Router();

router.post('/get-subscribe-type', getSubscribeType);

export default router;