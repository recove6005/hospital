import express from 'express';
import { acceptProject, dismissProject, getAllProjects, getProjectsBy0, getProjectsBy1, getProjectsBy2, getProjectsBy3, getProjectsByUid, requestPayment } from '../contollers/project-controller.js';

const router = express.Router();

router.post('/get-project-all', getAllProjects);
router.post('/get-project-0', getProjectsBy0);
router.post('/get-project-1', getProjectsBy1);
router.post('/get-project-2', getProjectsBy2);
router.post('/get-project-3', getProjectsBy3);

router.post('/accept-project', acceptProject);

router.post('/dismiss-project', dismissProject);

router.post('/request-payment', requestPayment);

router.post('/get-projects-by-uid', getProjectsByUid);

export default router;