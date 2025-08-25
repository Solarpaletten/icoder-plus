# 🌌 iCoder Plus v2.0

**AI-first IDE in a bottom sheet** - Clean frontend/backend architecture

## 🚀 Quick Start

### Automated Migration (Recommended)
```bash
# Migrate to clean structure
chmod +x migrate-to-structure.sh
./migrate-to-structure.sh

# Install dependencies
cd frontend && npm install
cd ../backend && npm install
```

### Manual Setup
```bash
# Frontend (React + Vite)
cd frontend
npm install
npm run dev    # http://localhost:5173

# Backend (Express + TypeScript)  
cd backend
npm install
cp .env.example .env  # Add your OpenAI/Claude API keys
npm run dev    # http://localhost:3000
```

## 📂 Project Structure

```
icoder-plus/
├── frontend/                  # 🎨 React UI (JavaScript)
│   ├── src/
│   │   ├── components/        # Bottom sheet, file list, AI chat
│   │   ├── services/          # API client, browser APIs
│   │   ├── utils/             # Formatters, helpers
│   │   └── App.jsx            # Main component
│   └── package.json           # React, Vite, Tailwind
│
├── backend/                   # 🔧 Express API (TypeScript)
│   ├── src/
│   │   ├── routes/            # AI, files, history endpoints
│   │   ├── services/          # OpenAI, diff, analysis
│   │   ├── middleware/        # Auth, validation, CORS
│   │   └── server.ts          # Express server
│   └── package.json           # Express, TypeScript, OpenAI
│
└── docs/                      # 📚 Documentation
    ├── README.md              # This file
    ├── ARCHITECTURE.md        # Technical architecture
    ├── ONBOARDING.md          # Developer guide
    └── CHANGELOG.md           # Version history
```

## ✨ Features

### 🎨 Frontend (JavaScript + React)
- **Bottom Sheet UI** - Draggable interface
- **File Management** - Drag & drop, version history  
- **Live Preview** - Run JS/HTML instantly
- **AI Chat** - Interactive code assistant
- **Dark Theme** - Modern Tailwind design

### 🔧 Backend (TypeScript + Express)
- **AI Integration** - OpenAI/Claude API
- **Code Analysis** - Smart reviews and fixes
- **Diff Engine** - Advanced file comparison
- **Rate Limiting** - API protection
- **Type Safety** - Full TypeScript coverage

## 🔑 Configuration

### Backend Environment (.env)
```env
# AI Configuration
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_claude_key

# Server Configuration  
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:5173

# Logging
LOG_LEVEL=info
```

### Frontend Environment (.env.local)
```env
# API Configuration
VITE_API_URL=http://localhost:3000/api
VITE_API_KEY=optional_api_key
```

## 🛠️ Development

### Available Commands

**Frontend:**
```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run preview  # Preview production build
```

**Backend:**
```bash
npm run dev      # Start with nodemon + ts-node
npm run build    # Compile TypeScript
npm run start    # Run compiled JavaScript
npm run typecheck # Check TypeScript types
```

## 🚀 API Endpoints

### AI Service
- `POST /api/ai/analyze` - Code analysis and review
- `POST /api/ai/chat` - Chat with AI about code
- `POST /api/ai/fix/apply` - Apply AI fixes
- `GET /api/ai/status` - AI service status

### File Service  
- `POST /api/files/upload` - Upload and process files
- `POST /api/files/diff` - Generate file diff

### History Service
- `POST /api/history/save` - Save version
- `GET /api/history/:fileName` - Get file history
- `POST /api/history/export` - Export as JSON
- `POST /api/history/import` - Import from JSON

## 🔧 Architecture

### Frontend Stack
- **React 18** - Component framework
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first styling  
- **Axios** - HTTP client
- **Lucide React** - Icon library

### Backend Stack
- **Express.js** - Web framework
- **TypeScript** - Type safety
- **OpenAI SDK** - AI integration
- **Winston** - Logging
- **Joi** - Request validation
- **Helmet** - Security headers

## 📚 Documentation

- [**ARCHITECTURE.md**](./ARCHITECTURE.md) - Technical deep dive
- [**ONBOARDING.md**](./ONBOARDING.md) - Developer onboarding
- [**CHANGELOG.md**](./CHANGELOG.md) - Version history
- [**Frontend README**](./frontend/README.md) - UI development
- [**Backend README**](./backend/README.md) - API development

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Run migration script: `./migrate-to-structure.sh`
4. Make changes in appropriate frontend/backend directories
5. Test both frontend and backend
6. Commit changes: `git commit -m 'Add amazing feature'`
7. Push branch: `git push origin feature/amazing-feature`
8. Open Pull Request

## 📦 Deployment

### Frontend (Vercel/Netlify)
```bash
cd frontend
npm run build
# Deploy /dist folder
```

### Backend (Railway/Heroku)
```bash
cd backend  
npm run build
# Deploy with start command: npm start
```

## 🎯 Roadmap

- [ ] Python code execution (WebAssembly)
- [ ] Multi-file project support
- [ ] Collaborative editing
- [ ] Plugin marketplace
- [ ] Mobile app (React Native)

## 📜 License

MIT License - Free to use, modify, and distribute.

---

**Built with ❤️ by Solar IT Team**

*AI-first development for the next generation of coding tools*