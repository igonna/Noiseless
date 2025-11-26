import React from 'react';
import { motion } from 'framer-motion';
import { FADE_IN_VARIANTS } from '../../constants';
import { useOnboarding } from '../../context/OnboardingContext';
import { ArrowLeft, ChevronLeft } from 'lucide-react';
import { ScreenStep } from '../../types';

interface StepLayoutProps {
  children: React.ReactNode;
  title?: React.ReactNode;
  subtitle?: string;
  showProgressBar?: boolean;
  currentStep?: number;
  totalSteps?: number;
  centerContent?: boolean;
  hideBackButton?: boolean;
  centerTitle?: boolean;
}

export const StepLayout: React.FC<StepLayoutProps> = ({ 
  children, 
  title, 
  subtitle, 
  showProgressBar = true,
  currentStep: propCurrentStep,
  totalSteps = 28,
  centerContent = false,
  hideBackButton = false,
  centerTitle = false
}) => {
  const { currentStep: contextStep, prevStep } = useOnboarding();
  
  // Use prop if provided, otherwise fallback to context
  const currentStep = propCurrentStep ?? contextStep;
  
  // Calculate progress, capped at 100%
  const progress = Math.min((currentStep / totalSteps) * 100, 100);

  // Show back button logic:
  // 1. Not explicitly hidden via prop
  // 2. Not on the very first step (Welcome)
  const showBack = !hideBackButton && currentStep > 1;

  // Check if we are on the specific screens that need a subtle back button
  const isMinimalBack = currentStep === ScreenStep.TRIAL_OFFER || currentStep === ScreenStep.PAYWALL;

  return (
    <div className="h-[100dvh] flex flex-col relative overflow-hidden max-w-md mx-auto bg-zinc-950">
      
      {/* Header: Back Button & Progress Bar */}
      <div className="absolute top-0 left-0 w-full z-50 px-6 pt-8 pb-2 flex items-center pointer-events-none">
          {/* Left: Back Button Slot */}
          <div className="w-8 h-8 flex items-center justify-start pointer-events-auto shrink-0">
            {showBack && (
                <button 
                    onClick={prevStep}
                    className={`p-1 -ml-2 rounded-full transition-all focus:outline-none ${
                        isMinimalBack 
                        ? 'text-zinc-600 hover:text-zinc-400' 
                        : 'text-zinc-400 hover:text-white hover:bg-zinc-800/50'
                    }`}
                    aria-label="Go back"
                >
                    {isMinimalBack ? <ChevronLeft size={32} strokeWidth={1.5} /> : <ArrowLeft size={24} />}
                </button>
            )}
          </div>

          {/* Center: Progress Bar */}
          {showProgressBar && (
            <div className="flex-1 pl-4">
               <div className="w-full h-1.5 bg-zinc-900 rounded-full overflow-hidden">
                    <motion.div 
                        className="h-full bg-white shadow-[0_0_10px_rgba(255,255,255,0.5)]"
                        initial={{ width: 0 }}
                        animate={{ width: `${progress}%` }}
                        transition={{ duration: 0.5 }}
                    />
               </div>
            </div>
          )}
      </div>

      <motion.div 
        className={`flex-1 flex flex-col px-6 pt-24 pb-8 min-h-0 ${centerContent ? 'justify-center items-center text-center' : ''}`}
        variants={FADE_IN_VARIANTS}
        initial="hidden"
        animate="visible"
        exit="exit"
      >
        <div className={`w-full shrink-0 ${centerContent ? 'mb-8' : 'mb-6'}`}>
          {title && (
            <h1 className={`text-3xl md:text-4xl font-bold text-white tracking-tight leading-[1.15] mb-4 ${centerContent || centerTitle ? 'mx-auto text-center' : ''}`}>
              {title}
            </h1>
          )}
          {subtitle && (
            <p className={`text-lg text-zinc-400 leading-relaxed ${centerContent || centerTitle ? 'text-center' : ''}`}>
              {subtitle}
            </p>
          )}
        </div>

        <div className="w-full flex-1 flex flex-col relative min-h-0">
          {children}
        </div>
      </motion.div>
    </div>
  );
};