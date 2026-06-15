import React, { InputHTMLAttributes } from "react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  icon?: React.ReactNode;
  rightElement?: React.ReactNode;
}

export function Input({ label, icon, rightElement, className = "", id, ...props }: InputProps) {
  const inputId = id || label.toLowerCase().replace(/\s+/g, "-");

  return (
    <div className="w-full">
      <label htmlFor={inputId} className="block text-sm font-medium text-brand-text-muted mb-2">
        {label}
      </label>
      <div className="relative">
        {icon && (
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-brand-text-muted">
            {icon}
          </div>
        )}
        <input
          id={inputId}
          className={`w-full bg-brand-input border border-brand-border text-brand-text text-sm rounded-lg focus:ring-brand-neon-blue focus:border-brand-neon-blue block p-3 transition-colors ${
            icon ? "pl-10" : ""
          } ${rightElement ? "pr-10" : ""} ${className}`}
          {...props}
        />
        {rightElement && (
          <div className="absolute inset-y-0 right-0 pr-3 flex items-center text-brand-text-muted">
            {rightElement}
          </div>
        )}
      </div>
    </div>
  );
}
