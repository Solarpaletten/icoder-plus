import React from 'react';

// Простой textarea fallback, если Monaco Editor не загружается
const SimpleEditor = ({ 
  value = '', 
  onChange, 
  language = 'javascript',
  height = '300px',
  placeholder = 'Enter your code here...'
}) => {
  const handleChange = (e) => {
    if (onChange) {
      onChange(e.target.value);
    }
  };

  return (
    <textarea
      value={value}
      onChange={handleChange}
      placeholder={placeholder}
      style={{ height }}
      className="w-full bg-gray-900 text-green-400 font-mono p-4 rounded-lg border border-gray-700 focus:border-blue-500 focus:outline-none resize-none"
      spellCheck={false}
    />
  );
};

export default SimpleEditor;
