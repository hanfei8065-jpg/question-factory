import React from "react";
import { QuestionCard } from "../components/ui/QuestionCard";

export default function DetailPage() {
  // 示例数据
  const question = {
    question: "已知x+y=10，求x的值。",
    answer: "无法确定，需更多条件。",
    explanation: "题干信息不足，无法唯一确定x。",
    tags: ["代数", "方程"],
    favorited: false,
  };
  return (
    <div className="min-h-screen bg-[#F5F7FA] flex flex-col items-center py-12">
      <div className="max-w-xl w-full">
        <QuestionCard {...question} />
      </div>
    </div>
  );
}
