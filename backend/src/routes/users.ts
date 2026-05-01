import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import { safeUser } from "../utils/helpers";

export const userRouter = Router();

userRouter.get("/me/complete", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
      include: { works: true, socialAccounts: true, chatPrivacySetting: true },
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

userRouter.put("/me/profile", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const user = await prisma.user.findUnique({ where: { id: req.userId } });
    if (!user) {
      res.status(404).json({ error: "用户不存在" });
      return;
    }
    const { name, avatarKey, gender, birthYear, birthMonth, city, signature, introVideoTitle, introVideoSummary, works } = req.body;
    const data: any = {};
    if (name !== undefined) data.name = name;
    if (avatarKey !== undefined) {
      data.avatarKey = avatarKey;
      data.faceStatus = "none";
      data.faceMatchScore = null;
    }
    if (gender !== undefined && user.gender === "undisclosed") data.gender = gender;
    if (birthYear !== undefined) data.birthYear = birthYear;
    if (birthMonth !== undefined) data.birthMonth = birthMonth;
    if (city !== undefined) data.city = city;
    if (signature !== undefined) data.signature = signature;
    if (introVideoTitle !== undefined) data.introVideoTitle = introVideoTitle;
    if (introVideoSummary !== undefined) data.introVideoSummary = introVideoSummary;

    const updated = await prisma.user.update({ where: { id: req.userId }, data, include: { works: true } });

    if (Array.isArray(works)) {
      await prisma.userWork.deleteMany({ where: { userId: req.userId } });
      if (works.length > 0) {
        await prisma.userWork.createMany({ data: works.map((w: any) => ({ ...w, userId: req.userId! })) });
      }
      const refreshed = await prisma.user.findUnique({ where: { id: req.userId }, include: { works: true } });
      res.json({ user: { ...safeUser(refreshed!), works: refreshed!.works } });
      return;
    }
    res.json({ user: { ...safeUser(updated), works: updated.works } });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.get("/me/settings", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const privacy = await prisma.chatUserPrivacySetting.findUnique({ where: { userId: req.userId } });
    res.json({ settings: privacy || { friendsOnly: false, allowSquareExposure: true, preferVerifiedUsers: false } });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.put("/me/settings", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { friendsOnly, allowSquareExposure, preferVerifiedUsers } = req.body;
    const privacy = await prisma.chatUserPrivacySetting.upsert({
      where: { userId: req.userId! },
      update: { friendsOnly, allowSquareExposure, preferVerifiedUsers },
      create: { userId: req.userId!, friendsOnly, allowSquareExposure, preferVerifiedUsers },
    });
    res.json({ success: true, settings: privacy });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.get("/me/devices", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const devices = await prisma.userDeviceSession.findMany({
      where: { userId: req.userId, revokedAt: null },
      orderBy: { lastActiveAt: "desc" },
    });
    res.json({ devices });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.post("/me/devices/:deviceId/revoke", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.userDeviceSession.update({
      where: { id: req.params.deviceId },
      data: { revokedAt: new Date() },
    });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.get("/me/blacklist", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const blacklist = await prisma.chatBlacklistEntry.findMany({
      where: { userId: req.userId },
      include: { target: { select: { id: true, name: true, avatarKey: true } } },
    });
    res.json({ blacklist });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.post("/me/blacklist", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { targetUserId } = req.body;
    const entry = await prisma.chatBlacklistEntry.create({
      data: { userId: req.userId!, targetUserId },
    });
    res.json({ success: true, entry });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.delete("/me/blacklist/:targetUserId", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.chatBlacklistEntry.deleteMany({
      where: { userId: req.userId, targetUserId: req.params.targetUserId },
    });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.post("/me/works", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const work = await prisma.userWork.create({ data: { ...req.body, userId: req.userId! } });
    res.json({ work });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.delete("/me/works/:workId", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.userWork.delete({ where: { id: req.params.workId } });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.post("/me/cancel", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const coolDownEnd = new Date(Date.now() + 15 * 24 * 60 * 60 * 1000);
    await prisma.user.update({ where: { id: req.userId }, data: { deletedAt: new Date() } });
    res.json({ success: true, coolDownEnd: coolDownEnd.toISOString() });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

userRouter.get("/:userId", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.userId, deletedAt: null },
      select: {
        id: true, name: true, avatarKey: true, gender: true, city: true,
        signature: true, membershipLevel: true, isOnline: true,
        phoneStatus: true, identityStatus: true, faceStatus: true,
        activityScore: true, createdAt: true,
      },
    });
    if (!user) {
      res.status(404).json({ error: "用户不存在" });
      return;
    }
    res.json({ user });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
