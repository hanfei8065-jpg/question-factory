import React from "react";

export const Banner = ({ title, subtitle, ctaText, onCta }: { title: string; subtitle?: string; ctaText?: string; onCta?: () => void; }) => (
  <div className="w-full bg-[#358373] rounded-xl flex flex-col items-center justify-center py-8 px-4 text-center shadow-lg">
    <h2 className="text-3xl font-bold text-white mb-2" style={{ fontFamily: "Montserrat, Inter, Arial, sans-serif" }}>{title}</h2>
    {subtitle && <p className="text-lg text-white/80 mb-4">{subtitle}</p>}
    {ctaText && <button className="bg-white text-[#358373] font-bold rounded-full px-6 py-2 shadow mt-2" onClick={onCta}>{ctaText}</button>}
  </div>
);