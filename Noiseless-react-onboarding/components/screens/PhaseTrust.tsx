import React, { useState, useEffect } from 'react';
import { useOnboarding } from '../../context/OnboardingContext';
import { StepLayout } from '../ui/StepLayout';
import { Button } from '../ui/Button';
import { OptionButton } from '../ui/OptionButton';
import { GLOW_ANIMATION } from '../../constants';
import { motion, AnimatePresence } from 'framer-motion';
import { ScreenStep } from '../../types';
import { Briefcase, GraduationCap, RefreshCw, Laptop, HelpCircle, User, Plus, ArrowLeft } from 'lucide-react';

export const TrustPhase: React.FC = () => {
  const { currentStep, nextStep, userData, updateUserData } = useOnboarding();
  const [showOtherInput, setShowOtherInput] = useState(false);
  const [customInput, setCustomInput] = useState("");

  // Reset "Other" input state when changing steps
  useEffect(() => {
    if (currentStep !== ScreenStep.IDENTITY_DETAILS) {
      setShowOtherInput(false);
      setCustomInput("");
    }
  }, [currentStep]);

  // Screen 1: Welcome (Universal)
  if (currentStep === ScreenStep.WELCOME) {
    return (
      <StepLayout centerContent showProgressBar={false}>
        <motion.div 
           variants={GLOW_ANIMATION}
           initial="initial"
           animate="animate"
           className="w-64 h-64 rounded-full bg-gradient-to-tr from-zinc-800 via-zinc-700 to-zinc-600 blur-3xl absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 -z-10 opacity-20"
        />
        <div className="flex flex-col items-center justify-center h-full space-y-8">
            <div className="w-20 h-20 bg-white rounded-2xl flex items-center justify-center shadow-2xl shadow-white/10 mb-6">
                <div className="w-10 h-10 bg-black rounded-full" />
            </div>
            <h1 className="text-4xl font-bold text-center">Let’s accelerate your growth.</h1>
            <p className="text-xl text-zinc-400 text-center max-w-xs">Daily insights. Smarter choices. Better outcomes.</p>
            <div className="absolute bottom-10 w-full px-6">
                <Button fullWidth onClick={nextStep}>Get Started</Button>
            </div>
        </div>
      </StepLayout>
    );
  }

  // Screen 2: Identity Fork
  if (currentStep === ScreenStep.IDENTITY) {
    const identities = [
      { id: 'pro', label: 'Working professional', icon: <Briefcase size={20}/> },
      { id: 'student', label: 'Student or learner', icon: <GraduationCap size={20}/> },
      { id: 'career_change', label: 'Changing careers', icon: <RefreshCw size={20}/> },
      { id: 'freelance', label: 'Freelancer / self-employed', icon: <Laptop size={20}/> },
      { id: 'figuring', label: 'Figuring things out', icon: <HelpCircle size={20}/> },
      { id: 'improving', label: 'Just improving myself', icon: <User size={20}/> },
    ];

    return (
      <StepLayout title="Which describes you best?">
        <div className="flex-1 overflow-y-auto -mx-4 px-4 py-2 mt-4 space-y-3 custom-scrollbar">
          {identities.map((item) => (
            <motion.button
              key={item.id}
              onClick={() => {
                updateUserData({ identity: item.label });
                nextStep();
              }}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="w-full p-4 rounded-xl border border-zinc-800/50 bg-zinc-900/50 hover:bg-zinc-900 hover:border-zinc-700 transition-all flex items-center gap-4 text-left"
            >
              <div className="p-2 bg-zinc-800 rounded-lg text-zinc-200">
                {item.icon}
              </div>
              <span className="text-lg font-medium text-zinc-200">{item.label}</span>
            </motion.button>
          ))}
        </div>
      </StepLayout>
    );
  }

  // Screen 3: Identity Details (Dynamic)
  if (currentStep === ScreenStep.IDENTITY_DETAILS) {
    const identity = userData.identity;
    
    let title = "";
    let placeholder = "";
    let options: string[] = [];
    let isDirectInput = false;

    if (identity === 'Working professional') {
      title = "What’s your current role?";
      placeholder = "Type your role…";
      isDirectInput = true;
    } else if (identity === 'Student or learner') {
      title = "What are you studying or learning?";
      options = ["Programming", "Engineering", "Business", "Finance", "Design", "Marketing", "AI / Machine Learning", "Data Science", "Psychology", "Health & Fitness", "Languages"];
      placeholder = "e.g. Astrophysics...";
    } else if (identity === 'Changing careers') {
      title = "What are you transitioning toward?";
      options = ["Tech / engineering", "Design", "Business / management", "Marketing", "Product", "Freelancing", "Entrepreneurship", "AI / ML", "Data", "Creative fields"];
      placeholder = "Describe your target career...";
    } else if (identity === 'Freelancer / self-employed') {
      title = "What type of work do you do?";
      options = ["Software", "Design", "Marketing", "Consulting", "Coaching", "Content creation", "Sales", "Service work"];
      placeholder = "Describe your work...";
    } else {
      // Figuring things out OR Just improving myself
      title = "What are you curious about right now?";
      options = ["AI & future tech", "Starting a business", "Earning more money", "Developing discipline", "Improving health", "Finding direction", "Creativity & art", "Personal development", "Relationships & social skills", "Learning new skills"];
      placeholder = "What are you curious about?";
    }

    // Special case for Working Professional where we only want input
    if (isDirectInput) {
       return (
        <StepLayout title={title}>
          <div className="mt-4">
             <input 
                type="text" 
                placeholder={placeholder}
                className="w-full bg-transparent border-b border-zinc-700 text-2xl py-4 focus:outline-none focus:border-white transition-colors placeholder:text-zinc-600"
                autoFocus
                value={userData.identityDetail}
                onChange={(e) => updateUserData({ identityDetail: e.target.value })}
              />
          </div>
          <div className="mt-auto">
              <Button fullWidth onClick={nextStep} disabled={!userData.identityDetail.trim()}>Continue</Button>
          </div>
        </StepLayout>
       );
    }

    const handleAddOption = () => {
      if (customInput.trim()) {
        updateUserData({ identityDetail: customInput.trim() });
        setShowOtherInput(false);
        setCustomInput("");
      }
    };

    // Construct display list: Default options + currently selected if custom
    const displayOptions = [...options];
    const currentSelected = userData.identityDetail;
    const isCustom = currentSelected && !options.includes(currentSelected);
    
    // Use a Set to avoid duplicates if user types something that exists
    const finalOptions = isCustom ? [...displayOptions, currentSelected] : displayOptions;

    return (
      <StepLayout title={title}>
        <div className="flex-1 flex flex-col relative min-h-0 mt-4">
            <AnimatePresence mode="wait">
            {!showOtherInput ? (
                <div className="flex-1 overflow-y-auto -mx-4 px-4 py-2 custom-scrollbar">
                    <div className="flex flex-wrap gap-3 pb-4">
                        {finalOptions.map(t => (
                            <OptionButton
                                key={t}
                                label={t}
                                selected={userData.identityDetail === t}
                                onClick={() => { 
                                    updateUserData({ identityDetail: t }); 
                                }}
                            />
                        ))}
                        
                        <OptionButton
                            label="Add"
                            icon={<Plus size={18} />}
                            isAdd
                            onClick={() => {
                                setShowOtherInput(true);
                                setCustomInput("");
                            }}
                        />
                    </div>
                </div>
            ) : (
                <motion.div 
                    key="input"
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -10 }}
                    className="flex flex-col w-full"
                >
                    <div className="flex items-center gap-2 mb-4">
                        <button 
                            onClick={() => setShowOtherInput(false)}
                            className="p-2 -ml-2 rounded-full hover:bg-zinc-800 text-zinc-400 transition-colors"
                        >
                            <ArrowLeft size={20} />
                        </button>
                        <span className="text-zinc-400">Add new option</span>
                    </div>

                    <input 
                        type="text" 
                        placeholder={placeholder}
                        className="w-full bg-transparent border-b border-zinc-700 text-xl py-3 focus:outline-none focus:border-white transition-colors placeholder:text-zinc-600 mb-6"
                        autoFocus
                        value={customInput}
                        onChange={(e) => setCustomInput(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && handleAddOption()}
                    />
                    
                    <Button 
                        fullWidth 
                        onClick={handleAddOption}
                        disabled={!customInput.trim()}
                    >
                        Add Option
                    </Button>
                </motion.div>
            )}
            </AnimatePresence>
        </div>
        {!showOtherInput && (
            <div className="mt-auto pt-6 border-t border-zinc-900">
                <Button fullWidth onClick={nextStep} disabled={!userData.identityDetail.trim()}>Continue</Button>
            </div>
        )}
      </StepLayout>
    );
  }

  return null;
};