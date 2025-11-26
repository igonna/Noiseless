import React, { createContext, useContext, useState, ReactNode } from 'react';
import { ScreenStep, UserData, OnboardingContextType } from '../types';

const defaultUserData: UserData = {
  identity: '',
  identityDetail: '',
  location: '',
  skills: [],
  traits: [],
  source: [],
  vision: [],
  visionDetail: '',
  values: [],
  constraints: [],
  constraintsDetail: '',
  timeBudget: '3-6h' // Default middle option
};

const OnboardingContext = createContext<OnboardingContextType | undefined>(undefined);

export const OnboardingProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [currentStep, setCurrentStep] = useState<ScreenStep>(ScreenStep.WELCOME);
  const [userData, setUserData] = useState<UserData>(defaultUserData);

  const nextStep = () => {
    setCurrentStep((prev) => prev + 1);
  };

  const prevStep = () => {
    if (currentStep > 1) setCurrentStep((prev) => prev - 1);
  };

  const goToStep = (step: ScreenStep) => {
    setCurrentStep(step);
  };

  const updateUserData = (data: Partial<UserData>) => {
    setUserData((prev) => ({ ...prev, ...data }));
  };

  return (
    <OnboardingContext.Provider value={{ currentStep, userData, nextStep, prevStep, goToStep, updateUserData }}>
      {children}
    </OnboardingContext.Provider>
  );
};

export const useOnboarding = () => {
  const context = useContext(OnboardingContext);
  if (!context) throw new Error("useOnboarding must be used within OnboardingProvider");
  return context;
};