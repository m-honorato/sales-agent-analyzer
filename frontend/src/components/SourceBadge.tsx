import { FileText, ExternalLink } from 'lucide-react';
import type { Source } from '../types';

interface SourceBadgeProps {
  source: Source;
}

export function SourceBadge({ source }: SourceBadgeProps) {
  return (
    <a
      href={source.url || '#'}
      target="_blank"
      rel="noopener noreferrer"
      className="inline-flex items-center gap-1.5 px-2.5 py-1 text-xs font-medium text-indigo-600 bg-indigo-50 hover:bg-indigo-100 rounded-lg transition-colors group"
    >
      <FileText size={12} />
      <span className="max-w-[150px] truncate">{source.title}</span>
      {source.url && <ExternalLink size={10} className="opacity-0 group-hover:opacity-100 transition-opacity" />}
    </a>
  );
}
