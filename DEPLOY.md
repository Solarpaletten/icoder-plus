# 🚀 iCoder Plus - Vercel Deployment Guide

## Quick Deploy

### Option 1: Automated Script
```bash
./deploy.sh
```

### Option 2: Manual Deploy

**Frontend:**
```bash
cd frontend
npm run build
npx vercel --prod
```

**Backend:** 
```bash
cd backend
npm run build
npx vercel --prod
```

## Environment Variables

### Frontend (Vercel Dashboard)
```
NODE_ENV=production
VITE_API_URL=https://your-backend.vercel.app/api
VITE_APP_NAME=iCoder Plus
VITE_APP_VERSION=2.0.0
```

### Backend (Vercel Dashboard)
```
NODE_ENV=production
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_claude_key
PORT=3000
```

## Custom Domains

After deploy, you can add custom domains:
- Frontend: `icoder.yourdomain.com`
- Backend: `api.yourdomain.com`

## Performance Tips

- ✅ Monaco Editor loads dynamically (reduces initial bundle)
- ✅ Code splitting enabled (vendor/editor/utils chunks)
- ✅ Console logs removed in production
- ✅ Minification with Terser
- ✅ Assets have cache-friendly hashes

## Monitoring

Check deployment status:
- Frontend: https://vercel.com/dashboard
- Backend: https://vercel.com/dashboard

## Troubleshooting

**Build fails?**
1. Check Node.js version (>=18.0.0)
2. Clear node_modules: `rm -rf node_modules && npm install`
3. Test local build: `npm run build`

**API calls fail?**
1. Check CORS settings in backend
2. Verify API URL in frontend .env
3. Check Vercel function logs

---

Built with ❤️ by Solar IT Team
