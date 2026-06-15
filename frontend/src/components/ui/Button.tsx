import React from "react";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "outline" | "google";
  fullWidth?: boolean;
}

export function Button({ 
  children, 
  variant = "primary", 
  fullWidth = false,
  className = "",
  ...props 
}: ButtonProps) {
  const baseStyles = "inline-flex items-center justify-center gap-2 px-4 py-3 text-sm font-medium transition-all rounded-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-brand-bg disabled:opacity-50 disabled:cursor-not-allowed";
  
  const variants = {
    primary: "bg-brand-neon-pink text-white hover:bg-brand-neon-pink-hover shadow-[0_0_15px_rgba(255,42,84,0.3)] hover:shadow-[0_0_20px_rgba(255,42,84,0.5)] focus:ring-brand-neon-pink",
    outline: "bg-transparent border border-brand-border text-brand-text hover:bg-brand-card focus:ring-brand-border",
    google: "bg-brand-input border border-brand-border text-brand-text hover:bg-brand-card focus:ring-brand-border transition-colors",
  };

  const widthStyle = fullWidth ? "w-full" : "";

  return (
    <button 
      className={`${baseStyles} ${variants[variant]} ${widthStyle} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
