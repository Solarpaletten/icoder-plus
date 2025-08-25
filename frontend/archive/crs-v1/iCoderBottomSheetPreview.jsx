// iCoderBottomSheetPreview.jsx
import { useState } from "react";

export default function iCoderBottomSheetPreview() {
  const [isOpen, setIsOpen] = useState(false);
  const [files, setFiles] = useState({});
  const [selectedFile, setSelectedFile] = useState(null);
  const [output, setOutput] = useState("");

  const getNextVersion = (history) => {
    if (history.length === 0) return "v1.0";
    const last = history[history.length - 1].versionName;
    const [_, major, minor] = last.match(/v(\d+)\.(\d+)/).map(Number);
    return `v${major}.${minor + 1}`;
  };

  // Drag&Drop загрузка файлов
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
          {
            versionName: nextVersion,
            timestamp: Date.now(),
            content: text,
          },
        ],
      });
      setSelectedFile(file.name);
    }
  };

  // Запуск кода
  const runCode = () => {
    if (!selectedFile) return;
    const history = files[selectedFile];
    const last = history[history.length - 1];
    const code = last.content;

    if (selectedFile.endsWith(".js")) {
      try {
        // capture console.log
        const logs = [];
        const originalLog = console.log;
        console.log = (...args) => logs.push(args.join(" "));
        eval(code);
        console.log = originalLog;
        setOutput(logs.join("\n") || "✅ Code executed with no output.");
      } catch (err) {
        setOutput("❌ Error: " + err.message);
      }
    } else if (selectedFile.endsWith(".html")) {
      setOutput(
        `<iframe style="width:100%;height:200px;background:white;" sandbox="allow-scripts allow-same-origin" srcdoc="${code}"></iframe>`
      );
    } else {
      setOutput("⚠️ Preview not supported for this file type.");
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
          isOpen ? "h-[80vh]" : "h-[12vh]"
        } overflow-y-auto`}
        onDragOver={(e) => e.preventDefault()}
        onDrop={handleDrop}
      >
        <div className="p-4 space-y-4">
          <h2 className="text-lg font-bold">⚡ iCoder Plus – Live Preview</h2>

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

          {/* История + кнопка Run */}
          {selectedFile && (
            <>
              <h3 className="text-md font-semibold mt-4">📜 History: {selectedFile}</h3>
              <p>
                Versions: {files[selectedFile].length} | Current:{" "}
                {files[selectedFile][files[selectedFile].length - 1].versionName}
              </p>

              <button
                onClick={runCode}
                className="bg-green-600 px-4 py-2 rounded hover:bg-green-700 mt-3"
              >
                ▶ Run / Preview
              </button>

              {/* Output / Render */}
              <div className="mt-4 bg-black p-3 rounded text-sm overflow-x-auto">
                {selectedFile.endsWith(".html") ? (
                  <div dangerouslySetInnerHTML={{ __html: output }} />
                ) : (
                  <pre>{output}</pre>
                )}
              </div>
            </>
          )}

          <p className="text-gray-400 text-sm italic mt-3">
            💡 Drag & drop a file → Run JS in console or preview HTML below.
          </p>
        </div>
      </div>
    </div>
  );
}
