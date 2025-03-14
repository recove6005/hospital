import express from 'express';
import multer from 'multer';
import { acceptProject, checkDeposit, checkSubscribePay, dismissProject, downloadDepositOwner, getAllProjects, getDownload, getpayDeposit, getPayedPrices, getpayKakaopay, getPriceValue, getProjectByDocId, getProjectsBy0, getProjectsBy1, getProjectsBy2, getProjectsBy3, getProjectsByUid, requestPayment, uploadDepositOwner } from '../contollers/project-controller.js';

const router = express.Router();

router.post('/get-project-all', getAllProjects);
router.post('/get-project-0', getProjectsBy0);
router.post('/get-project-1', getProjectsBy1);
router.post('/get-project-2', getProjectsBy2);
router.post('/get-project-3', getProjectsBy3);

router.post('/accept-project', acceptProject);
router.post('/dismiss-project', dismissProject);

router.post('/get-project-by-id', getProjectByDocId);

const upload = multer();
router.post('/request-payment', upload.array('files'), requestPayment);

router.post('/get-projects-by-uid', getProjectsByUid);

router.post('/getpay-deposit', getpayDeposit);
router.post('/getpay-kakaopay', getpayKakaopay);

router.post('/upload-deposit-owner', uploadDepositOwner);
router.post('/download-deposit-owner', downloadDepositOwner);

router.post('/get-price', getPriceValue);
router.post('/get-payed-prices', getPayedPrices);

router.post('/check-deposit', checkDeposit);
router.post('/check-subscribe-pay', checkSubscribePay);

router.post('/get-download', getDownload);

export default router;