import express from 'express';
import { getAllOrders, order, orderAll } from "../controllers/product-controller.js";

const router = express.Router();

router.post('/product/order', order);
router.post('/product/order-all', orderAll);
router.get('/product/get-all-orders', getAllOrders);

export default router;