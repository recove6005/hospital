const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendPushNotification = functions.https.onRequest(async (req, res) => {
    try {
        const { tokens, name, type, value, checkDate, checkTime } = req.body;
        console.log(req.body);

        if (req.method !== "POST") {
            return res.status(405).send({ success: false, error: "Method not allowed 405" });
        }

        // tokens 배열 검증
        if (!Array.isArray(tokens) || tokens.length === 0) {
            return res.status(400).json({ success: false, error: "Tokens must be a non-empty array 400" });
        }

        // Subscribe tokens to the topic
        // await admin.messaging().subscribeToTopic(tokens, 'patient_alert');

        const notification = {
            title: type === '혈당' ? `혈당 수치 위험 환자 : ${name}` : `혈압 수치 위험 환자 : ${name}`,
            body: type === '혈당' 
                ? `[${name}님의 혈당 수치가 ${value}mg/dL 으로 위험 수준입니다. [위험환자관리] 탭을 확인해 주세요.`
                : `[${name}님의 혈압 수치가 ${value}mmHg 으로 위험 수준입니다. [위험환자관리] 탭을 확인해 주세요.`,
        };


        // FCM 메시지 정의
        const message = {
            tokens: tokens,
            data: notification,
            notification: notification,  
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        console.log("Successfully sent message:", response);

        return res.status(200).json({ success: true });
    } catch(error) {
        console.error("Error sending message:", error);

        return res.status(500).json({ success: false, error: error.message });
    }
});