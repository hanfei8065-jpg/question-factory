import React from "react";
import { CourseCard } from "./CourseCard";

type CourseListProps = {
  courses: Array<{
    title: string;
    modules: number;
    progress: number;
  }>;
  className?: string;
};

export const CourseList = ({ courses, className }: CourseListProps) => (
  <div className={`grid gap-6 ${className ?? ""}`}>
    {courses.map((c, idx) => (
      <CourseCard key={idx} {...c} />
    ))}
  </div>
);
