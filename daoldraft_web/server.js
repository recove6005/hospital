import express from "express";
import session from "express-session";
import dotenv from "dotenv";
import cors from "cors";
import path from "path";
import { fileURLToPath } from "url";
import homeRouter from './routes/home-router.js';
import loginRouter from './routes/auth-router.js';
import userRouter from './routes/user-router.js';
import projectRouter from './routes/project-router.js';

dotenv.config();

const app = express();
const PORT = 3000;

// __dirname을 정의(ES 모듈 환경)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// middleware
app.use(cors({ origin: true }));
app.use(express.json());

// 서버 요청 크기 늘리기
app.use(express.json( { limit: '100mb'}));

// 세션 설정
app.use(
    session({
        secret: process.env.SESSION_SECRET,
        resave: false,            // 세션 데이터가 변경되지 않으면 저장하지 않음
        saveUninitialized: false, // 초기화되지 않은 세션 저장 안 함
        cookie: {
            httpOnly: true,       // JavaScript에서 쿠키 접근 불가
            secure: false,        // HTTPS 환경에서만 작동 (배포 시 true로 설정)
            maxAge: 3600000,      // 쿠키 유효 기간 (1시간)
        },
    })
);

// 정적 파일 제공
app.use(express.static('public'));
app.use(
    "/node_modules",
    express.static(path.join(__dirname, "node_modules"))
);

// 라우터 등록
app.use('/', homeRouter);
app.use('/login', loginRouter);
app.use('/user', userRouter);
app.use('/project', projectRouter);

// server excute
app.listen(PORT, () => {
    console.log(`server is running on http://localhost:${PORT}`);
});