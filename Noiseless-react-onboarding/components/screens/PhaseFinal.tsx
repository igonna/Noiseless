
import React from 'react';
import { useOnboarding } from '../../context/OnboardingContext';
import { StepLayout } from '../ui/StepLayout';
import { Button } from '../ui/Button';
import { ScreenStep } from '../../types';
import { LayoutDashboard } from 'lucide-react';
import { motion } from 'framer-motion';

export const FinalPhase: React.FC = () => {
  const { currentStep, goToStep } = useOnboarding();

  // Screen 23: Notifications (Revamped)
  if (currentStep === ScreenStep.NOTIFICATIONS) {
    return (
      <StepLayout 
        title="Reach your goals with notifications"
        subtitle="Stay on track with daily insights tailored to your journey."
        centerContent 
        hideBackButton
        showProgressBar={false}
      >
        <div className="flex-1 flex flex-col items-center justify-center w-full relative z-10">
            {/* Custom App-Themed Alert */}
            <motion.div 
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.3, type: "spring", bounce: 0.3 }}
                className="w-[270px] bg-zinc-900 rounded-[14px] overflow-hidden text-center shadow-[0_0_50px_rgba(0,0,0,0.5)] mx-auto border border-zinc-800"
            >
                <div className="pt-6 pb-5 px-4 space-y-2">
                    <h3 className="text-[17px] font-semibold text-white leading-snug">
                        "Aura" Would Like to Send You Notifications
                    </h3>
                    <p className="text-[13px] text-zinc-400 leading-relaxed">
                        Notifications may include alerts, sounds, and icon badges. These can be configured in Settings.
                    </p>
                </div>
                <div className="grid grid-cols-2 border-t border-zinc-800">
                    <button className="py-3 text-[17px] text-zinc-500 hover:text-zinc-300 active:bg-zinc-800/50 border-r border-zinc-800 transition-colors">
                        Don’t Allow
                    </button>
                    <button className="py-3 text-[17px] font-bold text-white hover:bg-zinc-800/50 transition-colors">
                        Allow
                    </button>
                </div>
            </motion.div>
        </div>

        <div className="w-full mt-auto pt-8">
            <Button fullWidth onClick={() => goToStep(ScreenStep.FINAL_WELCOME)}>Continue</Button>
        </div>
      </StepLayout>
    );
  }

  // Screen 25: Final Welcome (Revamped)
  if (currentStep === ScreenStep.FINAL_WELCOME) {
    return (
       <StepLayout centerContent showProgressBar={false} hideBackButton>
          {/* Ambient Background */}
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 1.5 }}
            className="absolute inset-0 bg-gradient-to-t from-zinc-950 via-zinc-900/20 to-zinc-950 pointer-events-none"
          />
          
          <div className="flex-1 flex flex-col items-center justify-center relative z-10">
              <motion.div
                 initial={{ scale: 0.8, opacity: 0 }}
                 animate={{ scale: 1, opacity: 1 }}
                 transition={{ duration: 0.8, ease: "easeOut" }}
                 className="mb-8 relative"
              >
                  <div className="absolute inset-0 bg-white/20 blur-3xl rounded-full" />
                  <div className="w-24 h-24 bg-white rounded-2xl flex items-center justify-center shadow-[0_0_50px_rgba(255,255,255,0.2)] relative z-10">
                        <div className="w-12 h-12 bg-black rounded-full" />
                  </div>
              </motion.div>

              <motion.h1 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3, duration: 0.6 }}
                className="text-4xl md:text-5xl font-bold text-center mb-6 text-white tracking-tight"
              >
                  Welcome to Noiseless.
              </motion.h1>
              
              <motion.p 
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.5, duration: 0.6 }}
                className="text-lg text-zinc-400 text-center max-w-xs leading-relaxed"
              >
                  Your personal model is ready — your first insight is waiting.
              </motion.p>
          </div>

          <div className="w-full mt-auto relative z-10 pt-8">
              <Button fullWidth onClick={() => goToStep(ScreenStep.DASHBOARD)}>
                  See My Insight
              </Button>
          </div>
       </StepLayout>
    );
  }

  // Screen 28: Dashboard (Placeholder)
  if (currentStep === ScreenStep.DASHBOARD) {
      return (
          <div className="min-h-screen bg-black text-white p-6 flex flex-col items-center justify-center relative overflow-hidden">
              <div className="w-full max-w-md border border-zinc-800 bg-zinc-900/50 p-8 rounded-2xl backdrop-blur-xl shadow-2xl relative z-10">
                  <div className="flex items-center gap-3 mb-6">
                      <LayoutDashboard className="text-white" />
                      <h2 className="text-xl font-bold">Welcome to Aura</h2>
                  </div>
                  <div className="space-y-6">
                    <div className="bg-zinc-800/50 p-4 rounded-xl border border-zinc-700/50">
                        <p className="text-zinc-500 text-xs uppercase tracking-wider mb-2">Today's Focus</p>
                        <p className="text-white font-medium">Review your career transition strategy.</p>
                    </div>
                    <p className="text-zinc-400 text-sm leading-relaxed">
                        This is where the actual application would begin. The onboarding flow is complete.
                    </p>
                  </div>
                  
                  <div className="mt-8">
                    <Button fullWidth onClick={() => window.location.reload()} variant="secondary">
                        Restart Demo
                    </Button>
                  </div>
              </div>
              
              {/* Background elements */}
              {[...Array(20)].map((_, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, y: 100 }}
                    animate={{ opacity: [0, 1, 0], y: -100, x: Math.random() * 100 - 50 }}
                    transition={{ duration: 2 + Math.random() * 2, repeat: Infinity, delay: Math.random() * 2 }}
                    className="absolute w-1 h-1 bg-white rounded-full"
                    style={{ left: `${Math.random() * 100}%`, top: `${Math.random() * 100}%` }}
                  />
              ))}
          </div>
      );
  }

  return null;
};
