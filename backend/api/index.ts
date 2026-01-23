import { IncomingMessage, ServerResponse } from "http";
import app from "../src/app";

export default async (req: IncomingMessage, res: ServerResponse) => {
  await app.ready();
  app.server.emit("request", req, res);
};
