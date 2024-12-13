// 플러터 프로젝트 - firebase에 notification컬렉션 추가
// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> addNotification(String userId, String message) async {
//   try {
//     await FirebaseFirestore.instance.collection('notifications').add({
//       'userId': userId, // 알림을 받을 사용자 ID
//       'message': message, // 푸시 알림 내용
//       'timestamp': FieldValue.serverTimestamp(), // 서버 시간
//     });
//     print("Notification added successfully!");
//   } catch (e) {
//     print("Error adding notification: $e");
//   }
// }

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendPushNotification = functions.firestore
  .document("notifications/{docId}") // 'notifications' 컬렉션의 새 문서 추가 감지
  .onCreate(async (snapshot, context) => {
    try {
      // Firestore에서 추가된 데이터 읽기
      const data = snapshot.data();
      const userId = data.userId;
      const message = data.message;

      // Firestore에서 사용자의 FCM 토큰 가져오기
      const userDoc = await admin.firestore().collection("users").doc(userId).get();
      if (!userDoc.exists) {
        console.log(`User with ID ${userId} not found.`);
        return;
      }

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) {
        console.log(`FCM token for user ${userId} not found.`);
        return;
      }

      // FCM 푸시 알림 메시지 생성
      const payload = {
        notification: {
          title: "새 알림",
          body: message,
        },
        token: fcmToken,
      };

      // FCM 푸시 알림 전송
      await admin.messaging().send(payload);
      console.log(`Notification sent to user ${userId}`);
    } catch (error) {
      console.error("Error sending push notification:", error);
    }
  });

  

// 플러터 프로젝트 - FCM토큰을 Firestore의 user컬렉션에 저장
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> setupFCM(String userId) async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // FCM 토큰 가져오기
//   String? token = await messaging.getToken();
//   if (token != null) {
//     // Firestore에 FCM 토큰 저장
//     await FirebaseFirestore.instance.collection('users').doc(userId).set({
//       'fcmToken': token,
//     }, SetOptions(merge: true));
//     print("FCM Token saved: $token");
//   }
// }


// notification 컬렉션 : 알림 정보
// {
//     "userId": "user123",
//     "message": "새로운 메시지가 도착했습니다!",
//     "timestamp": "2024-12-13T10:00:00Z"
// }

// user 컬렉션 : 사용자 정보
// {
//     "fcmToken": "abcdef123456", // 사용자의 FCM 토큰
//     "name": "John Doe"
// }
