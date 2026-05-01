import dotenv from "dotenv";
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || "3001", 10),
  jwtSecret: process.env.JWT_SECRET || "change-me",
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || "7d",
  uploadDir: process.env.UPLOAD_DIR || "./uploads",
  nodeEnv: process.env.NODE_ENV || "development",
};
