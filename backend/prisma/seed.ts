import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("Seeding database...");

  const passwordHash = await bcrypt.hash("Password123!", 10);

  const demoUser = await prisma.user.upsert({
    where: { email: "13800138000@37degrees.local" },
    update: {},
    create: {
      name: "刘洋",
      email: "13800138000@37degrees.local",
      phoneNumber: "13800138000",
      maskedPhoneNumber: "138****8000",
      passwordHash,
      avatarKey: "aurora",
      gender: "undisclosed",
      birthYear: 2000,
      birthMonth: 10,
      city: "上海",
      signature: "这个人很酷，还没有留下签名。",
      phoneStatus: "verified",
      identityStatus: "verified",
      faceStatus: "verified",
      legalName: "刘洋",
      maskedIdNumber: "3101********1234",
      faceMatchScore: 0.986,
      membershipLevel: "standard",
      isOnline: true,
      activityScore: 75,
    },
  });

  await prisma.chatUserPrivacySetting.upsert({
    where: { userId: demoUser.id },
    update: {},
    create: {
      userId: demoUser.id,
      friendsOnly: false,
      allowSquareExposure: true,
      preferVerifiedUsers: false,
    },
  });

  const guideConversation = await prisma.chatConversation.create({
    data: {
      title: "37° 向导",
      subtitle: "认证、资料与权限提醒",
      categoryLabel: "系统",
      segment: "system",
      lastMessagePreview: "欢迎来到 37°。",
      isPinned: true,
      members: {
        create: { userId: demoUser.id, unreadCount: 1 },
      },
      messages: {
        create: {
          senderId: demoUser.id,
          senderName: "37° 向导",
          text: "欢迎来到 37°。完成手机号认证后即可开始使用全部功能。",
          type: "system",
          deliveryStatus: "Delivered",
        },
      },
    },
  });

  await prisma.systemNotification.create({
    data: {
      title: "欢迎使用 37°",
      content: "感谢您加入 37° 社交平台，开始探索吧！",
      type: "welcome",
      isActive: true,
      userNotifications: {
        create: { userId: demoUser.id },
      },
    },
  });

  await prisma.squareBannerItem.createMany({
    data: [
      { title: "新人认证享特权", imageUrl: "/uploads/banner1.jpg", sort: 1 },
      { title: "实名认证更安全", imageUrl: "/uploads/banner2.jpg", sort: 2 },
    ],
  });

  console.log(`Demo user: ${demoUser.id}`);
  console.log(`Guide conversation: ${guideConversation.id}`);
  console.log("Seed completed.");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
