const admin = require('firebase-admin');
const express = require('express');
const bodyParser = require('body-parser');

// Firebase 서비스 계정 키 파일 경로
const serviceAccount = require('../glucocare/serviceAccountKey.json');

// Firebase Admin SDK 초기화
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(bodyParser.json());

// 푸시 알림 전송 엔드포인트
app.post('/send-notification', (req, res) => {
  const { fcmToken, title, body } = req.body;

  const message = {
    token: fcmToken,
    notification: {
      title: title,
      body: body,
    },
    data: {
      additionalData: '커스텀 데이터',
    },
  };

  // FCM 서버로 푸시 알림 보내기
  admin.messaging()
    .send(message)
    .then((response) => {
      res.status(200).send('푸시 알림 전송 성공');
      print('sented.');
    })
    .catch((error) => {
      res.status(500).send('푸시 알림 전송 실패');
      print('failed to send.');
    });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
