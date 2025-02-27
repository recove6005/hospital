import path from 'path';
import { fileURLToPath } from 'url';
import { db } from "../public/config/database-config.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const validateKey = async (req, res) => {
    const { key } = req.body;
    const entry_name = 'orders';
    const sql = "SELECT * FROM entryKeys WHERE entry_name = ?;";
    
    db.query(sql, [entry_name], (err, result) => {
        if(err) {
            return res.status(500).json({ error: err.message });
        }
        if(result[0].entry_key === key) {
            return res.sendStatus(200);
        } else {
            return res.sendStatus(401);
        }
    });
}
