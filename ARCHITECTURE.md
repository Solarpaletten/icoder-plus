🏗️ Architecture – iCoder Plus v2.0

iCoder Plus — это модульная AI-first песочница, построенная вокруг принципа Bottom Sheet IDE.
Вся логика разделена на UI-компоненты, сервисы и утилиты.

📂 Основная структура
icoder-plus/
│── src/
│   ├── components/      # UI-модули (React)
│   ├── services/        # Логика (AI, файлы, diff, preview)
│   ├── utils/           # Утилиты и генераторы
│   ├── App.jsx          # Корневой контейнер
│   └── index.js         # Точка входа

🧩 Модули и их роль
1. UI-компоненты (/components)

BottomSheet.jsx
Главный контейнер, который управляет состоянием экранчика.
Содержит навигацию между вкладками (History, Preview, AI Review, Chat).

FileList.jsx
Отображает список файлов проекта.
Сигналы: выбор файла, drag&drop, открытие папки.

DiffViewer.jsx
Отвечает за подсветку изменений (старый vs новый код).

VersionHistory.jsx
Таймлайн версий с rollback и экспортом/импортом JSON.

PreviewRunner.jsx
Выполнение JS через eval, рендер HTML через <iframe>.

AIChat.jsx
Встроенный чат-ассистент для вопросов про код.

AIReviewPanel.jsx
Панель рекомендаций: стили, оптимизация, баги.

AIFixButton.jsx
Кнопка "💡 Apply AI Fix" → генерирует новую версию с автоправками.

2. Сервисы (/services)

fileService.js
Управление файловой системой (File System API, drag&drop).

diffService.js
Алгоритмы сравнения (на базе jsdiff или собственного).

historyService.js
Сохранение версии, rollback, экспорт/импорт JSON.

previewService.js
Запуск кода (JS, HTML). В будущем — sandbox Python.

aiService.js
Обертка над OpenAI/Claude API:

commit notes,

ревью кода,

чат,

автофиксы.

fixService.js
Правила авто-исправлений:

var → let/const,

удаление console.log,

оптимизации импорта.

3. Утилиты (/utils)

versioning.js → генерация версий (v1.0, v1.1, v2.0).

logger.js → логирование действий (например, “AI Fix applied”).

helpers.js → форматирование текста, подсветка diff.

🔄 Поток данных
flowchart TD
  User[👨‍💻 User] -->|Drag & Drop File| FileService
  FileService --> HistoryService
  HistoryService --> DiffService
  DiffService --> BottomSheet

  BottomSheet -->|Show Changes| DiffViewer
  BottomSheet --> FileList
  BottomSheet --> VersionHistory
  BottomSheet --> PreviewRunner

  HistoryService -->|Export/Import| JSON[📤 JSON File]

  HistoryService --> AIService
  AIService -->|Commit Note + Review| AIReviewPanel
  AIService -->|Fix| AIFixButton
  AIService -->|Chat| AIChat

  PreviewRunner -->|Run/Render| Output[⚡ Preview Window]

🚀 Особенности архитектуры

AI-first: каждый шаг кода сопровождается AI (review, notes, fixes).

Модульность: легко заменить aiService на другой провайдер (OpenAI → Claude → Local LLM).

JSON-based History: история версий хранится в JSON → переносимая, удобна для экспорта.

UI-микро-компоненты: каждый блок (diff, чат, preview) можно переиспользовать отдельно.

Bottom Sheet UX: минимализм — всё под рукой, без громоздкой IDE.

🌌 Roadmap для v3.0

Поддержка Python execution (через Pyodide/WebAssembly).

Collaborative Mode (несколько пользователей в одном проекте).

Поддержка Docker-песочниц для бэкенд-кода.

Marketplace AI Fix Plugins (правила оптимизации под разные языки).