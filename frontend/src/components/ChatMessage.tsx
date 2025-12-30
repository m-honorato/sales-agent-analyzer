import { User, BarChart3 } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import { SourceBadge } from './SourceBadge';
import { CostDisplay } from './CostDisplay';
import type { Message } from '../types';
import { useState, useEffect } from 'react';

interface ChatMessageProps {
  message: Message;
}

// Function to filter out citation markers
const filterCitations = (content: string) => {
  let filteredContent = content
    // Remove square bracket citations: [CALL summary], [CALL conversation], [Chunk 1], etc.
    .replace(/\[CALL[^\]]*\]/gi, '')
    .replace(/\[Chunk[^\]]*\]/gi, '')
    .replace(/\[Chunks?[^\]]*\]/gi, '')
    // Remove full-width bracket citations: 【CALL summary】, 【CALL conversation】, etc.
    .replace(/【[^】]*】/g, '')
    // Clean up any double spaces left behind
    .replace(/  +/g, ' ')
    // Clean up empty quotes
    .replace(/"\s*"/g, '')
    // Clean up trailing periods after removed citations
    .replace(/\.\s*\./g, '.')
    .trim();

  return filteredContent;
};

// Helper to check if this list item is a section header (contains ONLY bold text)
const isSectionHeader = (node: any): boolean => {
  // Check the AST node children
  const nodeChildren = node?.children || [];
  
  // A section header should have:
  // 1. Only one child that is 'strong' OR
  // 2. A 'strong' element followed only by whitespace/newlines
  if (nodeChildren.length === 0) return false;
  
  const firstChild = nodeChildren[0];
  if (firstChild?.tagName !== 'strong') return false;
  
  // Check if the rest are just whitespace text nodes
  const restChildren = nodeChildren.slice(1);
  const onlyWhitespace = restChildren.every((child: any) => {
    if (child.type === 'text') {
      return !child.value || child.value.trim() === '';
    }
    return false;
  });
  
  // Also check if there's a nested list (means it's definitely a header)
  const hasNestedList = nodeChildren.some((child: any) => 
    child.tagName === 'ul' || child.tagName === 'ol'
  );
  
  return onlyWhitespace || hasNestedList || nodeChildren.length === 1;
};

