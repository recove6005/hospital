import express from "express";
import { addUser, getHomePage, readUsers } from "../contollers/home-contoller.js";

const router = express.Router();

// HOME 라우트
router.get('/', getHomePage);

// route : add data
router.post("/add", addUser);

// route : read data
router.get("/read", readUsers);

export default router;