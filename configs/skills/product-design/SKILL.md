---
name: product-design
description: "用於分析既有專案的 UI／UX、操作流程、資訊層級、互動設計與介面改善。遵循專業產品設計標準：資訊架構、互動狀態完整性、設計系統與設計標記 (Design Tokens)、UX 啟發式評估與既有介面優化診斷。觸發情境：UI／UX 審查、操作流程梳理、介面改善建議、資訊層級診斷、元件狀態檢查。"
author: Product Design / Zypsy
version: 1.0.0
---

# Zypsy Product Design Skill

> "Design is not decoration. It is the reduction of friction between a person and the outcome they need."

This skill encodes the design standards Zypsy applies across every engagement — from Series A SaaS dashboards to AI-native consumer apps. It goes beyond visual aesthetics into the full practice of product design: how to structure information, how to design behaviour, how to build systems, and how to make AI feel trustworthy.

---

## 00.1 — Response Mode

All sections of this skill are always active. The principles, constraints, and 
anti-patterns in sections 02–11 inform every response — they are never switched off.

What changes based on request scope is how much of that reasoning is shown.

### Quick mode
Trigger: a single question, a component-level request, a critique, or a fast check.

Respond conversationally. Apply all design principles internally. Surface only the 
answer and the most relevant rationale. Do not produce structured sections. Do not 
run the quality checklist visibly. Do not ask the Section 00 intake questions.

### Full mode
Trigger: an app concept, a multi-screen flow, a new product area, or any request 
that requires structural design decisions.

When Full mode is triggered, run Section 00.2 intake first. 
Then respond using the structure in Section 10.

### The rule
The skill informs the answer. It does not become the answer.
A question gets a response. A product gets a document.

---

## 00.0 — LiangHao 工作區治理對齊原則（最高優先）

本技能與全域開發憲法（`configs/AGENTS.md`）、`lianghao-development` 及 `windows-tool-ux` 搭配使用時，遵循以下優先邊界：
1. **語言與語氣**：所有產出、分析與介面文案一律使用標準台灣繁體中文。
2. **需求探索與執行分流（取代強制阻斷式 4 問）**：
   - 當使用者明確提出「幫我規劃產品」、「透過問卷引導我」、「幫我重新評估這個專案」或方向未定時，進入預設唯讀之引導式需求探索模式，遵循 `lianghao-development` 之 `references/project-product-assessment.md` 第 5 節（先讀現況 ➜ 每輪 3～5 題動態訪談與完全自由回答 ➜ 主動分析比較 ➜ 產出 11 項產品方向決策摘要，未獲明確要求不修改 Repository）。
   - 當需求已經明確，或使用者要求直接修改、製作、測試、發布時，直接依既有專案架構、程式碼或已確認需求推進，不重新啟動問卷。
3. **字型與離線優先**：Windows 桌面工具、免安裝 Portable 應用、公務／行政系統優先採用系統字型堆疊（`Segoe UI`, `Microsoft JhengHei UI`, `system-ui`），不強制引入外部 Web Fonts（覆寫下方第 06 節與第 09 節對系統預設字型的限制）。
4. **狀態與反應門檻依專案規模裁剪**：第 05 節之 8 種元件狀態與固定毫秒門檻適用於完整產品或重度互動介面；小型內部工具與局部修正依 `windows-tool-ux` 實測體感與最小修改原則按需套用，不因視覺美化延後已達門檻之交付。
5. **UI／UX 自主風格探索、反制式 AI 介面與遊戲風格工具 UI 選型**：
   - 遵循 `lianghao-development` 之 `references/agent-execution.md` 第 3、4 節：涉及全新 UI、整體視覺改版或重大流程調整時，設計前先理解產品用途並比較 2～3 個可查證案例（成熟產品、GitHub 開源 UI、遊戲介面或設計系統）。
   - 使用者未指定風格時，依產品定位、資訊密度與維護成本自主探索適合風格（專業工具、簡約、工業、科技、復古、手繪、遊戲、擬物等），不預設任何單一風格為最佳選擇，亦不將 Q 版設為預設；使用者已指定風格時，以指定方向優先。
   - 避免無理由套用制式 AI 介面（相似圓角卡片、大面積漸層背景、裝飾性陰影、過多彩色圖示、無用途浮動面板、過度寬鬆排列）。
   - 工具軟體採用遊戲風格 UI 時，須分開選擇「遊戲類型」與「美術風格」、保留工具軟體本質（不自行加入等級、經驗值、成就、虛擬貨幣或難懂遊戲術語）；使用者僅要求 UI 預覽圖時，依實際 Repository 現有功能產生概念圖，與實作分離，不修改程式與正式規格。

