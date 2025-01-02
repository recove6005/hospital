import express from 'express';
import { commissionProjectBlog, commissionProjectDraft, commissionProjectHomepage, commissionProjectLogo, commissionProjectSignage, getSubscribeType } from '../contollers/user-controller.js';

const router = express.Router();

router.post('/get-subscribe-type', getSubscribeType);

router.post('/commission-project-logo', commissionProjectLogo);

router.post('/commission-project-draft', commissionProjectDraft);

router.post('/commission-project-signage', commissionProjectSignage);

router.post('/commission-project-blog', commissionProjectBlog);

router.post('/commission-project-homepage', commissionProjectHomepage);

export default router;