import { useState } from 'react';

export function usePanelState() {
  const [leftCollapsed, setLeftCollapsed] = useState(false);
  const [rightCollapsed, setRightCollapsed] = useState(false);
  const [terminalCollapsed, setTerminalCollapsed] = useState(false);

  return {
    leftCollapsed,
    rightCollapsed,
    terminalCollapsed,
    toggleLeft: () => setLeftCollapsed(!leftCollapsed),
    toggleRight: () => setRightCollapsed(!rightCollapsed),
    toggleTerminal: () => setTerminalCollapsed(!terminalCollapsed),
  };
}