---

## 00.2 — Context Intake (When Essential Context Is Missing)

When designing a brand-new product or major multi-screen flow from scratch and the core context cannot be inferred from the repository, clarify up to four key dimensions (do not block execution if already clear from project files or user prompt):

1. **Primary user**: Specific role, domain knowledge, and operating environment.
2. **Core job**: The single primary verb-object outcome this interface exists to achieve.
3. **Riskiest moment**: Any irreversible, destructive, or high-consequence action requiring preview/confirmation.
4. **Success criteria**: The concrete operational state that signals safe completion.

---

## 01 — Output Format

When generating an app concept or interface, always structure the response in this order. Do not jump straight into visuals.

1. **Product goal** — what problem this solves and for whom
2. **Primary user** — specific, not a persona category
3. **Core workflow** — the single path that matters most
4. **Information architecture** — structure and navigation logic
5. **Key screens / modules** — what each contains and why
6. **States and edge cases** — all eight states per component
7. **AI behaviour** — only if the product includes AI features
8. **Design system / component logic** — tokens, variants, reuse
9. **Risks and recommendations** — what to prioritise now vs later

---

## 02 — Product Framing

- Optimise for the **main job**, not for feature count.
- Prefer **one strong workflow** over multiple weak ones.
- Separate clearly:
  - what the user needs to **understand**
  - what the user needs to **do**
  - what the user only needs as **context**
- If scope is broad, define:
  - **MVP** — what ships first
  - **v1 improvements** — what comes after validation
  - **future ideas** — what requires more signal

Never feature-dump. Every element on screen must earn its place.

---

## 03 — Information Architecture

IA is the skeleton. Bad IA cannot be fixed with good UI.

### Hierarchy before layout
Establish a strict content hierarchy before designing anything visual:

- **Level 1 — Identity**: What is this? Where am I?
- **Level 2 — Status**: What is the current state of things?
- **Level 3 — Action**: What can I do?
- **Level 4 — Context**: What do I need to know to act well?

Never invert this order. Never blend levels. The most common IA failure is promoting Level 4 (context) above Level 3 (action), burying the thing the user came to do.

### Navigation
- Navigation should reflect the user's mental model of their tasks, not the product's internal architecture.
- Maximum cognitive load for primary navigation: 5–7 items. Beyond this, group — never append.
- Active state must be unmistakable. Never rely on colour alone.
- Every screen must answer: "Where am I?", "Where can I go?", "How do I get back?"

### Progressive Disclosure
- Default views should show only what is needed to complete the primary action.
- Secondary and advanced options belong in overflow menus, drawers, or modals — not on the main canvas.
- The rule: *if fewer than 30% of users need it in the first 30 seconds, hide it by default.*

---

## 04 — Screen and Flow Design

For every proposed screen, define:

- **Purpose** — the single reason this screen exists
- **Primary action** — the one thing the user should do here
- **Secondary actions** — what is available but not dominant
- **Critical content** — what must be visible without scrolling
- **What should be hidden by default** — and where it lives
- **What happens after the main action** — next state, confirmation, redirect

Prefer flows that are:
- obvious on first use
- reversible where possible
- hard to misuse by accident
- fast for repeat users
- understandable without documentation

---

## 05 — Interaction Design

### Feedback and System Status
Every action must produce a visible response within 100ms. If the action takes longer:
- **< 1s**: Show a subtle loading indicator on the element itself (button spinner, skeleton shimmer). No full-screen loader.
- **1–5s**: Show progress with an estimate. Keep the user in context.
- **> 5s**: Give the user something to do while they wait, or move the task to the background and notify on completion.

Silence is failure. A system that does not respond is a system the user assumes is broken.

### Error Design
Errors are a product feature, not an edge case.

- **Prevent before you catch**: Use constraints, input validation, and confirmation patterns to reduce error rate.
- **Be specific, not apologetic**: "Something went wrong" is useless. "We couldn't save your changes — your session expired. Sign in again and your draft will be restored." is useful.
- **Point to the solution**: Every error message should contain or link to a resolution. Never a dead end.
- **Preserve user work**: Never lose a partially completed form, draft, or configuration on error. Auto-save aggressively.

### States — design all eight, every time
For every component or view, design these states before calling it done:

