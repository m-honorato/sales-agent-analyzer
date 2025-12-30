export function LoadingSpinner() {
  return (
    <div className="flex items-center gap-2 text-slate-500">
      <div className="flex gap-1">
        <div className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
        <div className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
        <div className="w-2 h-2 bg-indigo-400 rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
      </div>
      <span className="text-sm">Analyzing your sales calls...</span>
    </div>
  );
}
