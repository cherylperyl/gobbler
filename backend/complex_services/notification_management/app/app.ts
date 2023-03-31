import * as Koa from "koa";
import * as cors from "@koa/cors";
import { koaSwagger } from 'koa2-swagger-ui';

const serve = require("koa-static");
const koaValidator = require("koa-async-validator");
const { koaBody } = require("koa-body");

import { routes } from "./routes";
import { listenToQueue } from "./amqp";

const app = new Koa();

app.use(koaBody());
app.use(koaValidator());
app.use(cors());
app.use(routes);
app.use(serve("public"));
app.use(
  koaSwagger({
    routePrefix: "/swagger",
    swaggerOptions: {
      url: "/swagger.yml",
    },
  })
);

export const server = app.listen(3000);
listenToQueue();

console.log(`Server running on port 3000`);
