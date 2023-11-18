const functions = require("firebase-functions");
const dotenv = require("dotenv");
const {
  RtcTokenBuilder,
  RtcRole,
} = require("agora-token");
const admin = require("firebase-admin");
admin.initializeApp();
dotenv.config();

exports.generateToken = functions.https.onCall(async (data, context) => {
  const appId = process.env.APP_ID;
  const appCertificate = process.env.APP_CERTIFICATE;
  const channelName = data.channelName;
  const uid = data.uid || 0;
  const role = RtcRole.PUBLISHER;

  const expirationTimeInSeconds = data.expiryTime;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  if (channelName === undefined || channelName === null) {
    throw new functions.https.HttpsError(
        "aborted",
        "Channel name is required",
    );
  }

  try {
    const token = RtcTokenBuilder.buildTokenWithUid(
        appId,
        appCertificate,
        channelName,
        uid,
        role,
        privilegeExpiredTs,
    );
    return token;
  } catch (err) {
    throw new functions.https.HttpsError(
        "aborted",
        "Could not generate token",
    );
  }
},
);
exports.makeCall = functions.firestore
    .document("calls/{id}")
    .onCreate(async (callSnapshot) => {
      const call = callSnapshot.data();
      let callerData;
      let tokens = [];
      const usersSnapshot = await admin.firestore().collection("users").get();

      usersSnapshot.forEach(async (userDoc) => {
        const user = userDoc.data();
        if (user.id == call.caller) {
          callerData = user;
        }
        if (user.id == call.called) {
          tokens = user.tokens;
        }
      });

      if (call.active === true) {
        const callPayload = {
          data: {
            user: callerData.id,
            name: callerData.name,
            photo: callerData.photo,
            email: callerData.email,
            id: call.id,
            channel: call.channel,
            caller: call.caller,
            called: call.called,
            active: call.active.toString(),
            accepted: call.accepted.toString(),
            rejected: call.rejected.toString(),
            connected: call.connected.toString(),
          },
        };

        await admin.messaging().sendToDevice(tokens, callPayload);
      }
    });
