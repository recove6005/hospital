import express from "express";
import cors from "cors";
import session from "express-session";
import path from "path";
import { fileURLToPath } from "url";
import homeRouter from './routes/home-router.js';
import loginRouter from './routes/auth-router.js';
import userRouter from './routes/user-router.js';
import projectRouter from './routes/project-router.js';

const app = express();
const PORT = 3000;

// __dirname을 정의(ES 모듈 환경)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// middleware
app.use(cors({ origin: true }));
app.use('/project', projectRouter);

// 서버 요청 크기 늘리기
app.use(express.json( { limit: '100mb'}));

app.use(
    session({
        secret: '**daol2558**',
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
// multer를 express.json() 앞에 사용
app.use('/', homeRouter);
app.use('/login', loginRouter);
app.use('/user', userRouter);

export default app;