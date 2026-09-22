---
description: INNIO myPlant Figma design system — component keys, library keys, patterns and gotchas for building dashboards and screens that match the myPlant FSM / Energy Manager style.
---

# myPlant Figma Design System

Use this skill whenever building or updating screens in a Figma file that should match the INNIO myPlant design language.

**MANDATORY: Also load the `figma-use` and `figma-generate-design` skills before any `use_figma` call.**

---

## 1. Organization & Library Keys

Target plan key: `organization::1592715596783991584` (INNIO enterprise)

| Library | `libraryKey` |
|---|---|
| **MUI 6.1** (primary — most up-to-date myPlant components) | `lk-c8eea196199d4841541c08af8229047685f8d05f100d6fc8f6b341e9771d6ffc26f8ac6a11acb7622c8d1385f3c1c0d7683df3f882e4f975584859bd234b4c61` |
| **Commercial - v5.11.0-0** (older but has extra myPlant-specific components) | `lk-7b9be7c92e10156c39ae11505282c28aa6c95318754d4127816d9719387a56f9adfd2b732c39558c58a30ef3bf9e64b257eec0cb1edd30b196a741298ba51bcc` |

Always search these two libraries first before falling back to community kits.

---

## 2. Key Component Keys

Import with `figma.importComponentByKeyAsync(key)` or `figma.importComponentSetByKeyAsync(key)`.

### Shell / Layout

| Component | Library | Key | Notes |
|---|---|---|---|
| `myPlantAppbar` | MUI 6.1 | `6a6b6b0943277ad3f038ab7c57e7138aa7ab968a` | **component_set** — variants: `Property 1=Desktop` (1280×66), `Property 1=mobile`. Always use Desktop for dashboard screens. |
| `myPlant / Drawer` | MUI 6.1 | `cdb408123105978ecc0f94b8711933c0c9a32b23` | Single component, 260px wide sidebar with nav items, dark theme toggle, myPlant logo |
| `myPlant / drawer / menuElement` | MUI 6.1 | `c686f0fe76a55b923dbe76e86e569fd698cd9952` | **component_set** — variants: `elements=0`…`elements=5` |

### Dashboard cards

| Component | Library | Key | Notes |
|---|---|---|---|
| `myPlant / Dashboard / KPICard` | Commercial | `e44fbc9b45a548c0f5983cde08f878aff8254682` | Single component, 296×104. Has an **Instance Slot** for custom content — see Section 4. |
| `myPlant / Dashboard / Card` | Commercial | `07146b2378fa6a1a305fff27377f387daf31f699` | Single component, 608×456. Large content card. |
| `myPlant / Dashboard / Card / Action` | Commercial | `d38b8fe3f7b62ba237f5e5d71e4dd8cb46708b60` | **component_set** — icon button for card header actions. |

### Data

| Component | Library | Key | Notes |
|---|---|---|---|
| `<DataGridTable>` | MUI 6.1 | `ec32ecd8718aaa80d7beed8dac0537e9eab84761` | **component_set** — key props: `Checkbox` (True/False), `Density` (Standard/Compact/Comfortable), `Rows` (5/10), `ToolbarFilter?`, `TableFooter?` |
| `<Card>` | MUI 6.1 | `7728f410e79a95b5600be09782a41572f721b862` | **component_set** — variants: `Small Screen=False/True, Blank=False/True` |

### Controls

| Component | Library | Key | Notes |
|---|---|---|---|
| `<Button>` | MUI 6.1 | `c0dbbd635baca2ed6f2f9616f813b8c6ae14b1bb` | **component_set** — key props: `Size` (Small/Medium/Large), `Color` (Primary/Secondary/Inherit), `Variant` (Contained/Outlined/Text), `State` (Enabled/Focused/Pressed/Disabled) |
| `<Chip>` | MUI 6.1 | `0f1366a6a29266c0552664af44cc52f675ca2e6f` | **component_set** — key props: `Size` (Small/Medium), `Color` (Default/Primary/Secondary), `State` (Enabled/Disabled/Hovered), `Variant` (Filled/Outlined). Text prop key: `Label#11069:1495` |
| `<IconButton>` | MUI 6.1 | `c42f435a2dec57f931d598853c69b1569ad4728d` | **component_set** |

### Variables

