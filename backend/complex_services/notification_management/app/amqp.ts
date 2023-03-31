import * as Amqp from "amqp-ts";
import fetch from "node-fetch";

require("dotenv").config();
const admin = require("firebase-admin");

const amqpHost = process.env.AMQP_SERVER || "localhost";
const amqpPort = process.env.AMQP_PORT || 5672;
const userServiceHost = process.env.USER_MS_SERVER || "localhost";
const userServicePort = process.env.USER_MS_PORT || 80;
const serviceAccountJsonPath = process.env.SERVICE_ACCOUNT_JSON_PATH || "../../service-account.json";

const serviceAccount = require(serviceAccountJsonPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function listenToQueue() {
  const connection = new Amqp.Connection(`amqp://${amqpHost}:${amqpPort}`);
  await connection.completeConfiguration();
  const queue = connection.declareQueue("newposts");
  const exchange = connection.declareExchange("newposts");
  queue.bind(exchange);
  queue.activateConsumer((message) => {
    console.log("Message received: " + message.getContent());
    sendNotification(message.getContent());
    message.ack();
  });
}

async function sendNotification(message: string) {
  const resp = await fetch(
    `http://${userServiceHost}:${userServicePort}/api/User/premium_users`
  );

  const premiumUsers = await resp.json();
  if (premiumUsers.length === 0) {
    console.log("No premium users to send notification to")
    return;
  }

  const messageObj = JSON.parse(message);
  const posterId = messageObj.user_id;

  const tokens: string[] = [];

  for (const user of premiumUsers) {
    if (user.userId !== posterId) {
      tokens.push(user.fcmToken);
    }
  }

  if (tokens === undefined || tokens.length === 0) {
    console.log("No premium users to send notification to")
    return;
  }

  await admin.messaging().sendMulticast({
    tokens,
    notification: {
      title: "New post",
      body: message,
    },
  });
  console.log("Notification sent to " + tokens.length + " users")
}

export { listenToQueue };
