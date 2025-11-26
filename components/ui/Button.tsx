import React from "react";

type ButtonProps = {
  children: React.ReactNode;
  variant?: "primary" | "secondary" | "muted";
  className?: string;
  onClick?: () => void;
  disabled?: boolean;
};

export const Button = ({ children, variant = "primary", className, onClick, disabled }: ButtonProps) => {
  const base = "px-5 py-2 font-bold shadow transition focus:outline-none";
  const variants = {
    primary: "bg-[#358373] text-white rounded-full hover:bg-[#5FCEB3]",
    secondary: "bg-[#5FCEB3] text-[#1E293B] rounded-full hover:bg-[#358373]",
    muted: "bg-[#B9E4D4] text-[#1E293B] rounded-full hover:bg-[#5FCEB3]",
  };
  return (
    <button
      className={`${base} ${variants[variant]} ${className ?? ""}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};
