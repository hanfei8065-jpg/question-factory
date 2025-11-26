import React, { useState } from "react";
import { Button } from "./Button";

type FormProps = {
  fields: Array<{
    label: string;
    name: string;
    type?: string;
    required?: boolean;
    placeholder?: string;
  }>;
  onSubmit: (values: Record<string, string>) => void;
  className?: string;
  submitText?: string;
};

export const Form = ({ fields, onSubmit, className, submitText = "提交" }: FormProps) => {
  const [values, setValues] = useState<Record<string, string>>({});
  const handleChange = (name: string, value: string) => {
    setValues(v => ({ ...v, [name]: value }));
  };
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(values);
  };
  return (
    <form className={`bg-white rounded-xl shadow-sm p-6 flex flex-col gap-4 ${className ?? ""}`} style={{ background: "#F5F7FA" }} onSubmit={handleSubmit}>
      {fields.map(f => (
        <div key={f.name} className="flex flex-col gap-1">
          <label className="text-[#358373] font-semibold text-sm" htmlFor={f.name}>{f.label}{f.required && " *"}</label>
          <input
            id={f.name}
            name={f.name}
            type={f.type ?? "text"}
            required={f.required}
            placeholder={f.placeholder}
            value={values[f.name] ?? ""}
            onChange={e => handleChange(f.name, e.target.value)}
            className="rounded-xl border border-[#B9E4D4] px-3 py-2 text-[#1E293B] bg-white focus:border-[#358373] outline-none"
          />
        </div>
      ))}
      <Button type="submit" variant="primary">{submitText}</Button>
    </form>
  );
};
