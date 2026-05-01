import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";

export const reviewRouter = Router();

reviewRouter.get("/summary", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.userId },
      select: { phoneStatus: true, identityStatus: true, faceStatus: true },
    });
    res.json(user);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

reviewRouter.post("/identity", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { legalName, idNumber } = req.body;
    await prisma.identityVerificationRequest.create({
      data: { userId: req.userId!, legalName, idNumber, status: "approved" },
    });
    await prisma.adminAuditLog.create({
      data: {
        adminUserId: req.userId!,
        action: "identity_verified",
        targetType: "user",
        targetId: req.userId!,
        detail: `Auto-approved: ${legalName}`,
      },
    });
    const user = await prisma.user.update({
      where: { id: req.userId },
      data: {
        identityStatus: "verified",
        legalName,
        maskedIdNumber: idNumber.slice(0, 4) + "********" + idNumber.slice(-4),
      },
      include: { works: true },
    });
    res.json({ user: { ...user, passwordHash: undefined, idNumber: undefined } });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

reviewRouter.post("/face", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.faceVerificationRequest.create({
      data: { userId: req.userId!, matchScore: 0.99, status: "approved" },
    });
    await prisma.adminAuditLog.create({
      data: {
        adminUserId: req.userId!,
        action: "face_verified",
        targetType: "user",
        targetId: req.userId!,
        detail: "Auto-approved face verification",
      },
    });
    const user = await prisma.user.update({
      where: { id: req.userId },
      data: { faceStatus: "verified", faceMatchScore: 0.99 },
      include: { works: true },
    });
    res.json({ user: { ...user, passwordHash: undefined, idNumber: undefined } });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
