import { useState, useRef, useEffect, useCallback } from 'react';
import { BarChart3, Target, Trophy, TrendingUp, Menu, X, Clock, Plus, Trash2, MessageSquare, Users, Megaphone, Wrench, ChevronDown } from 'lucide-react';
import { QuestionInput } from './components/QuestionInput';
import { ChatMessage } from './components/ChatMessage';
import { LoadingSpinner } from './components/LoadingSpinner';
import { useSalesAgent } from './hooks/useSalesAgent';
import type { Message } from './types';

// Hardcoded call count for demo
const DEMO_CALL_COUNT = 1;

interface HistoryItem {
  id: string;
  question: string;
  preview: string;
  timestamp: Date;
}

type TeamType = 'sales' | 'pmm' | 'product';

interface TeamConfig {
  id: TeamType;
  name: string;
  icon: typeof Users;
  color: string;
  bgColor: string;
  description: string;
}

interface QuestionCard {
  icon: typeof BarChart3;
  title: string;
  description: string;
  color: string;
  question: string;
}

const TEAMS: TeamConfig[] = [
  {
    id: 'sales',
    name: 'Sales / GTM',
    icon: Users,
    color: 'text-blue-600',
    bgColor: 'bg-blue-50 hover:bg-blue-100 border-blue-200',
    description: 'Pipeline, training, and call feedback',
  },
  {
    id: 'pmm',
    name: 'Product Marketing',
    icon: Megaphone,
    color: 'text-purple-600',
    bgColor: 'bg-purple-50 hover:bg-purple-100 border-purple-200',
    description: 'Objections, competitors, and messaging',
  },
  {
    id: 'product',
    name: 'Product',
    icon: Wrench,
    color: 'text-emerald-600',
    bgColor: 'bg-emerald-50 hover:bg-emerald-100 border-emerald-200',
    description: 'Friction points, features, and sentiment',
  },
];

const TEAM_QUESTIONS: Record<TeamType, QuestionCard[]> = {
  sales: [
    {
      icon: BarChart3,
      title: 'Pipeline Forecast',
      description: 'Analyze opportunity pipeline and deal progression',
      color: 'bg-blue-50 text-blue-500',
      question: 'What is the current state of our opportunity pipeline? Which deals are most likely to close this quarter?',
    },
    {
      icon: Users,
      title: 'AE Training Insights',
      description: 'Identify coaching opportunities for new AEs',
      color: 'bg-indigo-50 text-indigo-500',
      question: 'What patterns do you see in calls from new AEs? Where do they need the most coaching and improvement?',
    },
    {
      icon: Target,
      title: 'Call Feedback',
      description: 'Get detailed feedback on specific rep calls',
      color: 'bg-cyan-50 text-cyan-500',
      question: 'Analyze the most recent sales calls and provide feedback on objection handling, discovery questions, and closing techniques.',
    },
    {
      icon: Trophy,
      title: 'Win/Loss Analysis',
      description: 'Understand why deals are won or lost',
      color: 'bg-amber-50 text-amber-500',
      question: 'What are the main reasons we are winning and losing deals? What patterns do you see in our wins vs losses?',
    },
  ],
  pmm: [
    {
      icon: Target,
      title: 'Objection Analysis',
      description: 'Understand common prospect objections',
      color: 'bg-rose-50 text-rose-500',
      question: 'What objections are prospects raising most frequently? Categorize them and provide specific quotes from calls.',
    },
    {
      icon: Users,
      title: 'Competitive Intelligence',
      description: 'Track competitor mentions and positioning',
      color: 'bg-orange-50 text-orange-500',
      question: 'How do we compare to competitors mentioned in calls? What are prospects saying about alternatives they are considering?',
    },
    {
      icon: Megaphone,
      title: 'Messaging Effectiveness',
      description: 'Analyze which messages resonate',
      color: 'bg-purple-50 text-purple-500',
      question: 'What messaging and value propositions are resonating with prospects? Analyze sentiment when different pitches are delivered.',
    },
    {
      icon: TrendingUp,
      title: 'Positioning Gaps',
      description: 'Identify opportunities to improve positioning',
      color: 'bg-pink-50 text-pink-500',
      question: 'What positioning gaps exist based on lost deals and objections? Where should we strengthen our narrative?',
    },
  ],
  product: [
    {
      icon: Wrench,
      title: 'Onboarding Friction',
      description: 'Identify pain points in onboarding',
      color: 'bg-emerald-50 text-emerald-500',
      question: 'Where is onboarding friction occurring? What pain points do customers mention during implementation and setup calls?',
    },
    {
      icon: Target,
      title: 'Feature Requests',
      description: 'Aggregate customer feature asks',
      color: 'bg-teal-50 text-teal-500',
      question: 'What features are customers asking for most frequently? Categorize and prioritize based on mention frequency and deal impact.',
    },
    {
      icon: TrendingUp,
      title: 'Churn Analysis',
      description: 'Understand why users churn',
      color: 'bg-red-50 text-red-500',
      question: 'Why are users churning? Analyze cancellation and support calls for common themes and preventable issues.',
    },
    {
      icon: Trophy,
      title: 'Customer Love',
      description: 'Extract positive sentiment patterns',
      color: 'bg-green-50 text-green-500',
      question: 'What do users love about our product? Extract positive sentiment patterns and specific features that delight customers.',
    },
  ],
};

