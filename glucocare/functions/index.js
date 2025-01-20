const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendPushNotification = functions.https.onRequest(async (req, res) => {
    try {
        if (req.method !== "POST") {
            return res.status(405).send({ success: false, error: "Method not allowed" });
        }

        const { tokens, name, type, value, checkDate, checkTime } = req.body;

        // Subscribe tokens to the topic
        await admin.messaging().subscribeToTopic(tokens, 'patient_alert');

        let message = {};

        // FCM 메시지 정의
        if(type == '혈당') {
            message = {
                topic: 'patient_alert',
                notification: {
                    title: `혈당 수치 위험 환자 : ${name}`,
                    body: `${checkDate} ${checkTime} 측정된 ${name}님의 혈당 측정 수치가 ${value}mg/dL 로 위험 수준입니다. [위험환자관리] 탭을 확인해 주세요.`,
                
                },
                android: {
                    priority: 'high',
                },
                apns: {
                    headers: {
                        'apns-priority': '10'
                    },
                },
            };
        } else if(type == '혈압') {
            message = {
                topic: 'patient_alert',
                notification: {
                    title: `혈압 수치 위험 환자 : ${name}`,
                    body: `${checkDate} ${checkTime} 측정된 ${name}님의 혈당 측정 수치가 ${value}mg/dL 로 위험 수준입니다. [위험환자관리] 탭을 확인해 주세요.`,
                }
            };
        }

        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);

        return res.status(200).json({ success: true });
    } catch(error) {
        console.error("Error sending message:", error);

        return res.status(500).json({ success: false, error: error.message });
    }
});