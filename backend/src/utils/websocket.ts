import { WebSocketServer, WebSocket } from "ws";
import { Server } from "http";
import jwt from "jsonwebtoken";
import { config } from "../config";

interface ClientWs extends WebSocket {
  userId?: string;
}

let wss: WebSocketServer;
const clients = new Map<string, Set<ClientWs>>();

export function initWebSocket(server: Server) {
  wss = new WebSocketServer({ server, path: "/ws/chat" });

  wss.on("connection", (ws: ClientWs, req) => {
    try {
      const url = new URL(req.url || "", `http://${req.headers.host}`);
      const token = url.searchParams.get("token");
      if (!token) {
        ws.close(4001, "Missing token");
        return;
      }
      const payload = jwt.verify(token, config.jwtSecret) as { userId: string };
      ws.userId = payload.userId;

      if (!clients.has(ws.userId)) clients.set(ws.userId, new Set());
      clients.get(ws.userId)!.add(ws);

      ws.send(JSON.stringify({ kind: "connected" }));

      ws.on("close", () => {
        if (ws.userId && clients.has(ws.userId)) {
          clients.get(ws.userId)!.delete(ws);
          if (clients.get(ws.userId)!.size === 0) clients.delete(ws.userId);
        }
      });
    } catch {
      ws.close(4001, "Invalid token");
    }
  });
}

export function broadcastToUser(userId: string, event: { kind: string; [key: string]: any }) {
  const userClients = clients.get(userId);
  if (!userClients) return;
  const data = JSON.stringify(event);
  userClients.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) ws.send(data);
  });
}
