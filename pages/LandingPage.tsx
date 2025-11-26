import React from "react";
import { Logo } from "../components/ui/Logo";
import { NavBar } from "../components/ui/NavBar";
import { CourseCard } from "../components/ui/CourseCard";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#F5F7FA] flex flex-col">
      <NavBar />
      <main className="flex flex-col items-center justify-center flex-1 py-16">
        <Logo variant="capsule" className="mb-8" />
        <h1 className="text-4xl font-bold text-[#1E293B] mb-4" style={{ fontFamily: "Montserrat, Inter, Arial, sans-serif" }}>
          See • Sense • Spark
        </h1>
        <p className="text-lg text-[#358373] mb-10 max-w-xl text-center">
          Welcome to Learnist.AI — The trusted academic platform for modern learners. Explore courses, track your progress, and spark your curiosity.
        </p>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 w-full max-w-4xl">
          <CourseCard title="Mathematics" modules={12} progress={75} />
          <CourseCard title="Physics" modules={10} progress={85} />
          <CourseCard title="Chemistry" modules={8} progress={96} />
        </div>
      </main>
    </div>
  );
}
