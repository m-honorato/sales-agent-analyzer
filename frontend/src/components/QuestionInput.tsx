import { useState, KeyboardEvent } from 'react';
import { Send, Sparkles } from 'lucide-react';

const SUGGESTED_QUESTIONS = [
  "What objections did prospects raise?",
  "Summarize key insights from calls",
  "Which deals are most likely to close?",
  "What competitors were mentioned?",
  "What pricing concerns came up?",
];

interface QuestionInputProps {
  onSubmit: (question: string) => void;
  isLoading: boolean;
}

export function QuestionInput({ onSubmit, isLoading }: QuestionInputProps) {
  const [question, setQuestion] = useState('');

  const handleSubmit = () => {
    if (question.trim() && !isLoading) {
      onSubmit(question.trim());
      setQuestion('');
    }
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSubmit();
    }
  };

  const handleSuggestedClick = (q: string) => {
    if (!isLoading) {
      onSubmit(q);
    }
  };

  return (
    <div className="space-y-4">
      {/* Suggested Questions */}
      <div className="flex flex-wrap gap-2 justify-center">
        {SUGGESTED_QUESTIONS.map((q, idx) => (
          <button
            key={idx}
            onClick={() => handleSuggestedClick(q)}
            disabled={isLoading}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-medium text-indigo-600 bg-indigo-50 hover:bg-indigo-100 disabled:opacity-50 disabled:cursor-not-allowed rounded-full transition-colors"
          >
            <Sparkles size={12} />
            {q}
          </button>
        ))}
      </div>

      {/* Input Area */}
      <div className="flex items-end gap-3 bg-slate-50 rounded-2xl p-3 border border-slate-200 focus-within:border-indigo-300 focus-within:ring-2 focus-within:ring-indigo-100 transition-all">
        <textarea
          value={question}
          onChange={(e) => setQuestion(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Ask a question about your sales calls..."
          disabled={isLoading}
          rows={1}
          className="flex-1 bg-transparent text-slate-800 placeholder:text-slate-400 placeholder:text-center resize-none focus:outline-none disabled:opacity-50 min-h-[44px] max-h-32 py-2"
          style={{ lineHeight: '1.5' }}
        />
        <button
          onClick={handleSubmit}
          disabled={!question.trim() || isLoading}
          className="flex-shrink-0 flex items-center gap-2 px-4 py-3 bg-indigo-500 hover:bg-indigo-600 disabled:bg-slate-200 disabled:cursor-not-allowed text-white disabled:text-slate-400 rounded-xl transition-all transform hover:scale-105 active:scale-95 disabled:transform-none shadow-lg shadow-indigo-500/20 disabled:shadow-none font-medium"
        >
          <span className="hidden sm:inline">Ask AI</span>
          <Send size={18} />
        </button>
      </div>

      {/* Helper Text */}
      <p className="text-xs text-slate-400 flex items-center justify-center gap-2">
        <span className="hidden sm:inline text-slate-300">—</span>
        <span>Press Enter to send • Shift+Enter for new line</span>
        <span className="hidden sm:inline text-slate-300">—</span>
      </p>
    </div>
  );
}
