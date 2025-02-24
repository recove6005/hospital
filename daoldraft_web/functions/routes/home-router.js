import express from "express";
import { getGeocord, getHomePage, getMap } from "../contollers/home-contoller.js";

const router = express.Router();

// HOME 라우트
router.get('/', getHomePage);
router.get('/api/geocord', getGeocord);
router.get('/api/map', getMap);

export default router;