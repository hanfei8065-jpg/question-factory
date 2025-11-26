# Learnist.AI VI视觉系统设计规范

## 1. 品牌主色与配色
- **Primary（主色）**：`#358373`（深翠绿，主按钮、Logo背景、Banner等）
- **Secondary（辅助色）**：`#5FCEB3`（亮青色，图标、强调、hover等）
- **Muted/Light（弱化/浅色）**：`#B9E4D4`（柔和薄荷，进度条底色、卡片背景、标签等）
- **Surface/Bg（表面/背景）**：`#F5F7FA`（极浅灰白，页面背景、卡片底色）
- **Text Main（主文字色）**：`#1E293B`（深石板灰，主文本、标题）

## 2. 字体与排版
- **主字体**：`Montserrat`, `Inter`, `Arial`, `sans-serif`
- **标题**：加粗，主色或主文字色
- **正文**：常规，主文字色
- **字号建议**：
  - 标题：`text-2xl` ~ `text-4xl`
  - 正文：`text-base` ~ `text-lg`
  - 标签/辅助：`text-xs` ~ `text-sm`

## 3. 圆角与阴影
- **圆角**：
  - 卡片/弹窗/输入框：`rounded-xl`（1rem）
  - 按钮/标签/进度条：`rounded-full`（pill形）
- **阴影**：`shadow-sm` ~ `shadow-xl`，柔和不夸张

## 4. Logo用法
- **SVG矢量Logo组件**（见`components/ui/Logo.tsx`）：
  - 符号：几何相机对焦框`[ ]`+斜杠`/`或镜头元素
  - 文字：Learnist.AI，粗体几何无衬线
  - Slogan：See • Sense • Spark（小字，主色或白色）
  - 变体：
    - default：深色文字+主色icon
    - capsule：主色底+白色icon/文字，圆角胶囊

## 5. 组件风格
- **按钮（Button）**：主色/辅助色/弱化色，圆角pill，字体加粗，hover有色彩变化
- **卡片（CourseCard/QuestionCard/UserCard）**：主色/弱化色背景，圆角，主文字色，阴影
- **进度条（ProgressBar）**：底色`#B9E4D4`，进度填充`#358373`，圆角
- **弹窗（Modal）**：圆角、主色按钮、柔和阴影
- **搜索框（SearchBox）**：圆角、主色icon、浅色背景
- **Banner/海报/PPT**：主色大底、Logo、Slogan、圆角、主视觉元素

## 6. 代码片段示例
### Tailwind 配色扩展
```ts
// tailwind.config.ts
colors: {
  primary: '#358373',
  secondary: '#5FCEB3',
  muted: '#B9E4D4',
  surface: '#F5F7FA',
  textmain: '#1E293B',
},
fontFamily: {
  sans: ['Montserrat', 'Inter', 'Arial', 'sans-serif'],
},
borderRadius: {
  pill: '9999px',
  xl: '1rem',
},
```

### Logo组件用法
```tsx
import { Logo } from "../components/ui/Logo";
<Logo variant="default" />
<Logo variant="capsule" className="mb-8" />
```

### 主按钮用法
```tsx
<Button variant="primary">主按钮</Button>
<Button variant="secondary">辅助按钮</Button>
<Button variant="muted">弱化按钮</Button>
```

### 卡片用法
```tsx
<CourseCard title="数学" modules={12} progress={75} />
<QuestionCard question="题干" answer="答案" explanation="解析" />
<UserCard name="张三" avatarUrl="..." progress={80} role="学生" />
```

### 进度条用法
```tsx
<ProgressBar value={75} />
```

### Banner/海报/PPT用法
```tsx
<Banner title="Learnist.AI" subtitle="See • Sense • Spark" ctaText="立即体验" />
<Poster title="Learnist.AI" slogan="See • Sense • Spark" info="AI赋能学习" qrUrl="..." />
<PPTTemplate title="Learnist.AI产品介绍">内容区块</PPTTemplate>
```

## 7. 设计原则
- 所有新页面、组件、物料必须100%复用上述VI规范，不得自定义配色、字体、圆角等风格。
- 发现不一致，立即修正。
- 所有代码和设计均以此文档为唯一标准。

---
如需补充或更新，请直接在此文档基础上迭代！
