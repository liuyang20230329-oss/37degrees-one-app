import { Request, Response } from "express";
import { AuthRequest } from "../middleware/auth";

export function safeUser(user: any) {
  const { passwordHash, idNumber, ...safe } = user;
  return safe;
}

export function getUserId(req: Request): string | undefined {
  return (req as AuthRequest).userId;
}
