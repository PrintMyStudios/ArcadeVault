# Arcade Vault — Theme Concepts

Three selectable retro-inspired themes, each with distinct visual identity.

---

## Theme A: Neon CRT

**Vibe:** Late-night arcade in the 80s. Glowing neon signs, CRT monitors humming.

| Token | Value |
|-------|-------|
| Background | Deep navy (#0D0D1A) |
| Accent | Hot magenta (#FF00FF) |
| Secondary | Electric cyan (#00FFFF) |
| Danger | Neon red (#FF3366) |
| Success | Mint green (#00FF88) |
| Glow | Strong (0.8 intensity) |
| Scanlines | Visible (0.15 opacity) |
| Corners | Rounded (12pt) |

**Typography:** Rounded system fonts, bold weights.

**Best for:** Maximum retro immersion with visible CRT effects.

---

## Theme B: Vector Arcade

**Vibe:** Asteroids, Battlezone, Tempest. Sharp lines on black void. Terminal green glow.

| Token | Value |
|-------|-------|
| Background | Pure black (#000000) |
| Accent | Phosphor green (#33FF33) |
| Secondary | Amber (#FFAA00) |
| Danger | Red alert (#FF3333) |
| Glow | Subtle (0.3 intensity) |
| Scanlines | None |
| Corners | Sharp (0pt) |

**Typography:** Monospaced system fonts throughout.

**Best for:** Clean, high-contrast vector graphics aesthetic.

---

## Theme C: 8-Bit Candy

**Vibe:** Colorful home consoles. Chunky pixels, playful palette.

| Token | Value |
|-------|-------|
| Background | Deep purple (#2B2B5E) |
| Accent | Bubble gum pink (#FF6B9D) |
| Secondary | Aqua (#7FE7DC) |
| Danger | Cherry red (#FF4757) |
| Success | Lime (#2ED573) |
| Glow | None |
| Scanlines | None |
| Corners | Chunky rounded (16pt) |

**Typography:** Heavy rounded fonts, bold and playful.

**Best for:** Cheerful, approachable retro style.

---

## Switching Themes

1. Go to **Settings** from the home screen
2. Tap on a theme in the **THEME** section
3. Changes apply immediately across the entire app

Theme selection persists across app launches.

---

## Implementation Notes

- All themes are defined in `Themes/*.swift`
- `ThemeManager` is `@Observable` and stored in environment
- UI components read from `themeManager.currentTheme.palette`, `.typography`, `.effects`, `.layout`
- CRT overlay is separate toggle (works with any theme but strongest with Neon CRT)
