// backend/src/middleware/cors.js
import cors from "cors";

const allow = [
  "http://localhost:5173",
  "https://icoder-solar.onrender.com",
];

export default cors({
  origin(origin, cb) {
    if (!origin) return cb(null, true);
    cb(allow.includes(origin) ? null : new Error("Not allowed by CORS"), true);
  },
  credentials: true
});