import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";

export const notificationRouter = Router();

notificationRouter.get("/", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    let notifications = await prisma.userNotification.findMany({
      where: { userId: req.userId },
      include: { systemNotification: true },
      orderBy: { createdAt: "desc" },
    });
    if (notifications.length === 0) {
      const sys = await prisma.systemNotification.create({
        data: {
          title: "欢迎使用 37°",
          content: "感谢您加入 37° 社交平台，开始探索吧！",
          type: "welcome",
          userNotifications: { create: { userId: req.userId! } },
        },
      });
      notifications = await prisma.userNotification.findMany({
        where: { userId: req.userId },
        include: { systemNotification: true },
        orderBy: { createdAt: "desc" },
      });
    }
    res.json({ notifications });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

notificationRouter.put("/:notificationId/read", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.userNotification.update({
      where: { id: req.params.notificationId },
      data: { isRead: true },
    });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

notificationRouter.put("/read-all", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.userNotification.updateMany({
      where: { userId: req.userId, isRead: false },
      data: { isRead: true },
    });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
