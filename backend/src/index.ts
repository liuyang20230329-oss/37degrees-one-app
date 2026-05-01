import express from "express";
import cors from "cors";
import path from "path";
import { createServer } from "http";
import { PrismaClient } from "@prisma/client";
import { config } from "./config";
import { errorHandler } from "./middleware/errorHandler";
import { initWebSocket } from "./utils/websocket";
import { authRouter } from "./routes/auth";
import { userRouter } from "./routes/users";
import { chatRouter } from "./routes/chat";
import { circleRouter } from "./routes/circle";
import { squareRouter } from "./routes/square";
import { notificationRouter } from "./routes/notifications";
import { searchRouter } from "./routes/search";
import { uploadRouter } from "./routes/upload";
import { adminRouter } from "./routes/admin";
import { reviewRouter } from "./routes/reviews";

export const prisma = new PrismaClient();

const app = express();
const server = createServer(app);

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.resolve(config.uploadDir)));

app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "37degrees-api", mode: "postgresql" });
});

app.get("/api/v1/status", (_req, res) => {
  res.json({ version: "1.0.0", endpoints: "50+", database: "postgresql" });
});

app.use("/api/v1/auth", authRouter);
app.use("/api/v1/users", userRouter);
app.use("/api/v1/chat", chatRouter);
app.use("/api/v1/circle", circleRouter);
app.use("/api/v1/square", squareRouter);
app.use("/api/v1/notifications", notificationRouter);
app.use("/api/v1/search", searchRouter);
app.use("/api/v1/upload", uploadRouter);
app.use("/api/v1/admin", adminRouter);
app.use("/api/v1/reviews", reviewRouter);

app.use(errorHandler);

initWebSocket(server);

server.listen(config.port, () => {
  console.log(`37° API running on port ${config.port} [${config.nodeEnv}]`);
});

export { app, server };
