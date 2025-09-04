import { Editor } from '../Editor';
import type { FileManagerState } from '../../types';

interface MainEditorProps extends FileManagerState {
  closeTab: (tab: any) => void;
  setActiveTab: (tab: any) => void;
  updateFileContent: (fileId: string, content: string) => void;
}

export function MainEditor(props: MainEditorProps) {
  return (
    <div className="flex-1 flex flex-col overflow-hidden">
      <Editor {...props} />
    </div>
  );
}
