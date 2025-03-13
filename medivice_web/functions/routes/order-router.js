import express from 'express';
import { order, storeGetOrders, storeGetScopedOrders, storeDeleteOrders, storeOrderRef } from "../controllers/order-controller.js";

const router = express.Router();

// mysql
// router.post('/order/db-order', dbOrder);
// router.post('/order/db-order-all', dbOrderAll);
// router.get('/order/db-get-all-orders', dbGetOrders);
// router.post('/order/db-get-scoped-orders', dbGetScopedOrders);
// router.post('/order/db-delete-orders', dbDeleteOrders);

// firestore
// router.post('/order/store-order', storeOrder);
// router.post('/order/store-order-all', storeOrderAll);
router.post('/order/order', order);
router.get('/order/store-get-all-orders', storeGetOrders);
router.post('/order/store-get-scoped-orders', storeGetScopedOrders);
router.post('/order/store-delete-orders', storeDeleteOrders);
router.post('/order/store-order-ref', storeOrderRef);

export default router;