import React from "react";
import { Logo } from "./Logo";

export const Poster = ({ title, slogan, info, qrUrl }: { title: string; slogan?: string; info?: string; qrUrl?: string; }) => (
  <div className="w-full max-w-lg bg-[#F5F7FA] rounded-xl shadow-xl p-8 flex flex-col items-center gap-4 border border-[#B9E4D4]">
    <Logo variant="capsule" />
    <h2 className="text-2xl font-bold text-[#358373] mt-2">{title}</h2>
    {slogan && <div className="text-[#1E293B] text-lg mb-2">{slogan}</div>}
    {info && <div className="text-[#358373] text-base mb-4 text-center">{info}</div>}
    {qrUrl && <img src={qrUrl} alt="二维码" className="w-24 h-24 rounded bg-muted" />}
  </div>
);