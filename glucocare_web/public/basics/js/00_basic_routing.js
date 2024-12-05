const express = require('express')
const app = express()

// get
// 클라이언트로부터 데이터 요청
app.get('/', (req, res) => {
    res.send('Hellow World!')
})

// post
// 클라이언트가 서버로 데이터 전송
app.post('/', (req, res) => {
    res.send('Got a POST request')
})

// put
// 서버에 저장된 데이터 수정
app.put('/user', (req, res) => {
    res.send(`Got a PUT request at /user.`)
})

// delete
// 서버에 저장된 데이터 삭제
app.delete('/user', (req, res) => {
    res.send(`Got a DELETE request at /user`)
})