import { useState, useCallback } from 'react';
import type { AgentResponse } from '../types';

const WEBHOOK_URL = 'http://localhost:5678/webhook/sales-agent';

export function useSalesAgent() {
  const [isLoading, setIsLoading] = useState(false);
  const [streamingMessage, setStreamingMessage] = useState<string | null>(null);

  const askQuestion = useCallback(async (question: string): Promise<AgentResponse> => {
    setIsLoading(true);
    setStreamingMessage(null);
    
    try {
      const response = await fetch(WEBHOOK_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ question }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      
      return {
        answer: data.answer || data.response || 'No response received.',
        sources: data.sources || [],
        cost: data.cost || undefined,
      };
    } catch (error) {
      console.error('Error asking question:', error);
      throw error;
    } finally {
      setIsLoading(false);
      setStreamingMessage(null);
    }
  }, []);

  return {
    askQuestion,
    isLoading,
    streamingMessage,
  };
}
