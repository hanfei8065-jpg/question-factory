import React from "react";

type ModalProps = {
  open: boolean;
  onClose: () => void;
  children: React.ReactNode;
  className?: string;
  title?: string;
};

export const Modal = ({ open, onClose, children, className, title }: ModalProps) => {
  if (!open) return null;
  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50">
      <div className={`bg-white rounded-xl shadow-lg p-6 min-w-[320px] max-w-[90vw] ${className ?? ""}`}
           style={{ background: "#F5F7FA" }}>
        {title && <div className="font-bold text-lg text-[#1E293B] mb-2">{title}</div>}
        {children}
        <button className="mt-4 bg-[#358373] text-white rounded-full px-4 py-1 font-bold" onClick={onClose}>Close</button>
      </div>
    </div>
  );
};
