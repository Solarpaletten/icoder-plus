// iCoderBottomSheetAI.jsx
import { useState } from "react";

// ⚡ mock AI function (здесь можно подключить OpenAI API или свой AI)
async function generateAIComment(oldCode, newCode) {
  if (oldCode === newCode) return "No changes detected.";
  if (!oldCode) return "🆕 New file created.";
  if (!newCode) return "❌ File removed.";
  return "✏️ Code updated: function or logic changed.";
}

export default function iCoderBottomSheetAI() {
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

      // ⚡ Генерация AI-комментария
      const aiNote = await generateAIComment(prevContent, text);

      setFiles({
        ...files,
        [file.name]: [
          ...history,
          {
            versionName: nextVersion,
            timestamp: Date.now(),
            content: text,
            aiNote,
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
          <h2 className="text-lg font-bold">🤖 iCoder Plus – AI Version History</h2>

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
                  </li>
                ))}
              </ul>
            </>
          )}

          <p className="text-gray-400 text-sm italic mt-3">
            💡 Drag & drop a file → AI will explain the change automatically.
          </p>
        </div>
      </div>
    </div>
  );
}
