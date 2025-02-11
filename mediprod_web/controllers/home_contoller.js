import path from "path";
import { fileURLToPath } from "url";

// __dirname 설정
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getHomePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../public/html/home.html'));
};