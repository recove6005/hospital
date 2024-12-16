const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyUserOnDataInsert = functions.firestore
.document("data/{docId}") // 'data컬렉션의 문서 추가 감지
.onCreate(async (snapshot, context) => {
  const newData = snapshot.data(); // 새로 추가된 데이터
  const addedBy = newData.addedBy;
  const targetUserId = newData.targetUserId;

  if(!addedBy || !targetUserId) {
    console.log("Invalied data structure");
    return null;
  }

  // 사용자 B의 FCM 토큰 가져오기
  const userDoc = await admin.firestore().collection("users").doc(targetUserId).get();
  if (!userDoc.exists) {
    console.log("Target user does not exist");
    return null;
  }

  const userToken = userDoc.data().fcmToken; 

  if (!userToken) {
    console.log("Target user does not have an FCM token");
    return null;
  }

  // FCM 알림 메시지 전송
  const message = {
    notification: {
      title: "new data added in data.",
      body: "User ${addedBy}.",
    },
    token: userToken,
  }

  // FCM 알림 전송
  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent notification:", response);  
  } catch(e) {
    console.error("Error sending notification:", error);
  }
  return null;
});