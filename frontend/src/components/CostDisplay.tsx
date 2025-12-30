import { DollarSign } from 'lucide-react';
import type { Cost } from '../types';

// GPT-5.1 pricing (approximate)
const PRICING = {
  input: 0.00001,   // $0.01 per 1K tokens
  output: 0.00003,  // $0.03 per 1K tokens
};

interface CostDisplayProps {
  cost: Cost;
}

export function CostDisplay({ cost }: CostDisplayProps) {
  // Calculate costs from tokens if not provided
  const inputCost = cost.input_cost ?? (cost.input_tokens ? cost.input_tokens * PRICING.input : 0);
  const outputCost = cost.output_cost ?? (cost.output_tokens ? cost.output_tokens * PRICING.output : 0);
  const totalCost = inputCost + outputCost;
  
  return (
    <div className="inline-flex items-center gap-1.5 px-2.5 py-1 text-xs text-slate-500 bg-slate-100 rounded-lg">
      <DollarSign size={12} />
      <span>
        ~${totalCost.toFixed(4)} ({cost.input_tokens?.toLocaleString() || 0} in / {cost.output_tokens?.toLocaleString() || 0} out)
      </span>
    </div>
  );
}