function App() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [selectedTeam, setSelectedTeam] = useState<TeamType>('sales');
  const [teamDropdownOpen, setTeamDropdownOpen] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  
  const { askQuestion, isLoading, streamingMessage } = useSalesAgent();
  
  const currentTeam = TEAMS.find(t => t.id === selectedTeam) || TEAMS[0];
  const currentQuestions = TEAM_QUESTIONS[selectedTeam];

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages, streamingMessage, scrollToBottom]);

  const handleAskQuestion = async (question: string) => {
    const userMessage: Message = {
      id: Date.now().toString(),
      type: 'user',
      content: question,
      timestamp: new Date(),
    };
    
    setMessages(prev => [...prev, userMessage]);
    
    try {
      const response = await askQuestion(question);
      
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        type: 'assistant',
        content: response.answer,
        timestamp: new Date(),
        sources: response.sources,
        cost: response.cost,
      };
      
      setMessages(prev => [...prev, assistantMessage]);
      
      // Add to history
      const historyItem: HistoryItem = {
        id: Date.now().toString(),
        question,
        preview: response.answer.substring(0, 100) + '...',
        timestamp: new Date(),
      };
      setHistory(prev => [historyItem, ...prev].slice(0, 20));
      
    } catch (error) {
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        type: 'assistant',
        content: 'Sorry, I encountered an error processing your question. Please try again.',
        timestamp: new Date(),
        isError: true,
      };
      setMessages(prev => [...prev, errorMessage]);
    }
  };

  const handleNewChat = () => {
    setMessages([]);
  };

  const handleClearHistory = () => {
    setHistory([]);
  };

  const handleHistoryClick = (item: HistoryItem) => {
    handleAskQuestion(item.question);
  };

  return (
    <div className="flex h-screen bg-slate-50">
      {/* Sidebar - Hidden on mobile */}
      <div className={`hidden md:block ${sidebarOpen ? 'w-72' : 'w-0'} transition-all duration-300 overflow-hidden flex-shrink-0`}>
        <div className="h-full bg-white border-r border-slate-200 flex flex-col w-72">
          {/* Sidebar Header - matches main header height exactly */}
          <div className="px-4 border-b border-slate-200 flex items-center justify-between h-[57px]">
            <h2 className="text-sm font-semibold text-slate-600 flex items-center gap-2">
              <Clock size={16} />
              Chat History
            </h2>
            <button
              onClick={() => setSidebarOpen(false)}
              className="p-1.5 hover:bg-slate-100 rounded-lg transition-colors text-slate-400 hover:text-slate-600"
            >
              <X size={18} />
            </button>
          </div>

          {/* History List */}
          <div className="flex-1 overflow-y-auto p-3">
            {history.length === 0 ? (
              <div className="flex flex-col items-center justify-center h-full text-center text-slate-400 px-4 py-8">
                <MessageSquare size={32} className="text-slate-300 mb-3" />
                <p className="text-sm font-medium mb-1">No conversations yet</p>
                <p className="text-xs">Your question history will appear here once you start chatting</p>
              </div>
            ) : (
              <div className="space-y-2">
                {history.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => handleHistoryClick(item)}
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

          {/* Sidebar Footer */}
          <div className="p-3 border-t border-slate-200">
            <button
              onClick={handleNewChat}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-indigo-500 hover:bg-indigo-600 text-white rounded-xl transition-colors shadow-lg shadow-indigo-500/20"
            >
              <Plus size={18} />
              <span className="font-medium">New Chat</span>
            </button>
            {history.length > 0 && (
              <button
                onClick={handleClearHistory}
                className="w-full flex items-center justify-center gap-2 px-3 py-2 text-sm text-red-500/70 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors mt-2"
              >
                <Trash2 size={16} />
                Clear History
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Header */}
        <header className="bg-white border-b border-slate-200 px-3 md:px-4 flex items-center justify-between h-[57px]">
          <div className="flex items-center gap-2 md:gap-3">
            {/* Menu button - only shows when sidebar is closed, hidden on mobile */}
            {!sidebarOpen && (
              <button
                onClick={() => setSidebarOpen(true)}
                className="hidden md:block p-2 hover:bg-slate-100 rounded-lg transition-colors"
              >
                <Menu size={20} />
              </button>
            )}
            <div className="flex items-center gap-2 md:gap-3">
              <div className="flex items-center justify-center w-7 h-7 md:w-8 md:h-8 rounded-lg bg-gradient-to-br from-indigo-500 to-purple-600">
                <BarChart3 size={16} className="text-white md:hidden" />
                <BarChart3 size={18} className="text-white hidden md:block" />
              </div>
              <div>
                <h1 className="text-sm md:text-lg font-semibold text-slate-800">GTM Intelligence</h1>
                <p className="text-[10px] md:text-xs text-slate-500">
                  GPT-5.2 • {DEMO_CALL_COUNT} call analyzed
                </p>
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2 md:gap-4">
            {/* Team Selector Dropdown */}
            <div className="relative">
              <button
                onClick={() => setTeamDropdownOpen(!teamDropdownOpen)}
                className={`flex items-center gap-1 md:gap-2 px-2 md:px-3 py-1 md:py-1.5 rounded-lg border transition-all ${currentTeam.bgColor} ${currentTeam.color} border-current/20`}
              >
                <currentTeam.icon size={12} className="md:hidden" />
                <currentTeam.icon size={14} className="hidden md:block" />
                <span className="text-[10px] md:text-xs font-medium hidden sm:inline">{currentTeam.name}</span>
                <ChevronDown size={12} className={`transition-transform ${teamDropdownOpen ? 'rotate-180' : ''}`} />
              </button>
              
              {teamDropdownOpen && (
                <div className="absolute right-0 top-full mt-1 w-44 md:w-48 bg-white rounded-xl shadow-lg border border-slate-200 py-1 z-50">
                  {TEAMS.map((team) => {
                    const TeamIcon = team.icon;
                    return (
                      <button
                        key={team.id}
                        onClick={() => {
                          setSelectedTeam(team.id);
                          setTeamDropdownOpen(false);
                        }}
                        className={`w-full flex items-center gap-2 px-3 py-2 text-left hover:bg-slate-50 transition-colors ${
                          selectedTeam === team.id ? team.color : 'text-slate-600'
                        }`}
                      >
                        <TeamIcon size={16} />
                        <span className="text-sm font-medium">{team.name}</span>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>

            <div className="hidden sm:flex items-center gap-2">
              <div className="w-2 h-2 bg-amber-500 rounded-full animate-pulse" />
              <span className="text-sm text-amber-600 font-medium">Demo Environment</span>
            </div>
          </div>
        </header>

        {/* Chat Area */}
        <div className="flex-1 overflow-y-auto">
          <div className="max-w-4xl mx-auto px-3 md:px-4 py-3 md:py-4">
            {messages.length === 0 ? (
              /* Welcome Screen - Compact layout */
              <div className="text-center py-2 md:py-4">
                {/* Icon - Smaller */}
                <div className="inline-flex items-center justify-center w-10 h-10 md:w-12 md:h-12 rounded-lg md:rounded-xl bg-indigo-100 mb-2 md:mb-3">
                  <BarChart3 size={20} className="text-indigo-500 md:hidden" />
                  <BarChart3 size={24} className="text-indigo-500 hidden md:block" />
                </div>
                
                {/* Heading - Smaller */}
                <h2 className="text-lg md:text-xl font-semibold text-slate-800 mb-1">
                  GTM Intelligence Agent
                </h2>
                <p className="text-xs md:text-sm text-slate-500 max-w-md mx-auto mb-3 md:mb-4 px-2">
                  Select your team to get insights tailored to your needs
                </p>

                {/* Team Selector - More compact */}
                <div className="flex justify-start md:justify-center gap-2 mb-3 md:mb-4 overflow-x-auto pb-2 px-1 -mx-1 scrollbar-hide">
                  {TEAMS.map((team) => {
                    const TeamIcon = team.icon;
                    const isSelected = selectedTeam === team.id;
                    return (
                      <button
                        key={team.id}
                        onClick={() => setSelectedTeam(team.id)}
                        className={`flex items-center gap-1.5 px-3 py-1.5 md:py-2 rounded-lg border-2 transition-all whitespace-nowrap flex-shrink-0 text-xs md:text-sm ${
                          isSelected
                            ? `${team.bgColor} border-current ${team.color} shadow-sm`
                            : 'bg-white border-slate-200 text-slate-600 hover:border-slate-300'
                        }`}
                      >
                        <TeamIcon size={14} className="md:hidden" />
                        <TeamIcon size={16} className="hidden md:block" />
                        <span className="font-medium">{team.name}</span>
                      </button>
                    );
                  })}
                </div>

                {/* Team Description - Smaller */}
                <div className={`inline-flex items-center gap-1.5 px-3 py-1 md:py-1.5 rounded-full mb-3 md:mb-4 ${currentTeam.bgColor.split(' ')[0]} ${currentTeam.color}`}>
                  <currentTeam.icon size={12} className="md:hidden" />
                  <currentTeam.icon size={14} className="hidden md:block" />
                  <span className="text-xs font-medium">{currentTeam.description}</span>
                </div>

                {/* Question Cards - More compact */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-3 max-w-xl mx-auto">
                  {currentQuestions.map((card, idx) => (
                    <button
                      key={idx}
                      onClick={() => handleAskQuestion(card.question)}
                      className="flex flex-col items-start p-3 md:p-4 bg-white rounded-lg border border-slate-200 hover:border-slate-300 hover:shadow-md transition-all text-left group"
                    >
                      <div className={`p-1.5 rounded-md ${card.color} mb-2`}>
                        <card.icon size={14} className="md:hidden" />
                        <card.icon size={16} className="hidden md:block" />
                      </div>
                      <h3 className="font-semibold text-sm text-slate-800 group-hover:text-indigo-600 transition-colors">
                        {card.title}
                      </h3>
                      <p className="text-xs text-slate-500 mt-0.5">
                        {card.description}
                      </p>
                    </button>
                  ))}
                </div>
              </div>
            ) : (
              /* Chat Messages */
              <div className="space-y-6">
                {messages.map((message) => (
                  <ChatMessage key={message.id} message={message} />
                ))}
                
                {isLoading && (
                  <div className="flex items-start gap-4">
                    <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-indigo-500 to-purple-600 flex items-center justify-center flex-shrink-0">
                      <BarChart3 size={16} className="text-white" />
                    </div>
                    <div className="flex-1 bg-white rounded-2xl rounded-tl-md p-4 shadow-sm border border-slate-100">
                      {streamingMessage ? (
                        <p className="text-slate-700 whitespace-pre-wrap">{streamingMessage}</p>
                      ) : (
                        <LoadingSpinner />
                      )}
                    </div>
                  </div>
                )}
                
                <div ref={messagesEndRef} />
              </div>
            )}
          </div>
        </div>

        {/* Input Area */}
        <div className="border-t border-slate-200 bg-white p-2 md:p-4">
          <div className="max-w-4xl mx-auto">
            <QuestionInput
              onSubmit={handleAskQuestion}
              isLoading={isLoading}
            />
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
