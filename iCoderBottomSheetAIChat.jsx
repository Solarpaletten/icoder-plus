// iCoderBottomSheetAIChat.jsx
import { useState } from "react";

// mock AI response (в реале подключить OpenAI/Claude)
async function askAI(question, code) {
  if (!question) return "❌ Please enter a question.";
  if (question.includes("оптимиз")) return "✨ Suggestion: Extract helper function for cleaner code.";
  if (question.includes("ошиб")) return "⚠️ Likely syntax issue: check missing brackets or semicolons.";
  return "🤖 This is a placeholder AI response. Real integration goes here.";
}

export default function iCoderBottomSheetAIChat() {
  const [isOpen, setIsOpen] = useState(false);
  const [files, setFiles] = useState({});
  const [selectedFile, setSelectedFile] = useState(null);
  const [chat, setChat] = useState([]);
  const [input, setInput] = useState("");

  const getNextVersion = (history) => {
    if (history.length === 0) return "v1.0";
    const last = history[history.length - 1].versionName;
    const [_, major, minor] = last.match(/v(\d+)\.(\d+)/).map(Number);
    return `v${major}.${minor + 1}`;
  };

  const handleDrop = async (event) => {
    event.preventDefault();
    const file = event.dataTransfer.files[0];
    if (file) {
      const text = await file.text();
      const history = files[file.name] || [];
      const nextVersion = getNextVersion(history);

      setFiles({
        ...files,
        [file.name]: [
          ...history,
          { versionName: nextVersion, timestamp: Date.now(), content: text },
        ],
      });
      setSelectedFile(file.name);
    }
  };

  const handleAskAI = async () => {
    if (!selectedFile) return;
    const code = files[selectedFile][files[selectedFile].length - 1].content;
    const answer = await askAI(input, code);
    setChat([...chat, { role: "user", text: input }, { role: "ai", text: answer }]);
    setInput("");
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
          isOpen ? "h-[80vh]" : "h-[12vh]"
        } overflow-y-auto`}
        onDragOver={(e) => e.preventDefault()}
        onDrop={handleDrop}
      >
        <div className="p-4 space-y-4">
          <h2 className="text-lg font-bold">💬 iCoder Plus – AI Chat Assistant</h2>

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

          {/* Чат-ассистент */}
          {selectedFile && (
            <>
              <h3 className="text-md font-semibold mt-4">🤖 Ask AI about {selectedFile}</h3>

              <div className="bg-gray-800 p-3 rounded h-40 overflow-y-auto">
                {chat.map((m, i) => (
                  <p
                    key={i}
                    className={`${
                      m.role === "user" ? "text-blue-400" : "text-green-400"
                    } mb-2`}
                  >
                    {m.role === "user" ? "🧑 You: " : "🤖 AI: "}
                    {m.text}
                  </p>
                ))}
              </div>

              <div className="flex mt-3 space-x-2">
                <input
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  placeholder="Ask AI about this file..."
                  className="flex-1 px-3 py-2 rounded bg-gray-700 text-white"
                />
                <button
                  onClick={handleAskAI}
                  className="bg-purple-600 px-4 py-2 rounded hover:bg-purple-700"
                >
                  Send
                </button>
              </div>
            </>
          )}

          <p className="text-gray-400 text-sm italic mt-3">
            💡 Drag & drop a file → Ask AI questions about its code directly.
          </p>
        </div>
      </div>
    </div>
  );
}
