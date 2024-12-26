import express from 'express';
import { moveToLoginEmail, moveToLoginPassword, login, getCurrentUser, register, saveToRegister, getToRegister, checkUserVerify } from "../contollers/login-controller.js";

const router = express.Router();

router.get('/email', moveToLoginEmail);

router.get('/password', moveToLoginPassword);

router.post('/login', login);

router.post('/verify', checkUserVerify);

router.post('/current-user', getCurrentUser);

router.post('/save-to-register', saveToRegister);

router.post('/get-to-register', getToRegister);

router.post('/register', register);

export default router;