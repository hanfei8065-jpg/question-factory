import React from "react";

type SearchBoxProps = {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  className?: string;
};

export const SearchBox = ({ value, onChange, placeholder = "Search", className }: SearchBoxProps) => (
  <div className={`flex items-center bg-white rounded-xl px-4 py-2 shadow-sm gap-2 ${className ?? ""}`}
       style={{ background: "#F5F7FA" }}>
    <svg width="20" height="20" fill="none" viewBox="0 0 20 20">
      <circle cx="9" cy="9" r="7" stroke="#358373" strokeWidth="2" />
      <path d="M15 15L13 13" stroke="#358373" strokeWidth="2" strokeLinecap="round" />
    </svg>
    <input
      className="bg-transparent outline-none text-[#1E293B] flex-1"
      value={value}
      onChange={e => onChange(e.target.value)}
      placeholder={placeholder}
      type="text"
    />
  </div>
);
