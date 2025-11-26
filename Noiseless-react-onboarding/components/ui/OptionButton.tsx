import React from 'react';
import { motion, Variants, HTMLMotionProps } from 'framer-motion';

interface OptionButtonProps extends HTMLMotionProps<"button"> {
  selected?: boolean;
  label: string;
  icon?: React.ReactNode;
  isAdd?: boolean;
  variants?: Variants;
}

export const OptionButton: React.FC<OptionButtonProps> = ({ 
  selected = false, 
  label, 
  icon, 
  className = '',
  isAdd = false,
  variants,
  ...props 
}) => {
  const baseStyles = "px-5 py-3 rounded-full border font-medium transition-all flex items-center justify-center gap-2 text-sm md:text-base";
  
  const standardStyles = selected 
    ? 'bg-white text-black border-white shadow-[0_0_15px_rgba(255,255,255,0.2)]' 
    : 'bg-zinc-900 text-zinc-400 border-zinc-800 hover:border-zinc-600 hover:text-white hover:bg-zinc-800/50';

  const addStyles = "bg-transparent text-zinc-500 border-zinc-800 hover:border-zinc-600 hover:text-zinc-300";

  return (
    <motion.button
      variants={variants}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className={`${baseStyles} ${isAdd ? addStyles : standardStyles} ${className}`}
      {...props}
    >
      {icon && <span className={selected ? 'text-black' : (isAdd ? 'text-zinc-500 group-hover:text-zinc-300' : 'text-zinc-400 group-hover:text-white')}>{icon}</span>}
      <span>{label}</span>
    </motion.button>
  );
};