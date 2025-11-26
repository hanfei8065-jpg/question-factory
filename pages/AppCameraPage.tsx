import React from "react";
import { Banner } from "../components/ui/Banner";

export default function AppCameraPage() {
  return (
    <div className="min-h-screen bg-[#F5F7FA] flex flex-col items-center py-12">
      <Banner title="拍题页" subtitle="拍照上传题目，AI自动识别与解析" ctaText="开始拍题" />
      <div className="mt-8 max-w-lg w-full bg-white rounded-xl shadow p-6">
        <h2 className="text-xl font-bold text-[#358373] mb-2">拍题引导</h2>
        <ul className="list-disc pl-6 text-[#1E293B] text-base mb-4">
          <li>请确保题目清晰完整</li>
          <li>避免反光、遮挡和模糊</li>
          <li>支持多种题型识别</li>
        </ul>
        <h2 className="text-xl font-bold text-[#358373] mb-2">最佳实践</h2>
        <ul className="list-disc pl-6 text-[#1E293B] text-base">
          <li>拍摄时保持手机稳定</li>
          <li>光线充足，背景简洁</li>
          <li>如有多题，请分批拍摄</li>
        </ul>
      </div>
    </div>
  );
}
