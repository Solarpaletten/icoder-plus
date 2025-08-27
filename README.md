🌌 iCoder Plus v2.0

AI-powered mini IDE in a bottom sheet.
A smart coding playground with version history, AI reviews, auto-fixes, live preview, and built-in chat assistant — all inside a draggable screen.

✨ Features

📂 File Management

Open local project folders via File System API

Drag & drop new files or updates

Automatic versioning (v1.0, v1.1, …)

Export/Import full history in JSON

🧠 AI Assistance

Auto commit notes for each change

AI review panel with suggestions (optimization, warnings, style)

Apply AI Fix → automatic improvements applied to code

Built-in AI Chat Assistant for asking code questions

🔍 Diff & History

Side-by-side diff viewer

Timeline of all changes per file

Rollback to previous versions

▶ Live Preview

Run JavaScript directly in console output

Render HTML live inside iframe

Instant feedback loop

🎨 UI/UX

Minimalistic bottom sheet design (drag up/down)

TailwindCSS styling

Dark theme by default

📂 Project Structure
icoder-plus/
│── src/
│   ├── components/
│   │   ├── BottomSheet.jsx        # Main container
│   │   ├── FileList.jsx           # File list
│   │   ├── DiffViewer.jsx         # Diff display
│   │   ├── VersionHistory.jsx     # Timeline + rollback
│   │   ├── PreviewRunner.jsx      # Run/Preview (HTML/JS)
│   │   ├── AIChat.jsx             # Built-in AI chat
│   │   ├── AIReviewPanel.jsx      # Review suggestions
│   │   └── AIFixButton.jsx        # Apply AI Fix button
│   │
│   ├── services/
│   │   ├── fileService.js         # File System API
│   │   ├── diffService.js         # Diff engine
│   │   ├── historyService.js      # Version history + JSON
│   │   ├── previewService.js      # Code execution/preview
│   │   ├── aiService.js           # AI integration
│   │   └── fixService.js          # Auto-fix logic
│   │
│   ├── utils/
│   │   ├── versioning.js          # v1.0, v1.1, v2.0
│   │   ├── logger.js              # Activity log
│   │   └── helpers.js             # Small helpers
│   │
│   ├── App.jsx
│   └── index.js
│
├── package.json
├── vite.config.js
├── README.md
└── .env.example

🚀 Getting Started
1. Clone repo
git clone https://github.com/YOUR_USERNAME/icoder-plus.git
cd icoder-plus

2. Install dependencies
npm install

3. Setup AI API keys

Create .env file:

OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here

4. Run dev server
npm run dev

5. Open in browser

Go to http://localhost:5173
Drag a file into the bottom sheet and start coding with AI ✨

🧩 Roadmap

 Add support for Python execution (sandboxed)

 Multi-file diff view

 Cloud sync for version history

 Collaborative editing (multi-user)

 Marketplace for AI fix-plugins

🤝 Contributing

Contributions are welcome! Fork the repo, create a PR, and join the journey 🚀

📜 License

MIT License. Free to use, modify, and distribute.

new structura

backend/package.json

3-1 file v2.1: Folder upload, D&D, CSS support, ZIP import/export

Remove duplicate iframe.src assignment