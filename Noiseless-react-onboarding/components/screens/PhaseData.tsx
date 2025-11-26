import React, { useState } from 'react';
import { useOnboarding } from '../../context/OnboardingContext';
import { StepLayout } from '../ui/StepLayout';
import { Button } from '../ui/Button';
import { OptionButton } from '../ui/OptionButton';
import { ScreenStep } from '../../types';
import { MapPin, Plus, ArrowLeft, DollarSign, Zap, Wind, Rocket, Target, Heart, Layers, Lightbulb, Compass, ShieldCheck } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { ITEM_VARIANTS } from '../../constants';

// --- Reusable Selection Screen Component ---
interface SelectionScreenProps {
  title: string;
  subtitle?: string;
  options: string[];
  selected: string[];
  onSelect: (newSelection: string[]) => void;
  onNext: () => void;
  placeholder?: string;
  multiSelect?: boolean;
  maxSelection?: number;
}

const SelectionScreen: React.FC<SelectionScreenProps> = ({
  title,
  subtitle,
  options,
  selected,
  onSelect,
  onNext,
  placeholder = "Add your own...",
  multiSelect = true,
  maxSelection
}) => {
  const [isAdding, setIsAdding] = useState(false);
  const [customInput, setCustomInput] = useState("");

  const handleToggle = (option: string) => {
    if (selected.includes(option)) {
      onSelect(selected.filter(s => s !== option));
    } else {
      if (maxSelection && selected.length >= maxSelection) return;
      if (!multiSelect) {
        onSelect([option]);
      } else {
        onSelect([...selected, option]);
      }
    }
  };

  const handleAddCustom = () => {
    if (!customInput.trim()) return;
    const val = customInput.trim();
    
    // Add to selection
    if (!selected.includes(val)) {
         if (maxSelection && selected.length >= maxSelection && multiSelect) {
             // If full, ignore.
         } else {
             const newSelection = multiSelect ? [...selected, val] : [val];
             onSelect(newSelection);
         }
    }
    setCustomInput("");
    setIsAdding(false);
  };

  // Merge default options with any selected options that aren't in the default list
  const displayOptions = [...options];
  selected.forEach(s => {
      if (!displayOptions.includes(s)) {
          displayOptions.push(s);
      }
  });

  return (
    <StepLayout title={title} subtitle={subtitle}>
      <div className="flex-1 flex flex-col mt-4 relative min-h-0">
        <AnimatePresence mode="wait">
          {!isAdding ? (
            <div className="flex-1 overflow-y-auto -mx-4 px-4 py-2 custom-scrollbar">
                <div className="flex flex-wrap gap-3 pb-4">
                {displayOptions.map(opt => (
                    <OptionButton
                    key={opt}
                    label={opt}
                    selected={selected.includes(opt)}
                    onClick={() => handleToggle(opt)}
                    className={maxSelection && selected.length >= maxSelection && !selected.includes(opt) ? 'opacity-50' : ''}
                    />
                ))}
                <OptionButton
                    label="Add"
                    icon={<Plus size={16} />}
                    isAdd
                    onClick={() => {
                        setIsAdding(true);
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
                className="w-full"
            >
                 <div className="flex items-center gap-2 mb-4">
                    <button 
                        onClick={() => setIsAdding(false)}
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
                    onKeyDown={(e) => e.key === 'Enter' && handleAddCustom()}
                />
                <Button fullWidth onClick={handleAddCustom} disabled={!customInput.trim()}>
                    Add Option
                </Button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
      
      {!isAdding && (
        <div className="mt-auto pt-6 border-t border-zinc-900 shrink-0">
          <Button fullWidth onClick={onNext} disabled={selected.length === 0}>Continue</Button>
        </div>
      )}
    </StepLayout>
  );
};

const TimeBudgetScreen: React.FC = () => {
    const { nextStep, userData, updateUserData } = useOnboarding();
    const options = [
          { label: "Gentle", desc: "Easy, flexible steps." },
          { label: "Steady", desc: "Solid weekly movement." },
          { label: "Focused", desc: "Consistent forward momentum." },
          { label: "Fast", desc: "Accelerated pacing." },
          { label: "Smart Adapt", desc: "Evolves with you." }
    ];

    const getInitialIndex = () => {
        if (!userData.timeBudget) return 2;
        const currentLabel = userData.timeBudget.split(" — ")[0];
        const idx = options.findIndex(o => o.label === currentLabel);
        return idx !== -1 ? idx : 2;
    }

    const [selectedIndex, setSelectedIndex] = useState(getInitialIndex);

    const handleSliderChange = (val: number) => {
        setSelectedIndex(val);
        const opt = options[val];
        updateUserData({ timeBudget: `${opt.label} — ${opt.desc}` });
    };

    const currentOption = options[selectedIndex];
    // Calculate percentage for the slider fill background
    const progressPercent = (selectedIndex / (options.length - 1)) * 100;

    return (
        <StepLayout title="What kind of pace feels right for you?">
             <div className="flex-1 flex flex-col items-center justify-center w-full">
                {/* Dynamic Text Display */}
                <div className="text-center mb-16 min-h-[120px] flex flex-col justify-center max-w-xs mx-auto">
                    <AnimatePresence mode="wait">
                        <motion.div
                            key={currentOption.label}
                            initial={{ opacity: 0, y: 10, scale: 0.95 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            exit={{ opacity: 0, y: -10, scale: 0.95 }}
                            transition={{ duration: 0.2 }}
                        >
                            <h2 className="text-4xl md:text-5xl font-bold text-white mb-4 leading-tight">{currentOption.label}</h2>
                            <p className="text-lg text-zinc-400 font-medium">“{currentOption.desc}”</p>
                        </motion.div>
                    </AnimatePresence>
                </div>

                {/* Slider Control */}
                <div className="w-full px-4 max-w-sm mx-auto">
                    <input 
                        type="range" 
                        min="0" 
                        max={options.length - 1} 
                        step="1"
                        value={selectedIndex}
                        onChange={(e) => handleSliderChange(parseInt(e.target.value))}
                        style={{
                            background: `linear-gradient(to right, white ${progressPercent}%, #27272a ${progressPercent}%)`
                        }}
                        className="w-full h-2 rounded-full appearance-none cursor-pointer outline-none transition-all
                                   [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-6 [&::-webkit-slider-thumb]:h-6 
                                   [&::-webkit-slider-thumb]:bg-white [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:shadow-[0_0_10px_rgba(255,255,255,0.5)] 
                                   [&::-webkit-slider-thumb]:hover:scale-110 [&::-webkit-slider-thumb]:transition-transform"
                    />
                    <div className="flex justify-between mt-6 text-[10px] font-bold text-zinc-600 uppercase tracking-[0.2em]">
                        <span>Gentle</span>
                        <span>Smart</span>
                    </div>
                </div>
            </div>

            <div className="mt-auto pt-6 border-t border-zinc-900">
                <Button fullWidth onClick={nextStep}>Continue</Button>
            </div>
        </StepLayout>
    );
};


export const DataPhase: React.FC = () => {
  const { currentStep, nextStep, userData, updateUserData } = useOnboarding();
  const [isEditingLocation, setIsEditingLocation] = useState(false);
  const [locationQuery, setLocationQuery] = useState(userData.location || "Los Angeles, US");

  // Screen 4: Location
  if (currentStep === ScreenStep.LOCATION) {
    return (
      <StepLayout 
        title="Where are you based?"
      >
        {!isEditingLocation ? (
             <div className="mt-8 p-6 bg-zinc-900 rounded-xl border border-zinc-800 flex items-center justify-between gap-4">
                <div className="flex items-center gap-4">
                    <div className="bg-zinc-800 p-3 rounded-full">
                        <MapPin className="text-white" size={24} />
                    </div>
                    <div>
                        <p className="text-sm text-zinc-500">Detected Location</p>
                        <p className="text-xl font-semibold text-white">{locationQuery}</p>
                    </div>
                </div>
                <button 
                    onClick={() => setIsEditingLocation(true)}
                    className="text-sm text-zinc-400 font-medium hover:text-white px-3 py-1.5 rounded-lg hover:bg-zinc-800 transition-colors"
                >
                    Change
                </button>
            </div>
        ) : (
             <div className="mt-8 relative">
                 <input 
                    type="text" 
                    value={locationQuery}
                    onChange={(e) => setLocationQuery(e.target.value)}
                    className="w-full bg-transparent border-b border-zinc-700 text-2xl py-2 focus:outline-none focus:border-white transition-colors text-white placeholder-zinc-600"
                    autoFocus
                    placeholder="Enter city..."
                    onKeyDown={(e) => {
                        if(e.key === 'Enter' && locationQuery.trim()) {
                            updateUserData({ location: locationQuery });
                            nextStep();
                        }
                    }}
                 />
                 <button 
                    onClick={() => setIsEditingLocation(false)}
                    className="absolute right-0 top-2 text-sm text-zinc-500 hover:text-white"
                 >
                    Cancel
                 </button>
             </div>
        )}

        <div className="mt-auto space-y-3">
          <div className="flex items-center justify-center gap-2 mb-2 opacity-50">
             <ShieldCheck size={12} className="text-zinc-500" />
             <p className="text-[10px] text-zinc-500 font-medium tracking-wide">Your information remains private and secure.</p>
          </div>
          <Button 
            fullWidth 
            onClick={() => { 
                updateUserData({ location: locationQuery }); 
                nextStep(); 
            }}
            disabled={!locationQuery.trim()}
          >
            Confirm
          </Button>
        </div>
      </StepLayout>
    );
  }

  // Screen 5: Skills
  if (currentStep === ScreenStep.SKILLS) {
    const skills = [
        "Strategic Thinking", "Programming", "Design", "Writing", 
        "Sales", "Data Analysis", "Leadership", "Public Speaking", 
        "Marketing", "Project Management"
    ];
    
    return (
      <SelectionScreen
        title="Your main skills or strengths?"
        options={skills}
        selected={userData.skills}
        onSelect={(newSkills) => updateUserData({ skills: newSkills })}
        onNext={nextStep}
        placeholder="e.g. negotiation, coding..."
      />
    );
  }

  // Screen 6: Traits
  if (currentStep === ScreenStep.TRAITS) {
    const traits = ["Creative", "Analytical", "Ambitious", "Curious", "Introverted", "Organized", "Independent", "Driven", "Calm", "Fast-learner"];
    
    return (
      <SelectionScreen
        title="Which of these describe you?"
        options={traits}
        selected={userData.traits}
        onSelect={(newTraits) => updateUserData({ traits: newTraits })}
        onNext={nextStep}
        placeholder="e.g. energetic..."
      />
    );
  }

  // Screen 7: Improvement Graph
  if (currentStep === ScreenStep.GRAPH) {
    return (
      <StepLayout title="People who stay informed grow faster." subtitle="The right insights at the right time create long-term momentum.">
        <div className="flex-1 flex items-center justify-center relative my-4">
          <div className="w-full h-64 bg-zinc-900/30 rounded-xl border border-zinc-800 relative overflow-hidden p-4">
              {/* Graph Grid */}
              <div className="absolute inset-0 grid grid-cols-6 grid-rows-6">
                  {[...Array(7)].map((_, i) => (
                      <div key={i} className="border-b border-zinc-800/50 w-full h-full" />
                  ))}
              </div>

              {/* Lines */}
              <svg className="absolute inset-0 w-full h-full overflow-visible" preserveAspectRatio="none">
                  <motion.path 
                    initial={{ pathLength: 0 }} 
                    animate={{ pathLength: 1 }} 
                    transition={{ duration: 1.5, ease: "easeOut" }}
                    d="M 0 200 L 400 140" 
                    fill="none" 
                    stroke="#52525b" 
                    strokeWidth="2" 
                    strokeDasharray="5 5"
                  />
                  <motion.path 
                     initial={{ pathLength: 0 }} 
                     animate={{ pathLength: 1 }} 
                     transition={{ duration: 1.5, ease: "easeOut", delay: 0.5 }}
                     d="M 0 200 C 100 180, 200 150, 400 20" 
                     fill="none" 
                     stroke="#3b82f6" 
                     strokeWidth="3" 
                  />
              </svg>

               {/* Glowing Node */}
              <motion.div 
                  initial={{ opacity: 0, scale: 0 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: 1.8 }}
                  className="absolute top-[20px] right-[0px] w-4 h-4 bg-blue-500 rounded-full shadow-[0_0_15px_#3b82f6] transform translate-x-1/2"
              />

              <div className="absolute bottom-12 right-4 text-xs text-zinc-500 bg-zinc-950/80 px-2 py-1 rounded border border-zinc-800">Without Guidance</div>
              <div className="absolute top-8 right-4 text-xs text-blue-400 bg-zinc-950/80 px-2 py-1 rounded border border-blue-500/30 font-medium">With Personalized Insights</div>
          </div>
        </div>
        <div className="mt-auto">
          <Button fullWidth onClick={nextStep}>Continue</Button>
        </div>
      </StepLayout>
    );
  }

  // Screen 8: Vision
  if (currentStep === ScreenStep.VISION) {
      const visionOptions = [
          { label: "More income", icon: <DollarSign size={20} /> },
          { label: "Learn powerful skills", icon: <Zap size={20} /> },
          { label: "More freedom", icon: <Wind size={20} /> },
          { label: "Start a business", icon: <Rocket size={20} /> },
          { label: "More discipline", icon: <Target size={20} /> },
          { label: "Better well-being", icon: <Heart size={20} /> },
          { label: "Multiple income streams", icon: <Layers size={20} /> },
          { label: "Find clarity", icon: <Lightbulb size={20} /> },
          { label: "New career path", icon: <Compass size={20} /> }
      ];

      const toggleVision = (label: string) => {
          const current = userData.vision;
          if (current.includes(label)) {
              updateUserData({ vision: current.filter(v => v !== label) });
          } else {
              if (current.length < 3) {
                  updateUserData({ vision: [...current, label] });
              }
          }
      };

      return (
        <StepLayout 
            title="What do you want to achieve?" 
            subtitle="Select up to 3"
        >
            <div className="flex-1 overflow-y-auto -mx-4 px-4 py-2 mt-2 space-y-3 custom-scrollbar">
                {visionOptions.map((item) => {
                    const isSelected = userData.vision.includes(item.label);
                    // Disable if not selected and we have 3 selected
                    const isMaxReached = !isSelected && userData.vision.length >= 3;

                    return (
                        <motion.button
                            key={item.label}
                            onClick={() => toggleVision(item.label)}
                            disabled={isMaxReached}
                            whileHover={{ scale: 1.01 }}
                            whileTap={{ scale: 0.99 }}
                            className={`w-full p-4 rounded-xl border transition-all flex items-center gap-4 text-left ${
                                isSelected 
                                ? 'border-zinc-500 bg-zinc-800 shadow-[0_0_15px_rgba(255,255,255,0.05)]' 
                                : isMaxReached 
                                    ? 'border-zinc-800/30 bg-zinc-900/20 opacity-50 cursor-not-allowed'
                                    : 'border-zinc-800/50 bg-zinc-900/50 hover:bg-zinc-900 hover:border-zinc-700'
                            }`}
                        >
                            <div className={`p-2 rounded-lg transition-colors ${isSelected ? 'bg-white text-black' : 'bg-zinc-800 text-zinc-200'}`}>
                                {item.icon}
                            </div>
                            <span className={`text-lg font-medium transition-colors ${isSelected ? 'text-white' : 'text-zinc-200'}`}>
                                {item.label}
                            </span>
                        </motion.button>
                    );
                })}
            </div>
            <div className="mt-4 pt-4 border-t border-zinc-900 shrink-0">
                <Button fullWidth onClick={nextStep} disabled={userData.vision.length === 0}>
                    Continue
                </Button>
            </div>
        </StepLayout>
      );
  }

  // Screen 9: Values
  if (currentStep === ScreenStep.VALUES) {
      const values = ["Freedom", "Mastery", "Money", "Growth", "Health", "Stability", "Creativity", "Impact", "Recognition", "Relationships"];
      return (
        <SelectionScreen
            title="What matters most to you?"
            subtitle="Pick up to 3"
            options={values}
            selected={userData.values}
            onSelect={(v) => updateUserData({ values: v })}
            onNext={nextStep}
            maxSelection={3}
            placeholder="e.g. Adventure..."
        />
      );
  }

  // Screen 10: Constraints
  if (currentStep === ScreenStep.CONSTRAINTS) {
      const constraints = ["Time", "Money", "Confidence", "Focus", "Burnout", "No clear direction", "Responsibilities", "Health issues", "No major hurdles"];
      return (
        <SelectionScreen
            title="What’s holding you back right now?"
            options={constraints}
            selected={userData.constraints}
            onSelect={(c) => updateUserData({ constraints: c })}
            onNext={nextStep}
            placeholder="e.g. Procrastination..."
        />
      );
  }

  // Screen 11: Time Budget (Refactored to use Slider)
  if (currentStep === ScreenStep.TIME_BUDGET) {
      return <TimeBudgetScreen />;
  }

  return null;
};