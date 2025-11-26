import React from "react";
import { Logo } from "./Logo";

export const NavBar = () => (
  <nav className="w-full bg-white shadow-sm px-8 py-3 flex items-center justify-between" style={{ background: "#F5F7FA" }}>
    <Logo variant="default" />
    <div className="flex gap-6 items-center">
      <a href="#courses" className="text-[#1E293B] font-semibold hover:text-[#358373] transition">Courses</a>
      <a href="#about" className="text-[#1E293B] font-semibold hover:text-[#358373] transition">About</a>
      <a href="#contact" className="text-[#1E293B] font-semibold hover:text-[#358373] transition">Contact</a>
      <button className="bg-[#358373] text-white rounded-full px-5 py-2 font-bold shadow hover:bg-[#5FCEB3] transition">Sign Up</button>
    </div>
  </nav>
);
