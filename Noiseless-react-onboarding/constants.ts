import { Variants } from 'framer-motion';

export const APP_NAME = "Aura";

export const FADE_IN_VARIANTS: Variants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { duration: 0.5, ease: "easeOut" } },
  exit: { opacity: 0, transition: { duration: 0.3 } }
};

export const STAGGER_CHILDREN: Variants = {
  hidden: { opacity: 1 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.05
    }
  },
  exit: {
    opacity: 0
  }
};

export const ITEM_VARIANTS: Variants = {
  hidden: { opacity: 0 },
  visible: { 
    opacity: 1, 
    transition: { 
      duration: 0.4,
      ease: "easeOut"
    } 
  }
};

export const GLOW_ANIMATION: Variants = {
  initial: { opacity: 0.5, scale: 0.95 },
  animate: { 
    opacity: [0.5, 0.8, 0.5], 
    scale: [0.95, 1.05, 0.95], 
    transition: { duration: 3, repeat: Infinity, ease: "easeInOut" }
  }
};