import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";

export const circleRouter = Router();

circleRouter.get("/posts", authMiddleware, async (_req: AuthRequest, res: Response) => {
  try {
    const posts = await prisma.circlePost.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        media: true,
        author: { select: { id: true, name: true, avatarKey: true, identityStatus: true, faceStatus: true } },
        _count: { select: { comments: true } },
      },
    });
    const result = posts.map((p: any) => ({
      id: p.id,
      authorId: p.authorId,
      authorName: p.authorName,
      location: p.location,
      content: p.content,
      visibility: p.visibility,
      verificationLabel: p.verificationLabel,
      likes: p.likesCount,
      comments: p._count.comments,
      media: p.media.map((m: any) => ({ media_type: m.mediaType, url: m.url, label: m.label })),
      createdAt: p.createdAt,
    }));
    res.json({ posts: result });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

circleRouter.get("/posts/:postId", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const post = await prisma.circlePost.findUnique({
      where: { id: req.params.postId },
      include: {
        media: true,
        author: { select: { id: true, name: true, avatarKey: true } },
        comments: { include: { author: { select: { id: true, name: true, avatarKey: true } } }, orderBy: { createdAt: "asc" } },
      },
    });
    if (!post) {
      res.status(404).json({ error: "动态不存在" });
      return;
    }
    res.json({
      post: {
        id: post.id,
        authorId: post.authorId,
        authorName: post.authorName,
        location: post.location,
        content: post.content,
        visibility: post.visibility,
        verificationLabel: post.verificationLabel,
        likes: post.likesCount,
        media: post.media.map((m: any) => ({ media_type: m.mediaType, url: m.url, label: m.label })),
        comments: post.comments,
        createdAt: post.createdAt,
      },
    });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

circleRouter.post("/posts", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { location, content, visibility = "public", attachments = [] } = req.body;
    const user = await prisma.user.findUnique({ where: { id: req.userId } });
    const labels: string[] = [];
    if (user?.faceStatus === "verified") labels.push("真人");
    if (user?.identityStatus === "verified") labels.push("实名");

    const post = await prisma.circlePost.create({
      data: {
        authorId: req.userId!,
        authorName: user?.name || "",
        location,
        content,
        visibility,
        verificationLabel: labels.length > 0 ? labels.join("·") : null,
        media: {
          create: attachments.map((a: any) => ({ mediaType: a.type || "image", url: a.url, label: a.label })),
        },
      },
      include: { media: true },
    });
    res.json({ post });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

circleRouter.put("/posts/:postId", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const existing = await prisma.circlePost.findUnique({ where: { id: req.params.postId } });
    if (!existing || existing.authorId !== req.userId) {
      res.status(403).json({ error: "无权编辑此动态" });
      return;
    }
    const { content, location, visibility } = req.body;
    const post = await prisma.circlePost.update({
      where: { id: req.params.postId },
      data: { content, location, visibility },
    });
    res.json({ post });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

circleRouter.post("/posts/:postId/comments", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { content, parentCommentId } = req.body;
    const user = await prisma.user.findUnique({ where: { id: req.userId } });
    const comment = await prisma.circleComment.create({
      data: { postId: req.params.postId, authorId: req.userId!, authorName: user?.name || "", content, parentCommentId },
    });
    await prisma.circlePost.update({
      where: { id: req.params.postId },
      data: { commentsCount: { increment: 1 } },
    });
    res.json({ comment });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

circleRouter.post("/posts/:postId/reports", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { reason } = req.body;
    const report = await prisma.circleReport.create({
      data: { postId: req.params.postId, reporterId: req.userId!, reason },
    });
    res.json({ success: true, report });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
