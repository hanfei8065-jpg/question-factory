import React from "react";

type LogoProps = { variant?: "default" | "capsule"; className?: string };

export const Logo = ({ variant = "default", className }: LogoProps) => {
  const isCapsule = variant === "capsule";
  const containerClass = [
    "flex flex-col items-center justify-center",
    isCapsule ? "rounded-full bg-[#358373] px-8 py-4" : "",
    className ?? ""
  ].join(" ").trim();
  const textMainClass = [
    "font-bold text-lg tracking-wide",
    isCapsule ? "text-white" : "text-[#1E293B]"
  ].join(" ").trim();
  const sloganClass = [
    "text-xs mt-1",
    isCapsule ? "text-white/80" : "text-[#358373]"
  ].join(" ").trim();
  return (
    <div className={containerClass}>
      <svg
        width={isCapsule ? 64 : 48}
        height={isCapsule ? 64 : 48}
        viewBox="0 0 64 64"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ display: "block" }}
      >
        {/* Camera focus frame */}
        <rect
          x="8"
          y="8"
          width="48"
          height="48"
          rx="8"
          stroke={isCapsule ? "#fff" : "#358373"}
          strokeWidth="3"
        />
        {/* Slash/Lens element */}
        <path
          d="M20 44L44 20"
          stroke={isCapsule ? "#fff" : "#358373"}
          strokeWidth="3"
          strokeLinecap="round"
        />
      </svg>
      <div className="flex flex-col items-center mt-2">
        <span
          className={textMainClass}
          style={{ fontFamily: "'Montserrat', 'Inter', 'Arial', sans-serif" }}
        >
          Learnist.AI
        </span>
        <span
          className={sloganClass}
          style={{ letterSpacing: "0.08em" }}
        >
          See • Sense • Spark
        </span>
      </div>
    </div>
  );
};
