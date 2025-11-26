import React from "react";

type UserCardProps = {
  name: string;
  avatarUrl?: string;
  progress?: number;
  role?: string;
  className?: string;
};

export const UserCard = ({ name, avatarUrl, progress, role, className }: UserCardProps) => (
  <div className={`bg-white rounded-xl shadow-sm p-4 flex items-center gap-4 ${className ?? ""}`}
       style={{ background: "#F5F7FA" }}>
    <img
      src={avatarUrl ?? "https://api.dicebear.com/7.x/identicon/svg?seed=" + name}
      alt={name}
      className="w-12 h-12 rounded-full bg-muted object-cover"
    />
    <div className="flex flex-col flex-1">
      <span className="font-bold text-[#1E293B] text-base">{name}</span>
      {role && <span className="text-xs text-[#358373] mt-1">{role}</span>}
      {typeof progress === "number" && (
        <div className="w-full h-2 bg-muted rounded-pill mt-2">
          <div className="h-2 rounded-pill" style={{ width: `${progress}%`, background: "#358373" }} />
        </div>
      )}
    </div>
  </div>
);