import { Clock, Plus, Trash2, MessageSquareText } from 'lucide-react';
import type { HistoryItem } from '../types';

interface SidebarProps {
  history: HistoryItem[];
  onHistoryClick: (item: HistoryItem) => void;
  onNewChat: () => void;
  onClearHistory: () => void;
}

export function Sidebar({ history, onHistoryClick, onNewChat, onClearHistory }: SidebarProps) {
  return (
    <div className="h-full bg-white border-r border-slate-200 flex flex-col">
      {/* Header */}
      <div className="p-4 border-b border-slate-200">
        <h2 className="text-sm font-semibold text-slate-600 flex items-center gap-2">
          <Clock size={16} />
          Recent Questions
        </h2>
      </div>

      {/* History List */}
      <div className="flex-1 overflow-y-auto p-3">
        {history.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center text-slate-400 px-4 py-8">
            <MessageSquareText size={32} className="text-indigo-300 mb-3" />
            <p className="text-sm font-medium mb-1">No conversations yet</p>
            <p className="text-xs">Start by asking a question in the main chat.</p>
          </div>
        ) : (
          <div className="space-y-2">
            {history.map((item) => (
              <button
                key={item.id}
                onClick={() => onHistoryClick(item)}
                className="w-full text-left p-3 rounded-xl hover:bg-slate-50 transition-colors group"
              >
                <p className="text-sm text-slate-700 font-medium truncate group-hover:text-indigo-600">
                  {item.question}
                </p>
                <p className="text-xs text-slate-400 mt-1 truncate">
                  {item.preview}
                </p>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Footer with New Chat button */}
      <div className="p-3 border-t border-slate-200 mt-auto">
        <button
          onClick={onNewChat}
          className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-indigo-500 hover:bg-indigo-600 text-white rounded-xl transition-colors shadow-lg shadow-indigo-500/20"
        >
          <Plus size={18} />
          <span className="font-medium">New Chat</span>
        </button>
        {history.length > 0 && (
          <button
            onClick={onClearHistory}
            className="w-full flex items-center justify-center gap-2 px-3 py-2 text-sm text-red-500/70 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors mt-2"
          >
            <Trash2 size={16} />
            Clear History
          </button>
        )}
      </div>
    </div>
  );
}
