import React, { useState } from 'react';
import { useOnboarding } from '../../context/OnboardingContext';
import { StepLayout } from '../ui/StepLayout';
import { Button } from '../ui/Button';
import { ScreenStep } from '../../types';
import { Check, X, ShieldCheck } from 'lucide-react';

export const PaywallPhase: React.FC = () => {
  const { currentStep, goToStep } = useOnboarding();
  const [selectedPlan, setSelectedPlan] = useState<'yearly' | 'monthly'>('yearly');

  // Screen 20: Hard Paywall + Trial
  if (currentStep === ScreenStep.PAYWALL) {
    return (
      <StepLayout title="Unlock Your Noiseless Advantage" showProgressBar={false} centerTitle>
        {/* Features List */}
        <div className="mt-8 space-y-5">
            {[
                "Daily insights tailored to your goals",
                "Smart opportunities matched to your skills",
                "Clear next steps you can act on immediately",
                "Real shifts that actually affect your future",
                "Always adapting as you grow"
            ].map((adv, i) => (
                <div key={i} className="flex items-start gap-4">
                    <div className="mt-1 shrink-0 text-white bg-white/10 p-1 rounded-full">
                        <Check size={12} strokeWidth={4} />
                    </div>
                    <span className="text-base text-zinc-100 leading-snug font-medium">{adv}</span>
                </div>
            ))}
        </div>

        <div className="mt-auto pt-8">
            {/* Plan Selection */}
            <div className="grid grid-cols-2 gap-3 mb-6">
                {/* Monthly */}
                <button
                    onClick={() => setSelectedPlan('monthly')}
                    className={`py-3 px-3 rounded-xl border transition-all duration-300 flex flex-col items-center justify-center relative ${
                        selectedPlan === 'monthly' 
                        ? 'bg-zinc-900 border-white shadow-lg z-10 scale-[1.02]' 
                        : 'bg-transparent border-zinc-800 hover:border-zinc-700'
                    }`}
                >
                    <span className="text-sm font-bold uppercase tracking-wide mb-1 text-white">Monthly</span>
                    <span className="text-lg font-bold text-white">11,99 US$/mo</span>
                </button>

                {/* Yearly */}
                <button
                    onClick={() => setSelectedPlan('yearly')}
                    className={`py-3 px-3 rounded-xl border transition-all duration-300 flex flex-col items-center justify-center relative ${
                        selectedPlan === 'yearly' 
                        ? 'bg-zinc-900 border-white shadow-lg z-10 scale-[1.02]' 
                        : 'bg-transparent border-zinc-800 hover:border-zinc-700'
                    }`}
                >
                   {/* Badge */}
                   <div className="absolute -top-2.5 left-1/2 -translate-x-1/2 bg-white text-black text-[9px] font-extrabold px-2.5 py-0.5 rounded-full tracking-wider shadow-md whitespace-nowrap z-20">
                        3 DAYS FREE
                    </div>

                    <span className="text-sm font-bold uppercase tracking-wide mb-1 text-white">Yearly</span>
                    <span className="text-lg font-bold text-white">3,91 US$/mo</span>
                </button>
            </div>

            {/* Label behind button */}
            <div className="flex items-center justify-center gap-2 mb-4">
                <ShieldCheck size={16} className="text-zinc-400" />
                <span className="text-sm font-semibold text-zinc-300">
                    {selectedPlan === 'yearly' ? 'No Payment Due Now' : 'Cancel Anytime'}
                </span>
            </div>

            {/* Main Button */}
            <Button fullWidth onClick={() => goToStep(ScreenStep.NOTIFICATIONS)} className="h-14 text-lg font-bold shadow-xl">
                {selectedPlan === 'yearly' ? 'Start My 3-Day Free Trial' : 'Unlock Full Access'}
            </Button>
            
            {/* Small text under button */}
            <div className="text-center mt-3">
                <p className="text-xs text-zinc-500 font-medium">
                    {selectedPlan === 'yearly' 
                        ? '3 days free, then 46,99 US$ per year (3,91US$/mo)' 
                        : 'Just 11,99 US$ per month'}
                </p>
            </div>
        </div>
      </StepLayout>
    );
  }

  // Screen 21: Discount Offer (Optional)
  if (currentStep === ScreenStep.DISCOUNT_OFFER) {
    return (
      <StepLayout centerContent showProgressBar={false}>
         <div className="w-full max-w-sm bg-zinc-900 rounded-2xl p-6 border border-zinc-800 shadow-2xl">
              <div className="flex justify-between items-start mb-4">
                  <h2 className="text-xl font-bold text-white">Want 20% off your first year?</h2>
                  <button onClick={() => goToStep(ScreenStep.PAYWALL)}><X className="text-zinc-500" /></button>
              </div>
              <p className="text-zinc-400 mb-6 text-left">Optional offer — no pressure.</p>
              <div className="space-y-3">
                  <Button fullWidth onClick={() => goToStep(ScreenStep.NOTIFICATIONS)}>Claim Discount</Button>
                  <Button fullWidth variant="secondary" onClick={() => goToStep(ScreenStep.PAYWALL)}>Skip</Button>
              </div>
          </div>
      </StepLayout>
    );
  }

  return null;
};