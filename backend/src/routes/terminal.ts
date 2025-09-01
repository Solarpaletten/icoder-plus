import express from 'express'

const router = express.Router()

router.get('/status', (req, res) => {
  res.json({
    status: 'OK',
    terminal: 'WebSocket based',
    platform: process.platform
  })
})

// ✅ Экспорт для TypeScript (совместимый и с JS)
export default router