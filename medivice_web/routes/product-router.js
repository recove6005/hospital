import express from 'express';
import { dbOrder, dbOrderAll, dbGetOrders, dbGetScopedOrders, dbDeleteOrders, storeOrder, storeOrderAll, storeGetOrders, storeGetScopedOrders, storeDeleteOrders } from "../controllers/product-controller.js";

const router = express.Router();

// mysql
router.post('/product/db-order', dbOrder);
router.post('/product/db-order-all', dbOrderAll);
router.get('/product/db-get-all-orders', dbGetOrders);
router.post('/product/db-get-scoped-orders', dbGetScopedOrders);
router.post('/product/db-delete-orders', dbDeleteOrders);

// firestore
router.post('/product/store-order', storeOrder);
router.post('/product/store-order-all', storeOrderAll);
router.get('/product/store-get-all-orders', storeGetOrders);
router.post('/product/store-get-scoped-orders', storeGetScopedOrders);
router.post('/product/store-delete-orders', storeDeleteOrders);

export default router;