import React from "react";

type ProgressBarProps = {
  value: number; // 0-100
  className?: string;
};

export const ProgressBar = ({ value, className }: ProgressBarProps) => (
  <div className={`w-full h-2 bg-[#B9E4D4] rounded-pill overflow-hidden ${className ?? ""}`}>
    <div
      className="h-2 rounded-pill transition-all duration-300"
      style={{ width: `${value}%`, background: "#358373" }}
    />
  </div>
);
