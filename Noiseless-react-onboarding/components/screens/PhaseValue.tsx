import React from 'react';
import { useOnboarding } from '../../context/OnboardingContext';
import { StepLayout } from '../ui/StepLayout';
import { Button } from '../ui/Button';
import { ScreenStep } from '../../types';
import { motion } from 'framer-motion';
import { ShieldCheck, Bell, Sparkles } from 'lucide-react';

export const ValuePhase: React.FC = () => {
  const { currentStep, nextStep } = useOnboarding();

  // Screen 18: Save Progress (Formerly Three Insights)
  if (currentStep === ScreenStep.INSIGHTS_PREVIEW) {
    return (
      <StepLayout 
        title="Save Your Progress" 
        centerContent
      >
          <div className="flex-1 flex flex-col justify-center w-full max-w-xs mx-auto space-y-4">
              {/* Apple Button */}
              <button 
                onClick={nextStep}
                className="w-full bg-white text-black font-bold h-12 rounded-full flex items-center justify-center gap-3 hover:bg-zinc-200 transition-colors shadow-[0_0_15px_rgba(255,255,255,0.1)]"
              >
                  <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 384 512">
                    <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 52.3-11.4 69.5-34.3z" />
                  </svg>
                  <span>Sign in with Apple</span>
              </button>

              {/* Google Button */}
              <button 
                onClick={nextStep}
                className="w-full bg-zinc-800 text-white font-bold h-12 rounded-full flex items-center justify-center gap-3 border border-zinc-700 hover:bg-zinc-700 transition-colors"
              >
                  <svg className="h-5 w-5" viewBox="0 0 24 24">
                     <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
                     <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
                     <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
                     <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
                  </svg>
                  <span>Sign in with Google</span>
              </button>
          </div>
          
          <div className="mt-auto shrink-0">
             <p className="text-zinc-600 text-xs text-center pb-4">
                We'll sync your data securely.
             </p>
          </div>
      </StepLayout>
    );
  }

  // Screen 19: Trial Offer (Merged with elements from old Reminder screen)
  if (currentStep === ScreenStep.TRIAL_OFFER) {
    return (
      <StepLayout 
        title="Try Noiseless free for 3 days."
        subtitle="We'll send you a reminder before your free trial ends"
        showProgressBar={false}
      >
         <div className="flex-1 flex items-center justify-center">
            {/* Notification Visual */}
            <div className="w-full max-w-sm bg-zinc-900/80 backdrop-blur-md p-4 rounded-2xl border border-zinc-800 shadow-2xl relative">
                {/* Glow behind */}
                <div className="absolute -inset-4 bg-gradient-to-r from-blue-500/20 to-purple-500/20 rounded-3xl blur-xl -z-10 opacity-50"></div>
                
                <div className="flex items-start gap-3">
                    <div className="bg-zinc-800 p-2 rounded-xl">
                        <Bell size={24} className="text-white fill-white" />
                    </div>
                    <div className="flex-1">
                        <div className="flex justify-between items-center mb-1">
                            <h3 className="font-bold text-white text-sm">Noiseless</h3>
                            <span className="text-xs text-zinc-500">now</span>
                        </div>
                        <p className="text-sm text-zinc-200 font-medium">Your 3-day trial is ending soon.</p>
                        <p className="text-xs text-zinc-400 mt-1">We'll remind you 24h before you're charged so you have full control.</p>
                    </div>
                </div>
            </div>
         </div>

         <div className="mt-auto pt-6">
              <div className="flex items-center justify-center gap-2 mb-4">
                    <ShieldCheck size={16} className="text-zinc-400" />
                    <span className="text-sm font-semibold text-zinc-300">No Payment Due Now</span>
              </div>

             <Button fullWidth onClick={nextStep}>Continue for FREE</Button>
             
             <div className="text-center mt-3">
                <p className="text-xs text-zinc-500 font-medium">Just 46,99 US$ per year (3,91 US$/mo)</p>
             </div>
         </div>
      </StepLayout>
    );
  }

  return null;
};