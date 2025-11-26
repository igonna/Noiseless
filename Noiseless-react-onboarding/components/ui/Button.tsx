import React from 'react';
import { motion, HTMLMotionProps } from 'framer-motion';

interface ButtonProps extends Omit<HTMLMotionProps<"button">, "children"> {
  variant?: 'primary' | 'secondary' | 'ghost';
  fullWidth?: boolean;
  icon?: React.ReactNode;
  children?: React.ReactNode;
}

export const Button: React.FC<ButtonProps> = ({ 
  children, 
  variant = 'primary', 
  fullWidth = false, 
  className = '',
  icon,
  ...props 
}) => {
  const baseStyles = "py-3.5 px-6 rounded-full font-bold transition-all duration-200 flex items-center justify-center gap-2 active:scale-95 disabled:opacity-50 disabled:pointer-events-none text-sm md:text-base";
  
  const variants = {
    primary: "bg-white text-black hover:bg-zinc-200 shadow-[0_0_15px_rgba(255,255,255,0.15)]",
    secondary: "bg-zinc-800 text-white border border-zinc-700 hover:bg-zinc-700",
    ghost: "bg-transparent text-zinc-400 hover:text-white hover:bg-white/5"
  };

  return (
    <motion.button
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className={`${baseStyles} ${variants[variant]} ${fullWidth ? 'w-full' : ''} ${className}`}
      {...props}
    >
      {children}
      {icon}
    </motion.button>
  );
};