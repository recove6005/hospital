const functions = require("firebase-functions");
exports.hellowWorld = functions.https.onRequest((request, response) => {
  response.json({
    data: {
      message: "Hello from Firebase Functions!",
      date: new Date().toISOString(),
    },
  });
});
