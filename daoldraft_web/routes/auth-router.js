import express from 'express';
import { moveToLoginEmail, moveToLoginPassword, login, getCurrentUser, register, checkUserVerify, logout, checkAdmin } from "../contollers/auth-controller.js";

const router = express.Router();

router.get('/email', moveToLoginEmail);

router.get('/password', moveToLoginPassword);

router.post('/login', login);

router.post('/verify', checkUserVerify);

router.post('/current-user', getCurrentUser);

router.post('/register', register);

router.post('/logout', logout);

router.post('/check-admin', checkAdmin);

export default router;