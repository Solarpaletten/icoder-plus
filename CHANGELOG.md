📜 Changelog – iCoder Plus
[2.0.0] – 2025-08-25
Added

📂 Modular Architecture: проект разбит на components/, services/, utils/.

💬 AI Chat Assistant: встроенный чат для вопросов по коду.

▶ Live Preview: запуск JS (console) и HTML (iframe).

🔍 Diff Viewer: отдельный компонент для наглядного сравнения.

🗂 Version History Module: управление версиями, rollback, экспорт/импорт JSON.

🧠 AI Service Layer: централизованный слой для OpenAI/Claude API.

Improved

🎨 UI стал чище и отзывчивее (TailwindCSS, bottom sheet).

📤 Экспорт и 📥 импорт истории вынесены в historyService.js.

⚡ Автоматизация версий: auto-increment (v1.0, v1.1, …).

[1.3.0] – 2025-08-20
Added

▶ Run/Preview Mode:

JS исполняется с выводом в консоль.

HTML рендерится в iframe.

Мини-терминал для отображения результатов.

[1.2.0] – 2025-08-15
Added

💡 Apply AI Fix Button:

автоматическая замена var → let/const.

удаление console.log.

простые оптимизации.

AI фиксирует изменения в истории как отдельные версии [AI FIXED].

[1.1.0] – 2025-08-10
Added

🧠 AI Review Panel: рекомендации по улучшению кода.

✏️ AI Commit Notes: автогенерация комментариев к каждой версии.

[1.0.0] – 2025-08-01
Initial Release

📂 Управление файлами (File System API).

🖱 Drag & Drop новых файлов.

🔍 Базовое сравнение (diff).

📜 Хранение истории версий.

📤 Экспорт/📥 импорт JSON.