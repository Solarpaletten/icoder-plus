// iCoderBottomSheetAIReview.jsx
import { useState } from "react";

// ⚡ mock AI functions (замени на OpenAI/Claude API)
async function generateAIComment(oldCode, newCode) {
  if (oldCode === newCode) return "No changes detected.";
  if (!oldCode) return "🆕 New file created.";
  if (!newCode) return "❌ File removed.";
  return "✏️ Code updated: logic/function changed.";
}

async function generateAIReview(code) {
  const suggestions = [];
  if (code.includes("console.log")) {
    suggestions.push("🔇 Consider removing console.log before production.");
  }
  if (code.length > 500) {
    suggestions.push("📏 This file is large; consider splitting into smaller modules.");
  }
  if (code.includes("var ")) {
    suggestions.push("⚠️ Replace 'var' with 'let' or 'const' for modern JavaScript.");
  }
  if (suggestions.length === 0) {
    suggestions.push("✅ No major issues found. Code looks clean!");
  }
  return suggestions;
}

export default function iCoderBottomSheetAIReview() {
  const [isOpen, setIsOpen] = useState(false);
  const [files, setFiles] = useState({});
  const [selectedFile, setSelectedFile] = useState(null);

  const getNextVersion = (history) => {
    if (history.length === 0) return "v1.0";
    const last = history[history.length - 1].versionName;
    const [_, major, minor] = last.match(/v(\d+)\.(\d+)/).map(Number);
    return `v${major}.${minor + 1}`;
  };

  // Drag&Drop новый файл
  const handleDrop = async (event) => {
    event.preventDefault();
    const file = event.dataTransfer.files[0];
    if (file) {
      const text = await file.text();
      const history = files[file.name] || [];
      const prevContent = history.length > 0 ? history[history.length - 1].content : "";
      const nextVersion = getNextVersion(history);

      // AI-комментарий
      const aiNote = await generateAIComment(prevContent, text);
      // AI-ревью (оптимизация)
      const aiReview = await generateAIReview(text);

      setFiles({
        ...files,
        [file.name]: [
          ...history,
          {
            versionName: nextVersion,
            timestamp: Date.now(),
            content: text,
            aiNote,
            aiReview,
          },
        ],
      });
    }
  };

  return (
    <div className="fixed inset-x-0 bottom-0">
      {/* Хедер-ручка */}
      <div
        className="flex justify-center p-2 bg-gray-800 cursor-pointer"
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="w-12 h-1.5 rounded bg-gray-400"></div>
      </div>

      {/* Контент */}
      <div
        className={`bg-gray-900 text-white transition-all duration-300 ${
          isOpen ? "h-[75vh]" : "h-[12vh]"
        } overflow-y-auto`}
        onDragOver={(e) => e.preventDefault()}
        onDrop={handleDrop}
      >
        <div className="p-4 space-y-4">
          <h2 className="text-lg font-bold">🤖 iCoder Plus – AI Review History</h2>

          {/* Список файлов */}
          <ul className="space-y-2">
            {Object.keys(files).map((fname, idx) => (
              <li
                key={idx}
                className={`p-2 rounded cursor-pointer ${
                  selectedFile === fname ? "bg-blue-700" : "bg-gray-700 hover:bg-gray-600"
                }`}
                onClick={() => setSelectedFile(fname)}
              >
                {fname}
              </li>
            ))}
          </ul>

          {/* История файла */}
          {selectedFile && (
            <>
              <h3 className="text-md font-semibold mt-4">📜 History: {selectedFile}</h3>
              <ul className="space-y-2">
                {files[selectedFile].map((v, idx) => (
                  <li key={idx} className="bg-gray-800 rounded p-2 text-sm">
                    <p>
                      {v.versionName} — {new Date(v.timestamp).toLocaleString()}
                    </p>
                    <p className="italic text-green-400">AI Note: {v.aiNote}</p>
                    <ul className="list-disc ml-4 text-yellow-300">
                      {v.aiReview.map((r, i) => (
                        <li key={i}>{r}</li>
                      ))}
                    </ul>
                  </li>
                ))}
              </ul>
            </>
          )}

          <p className="text-gray-400 text-sm italic mt-3">
            💡 Drag & drop a file → AI will explain the change and suggest improvements.
          </p>
        </div>
      </div>
    </div>
  );
}
