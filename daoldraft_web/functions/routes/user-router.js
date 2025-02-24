import express from 'express';
import { getSid, getSubscribeInfo, getSubscribeType, subscribeBasic, subscribePeriodic, commissionProject, getPayWithSubscribe } from '../contollers/user-controller.js';

const router = express.Router();

router.post('/get-subscribe-type', getSubscribeType);
router.post('/get-subscribe-info', getSubscribeInfo);

router.post('/commission-project', commissionProject);

router.post('/getpay-with-subscribe', getPayWithSubscribe);

router.post('/subscribe-basic', subscribeBasic); // 구독권 초기 결제
router.post('/get-sid', getSid); // sid 발급 요청
router.post('/subscribe-periodic', subscribePeriodic); // 정기 결제 요청

export default router;