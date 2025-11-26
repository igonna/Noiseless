import React from 'react';
import { useOnboarding } from '../../context/OnboardingContext';
import { StepLayout } from '../ui/StepLayout';
import { Button } from '../ui/Button';
import { ScreenStep } from '../../types';
import { motion } from 'framer-motion';
import { Star, ShieldCheck, Check, Sparkles } from 'lucide-react';

export const RewardPhase: React.FC = () => {
  const { currentStep, nextStep, goToStep } = useOnboarding();

  // Screen 12: Social Proof
  if (currentStep === ScreenStep.SOCIAL_PROOF) {
    const reviews = [
        { 
            name: "Alex Richardson", 
            text: "I finally got clarity on what I should actually focus on. No fluff — just straight direction I wish I had years ago.",
            initial: "A",
            color: "bg-blue-600"
        },
        { 
            name: "Jena Porter", 
            text: "This thing keeps surfacing opportunities I would’ve completely missed on my own. Honestly wasn’t expecting it to be this accurate :)",
            initial: "J",
            color: "bg-emerald-600"
        },
        { 
            name: "Marcus Delaney", 
            text: "I thought this would be another ‘motivation’ app. Nope. It actually shows me what to do next, which is all I needed.",
            initial: "M",
            color: "bg-purple-600"
        }
    ];

    return (
      <StepLayout title="Trusted by people improving their lives every day">
        {/* Scrollable Container */}
        <div className="flex-1 overflow-y-auto -mx-6 px-6 py-2 custom-scrollbar min-h-0">
            <div className="space-y-4">
                {reviews.map((review, i) => (
                    <div
                        key={i}
                        className="bg-transparent p-5 rounded-2xl border border-zinc-800"
                    >
                        {/* Header: Avatar + Name + Stars */}
                        <div className="flex items-center mb-3 w-full">
                            {/* Avatar (Smaller) */}
                            <div className={`w-8 h-8 rounded-full ${review.color} flex items-center justify-center text-white text-xs font-bold shadow-lg shrink-0 mr-3`}>
                                {review.initial}
                            </div>
                            
                            {/* Name (Bigger) */}
                            <p className="font-bold text-white text-base leading-tight truncate mr-2">{review.name}</p>
                            
                            {/* Stars (Right Aligned) */}
                            <div className="flex text-yellow-500 gap-0.5 ml-auto shrink-0">
                                <Star size={14} fill="currentColor" />
                                <Star size={14} fill="currentColor" />
                                <Star size={14} fill="currentColor" />
                                <Star size={14} fill="currentColor" />
                                <Star size={14} fill="currentColor" />
                            </div>
                        </div>

                        {/* Review Text (No quotes) */}
                        <p className="text-zinc-300 text-sm leading-relaxed">
                            {review.text}
                        </p>
                    </div>
                ))}
            </div>
        </div>
        
        <div className="mt-auto pt-4 border-t border-zinc-900 shrink-0">
            <Button fullWidth onClick={nextStep}>Continue</Button>
        </div>
      </StepLayout>
    );
  }

  // Screen 13: Privacy & Commitment (Merged)
  if (currentStep === ScreenStep.PRIVACY) {
    return (
      <StepLayout 
        title="Time to generate your custom plan!" 
        centerContent
      >
         <div className="flex-1 flex flex-col justify-center items-center w-full">
            <motion.div
                initial={{ scale: 0.9, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                transition={{ duration: 0.5 }}
                className="relative"
            >
                <div className="w-32 h-32 bg-zinc-900 rounded-full border border-zinc-800 flex items-center justify-center shadow-2xl relative z-10">
                    <Sparkles size={48} className="text-white" strokeWidth={1} />
                </div>
                {/* Subtle glow behind */}
                <div className="absolute inset-0 bg-white/10 blur-2xl rounded-full scale-110 -z-10" />
            </motion.div>
         </div>
         
         <div className="mt-auto pt-8 w-full">
            <div className="flex items-center justify-center gap-2 mb-6 opacity-50">
                <ShieldCheck size={12} className="text-zinc-500" />
                <p className="text-[10px] text-zinc-500 font-medium tracking-wide">Your information remains private and secure.</p>
            </div>
            
            {/* Skip Screen 14 (Encouragement) and go straight to Ritual */}
            <Button fullWidth onClick={() => goToStep(ScreenStep.BUILDING_MODEL)}>Continue</Button>
         </div>
      </StepLayout>
    );
  }

  return null;
};