import React from "react";
import { Logo } from "./Logo";

export const PPTTemplate = ({ title, children }: { title: string; children?: React.ReactNode }) => (
  <div className="w-full max-w-3xl bg-[#F5F7FA] rounded-2xl shadow-2xl p-10 flex flex-col items-center gap-6 border border-[#B9E4D4]">
    <Logo variant="default" />
    <h1 className="text-3xl font-bold text-[#358373] mb-2">{title}</h1>
    <div className="w-full text-[#1E293B] text-lg">{children}</div>
  </div>
);