import express from 'express';
import { order, storeGetOrders, storeGetScopedOrders, storeDeleteOrders, storeOrderRef } from "../controllers/order-controller.js";

const router = express.Router();

router.post('/order/order', order);
router.get('/order/store-get-all-orders', storeGetOrders);
router.post('/order/store-get-scoped-orders', storeGetScopedOrders);
router.post('/order/store-delete-orders', storeDeleteOrders);
router.post('/order/store-order-ref', storeOrderRef);

export default router;