import React, { useEffect, useState } from 'react';
import { useOnboarding } from '../../context/OnboardingContext';
import { StepLayout } from '../ui/StepLayout';
import { Button } from '../ui/Button';
import { ScreenStep } from '../../types';
import { motion } from 'framer-motion';
import { Check, CheckCircle2 } from 'lucide-react';

const ProcessingSteps: React.FC = () => {
  const { goToStep } = useOnboarding();
  const [completedCount, setCompletedCount] = useState(0);

  const steps = [
    "Analyzing your strengths",
    "Interpreting your goals & values",
    "Mapping your constraints",
    "Connecting skills & curiosity",
    "Reading local opportunities",
    "Designing your path forward"
  ];

  useEffect(() => {
    // Process one step every 1 second (1000ms)
    if (completedCount < steps.length) {
      const timer = setTimeout(() => {
        setCompletedCount((prev) => prev + 1);
      }, 1000);
      return () => clearTimeout(timer);
    } else {
      // All steps done, auto-advance after a short pause
      const endTimer = setTimeout(() => {
        if ("vibrate" in navigator) try { navigator.vibrate(10); } catch(e) {}
        goToStep(ScreenStep.PATH_READY);
      }, 800);
      return () => clearTimeout(endTimer);
    }
  }, [completedCount, steps.length, goToStep]);

  const progress = Math.min(Math.round((completedCount / steps.length) * 100), 100);

  return (
    <StepLayout centerContent hideBackButton showProgressBar={false}>
      {/* Background Animation */}
      <div className="absolute inset-0 overflow-hidden -z-10 pointer-events-none">
          <motion.div 
             className="absolute top-[-10%] left-[-10%] w-[500px] h-[500px] bg-blue-900/10 rounded-full blur-[100px]"
             animate={{ 
                x: [0, 50, 0], 
                y: [0, 30, 0], 
                scale: [1, 1.1, 1],
                opacity: [0.3, 0.5, 0.3] 
             }}
             transition={{ duration: 10, repeat: Infinity, ease: "easeInOut" }}
          />
          <motion.div 
             className="absolute bottom-[-10%] right-[-10%] w-[500px] h-[500px] bg-violet-900/10 rounded-full blur-[100px]"
             animate={{ 
                x: [0, -30, 0], 
                y: [0, -50, 0], 
                scale: [1, 1.2, 1],
                opacity: [0.2, 0.4, 0.2] 
             }}
             transition={{ duration: 12, repeat: Infinity, ease: "easeInOut", delay: 2 }}
          />
      </div>

      <div className="w-full h-full flex flex-col relative">
          {/* Centered Title & Progress Section */}
          <div className="mt-8 mb-10 text-center shrink-0 z-10 w-full max-w-xs mx-auto">
              <motion.h1 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-3xl font-bold text-white tracking-tight mb-8"
              >
                We're setting everything up for you
              </motion.h1>
              
              <div className="w-full px-2">
                 <div className="flex justify-between items-end mb-2">
                    <span className="text-xs font-medium text-zinc-500 uppercase tracking-wider">Processing</span>
                    <span className="text-xl font-bold text-white tabular-nums">{progress}%</span>
                 </div>
                 <div className="h-1.5 w-full bg-zinc-800 rounded-full overflow-hidden">
                    <motion.div
                        className="h-full bg-white rounded-full"
                        initial={{ width: 0 }}
                        animate={{ width: `${progress}%` }}
                        transition={{ duration: 0.5, ease: "easeOut" }}
                    />
                 </div>
              </div>
          </div>

          {/* Left-aligned checklist inside a centered container */}
          <div className="flex-1 flex flex-col justify-start overflow-y-auto min-h-0 z-10 custom-scrollbar pb-4 w-full">
             <div className="w-full max-w-xs mx-auto space-y-6 pl-2">
                {steps.map((step, index) => {
                    const isCompleted = index < completedCount;
                    const isActive = index === completedCount;
                    const isPending = index > completedCount;

                    return (
                        <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: index * 0.1 }}
                            className="flex items-center gap-5"
                        >
                            {/* Icon Container */}
                            <div className="flex-shrink-0 w-5 flex items-center justify-center">
                                {isCompleted && (
                                    <motion.div
                                        initial={{ scale: 0.5, opacity: 0 }}
                                        animate={{ scale: 1, opacity: 1 }}
                                    >
                                        <Check size={18} className="text-white" strokeWidth={3} />
                                    </motion.div>
                                )}
                                
                                {isActive && (
                                    <div className="w-2 h-2 bg-white rounded-full" />
                                )}

                                {isPending && (
                                    <div className="w-1.5 h-1.5 bg-zinc-800 rounded-full" />
                                )}
                            </div>

                            {/* Text */}
                            <span 
                                className={`text-base font-medium transition-colors duration-500 ${
                                    isPending ? 'text-zinc-600' : 'text-white'
                                }`}
                            >
                                {step}
                            </span>
                        </motion.div>
                    );
                })}
             </div>
          </div>

          <div className="mt-auto pt-6 shrink-0 z-20 pb-2 min-h-[100px]">
              <motion.p 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="text-[11px] text-zinc-600 text-center mt-4 font-medium tracking-wide animate-pulse"
              >
                  Building your personal model...
              </motion.p>
          </div>
      </div>
    </StepLayout>
  );
};

const PathReadyScreen: React.FC = () => {
  const { nextStep } = useOnboarding();

  return (
    <StepLayout centerContent hideBackButton showProgressBar={false}>
        <div className="relative flex items-center justify-center mb-10">
          <motion.div
             animate={{ rotate: 360, scale: [1, 1.1, 1] }}
             transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
             className="absolute w-64 h-64 bg-zinc-800/30 rounded-full blur-3xl"
          />
          
          <motion.div
              initial={{ scale: 0, rotate: -45 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ 
                  type: "spring",
                  stiffness: 200,
                  damping: 20,
                  duration: 0.8 
              }}
              className="relative z-10"
          >
              <CheckCircle2 size={64} className="text-white" strokeWidth={1.5} />
          </motion.div>
        </div>
        
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.6 }}
          className="text-center mb-12"
        >
          <h1 className="text-4xl font-bold text-white mb-4 tracking-tight">
              Congratulations your custom plan is ready!
          </h1>
          <p className="text-lg text-zinc-400 max-w-sm mx-auto leading-relaxed">
              Built from your strengths, goals, and real-world context — optimized for results.
          </p>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="w-full mt-auto"
        >
            <Button fullWidth onClick={nextStep}>Let's get started!</Button>
        </motion.div>
    </StepLayout>
  );
};

export const RitualPhase: React.FC = () => {
  const { currentStep } = useOnboarding();

  if (currentStep === ScreenStep.BUILDING_MODEL || currentStep === ScreenStep.CALIBRATING) {
      return <ProcessingSteps />;
  }

  if (currentStep === ScreenStep.PATH_READY) {
      return <PathReadyScreen />;
  }

  return null;
};