// Custom renderer for ReactMarkdown to add styling to headers and lists
const renderers = {
  h1: ({ children }: any) => (
    <h1 className="text-xl font-bold text-slate-800 mt-6 mb-3 first:mt-0">{children}</h1>
  ),
  h2: ({ children }: any) => (
    <h2 className="text-lg font-bold text-slate-800 mt-5 mb-3 first:mt-0">{children}</h2>
  ),
  h3: ({ children }: any) => (
    <h3 className="text-base font-bold text-slate-800 mt-4 mb-2 first:mt-0">{children}</h3>
  ),
  h4: ({ children }: any) => (
    <h4 className="text-sm font-bold text-indigo-700 mt-4 mb-2 first:mt-0">{children}</h4>
  ),
  ul: ({ children }: any) => (
    <div>{children}</div>
  ),
  ol: ({ children }: any) => (
    <div>{children}</div>
  ),
  li: ({ children, node }: any) => {
    // Check if this is a section header (only bold text)
    if (isSectionHeader(node)) {
      return (
        <div style={{ marginTop: '24px', paddingTop: '20px', marginBottom: '12px', borderTop: '1px solid #e2e8f0' }} className="first:mt-0 first:pt-0 first:border-t-0">
          <span className="inline-flex items-center bg-gradient-to-r from-indigo-50 to-purple-50 text-indigo-700 px-3 py-1.5 rounded-lg font-semibold text-sm border border-indigo-100">
            {children}
          </span>
        </div>
      );
    }
    
    // Regular list item with bullet
    return (
      <div className="flex items-start gap-2.5 ml-4 py-0.5">
        <span className="text-indigo-400 mt-1.5 text-xs">●</span>
        <span className="text-slate-700 leading-relaxed flex-1">{children}</span>
      </div>
    );
  },
  blockquote: ({ children }: any) => (
    <blockquote className="border-l-4 border-indigo-300 bg-indigo-50 pl-4 py-2 my-3 italic text-slate-600 rounded-r">
      {children}
    </blockquote>
  ),
  p: ({ children, node }: any) => {
    // Check if this paragraph contains only a strong element (it's a standalone header)
    const nodeChildren = node?.children || [];
    const hasOnlyStrong = nodeChildren.length === 1 && nodeChildren[0]?.tagName === 'strong';
    
    if (hasOnlyStrong) {
      return (
        <div style={{ marginTop: '24px', paddingTop: '20px', marginBottom: '12px', borderTop: '1px solid #e2e8f0' }} className="first:mt-0 first:pt-0 first:border-t-0">
          <span className="inline-flex items-center bg-gradient-to-r from-indigo-50 to-purple-50 text-indigo-700 px-3 py-1.5 rounded-lg font-semibold text-sm border border-indigo-100">
            {children}
          </span>
        </div>
      );
    }
    
    return <p className="mb-3 leading-relaxed last:mb-0">{children}</p>;
  },
  strong: ({ children }: any) => <strong className="font-semibold text-slate-800">{children}</strong>,
  em: ({ children }: any) => <em className="italic text-slate-600">{children}</em>,
  table: ({ children }: any) => (
    <div className="overflow-x-auto my-4">
      <table className="min-w-full border-collapse border border-slate-200 rounded-lg overflow-hidden">
        {children}
      </table>
    </div>
  ),
  thead: ({ children }: any) => <thead className="bg-indigo-50">{children}</thead>,
  tbody: ({ children }: any) => <tbody className="divide-y divide-slate-200">{children}</tbody>,
  tr: ({ children }: any) => <tr className="hover:bg-slate-50">{children}</tr>,
  th: ({ children }: any) => (
    <th className="px-4 py-2 text-left text-sm font-semibold text-slate-700 border-b border-slate-200">{children}</th>
  ),
  td: ({ children }: any) => (
    <td className="px-4 py-2 text-sm text-slate-600 border-b border-slate-100">{children}</td>
  ),
};

export function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.type === 'user';
  const [displayContent, setDisplayContent] = useState('');

  useEffect(() => {
    if (!isUser) {
      setDisplayContent(filterCitations(message.content));
    } else {
      setDisplayContent(message.content);
    }
  }, [message.content, isUser]);

  return (
    <div className={`flex items-start gap-4 ${isUser ? 'flex-row-reverse' : ''} animate-slide-up`}>
      {/* Avatar */}
      <div className={`w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ${
        isUser 
          ? 'bg-slate-200' 
          : 'bg-gradient-to-br from-indigo-500 to-purple-600'
      }`}>
        {isUser ? (
          <User size={16} className="text-slate-600" />
        ) : (
          <BarChart3 size={16} className="text-white" />
        )}
      </div>

      {/* Message Content */}
      <div className={`flex-1 max-w-[85%] ${isUser ? 'text-right' : ''}`}>
        <div className={`inline-block text-left rounded-2xl p-5 transition-all duration-300 hover:shadow-lg ${
          isUser 
            ? 'bg-indigo-500 text-white rounded-tr-md shadow-md'
            : message.isError 
              ? 'bg-red-50 border border-red-100 text-red-700 rounded-tl-md shadow-md'
              : 'bg-white shadow-md border border-slate-100 rounded-tl-md'
        }`}>
          {isUser ? (
            <p className="whitespace-pre-wrap">{displayContent}</p>
          ) : (
            <div className="markdown-content text-slate-700">
              <ReactMarkdown components={renderers}>{displayContent}</ReactMarkdown>
            </div>
          )}
        </div>

        {/* Sources and Cost */}
        {!isUser && !message.isError && (
          <div className="mt-3 space-y-2">
            {message.sources && message.sources.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {message.sources.map((source, idx) => (
                  <SourceBadge key={idx} source={source} />
                ))}
              </div>
            )}
            {message.cost && <CostDisplay cost={message.cost} />}
          </div>
        )}

        {/* Timestamp */}
        <p className={`text-xs text-slate-400 mt-2 ${isUser ? 'text-right' : ''}`}>
          {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </p>
      </div>
    </div>
  );
}
