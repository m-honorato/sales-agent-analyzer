export interface Source {
  title: string;
  url?: string;
  type?: string;
}

export interface Cost {
  input_tokens?: number;
  output_tokens?: number;
  input_cost?: number;
  output_cost?: number;
}

export interface Message {
  id: string;
  type: 'user' | 'assistant';
  content: string;
  timestamp: Date;
  sources?: Source[];
  cost?: Cost;
  isError?: boolean;
}

export interface HistoryItem {
  id: string;
  question: string;
  preview: string;
  timestamp: Date;
}

export interface AgentResponse {
  answer: string;
  sources: Source[];
  cost?: Cost;
}
