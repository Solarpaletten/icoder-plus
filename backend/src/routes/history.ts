import { Router, Request, Response } from "express";
const router = Router();

router.get("/", (req: Request, res: Response): void => {
  res.json({ message: "History route working" });
});

export default router;
