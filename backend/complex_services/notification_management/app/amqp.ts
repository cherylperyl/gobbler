import * as Amqp from "amqp-ts";
import fetch from "node-fetch";

require("dotenv").config();
const admin = require("firebase-admin");

const amqpHost = process.env.AMQP_SERVER || "localhost";
const amqpPort = process.env.AMQP_PORT || 5672;
const userServiceHost = process.env.USER_MS_SERVER || "localhost";
const userServicePort = process.env.USER_MS_PORT || 80;
const reservationServiceHost = process.env.RESERVATION_MS_SERVER || "localhost";
const reservationServicePort = process.env.RESERVATION_MS_PORT || 80;
const serviceAccountJsonPath =
  process.env.SERVICE_ACCOUNT_JSON_PATH || "../../service-account.json";

const serviceAccount = require(serviceAccountJsonPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const queues: Record<string, Function> = {
  newpost: sendNewPostNotification,
  updatepost: sendUpdatePostNotification,
  deletepost: sendDeletePostNotification,
};

async function listenToQueue(): Promise<void> {
  const connection = new Amqp.Connection(`amqp://${amqpHost}:${amqpPort}`);
  await connection.completeConfiguration();

  for (const queueName in queues) {
    const queue = connection.declareQueue(queueName);
    queue.activateConsumer((message: Amqp.Message) => {
      console.log(
        `Message received in queue ${queueName}: ${message.getContent()}`
      );
      queues[queueName](message.getContent());
      message.ack();
    });
  }
}

async function sendNewPostNotification(message: string) {
  const resp = await fetch(
    `http://${userServiceHost}:${userServicePort}/api/User/premium_users`
  );

  const premiumUsers = await resp.json();
  if (premiumUsers.length === 0) {
    console.log("No premium users to send notification to");
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
    console.log("No premium users to send notification to");
    return;
  }

  await admin.messaging().sendMulticast({
    tokens,
    notification: {
      title: "New post",
      body: message,
    },
  });
  console.log("Notification sent to " + tokens.length + " users");
}

async function getAffectedUserTokens(message: string): Promise<string[]> {
  const messageObj = JSON.parse(message);
  const post_id = messageObj.post_id;
  const resp = await fetch(
    `http://${reservationServiceHost}:${reservationServicePort}/reservations/post/${post_id}`
  );
  if (resp.status === 404) {
    console.log("No reservations for this post");
    return;
  }

  const reservations = await resp.json();
  if (reservations.length === 0) {
    console.log("No users to send notification to");
    return;
  }

  const tokens: string[] = [];
  for (const reservation of reservations) {
    const user = await fetch(
      `http://${userServiceHost}:${userServicePort}/api/User/${reservation.user_id}`
    );
    const userJson = await user.json();
    tokens.push(userJson.fcmToken);
  }

  return tokens;
}

async function sendUpdatePostNotification(message: string) {
  const tokens = await getAffectedUserTokens(message);

  await admin.messaging().sendMulticast({
    tokens,
    notification: {
      title: "A post you reserved has been updated",
      body: message,
    },
  });
  console.log("Notification sent to " + tokens.length + " users");
}

async function sendDeletePostNotification(message: string) {
  const tokens = await getAffectedUserTokens(message);

  await admin.messaging().sendMulticast({
    tokens,
    notification: {
      title: "A post you reserved has been deleted",
      body: message,
    },
  });
  console.log("Notification sent to " + tokens.length + " users");
}

export { listenToQueue };
