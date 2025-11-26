import React from "react";

type CourseCardProps = {
  title: string;
  modules: number;
  progress: number; // 0-100
  className?: string;
};

export const CourseCard = ({ title, modules, progress, className }: CourseCardProps) => (
  <div className={`bg-white rounded-xl shadow-sm p-4 flex flex-col gap-2 ${className ?? ""}`}
       style={{ background: "#F5F7FA" }}>
    <div className="flex items-center gap-2">
      <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <circle cx="10" cy="10" r="9" stroke="#358373" strokeWidth="2" />
          <path d="M7 10h6" stroke="#358373" strokeWidth="2" strokeLinecap="round" />
        </svg>
      </div>
      <span className="font-bold text-[#1E293B] text-base">{title}</span>
    </div>
    <div className="text-xs text-[#358373]">Modules: {modules}</div>
    <div className="w-full h-2 bg-muted rounded-pill overflow-hidden">
      <div
        className="h-2 rounded-pill"
        style={{ width: `${progress}%`, background: "#358373" }}
      />
    </div>
    <div className="text-right text-xs text-[#1E293B] font-semibold">{progress}%</div>
  </div>
);
