import jwt from "jsonwebtoken";
import { Request, Response, NextFunction } from "express";
import { config } from "../config";

export interface AuthRequest extends Request {
  userId?: string;
}

export function authMiddleware(req: AuthRequest, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    res.status(401).json({ error: "未登录" });
    return;
  }
  try {
    const payload = jwt.verify(header.slice(7), config.jwtSecret) as { userId: string };
    req.userId = payload.userId;
    next();
  } catch {
    res.status(401).json({ error: "登录已过期" });
  }
}

export function generateToken(userId: string): string {
  return jwt.sign({ userId }, config.jwtSecret, { expiresIn: config.jwtExpiresIn as any });
}
