import express from 'express'

const router = express.Router()

router.get('/status', (req, res) => {
  res.json({
    status: 'OK',
    terminal: 'WebSocket based',
    platform: process.platform
  })
})

// ✅ Чистый JS-экспорт
export default router