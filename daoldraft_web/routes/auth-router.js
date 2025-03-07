import express from 'express';
import { moveToLoginEmail, login, getCurrentUser, register, logout, checkAdmin, updatePassword, findPassword } from "../contollers/auth-controller.js";

const router = express.Router();

router.get('/email', moveToLoginEmail);

router.post('/login', login);

router.post('/current-user', getCurrentUser);

router.post('/register', register);

router.post('/logout', logout);

router.post('/check-admin', checkAdmin);

router.post('/update-password', updatePassword);
router.post('/find-password', findPassword);

export default router;