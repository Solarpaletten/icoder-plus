import { ReactNode } from 'react';

interface ResizableLayoutProps {
  panelState: {
    leftCollapsed: boolean;
    rightCollapsed: boolean;
    terminalCollapsed: boolean;
  };
  children: ReactNode;
}

export function ResizableLayout({ children }: ResizableLayoutProps) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      <div className="flex-1 flex overflow-hidden">
        {children}
      </div>
    </div>
  );
}
