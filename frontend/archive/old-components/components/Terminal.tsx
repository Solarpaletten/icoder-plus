import React from 'react';

export function Terminal() {
  return (
    <div className="h-full bg-background p-3 font-mono text-sm">
      <div className="text-secondary">$ npm run dev</div>
      <div className="text-gray-400">🚀 iCoder Plus v2.0 starting...</div>
      <div className="text-secondary">✅ Clean TypeScript architecture loaded</div>
      <div className="text-secondary">✅ Backend: api.icoder.swapoil.de - Online</div>
      <div className="text-gray-400">Ready for development...</div>
      <div className="flex items-center mt-2">
        <span className="text-secondary">$ </span>
        <span className="bg-white w-2 h-4 ml-1 animate-pulse"></span>
      </div>
    </div>
  );
}
