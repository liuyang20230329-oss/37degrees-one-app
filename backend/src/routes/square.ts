import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";

export const squareRouter = Router();

squareRouter.get("/banner", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const banners = await prisma.squareBannerItem.findMany({
      where: { isActive: true },
      orderBy: { sort: "asc" },
    });
    res.json({ banners });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

squareRouter.get("/notices", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const notifications = await prisma.systemNotification.findMany({
      where: { isActive: true },
      orderBy: { createdAt: "desc" },
    });
    res.json({ notices: notifications });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

squareRouter.get("/users", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { region, gender, membershipLevel, verifiedOnly, onlineOnly, search } = req.query;
    const where: any = { deletedAt: null };
    if (region) where.city = String(region);
    if (gender) where.gender = String(gender);
    if (membershipLevel) where.membershipLevel = String(membershipLevel);
    if (verifiedOnly === "true") where.identityStatus = "verified";
    if (onlineOnly === "true") where.isOnline = true;
    if (search) {
      where.OR = [
        { name: { contains: String(search) } },
        { signature: { contains: String(search) } },
        { city: { contains: String(search) } },
      ];
    }
    const users = await prisma.user.findMany({
      where,
      select: {
        id: true, name: true, avatarKey: true, gender: true, city: true,
        signature: true, membershipLevel: true, isOnline: true,
        identityStatus: true, faceStatus: true, activityScore: true,
      },
      take: 50,
      orderBy: { activityScore: "desc" },
    });
    res.json({ users });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

squareRouter.post("/filters", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const filter = await prisma.savedSquareFilter.create({ data: { ...req.body, userId: req.userId! } });
    res.json({ filter });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

squareRouter.get("/filters", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const filters = await prisma.savedSquareFilter.findMany({ where: { userId: req.userId } });
    res.json({ filters });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
