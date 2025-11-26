import React from "react";

type QuestionCardProps = {
  question: string;
  answer: string;
  explanation?: string;
  tags?: string[];
  onFavorite?: () => void;
  favorited?: boolean;
  className?: string;
};

export const QuestionCard = ({ question, answer, explanation, tags, onFavorite, favorited, className }: QuestionCardProps) => (
  <div className={`bg-white rounded-xl shadow-sm p-4 flex flex-col gap-2 ${className ?? ""}`}
       style={{ background: "#F5F7FA" }}>
    <div className="flex items-center justify-between gap-2">
      <span className="font-bold text-[#1E293B] text-base">{question}</span>
      <button
        className={`ml-2 px-2 py-1 rounded-full text-xs font-semibold ${favorited ? "bg-[#358373] text-white" : "bg-[#B9E4D4] text-[#358373]"}`}
        onClick={onFavorite}
        title={favorited ? "已收藏" : "收藏"}
      >
        {favorited ? "★" : "☆"}
      </button>
    </div>
    <div className="text-xs text-[#358373]">答案：{answer}</div>
    {explanation && (
      <div className="text-xs text-[#1E293B] opacity-80">解析：{explanation}</div>
    )}
    {tags && tags.length > 0 && (
      <div className="flex flex-wrap gap-2 mt-2">
        {tags.map(tag => (
          <span key={tag} className="bg-[#B9E4D4] text-[#358373] rounded-full px-2 py-1 text-xs font-medium">{tag}</span>
        ))}
      </div>
    )}
  </div>
);