1. **Empty** — nothing exists yet. This is an onboarding moment, not a blank void.
2. **Loading** — data is in transit. Match the skeleton to the expected loaded shape.
3. **Partial** — some data is present, more is coming.
4. **Populated** — the primary state. Usually the only one that gets designed.
5. **Error** — the fetch failed, the action failed, the input is invalid.
6. **Disabled** — the user lacks permission or the action is unavailable in context.
7. **Read-only** — data is visible but not editable.
8. **Overflow** — 10x more data than expected. Tables with 1,000 rows. Names with 80 characters. Images that fail to load.

If you design only the populated state, you have designed less than 15% of the interface.

### Affordances and Signifiers
- Every interactive element must look interactive. Clickable things look different from readable things.
- Hover states are mandatory on desktop.
- Touch targets on mobile: minimum 44×44px. No exceptions.
- Drag-and-drop requires a persistent visual cue — not just a cursor change.

---

## 06 — Visual Design

### Commitment over compromise
Pick a clear aesthetic direction that fits the product, the user, and the job to be done. Commit once the direction is justified by context — not by novelty, trend, or surface polish alone.

Choose one direction and commit:
- **Editorial** — type as hero, strong vertical rhythm, aggressive white space, ink-heavy moments
- **Systems** — grid supremacy, monospace accents, dense information, nothing decorative
- **Organic** — variable weight type, natural textures, irregular containers, warmth
- **Minimalism** — restraint, generous spacing, muted palette with a single precious accent
- **Kinetic** — the interface is in motion by default; stasis is the exception
- **Raw / Brutalist** — structural honesty, no decoration, contrast as the only softness

### Typography
Typography is the primary carrier of hierarchy, brand, and tone. Treat it as the most important design decision, not the last one.

**Rules:**
- Use a maximum of two typefaces: one for display/headings, one for body/UI. Never more.
- For Windows desktop apps, offline portable tools, and public-sector/utility systems, prioritize the native system font stack (`Segoe UI`, `Microsoft JhengHei UI`, `system-ui`). For brand-driven consumer web products where web fonts are appropriate, avoid generic unstyled defaults when a distinctive typeface serves the brand.
- Choose typefaces that are appropriate to the product.
- Type scale: establish 5–6 sizes maximum. Assign each a role. Never deviate.
- Line height for body text: 1.5–1.6. For display: 1.0–1.2.
- Measure (line length): 60–75 characters for body copy. Anything longer degrades comprehension.
- Colour contrast for text: 4.5:1 minimum (WCAG AA). Target 7:1 for primary body copy.
- Typography must carry hierarchy before colour does.

### Theme Selection
- Theme choice is a product decision, not a stylistic default.
- Select the initial theme based on product type, audience expectations, content density, and likely usage context.
- Prefer light mode for editorial, reading-heavy, marketing, ecommerce, healthcare, education, lifestyle, wellness, and general consumer products.
- Prefer dark mode only when it is clearly supported by product context or research, such as for developer tools, trading terminals, technical dashboards, monitoring systems, media tools, or dense professional interfaces.
- In ambiguous cases, prefer light mode.
- Only create dark mode when explicitly requested or when research strongly indicates it should be the primary theme.
- Dark mode must be designed intentionally. It is not a simple inversion of light mode and requires separate decisions around contrast, elevation, shadow, and colour weight.
- Build only one primary theme by default.
- Generate both light and dark themes only when explicitly requested.

### Colour
- The palette serves hierarchy, not decoration. Assign roles before assigning hues.
- **Roles to define first**: background, surface, border, text-primary, text-secondary, text-disabled, interactive, interactive-hover, interactive-active, success, warning, error, info.
- A palette with more than 3 brand colours is not a palette. It is chaos with names.
- Accent colours work because they are rare. If everything is accented, nothing is.
- Avoid gradient as a default. Use it intentionally: to communicate depth, direction, or energy — not to fill space.

### Spacing
- Use a base-8 spacing system (4px minimum unit). Consistent spacing creates rhythm.
- Proximity signals relationship. Elements that belong together should be closer to each other than to things they don't belong to.
- Generous spacing is not wasted space. It is breath.
- Padding inside a component should be proportional to the component's size. A small chip and a large card do not share the same padding values.

### Layout & Composition
- Establish a grid and honour it. Break it only intentionally, only once, and only for a reason.
- Asymmetry is more interesting than symmetry, but it requires more control.
- Alignment is not aesthetic preference. Misalignment signals disorder to the subconscious.
- Design for the critical content length, not the placeholder. One-word labels and 200-character labels both need to work.

