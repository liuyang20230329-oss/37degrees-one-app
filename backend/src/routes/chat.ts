import { Router, Response } from "express";
import { prisma } from "../index";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import { broadcastToUser } from "../utils/websocket";

export const chatRouter = Router();

chatRouter.get("/conversations", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    let memberships = await prisma.chatConversationMember.findMany({
      where: { userId: req.userId },
      include: {
        conversation: {
          include: {
            members: { include: { user: { select: { id: true, name: true, avatarKey: true, isOnline: true } } } },
            messages: { orderBy: { createdAt: "desc" }, take: 1 },
          },
        },
      },
      orderBy: { conversation: { isPinned: "desc" } },
    });

    if (memberships.length === 0) {
      const guide = await prisma.chatConversation.create({
        data: {
          title: "37° 向导",
          subtitle: "认证、资料与权限提醒",
          categoryLabel: "系统",
          segment: "system",
          lastMessagePreview: "欢迎来到 37°。",
          isPinned: true,
          members: { create: { userId: req.userId!, unreadCount: 1 } },
          messages: {
            create: {
              senderId: req.userId!,
              senderName: "37° 向导",
              text: "欢迎来到 37°。完成手机号认证后即可开始使用全部功能。",
              type: "system",
              deliveryStatus: "Delivered",
            },
          },
        },
        include: { members: { include: { user: { select: { id: true, name: true, avatarKey: true, isOnline: true } } } }, messages: { orderBy: { createdAt: "desc" }, take: 1 } },
      });
      memberships = [{ id: "seed", userId: req.userId!, conversationId: guide.id, unreadCount: 1, lastReadAt: null, joinedAt: new Date(), conversation: guide }];
    }

    const conversations = memberships.map((m: any) => {
      const c = m.conversation;
      const lastMsg = c.messages[0];
      const otherMembers = c.members.filter((mb: any) => mb.userId !== req.userId);
      return {
        id: c.id,
        title: c.title,
        subtitle: c.subtitle,
        categoryLabel: c.categoryLabel,
        segment: c.segment,
        lastMessagePreview: c.lastMessagePreview,
        unreadCount: m.unreadCount,
        isPinned: c.isPinned,
        isOnline: otherMembers.length > 0 ? otherMembers[0].user.isOnline : false,
        members: c.members.map((mb: any) => ({ ...mb.user, unreadCount: mb.unreadCount })),
        lastMessage: lastMsg || null,
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
      };
    });

    res.json({ conversations });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.post("/conversations", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { title, subtitle, categoryLabel, segment } = req.body;
    const conversation = await prisma.chatConversation.create({
      data: {
        title: title || "新会话",
        subtitle: subtitle || "刚刚创建",
        categoryLabel: categoryLabel || "私聊",
        segment: segment || "friends",
        createdBy: req.userId,
        members: { create: { userId: req.userId! } },
      },
      include: { members: true },
    });
    broadcastToUser(req.userId!, { kind: "conversation-created", conversationId: conversation.id });
    res.json({ conversation });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.patch("/conversations/:conversationId/pin", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const conv = await prisma.chatConversation.findUnique({ where: { id: req.params.conversationId } });
    if (!conv) {
      res.status(404).json({ error: "会话不存在" });
      return;
    }
    const updated = await prisma.chatConversation.update({
      where: { id: req.params.conversationId },
      data: { isPinned: !conv.isPinned },
    });
    broadcastToUser(req.userId!, { kind: "conversation-updated", conversationId: updated.id });
    res.json({ conversation: updated });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.post("/conversations/read-all", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.chatConversationMember.updateMany({
      where: { userId: req.userId },
      data: { unreadCount: 0, lastReadAt: new Date() },
    });
    broadcastToUser(req.userId!, { kind: "conversation-read-all" });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.post("/conversations/:conversationId/read", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.chatConversationMember.updateMany({
      where: { userId: req.userId, conversationId: req.params.conversationId },
      data: { unreadCount: 0, lastReadAt: new Date() },
    });
    broadcastToUser(req.userId!, { kind: "conversation-read", conversationId: req.params.conversationId });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.delete("/conversations/:conversationId", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await prisma.chatConversationMember.deleteMany({
      where: { userId: req.userId, conversationId: req.params.conversationId },
    });
    broadcastToUser(req.userId!, { kind: "conversation-deleted", conversationId: req.params.conversationId });
    res.json({ success: true });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.get("/messages/:conversationId", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const messages = await prisma.chatMessage.findMany({
      where: { conversationId: req.params.conversationId, isRecalled: false },
      orderBy: { createdAt: "asc" },
    });
    res.json({ messages });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.post("/messages", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { conversationId, text, type = "text", mediaUrl, metadataLabel } = req.body;
    const user = await prisma.user.findUnique({ where: { id: req.userId } });
    if (!user) {
      res.status(404).json({ error: "用户不存在" });
      return;
    }
    const conv = await prisma.chatConversation.findUnique({ where: { id: conversationId } });
    if (!conv) {
      res.status(404).json({ error: "会话不存在" });
      return;
    }
    if (conv.segment !== "system" && user.phoneStatus !== "verified") {
      res.status(403).json({ error: "请先完成手机号认证" });
      return;
    }
    const message = await prisma.chatMessage.create({
      data: { conversationId, senderId: req.userId!, senderName: user.name, text, type, mediaUrl, metadataLabel },
    });
    await prisma.chatConversation.update({
      where: { id: conversationId },
      data: { lastMessagePreview: text?.slice(0, 50) || `[${type}]`, lastMessageAt: new Date() },
    });
    await prisma.chatConversationMember.updateMany({
      where: { conversationId, userId: { not: req.userId } },
      data: { unreadCount: { increment: 1 } },
    });

    const members = await prisma.chatConversationMember.findMany({ where: { conversationId } });
    members.forEach((m: any) => {
      broadcastToUser(m.userId, { kind: "message-created", conversationId, messageId: message.id });
    });

    if (conv.segment === "system" || conv.segment === "guide") {
      setTimeout(async () => {
        const replies = [
          "收到你的消息了！",
          "在 37°，每一条消息都是真实的连接。",
          "认证后可以解锁更多功能哦！",
          "有任何问题都可以随时找我。",
        ];
        const reply = replies[Math.floor(Math.random() * replies.length)];
        const autoMsg = await prisma.chatMessage.create({
          data: { conversationId, senderId: req.userId!, senderName: conv.title, text: reply, type: "text", deliveryStatus: "Delivered" },
        });
        await prisma.chatConversation.update({
          where: { id: conversationId },
          data: { lastMessagePreview: reply, lastMessageAt: new Date() },
        });
        await prisma.chatConversationMember.update({
          where: { id: (await prisma.chatConversationMember.findFirst({ where: { conversationId, userId: req.userId } }))!.id },
          data: { unreadCount: { increment: 1 } },
        });
        broadcastToUser(req.userId!, { kind: "message-created", conversationId, messageId: autoMsg.id });
      }, 1500);
    }

    res.json({ message });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.get("/privacy", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const privacy = await prisma.chatUserPrivacySetting.findUnique({ where: { userId: req.userId } });
    res.json(privacy || { friendsOnly: false, allowSquareExposure: true, preferVerifiedUsers: false });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

chatRouter.put("/privacy", authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { friendsOnly, allowSquareExposure, preferVerifiedUsers } = req.body;
    const privacy = await prisma.chatUserPrivacySetting.upsert({
      where: { userId: req.userId! },
      update: { friendsOnly, allowSquareExposure, preferVerifiedUsers },
      create: { userId: req.userId!, friendsOnly, allowSquareExposure, preferVerifiedUsers },
    });
    res.json(privacy);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});
