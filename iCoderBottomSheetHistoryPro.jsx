// iCoderBottomSheetHistoryPro.jsx
import { useState } from "react";

export default function iCoderBottomSheetHistoryPro() {
  const [isOpen, setIsOpen] = useState(false);
  const [files, setFiles] = useState({});
  const [selectedFile, setSelectedFile] = useState(null);

  // Функция генерации номера версии
  const getNextVersion = (history) => {
    if (history.length === 0) return "v1.0";
    const last = history[history.length - 1].versionName;
    const [v, major, minor] = last.match(/v(\d+)\.(\d+)/).map(Number);
    return `v${major}.${minor + 1}`;
  };

  // Открыть папку
  const openFolder = async () => {
    try {
      const dirHandle = await window.showDirectoryPicker();
      const newFiles = {};
      for await (const [name, handle] of dirHandle.entries()) {
        if (handle.kind === "file") {
          const file = await handle.getFile();
          const text = await file.text();
          newFiles[name] = [
            { versionName: "v1.0", timestamp: Date.now(), content: text },
          ];
        }
      }
      setFiles(newFiles);
    } catch (e) {
      console.error("Folder open canceled", e);
    }
  };

  // Drag&Drop новый файл
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
    }
  };

  // Diff простейший (в будущем можно подключить jsdiff)
  const compare = (oldText, newText) => {
    if (oldText === newText) {
      return <p className="text-gray-400">No changes detected ✅</p>;
    }
    return (
      <div className="bg-gray-800 rounded p-3 font-mono text-sm">
        <p className="text-red-400">- {oldText.slice(0, 100)}...</p>
        <p className="text-green-400">+ {newText.slice(0, 100)}...</p>
      </div>
    );
  };

  // Экспорт истории в JSON
  const exportJSON = () => {
    const blob = new Blob([JSON.stringify(files, null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "icoder-history.json";
    a.click();
  };

  // Импорт JSON
  const importJSON = (event) => {
    const file = event.target.files[0];
    if (file) {
      file.text().then((text) => {
        try {
          setFiles(JSON.parse(text));
        } catch (e) {
          alert("Invalid JSON file");
        }
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
          <h2 className="text-lg font-bold">📂 iCoder Plus – Versioned History</h2>

          <div className="flex space-x-3">
            <button
              onClick={openFolder}
              className="bg-blue-600 px-4 py-2 rounded hover:bg-blue-700"
            >
              Open Project Folder
            </button>
            <button
              onClick={exportJSON}
              className="bg-green-600 px-4 py-2 rounded hover:bg-green-700"
            >
              Export JSON
            </button>
            <label className="bg-yellow-600 px-4 py-2 rounded hover:bg-yellow-700 cursor-pointer">
              Import JSON
              <input
                type="file"
                className="hidden"
                accept="application/json"
                onChange={importJSON}
              />
            </label>
          </div>

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

          {/* История выбранного файла */}
          {selectedFile && (
            <>
              <h3 className="text-md font-semibold mt-4">
                📜 History: {selectedFile}
              </h3>
              <ul className="space-y-2">
                {files[selectedFile].map((v, idx, arr) => (
                  <li key={idx} className="bg-gray-800 rounded p-2 text-sm">
                    <p>
                      {v.versionName} — {new Date(v.timestamp).toLocaleString()}
                    </p>
                    {idx > 0 && compare(arr[idx - 1].content, v.content)}
                    <div className="flex space-x-2 mt-2">
                      <button className="bg-green-600 px-3 py-1 rounded hover:bg-green-700">
                        Rollback
                      </button>
                    </div>
                  </li>
                ))}
              </ul>
            </>
          )}

          <p className="text-gray-400 text-sm italic mt-3">
            💡 Tip: Drag & drop new versions here to auto-save history with version numbers.
          </p>
        </div>
      </div>
    </div>
  );
}