### Motion
- Motion is communication. Every animation should have a reason: state change, attention direction, action confirmation, or spatial relationship.
- Default easing: ease-out for elements entering (decelerate to rest), ease-in for elements leaving (accelerate away).
- Duration: 150–200ms for micro-interactions, 300–400ms for page transitions, 500–600ms for orchestrated reveals.
- Staggered entry animations (100–150ms offset) create rhythm without chaos.
- Respect `prefers-reduced-motion`. All motion must have a static fallback.
- Never animate just to fill silence. A still interface is not an unfinished interface.

---

## 07 — AI-Native Interface Patterns

AI features introduce states and behaviours that do not exist in traditional software. These patterns must be designed explicitly. Never let them emerge accidentally.

### Trust and Transparency
The central challenge of AI UI is calibrating user trust. Overtrust causes errors. Undertrust causes abandonment.

- **Show the basis for AI output**: Where the answer came from, what data it used, what timeframe it covers. Even a single metadata line ("Based on 47 transactions, Sep–Nov 2024") dramatically increases trust.
- **Confidence signals**: Not all AI output is equally reliable. Design a visual vocabulary for confidence — definitive outputs look different from suggested outputs. Use visual weight, not just labels.
- **Never fake certainty**: If the model is uncertain, the interface must reflect that. A confident UI over an uncertain model is a liability.

### Streaming and Progressive Generation
- Streaming text must not cause layout reflow. Reserve space before content arrives.
- Show a generation indicator (cursor, pulse, shimmer on the output area) — not a full-screen loader.
- Allow interruption. The user should be able to stop generation at any point.
- Once generated, clearly distinguish AI-produced content from user-produced content. They have different epistemological status.

### AI Input Design
- The prompt input is a product surface, not a text field. Design it with appropriate weight and affordance.
- Provide example prompts, suggested actions, or guided templates for new users — the blank box is the most intimidating UI in AI products.
- Voice, image, and file inputs should feel first-class, not bolt-ons.
- Show length constraints only when approaching the limit. Otherwise, hide the infrastructure.

### Human-in-the-Loop Moments
- Identify actions that are irreversible or high-consequence. These require explicit human confirmation regardless of AI confidence.
- Confirmation dialogs must describe the action in plain language. Never "Are you sure?" — always "This will permanently delete 14 client records. This cannot be undone."
- **Preview before commit**: show the user what the AI intends to do before doing it.
- **Edit before apply**: AI-generated content should be editable before it affects state.

### Graceful Degradation
- AI features must degrade gracefully when the model is slow, rate-limited, or unavailable.
- Fallback states must be designed, not handled with a generic error message.
- Degraded mode should be functional. The core product must not become unusable because an AI feature is down.
- Retry logic should be transparent and user-controlled, not silent.

### AI Feature Anti-Patterns
- **The blank oracle**: A chat interface with no guidance, examples, or structure.
- **Silent failure**: An AI that returns nothing, returns garbage, or fails without communicating why.
- **Overexposed infrastructure**: Token counts, model names, temperature settings visible to users who didn't ask for them.
- **Magic without feedback**: Actions taken by AI without any explanation of what happened or why.
- **Generic AI aesthetic**: Purple gradient on white. Confident UI over uncertain output. Rounded everything.

---

## 08 — Design Systems Thinking

Think in systems, not in isolated mockups.

### Tokens First
Before building any component, establish the token layer:

```
-- Primitives (raw values):
   color-blue-500: #3B82F6
   space-4: 16px
   radius-md: 8px
   font-size-base: 16px

-- Semantic tokens (role-based):
   color-action-primary: {color-blue-500}
   space-component-padding: {space-4}
   radius-card: {radius-md}

-- Component tokens (component-scoped):
   button-background: {color-action-primary}
   card-padding: {space-component-padding}
```

This separation means theme changes happen at the token level, not in every component. One change propagates everywhere.

### Component Architecture
Every component should be:
- **Composable**: Built from smaller primitives, not monolithic.
- **Variant-driven**: Sizes, appearances, and states as explicit props — not one-off class overrides.
- **Context-agnostic**: A Button does not know it is in a Header. A Card does not know it is in a Dashboard.
- **Predictable**: The same input always produces the same output. No hidden stateful side-effects.

### Consistency as Trust
- Inconsistent spacing, inconsistent type sizes, inconsistent corner radii — these do not just look bad. They communicate to the user that the product is unfinished or untrustworthy.
- Every component should use only values from the token system. No hardcoded values except in tokens themselves.
- When you find yourself writing `margin-left: 13px`, stop. That is a signal that a token is missing or a layout assumption is wrong.

---

## 09 — Anti-Patterns (Avoid Always)

