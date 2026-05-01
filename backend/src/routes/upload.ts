import { Router, Response } from "express";
import multer from "multer";
import path from "path";
import { v4 as uuid } from "uuid";
import { config } from "../config";
import { authMiddleware, AuthRequest } from "../middleware/auth";

const storage = multer.diskStorage({
  destination: config.uploadDir,
  filename: (_req, _file, cb) => cb(null, uuid() + path.extname(_file.originalname)),
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

export const uploadRouter = Router();

function fileResult(file: Express.Multer.File) {
  return {
    filename: file.filename,
    originalName: file.originalname,
    mimetype: file.mimetype,
    size: file.size,
    url: `/uploads/${file.filename}`,
  };
}

uploadRouter.post("/single", authMiddleware, upload.single("file"), (req: AuthRequest, res: Response) => {
  if (!req.file) {
    res.status(400).json({ error: "No file uploaded" });
    return;
  }
  res.json(fileResult(req.file));
});

uploadRouter.post("/multiple", authMiddleware, upload.array("files", 9), (req: AuthRequest, res: Response) => {
  const files = req.files as Express.Multer.File[];
  if (!files?.length) {
    res.status(400).json({ error: "No files uploaded" });
    return;
  }
  res.json({ files: files.map(fileResult) });
});

uploadRouter.post("/avatar", authMiddleware, upload.single("avatar"), (req: AuthRequest, res: Response) => {
  if (!req.file) {
    res.status(400).json({ error: "No avatar uploaded" });
    return;
  }
  res.json(fileResult(req.file));
});

uploadRouter.post("/video", authMiddleware, upload.single("video"), (req: AuthRequest, res: Response) => {
  if (!req.file) {
    res.status(400).json({ error: "No video uploaded" });
    return;
  }
  res.json(fileResult(req.file));
});

uploadRouter.post("/audio", authMiddleware, upload.single("audio"), (req: AuthRequest, res: Response) => {
  if (!req.file) {
    res.status(400).json({ error: "No audio uploaded" });
    return;
  }
  res.json(fileResult(req.file));
});

uploadRouter.delete("/:filename", authMiddleware, async (req: AuthRequest, res: Response) => {
  const fs = await import("fs/promises");
  const filePath = path.join(config.uploadDir, req.params.filename);
  try {
    await fs.unlink(filePath);
    res.json({ success: true });
  } catch {
    res.status(404).json({ error: "文件不存在" });
  }
});
