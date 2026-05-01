-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL DEFAULT '',
    "email" TEXT NOT NULL DEFAULT '',
    "phoneNumber" TEXT,
    "maskedPhoneNumber" TEXT,
    "passwordHash" TEXT NOT NULL DEFAULT '',
    "avatarKey" TEXT NOT NULL DEFAULT 'aurora',
    "gender" TEXT NOT NULL DEFAULT 'undisclosed',
    "birthYear" INTEGER,
    "birthMonth" INTEGER,
    "city" TEXT NOT NULL DEFAULT '',
    "signature" TEXT NOT NULL DEFAULT '这个人很酷，还没有留下签名。',
    "introVideoTitle" TEXT NOT NULL DEFAULT '还没有上传视频介绍',
    "introVideoSummary" TEXT NOT NULL DEFAULT '后续可以用一段视频介绍自己，让更多人更快认识你。',
    "phoneStatus" TEXT NOT NULL DEFAULT 'none',
    "identityStatus" TEXT NOT NULL DEFAULT 'none',
    "faceStatus" TEXT NOT NULL DEFAULT 'none',
    "legalName" TEXT,
    "idNumber" TEXT,
    "maskedIdNumber" TEXT,
    "faceMatchScore" REAL,
    "membershipLevel" TEXT NOT NULL DEFAULT 'standard',
    "isOnline" BOOLEAN NOT NULL DEFAULT false,
    "activityScore" INTEGER NOT NULL DEFAULT 0,
    "deletedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "sms_codes" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "phoneNumber" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "purpose" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" DATETIME NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "user_social_accounts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "providerUid" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_social_accounts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "user_device_sessions" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "platform" TEXT NOT NULL DEFAULT 'unknown',
    "deviceModel" TEXT,
    "pushToken" TEXT,
    "ipAddress" TEXT,
    "lastActiveAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_device_sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "identity_verification_requests" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "legalName" TEXT NOT NULL,
    "idNumber" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'approved',
    "reviewedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "identity_verification_requests_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "face_verification_requests" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "matchScore" REAL NOT NULL DEFAULT 0.99,
    "status" TEXT NOT NULL DEFAULT 'approved',
    "reviewedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "face_verification_requests_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "user_works" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "summary" TEXT NOT NULL DEFAULT '',
    "mediaUrl" TEXT,
    "duration" INTEGER,
    "isPinned" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_works_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chat_conversations" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "subtitle" TEXT NOT NULL DEFAULT '',
    "categoryLabel" TEXT NOT NULL DEFAULT '',
    "segment" TEXT NOT NULL DEFAULT 'private',
    "lastMessagePreview" TEXT,
    "lastMessageAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isPinned" BOOLEAN NOT NULL DEFAULT false,
    "createdBy" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "chat_conversation_members" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "conversationId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "unreadCount" INTEGER NOT NULL DEFAULT 0,
    "lastReadAt" DATETIME,
    "joinedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chat_conversation_members_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "chat_conversations" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "chat_conversation_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chat_messages" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "conversationId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "senderName" TEXT NOT NULL DEFAULT '',
    "text" TEXT,
    "type" TEXT NOT NULL DEFAULT 'text',
    "deliveryStatus" TEXT NOT NULL DEFAULT 'Sent',
    "mediaUrl" TEXT,
    "metadataLabel" TEXT,
    "isRecalled" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chat_messages_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "chat_conversations" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "chat_messages_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chat_user_privacy_settings" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "friendsOnly" BOOLEAN NOT NULL DEFAULT false,
    "allowSquareExposure" BOOLEAN NOT NULL DEFAULT true,
    "preferVerifiedUsers" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "chat_user_privacy_settings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "chat_blacklist_entries" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "targetUserId" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "chat_blacklist_entries_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "chat_blacklist_entries_targetUserId_fkey" FOREIGN KEY ("targetUserId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "circle_posts" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "authorId" TEXT NOT NULL,
    "authorName" TEXT NOT NULL DEFAULT '',
    "location" TEXT,
    "content" TEXT NOT NULL,
    "visibility" TEXT NOT NULL DEFAULT 'public',
    "verificationLabel" TEXT,
    "likesCount" INTEGER NOT NULL DEFAULT 0,
    "commentsCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    CONSTRAINT "circle_posts_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "circle_post_media" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "postId" TEXT NOT NULL,
    "mediaType" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "label" TEXT,
    CONSTRAINT "circle_post_media_postId_fkey" FOREIGN KEY ("postId") REFERENCES "circle_posts" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "circle_comments" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "postId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "authorName" TEXT NOT NULL DEFAULT '',
    "content" TEXT NOT NULL,
    "parentCommentId" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "circle_comments_postId_fkey" FOREIGN KEY ("postId") REFERENCES "circle_posts" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "circle_comments_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "circle_comments_parentCommentId_fkey" FOREIGN KEY ("parentCommentId") REFERENCES "circle_comments" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "circle_reports" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "postId" TEXT NOT NULL,
    "reporterId" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "circle_reports_postId_fkey" FOREIGN KEY ("postId") REFERENCES "circle_posts" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "circle_reports_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "system_notifications" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'info',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "user_notifications" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "systemNotificationId" TEXT,
    "title" TEXT,
    "content" TEXT,
    "type" TEXT NOT NULL DEFAULT 'system',
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "user_notifications_systemNotificationId_fkey" FOREIGN KEY ("systemNotificationId") REFERENCES "system_notifications" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "square_banner_items" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "imageUrl" TEXT,
    "linkUrl" TEXT,
    "sort" INTEGER NOT NULL DEFAULT 0,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "saved_square_filters" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "region" TEXT,
    "gender" TEXT,
    "ageMin" INTEGER,
    "ageMax" INTEGER,
    "membershipLevel" TEXT,
    "verifiedOnly" BOOLEAN NOT NULL DEFAULT false,
    "onlineOnly" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "saved_square_filters_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "admin_audit_logs" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "adminUserId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "targetType" TEXT,
    "targetId" TEXT,
    "detail" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "admin_audit_logs_adminUserId_fkey" FOREIGN KEY ("adminUserId") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "admin_audit_logs_targetId_fkey" FOREIGN KEY ("targetId") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_phoneNumber_key" ON "users"("phoneNumber");

-- CreateIndex
CREATE UNIQUE INDEX "user_social_accounts_provider_providerUid_key" ON "user_social_accounts"("provider", "providerUid");

-- CreateIndex
CREATE UNIQUE INDEX "chat_conversation_members_conversationId_userId_key" ON "chat_conversation_members"("conversationId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "chat_user_privacy_settings_userId_key" ON "chat_user_privacy_settings"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "chat_blacklist_entries_userId_targetUserId_key" ON "chat_blacklist_entries"("userId", "targetUserId");
