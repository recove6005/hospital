import express from 'express';
import { getAllOrders, order, orderAll, getScopedOrders, deleteOrders } from "../controllers/product-controller.js";

const router = express.Router();

router.post('/product/order', order);
router.post('/product/order-all', orderAll);
router.get('/product/get-all-orders', getAllOrders);
router.post('/product/get-scoped-orders', getScopedOrders);
router.post('/product/delete-orders', deleteOrders);

export default router;