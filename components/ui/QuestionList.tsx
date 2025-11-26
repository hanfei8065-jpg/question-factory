import React from "react";
import { QuestionCard } from "./QuestionCard";

type QuestionListProps = {
  questions: Array<{
    question: string;
    answer: string;
    explanation?: string;
    tags?: string[];
    favorited?: boolean;
  }>;
  onFavorite?: (idx: number) => void;
  className?: string;
};

export const QuestionList = ({ questions, onFavorite, className }: QuestionListProps) => (
  <div className={`grid gap-4 ${className ?? ""}`}>
    {questions.map((q, idx) => (
      <QuestionCard
        key={idx}
        {...q}
        onFavorite={onFavorite ? () => onFavorite(idx) : undefined}
      />
    ))}
  </div>
);
