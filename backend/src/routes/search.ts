import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";

export const searchRouter = Router();

searchRouter.get("/users", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const q = String(req.query.q || "");
    if (!q) {
      res.json({ users: [] });
      return;
    }
    const users = await prisma.user.findMany({
      where: {
        deletedAt: null,
        OR: [
          { name: { contains: q } },
          { signature: { contains: q } },
          { city: { contains: q } },
        ],
      },
      select: {
        id: true, name: true, avatarKey: true, gender: true, city: true,
        signature: true, membershipLevel: true, isOnline: true,
      },
      take: 20,
    });
    res.json({ users });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
