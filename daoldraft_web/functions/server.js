import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import session from "express-session";
import path from "path";
import { fileURLToPath } from "url";

import homeRouter from './routes/home-router.js';
import loginRouter from './routes/auth-router.js';
import userRouter from './routes/user-router.js';
import projectRouter from './routes/project-router.js';

const expressApp = express();

// __dirname을 정의(ES 모듈 환경)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// middleware
expressApp.use(express.json());
expressApp.use(cors());
expressApp.use(bodyParser.json());

console.log(`PORT: ${process.env.PORT}`);

expressApp.use(
    session({
        secret: process.env.DAOLKEY,
        resave: false,            // 세션 데이터가 변경되지 않으면 저장하지 않음
        saveUninitialized: false, // 초기화되지 않은 세션 저장 안 함
    })
);
// 서버 요청 크기 늘리기
expressApp.use(express.json( { limit: '50mb'}));
expressApp.use(express.urlencoded({ limit: '50mb', extended: true }));

// 정적 파일 제공
expressApp.use(express.static('public'));
expressApp.use(
    "/node_modules",
    express.static(path.join(__dirname, "node_modules"))
);

expressApp.get("/", (req, res) => {
    res.send("Hello from Firebase Functions!");
});

// 라우터 등록
expressApp.use('/', homeRouter);
expressApp.use('/login', loginRouter);
expressApp.use('/user', userRouter);
expressApp.use('/project', projectRouter);

// Firebase Functions에 Express 앱 등록
export default expressApp;