| Variable | Collection | Key |
|---|---|---|
| `background/default` | myplant theming // primitive | `205094dca4f722d6877cf884e668f2b5c99a263c` |
| `background/paper-elevation-1` | myplant theming // primitive | `b8400509983acf8909d7045a92217adb7407b934` |
| `background/paper-elevation-2` | myplant theming // primitive | `006917d7036d77d171c17c4e817351366f6486e7` |

---

## 3. Page & Canvas Layout

- **Dashboards**: 1920×1080, no sidebar unless explicitly required
- **Background**: `{ r: 0.949, g: 0.953, b: 0.961 }` (#F2F3F5)
- **Card background**: white `{ r: 1, g: 1, b: 1 }`
- **Card border**: `{ r: 0.898, g: 0.91, b: 0.929 }` stroke, weight 1
- **Card shadow**: `DROP_SHADOW, color {r:0,g:0,b:0,a:0.05}, offset {x:0,y:1}, radius 4`
- **Card corner radius**: 8px
- **Content padding**: 24px all sides, 16px gap between sections
- **Content padding inside cards**: 16px

### Standard dashboard structure (top → bottom)

```
myPlantAppbar           ← always first; Desktop variant; layoutSizingHorizontal = FILL
Sub Header (white)      ← title "Welcome, [Name] 👋" + optional tabs; paddingLeft/Right 24
Content (grey bg)       ← vertical auto-layout, gap 16, padding 24
  ├── Filter Chips row  ← <Chip> components; one highlighted Primary for the key alert
  ├── KPI Cards row     ← 4× myPlant/Dashboard/KPICard; FILL width each
  ├── Tables row        ← 2× card wrappers side-by-side; each FILL width
  └── Full-width table  ← single card wrapper spanning full width
```

---

## 4. The KPICard Instance Slot Pattern

KPICard has a nested `_Library / Instance Slot` that renders as placeholder text by default. To fill it with real data:

1. Find the slot node (nested path: `<Paper> → _myPlant/Dashboard/KPICardHover → _myPlant/Dashboard/KPICardBase → _Library/Instance Slot`)
2. Call `.detachInstance()` on it to get a mutable frame
3. Clear its children, set `layoutMode = "VERTICAL"`, `itemSpacing = 4`, `fills = []`
4. Append your content nodes

### Canonical slot-fill script

```js
const slotInst = await figma.getNodeByIdAsync("SLOT_INSTANCE_ID");
const slotFrame = slotInst.detachInstance();
slotFrame.name = "KPI Content";
for (const child of [...slotFrame.children]) child.remove();

slotFrame.layoutMode = "VERTICAL";
slotFrame.primaryAxisSizingMode = "AUTO";
slotFrame.counterAxisSizingMode = "AUTO";
slotFrame.itemSpacing = 4;
slotFrame.fills = [];

// Big headline number
await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" });
const num = figma.createText();
num.characters = "33";
num.fontName = { family: "Inter", style: "Semi Bold" };
num.fontSize = 32;
num.fills = [{ type: "SOLID", color: { r: 0.102, g: 0.122, b: 0.157 } }];
slotFrame.appendChild(num);

// Trend badge + label
await figma.loadFontAsync({ family: "Inter", style: "Medium" });
await figma.loadFontAsync({ family: "Inter", style: "Regular" });
const row = figma.createAutoLayout("HORIZONTAL");
row.primaryAxisAlignItems = "CENTER";
row.itemSpacing = 6;
row.fills = [];
slotFrame.appendChild(row);

const badge = figma.createAutoLayout("HORIZONTAL");
badge.paddingTop = 2; badge.paddingBottom = 2;
badge.paddingLeft = 6; badge.paddingRight = 6;
badge.cornerRadius = 12; badge.itemSpacing = 2;
badge.fills = [{ type: "SOLID", color: { r: 0.063, g: 0.733, b: 0.447 }, opacity: 0.12 }];
row.appendChild(badge);

const trendText = figma.createText();
trendText.characters = "↑ +10%";
trendText.fontName = { family: "Inter", style: "Medium" };
trendText.fontSize = 11;
trendText.fills = [{ type: "SOLID", color: { r: 0.031, g: 0.553, b: 0.329 } }];
badge.appendChild(trendText);

const vsText = figma.createText();
vsText.characters = "vs last week";
vsText.fontName = { family: "Inter", style: "Regular" };
vsText.fontSize = 11;
vsText.fills = [{ type: "SOLID", color: { r: 0.435, g: 0.482, b: 0.553 } }];
row.appendChild(vsText);
```

---

## 5. Chip Filter Row Pattern

```js
const chipSet = await figma.importComponentSetByKeyAsync("0f1366a6a29266c0552664af44cc52f675ca2e6f");
const chipDefault = chipSet.children.find(c =>
  c.name === "Size=Medium, Color=Default, State=Enabled, Variant=Filled");
const chipPrimary = chipSet.children.find(c =>
  c.name === "Size=Medium, Color=Primary, State=Enabled, Variant=Filled");

const row = figma.createAutoLayout("HORIZONTAL");
row.itemSpacing = 8;
row.fills = [];

const items = [
  { label: "Events this week: 33", primary: false },
  { label: "Unassigned Events: 2", primary: true },   // ← alert chip uses Primary
  { label: "Open Reports: 5",      primary: false },
  { label: "Open Tickets: 13",     primary: false },
];

for (const item of items) {
  const inst = (item.primary ? chipPrimary : chipDefault).createInstance();
  inst.setProperties({ "Label#11069:1495": item.label });
  row.appendChild(inst);
}
```

---

## 6. DataGrid Table Card Pattern

```js
const dataGrid = await figma.importComponentSetByKeyAsync("ec32ecd8718aaa80d7beed8dac0537e9eab84761");
const compactVariant = dataGrid.children.find(c =>
  c.name.includes("Density=Compact") && c.name.includes("Rows=5") && c.name.includes("Checkbox=False")
) || dataGrid.defaultVariant;

const card = figma.createAutoLayout("VERTICAL");
card.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
card.cornerRadius = 8;
card.paddingTop = 16; card.paddingBottom = 0;
card.paddingLeft = 16; card.paddingRight = 16;
card.itemSpacing = 8;
card.strokes = [{ type: "SOLID", color: { r: 0.898, g: 0.91, b: 0.929 } }];
card.strokeWeight = 1;

// Card title
await figma.loadFontAsync({ family: "Inter", style: "Semi Bold" });
const title = figma.createText();
title.characters = "Latest Events";
title.fontName = { family: "Inter", style: "Semi Bold" };
title.fontSize = 14;
title.fills = [{ type: "SOLID", color: { r: 0.102, g: 0.122, b: 0.157 } }];
card.appendChild(title);

// Grid
const grid = compactVariant.createInstance();
grid.setProperties({
  "ToolbarFilter?#215:13": false,
  "TableFooter?#215:0": false,   // true for the full-width bottom table
  "Checkbox": "False",
  "Density": "Compact",
  "Rows": "5",
});
card.appendChild(grid);
grid.layoutSizingHorizontal = "FILL";
```

---

## 7. Typography & Color Tokens

| Use | Font | Size | Color |
|---|---|---|---|
| Page title | Inter Semi Bold | 20 | `{r:0.102, g:0.122, b:0.157}` |
| Card title | Inter Semi Bold | 14–16 | `{r:0.102, g:0.122, b:0.157}` |
| Body / cell | Inter Regular | 13 | `{r:0.102, g:0.122, b:0.157}` |
| Muted label | Inter Regular | 11–13 | `{r:0.435, g:0.482, b:0.553}` |
| Positive trend | Inter Medium | 11 | `{r:0.031, g:0.553, b:0.329}` |
| Negative trend | Inter Medium | 11 | `{r:0.78, g:0.106, b:0.106}` |
| Warning | Inter Medium | 11 | `{r:0.769, g:0.498, b:0}` |
| Primary blue | — | — | `{r:0.231, g:0.51, b:0.965}` |

---

## 8. Gotchas

- **KPICard has no top-level component properties** (`props: []`) — you cannot use `setProperties()` on it directly. You must navigate to the nested `Title` instance and call `setProperties({ "Content#11609:11": "..." })` on that, or detach the Instance Slot as shown in Section 4.
- **myPlantAppbar width**: it is designed at 1280px but should always be set to `layoutSizingHorizontal = "FILL"` so it spans the full dashboard width.
- **Drawer from MUI 6.1 vs Commercial**: prefer MUI 6.1 key `cdb408123105978ecc0f94b8711933c0c9a32b23` — it is more up-to-date.
- **DataGrid `ToolbarFilter?` key includes a hash**: the full key is `ToolbarFilter?#215:13` — always use the full key in `setProperties()`.
- **Always load Inter fonts** before creating or mutating text: Semi Bold, Medium, and Regular are all used.
- **layoutSizingHorizontal = "FILL"** must be set *after* `parent.appendChild(child)`, not before.
