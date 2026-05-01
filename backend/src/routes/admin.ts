import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";

export const adminRouter = Router();

adminRouter.get("/dashboard", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const [totalUsers, onlineUsers, totalPosts, totalMessages] = await Promise.all([
      prisma.user.count({ where: { deletedAt: null } }),
      prisma.user.count({ where: { isOnline: true, deletedAt: null } }),
      prisma.circlePost.count(),
      prisma.chatMessage.count(),
    ]);
    res.json({ totalUsers, onlineUsers, totalPosts, totalMessages });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

adminRouter.get("/users", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const users = await prisma.user.findMany({
      where: { deletedAt: null },
      select: {
        id: true, name: true, email: true, phoneNumber: true, avatarKey: true,
        gender: true, city: true, membershipLevel: true, isOnline: true,
        phoneStatus: true, identityStatus: true, faceStatus: true,
        activityScore: true, createdAt: true,
      },
      orderBy: { createdAt: "desc" },
    });
    res.json({ users });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

adminRouter.get("/reviews", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const [identityReviews, faceReviews] = await Promise.all([
      prisma.identityVerificationRequest.findMany({ orderBy: { createdAt: "desc" }, take: 50 }),
      prisma.faceVerificationRequest.findMany({ orderBy: { createdAt: "desc" }, take: 50 }),
    ]);
    res.json({ identityReviews, faceReviews });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

adminRouter.get("/banners", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const banners = await prisma.squareBannerItem.findMany({ orderBy: { sort: "asc" } });
    res.json({ banners });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

adminRouter.get("/logs", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const logs = await prisma.adminAuditLog.findMany({
      orderBy: { createdAt: "desc" },
      take: 100,
      include: {
        adminUser: { select: { id: true, name: true } },
        auditTarget: { select: { id: true, name: true } },
      },
    });
    res.json({ logs });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
