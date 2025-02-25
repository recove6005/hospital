import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();
const PORT = 3000;

// __dirname을 정의(ES 모듈 환경)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// 미들 웨어 설정
app.use(express.json());

// 서버 요청 크기 확장
app.use(express.json({limit: '50mb'} ));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// public 폴더를 정적 파일로 제공
app.use(express.static('public')); 

// node_modules를 정적 파일로 제공
app.use("/node_modules", express.static(path.join(__dirname, "node_modules"))); 

// 라우터 등록
// app.use('/', './public/intro/index.html');
// import homeRouter from './routers/home_router.js';
// app.use('/', homeRouter);

// 서버 실행
app.listen(PORT, () => {
	console.log(`Server is running on http://localhost:${PORT}`);
});