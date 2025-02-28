import express from "express";

const router = express.Router();

// HOME 라우트
router.get('/', getHomePage);

export default router;