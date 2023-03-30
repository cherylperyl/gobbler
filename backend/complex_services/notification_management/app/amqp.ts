import * as Amqp from "amqp-ts";
import fetch from "node-fetch";

const admin = require("firebase-admin");

require("dotenv").config();

const amqpHost = process.env.AMQP_SERVER || "localhost";
const amqpPort = process.env.AMQP_PORT || 5672;
const userServiceHost = process.env.USER_MS_SERVER || "localhost";
const userServicePort = process.env.USER_MS_PORT || 80;

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
  const premiumUsers = (await fetch(
    `http://${userServiceHost}:${userServicePort}/premium`
  ).then((res: any) => res.json())) as Array<{}>;

  const tokens = premiumUsers.map((user: any) => user.token);

  await admin.messaging().sendMulticast({
    tokens,
    notification: {
      title: "New post",
      body: message,
    },
  });
}

export { listenToQueue };
