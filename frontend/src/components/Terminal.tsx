import { XTermTerminal } from './XTermTerminal';

interface TerminalProps {
  isVisible?: boolean;
  height?: number;
}

export function Terminal({ isVisible = true, height = 200 }: TerminalProps) {
  return <XTermTerminal isVisible={isVisible} height={height} />;
}
