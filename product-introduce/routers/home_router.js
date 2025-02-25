import express from "express"
import { getHomePage } from "../controllers/home_contoller.js";

const router = express.Router();

router.get('/', getHomePage);

export default router;