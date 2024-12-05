const express = require('express')
const app = express()

// express.static(root, [option])
// Express.js에서 제공하는 내장 미들웨어
// 정적 파일을 서버에서 가져와 클라이언트에 제공
// root : 정적 파일이 저장된 기본 경로
// option : 정적 파일 제공 동작을 추가로 설정하는 객체, 캐싱 또는 숨김파일 제공 여부 등

app.use(express.static(path.join(__dirname, 'public'))) // 절대 경로 - __dirname : 현재 파일이 위치한 루트 디렉터리의 절대 경로
// app.use(express.static('public')) // 상대 경로 - /Users/username/myproject/public

// URL 경로 접두사 지정
// 모든 요청은 해당 접두사로 시작해야 정적 파일에 접근이 가능
app.use('/static', express.static(path.join(__dirname, 'public')))
