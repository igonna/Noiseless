export enum ScreenStep {
  // Part 1: Friendly Opening
  WELCOME = 1,
  IDENTITY = 2,
  IDENTITY_DETAILS = 3,

  // Part 2: Location & Skills
  LOCATION = 4,
  SKILLS = 5,
  TRAITS = 6,
  
  // Part 3: Motivation Boost
  GRAPH = 7, // New

  // Part 4: Future Self
  VISION = 8,
  VALUES = 9,
  CONSTRAINTS = 10,
  TIME_BUDGET = 11,

  // Part 5: Trust + Social Proof
  SOCIAL_PROOF = 12,
  PRIVACY = 13,
  ENCOURAGEMENT = 14,

  // Part 6: Personalization Ritual
  BUILDING_MODEL = 15,
  CALIBRATING = 16,
  PATH_READY = 17,

  // Part 7: Value Preview
  INSIGHTS_PREVIEW = 18,
  TRIAL_OFFER = 19, // New Screen, Merged with Reminder
  
  // Part 8: Hard Paywall + Trial
  PAYWALL = 20,
  DISCOUNT_OFFER = 21,
  SUBSCRIPTION_CONFIRM = 22,

  // Part 9: Final Screens
  NOTIFICATIONS = 23,
  INTEGRATIONS = 24,
  FINAL_WELCOME = 25,
  FIRST_SUGGESTION = 26,
  HABIT_LOOP = 27,

  // Post-onboarding
  DASHBOARD = 28
}

export interface UserData {
  identity: string;
  identityDetail: string;
  location: string;
  skills: string[];
  traits: string[];
  source: string[]; // Kept for legacy/future use if needed, though screen removed
  vision: string[];
  visionDetail: string; // New
  values: string[];
  constraints: string[];
  constraintsDetail: string; // New
  timeBudget: string;
}

export interface OnboardingContextType {
  currentStep: ScreenStep;
  userData: UserData;
  nextStep: () => void;
  prevStep: () => void;
  goToStep: (step: ScreenStep) => void;
  updateUserData: (data: Partial<UserData>) => void;
}