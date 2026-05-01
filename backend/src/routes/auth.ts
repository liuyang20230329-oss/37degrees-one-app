import { Router, Request, Response } from "express";
import bcrypt from "bcryptjs";
import { v4 as uuid } from "uuid";
import { prisma } from "../index";
import { authMiddleware, generateToken, AuthRequest } from "../middleware/auth";
import { safeUser } from "../utils/helpers";

export const authRouter = Router();

authRouter.post("/sms/send", async (req: Request, res: Response) => {
  try {
    const { phoneNumber, purpose = "general" } = req.body;
    if (!phoneNumber) {
      res.status(400).json({ error: "手机号不能为空" });
      return;
    }
    const code = String(Math.floor(100000 + Math.random() * 900000));
    const sessionId = uuid();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    await prisma.smsCode.create({ data: { phoneNumber, code, purpose, sessionId, expiresAt } });
    res.json({ sessionId, debugCode: code, expiresAt: expiresAt.toISOString() });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/register", async (req: Request, res: Response) => {
  try {
    const { name, phoneNumber, smsCode, password } = req.body;
    if (!phoneNumber || !smsCode || !password) {
      res.status(400).json({ error: "缺少必填字段" });
      return;
    }
    const latest = await prisma.smsCode.findFirst({
      where: { phoneNumber, purpose: "register", verified: false },
      orderBy: { createdAt: "desc" },
    });
    if (!latest || latest.code !== smsCode || new Date() > latest.expiresAt) {
      res.status(400).json({ error: "验证码无效或已过期" });
      return;
    }
    const exists = await prisma.user.findUnique({ where: { phoneNumber } });
    if (exists) {
      res.status(409).json({ error: "该手机号已注册" });
      return;
    }
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        name: name || phoneNumber,
        email: `${phoneNumber}@37degrees.local`,
        phoneNumber,
        maskedPhoneNumber: phoneNumber.slice(0, 3) + "****" + phoneNumber.slice(-4),
        passwordHash,
        phoneStatus: "verified",
      } as any,
    });
    await prisma.smsCode.update({ where: { id: latest.id }, data: { verified: true } });
    await prisma.chatUserPrivacySetting.create({ data: { userId: user.id } });
    await prisma.userDeviceSession.create({
      data: { userId: user.id, platform: "mobile", ipAddress: req.ip },
    });
    const token = generateToken(user.id);
    res.json({ user: safeUser(user), token });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/login", async (req: Request, res: Response) => {
  try {
    const { phoneNumber, password } = req.body;
    if (!phoneNumber || !password) {
      res.status(400).json({ error: "缺少手机号或密码" });
      return;
    }
    const user = await prisma.user.findUnique({
      where: { phoneNumber },
      include: { works: true },
    });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      res.status(401).json({ error: "手机号或密码错误" });
      return;
    }
    if (user.deletedAt) {
      res.status(403).json({ error: "账号已注销" });
      return;
    }
    await prisma.user.update({ where: { id: user.id }, data: { isOnline: true } });
    const token = generateToken(user.id);
    res.json({ user: { ...safeUser(user), works: user.works }, token });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.get("/me", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
      include: { works: true },
    });
    if (!user) {
      res.status(404).json({ error: "用户不存在" });
      return;
    }
    res.json({ user: { ...safeUser(user), works: user.works } });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/phone/confirm", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { sessionId, phoneNumber, code } = req.body;
    const sms = await prisma.smsCode.findFirst({
      where: { sessionId, phoneNumber, purpose: "verify-phone", verified: false },
    });
    if (!sms || sms.code !== code || new Date() > sms.expiresAt) {
      res.status(400).json({ error: "验证码无效" });
      return;
    }
    await prisma.smsCode.update({ where: { id: sms.id }, data: { verified: true } });
    const user = await prisma.user.update({
      where: { id: req.userId },
      data: {
        phoneNumber,
        maskedPhoneNumber: phoneNumber.slice(0, 3) + "****" + phoneNumber.slice(-4),
        phoneStatus: "verified",
      },
    });
    res.json({ user: safeUser(user) });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/password-reset/request", async (req: Request, res: Response) => {
  try {
    const { phoneNumber } = req.body;
    if (!phoneNumber) {
      res.status(400).json({ error: "手机号不能为空" });
      return;
    }
    const code = String(Math.floor(100000 + Math.random() * 900000));
    const sessionId = uuid();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
    await prisma.smsCode.create({ data: { phoneNumber, code, purpose: "password-reset", sessionId, expiresAt } });
    res.json({ sessionId, debugCode: code, expiresAt: expiresAt.toISOString() });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/password-reset/confirm", async (req: Request, res: Response) => {
  try {
    const { phoneNumber, code, newPassword } = req.body;
    const sms = await prisma.smsCode.findFirst({
      where: { phoneNumber, purpose: "password-reset", verified: false },
      orderBy: { createdAt: "desc" },
    });
    if (!sms || sms.code !== code || new Date() > sms.expiresAt) {
      res.status(400).json({ error: "验证码无效" });
      return;
    }
    const passwordHash = await bcrypt.hash(newPassword, 10);
    await prisma.user.update({ where: { phoneNumber }, data: { passwordHash } });
    await prisma.smsCode.update({ where: { id: sms.id }, data: { verified: true } });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/social/wechat", (_req: Request, res: Response) => {
  res.status(501).json({ error: "微信登录暂未开放" });
});

authRouter.post("/social/qq", (_req: Request, res: Response) => {
  res.status(501).json({ error: "QQ登录暂未开放" });
});

authRouter.post("/social/bind", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { provider, providerUid } = req.body;
    await prisma.userSocialAccount.create({ data: { userId: req.userId!, provider, providerUid } });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/social/unbind", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { provider } = req.body;
    await prisma.userSocialAccount.deleteMany({ where: { userId: req.userId!, provider } });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

authRouter.post("/logout", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.user.update({ where: { id: req.userId }, data: { isOnline: false } });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
