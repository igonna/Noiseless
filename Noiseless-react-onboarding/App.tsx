import React from 'react';
import { OnboardingProvider, useOnboarding } from './context/OnboardingContext';
import { TrustPhase } from './components/screens/PhaseTrust';
import { DataPhase } from './components/screens/PhaseData';
import { RewardPhase } from './components/screens/PhaseReward';
import { RitualPhase } from './components/screens/PhaseRitual';
import { ValuePhase } from './components/screens/PhaseValue';
import { PaywallPhase } from './components/screens/PhasePaywall';
import { FinalPhase } from './components/screens/PhaseFinal';
import { ScreenStep } from './types';

function App() {
  return (
    <OnboardingProvider>
      <MainFlow />
    </OnboardingProvider>
  );
}

const MainFlow: React.FC = () => {
  const { currentStep } = useOnboarding();

  return (
    <div className="bg-black min-h-screen text-zinc-100 font-sans selection:bg-white/20">
      {/* Part 1: Opening (Screens 1-3) */}
      {currentStep >= ScreenStep.WELCOME && currentStep <= ScreenStep.IDENTITY_DETAILS && <TrustPhase />}
      
      {/* Part 2, 3 & 4: Location, Skills, Graph, Future Self (Screens 4-11) */}
      {currentStep >= ScreenStep.LOCATION && currentStep <= ScreenStep.TIME_BUDGET && <DataPhase />}
      
      {/* Part 5: Trust + Social Proof (Screens 12-14) */}
      {currentStep >= ScreenStep.SOCIAL_PROOF && currentStep <= ScreenStep.ENCOURAGEMENT && <RewardPhase />}
      
      {/* Part 6: Ritual (Screens 15-17) */}
      {currentStep >= ScreenStep.BUILDING_MODEL && currentStep <= ScreenStep.PATH_READY && <RitualPhase />}
      
      {/* Part 7: Value Preview (Screens 18-19) */}
      {currentStep >= ScreenStep.INSIGHTS_PREVIEW && currentStep <= ScreenStep.TRIAL_OFFER && <ValuePhase />}
      
      {/* Part 8: Hard Paywall + Trial (Screens 20-22) */}
      {currentStep >= ScreenStep.PAYWALL && currentStep <= ScreenStep.SUBSCRIPTION_CONFIRM && <PaywallPhase />}
      
      {/* Part 9: Final Screens (Screens 23-28) + Dashboard */}
      {currentStep >= ScreenStep.NOTIFICATIONS && <FinalPhase />}
    </div>
  );
};

export default App;