### Structural
- **Card cemetery**: A grid of equal-weight cards. Use hierarchy — not everything is equal.
- **Sidebar overload**: A left sidebar with 20+ items is not navigation. It is a list of features the product doesn't know how to organise.
- **Modal cascade**: A modal that opens another modal. A sign that a full page or drawer is needed.
- **Orphaned empty state**: An empty table or list with no call to action. Every empty state is an onboarding moment.
- **Settings as graveyard**: A settings section that is a dumping ground for everything that didn't fit elsewhere.

### Visual
- Purple gradient on white — the universal signal of generic AI output.
- Inter or Roboto as the only typeface — communicates nothing about the product.
- Ghost button as primary action — too low-contrast to carry the user's intent.
- Uniform corner radius on everything — monotonous and context-free.
- Icon-only navigation without labels (unless the product has strong established user training).
- Colour used as decoration, not as information.

### Interaction
- Hover states that change layout (cause reflow).
- Form submission that loses data on error.
- Destructive actions without confirmation.
- Full-page loading blocks for non-blocking operations.
- Success states that disappear before the user can read them (minimum 3 seconds).
- Tooltips as the only source of critical information — inaccessible on touch.

### Copy
- Button labels that describe the system's action, not the user's intention:
  - "Submit" → "Save changes"
  - "Confirm" → "Confirm booking"
  - "OK" → "Delete account"
- Error messages that apologise but do not help:
  - "An error occurred" → "We couldn't connect. Check your internet connection and try again."
- Placeholder text used as a label (disappears on input).
- Marketing copy inside a product interface. The user is already inside. They do not need to be sold to.
- Widows and orphans in paragraphs.

---

## 10 — Preferred Response Pattern for App Concepts

When asked to design an app or feature, respond in this structure:

### Summary
A concise concept of the product and who it serves. 2–3 sentences maximum.

### Product structure
Core areas, navigation, and why each exists.

### Main workflow
Step-by-step path for the primary job. Include what happens at the riskiest moment.

### Screen logic
What each main screen contains, its primary action, and what is hidden by default.

### States and edge cases
Empty, loading, error, permission-denied, long content, overflow, first-time vs. returning user.

### AI layer (if applicable)
How AI behaves, how trust and uncertainty are surfaced, how failure is handled, what requires human confirmation.

### System and styling direction
Visual direction chosen and why. Component logic. Token structure. Implementation notes.

### Recommendations
What to build now, what to defer, and what signals to watch before deciding.

---

## 11 — Quality Bar

Before any interface is considered complete, run this checklist internally and list only items that that fail. No checklist dump in every response.

### Functional
- [ ] All eight component states designed
- [ ] Every error state has a resolution path
- [ ] Destructive actions have confirmation
- [ ] Forms auto-save or warn on unsaved exit
- [ ] All interactive elements are keyboard-navigable

### Visual
- [ ] Consistent type scale (max 6 sizes, all role-assigned)
- [ ] Consistent spacing (base-8 system, no magic numbers)
- [ ] Colour contrast meets 4.5:1 minimum for all text
- [ ] No more than two typefaces
- [ ] No purple gradient without a genuine reason

### Information Architecture
- [ ] Primary action is immediately visible without scrolling
- [ ] Navigation reflects user task model, not product architecture
- [ ] Empty states include a call to action

### AI-Specific (if applicable)
- [ ] AI outputs have a visible basis or source signal
- [ ] Streaming content does not cause layout reflow
- [ ] Generation can be interrupted
- [ ] High-consequence AI actions require explicit confirmation
- [ ] Graceful degradation state designed and tested

### Accessibility
- [ ] All text meets WCAG AA contrast ratio
- [ ] Focus states are visible and unambiguous
- [ ] Interactive elements have accessible labels
- [ ] Motion respects `prefers-reduced-motion`
- [ ] Touch targets ≥ 44×44px on mobile

### Copy
- [ ] Every button label describes the user's action, not the system's
- [ ] Every error message includes a resolution path
- [ ] No placeholder text used as a field label
- [ ] No marketing language inside the product UI
- [ ] No widows or orphans in paragraphs

---

## The Zypsy Standard

We believe the future of product design is one designer with the leverage of a team. AI is the multiplier. But a multiplier applied to low-quality input produces low-quality output at scale.

This skill exists to raise the floor. To ensure that AI-assisted interfaces start from real design thinking, not from pattern-matching on what a "dashboard" or "landing page" usually looks like.

The measure is not: "Does this look like a designed product?"

The measure is: "Does this make the user's job easier, faster, and less prone to error — and does it do so in a way that is beautiful, coherent, and trustworthy?"

If yes: ship it.

If no: go back to section 00.

---

*Maintained by [Zypsy Design Studio](https://zypsy.com)*
