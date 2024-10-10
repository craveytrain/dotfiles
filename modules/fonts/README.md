# Fonts Module

This module installs developer-focused programming fonts with excellent support for coding, terminals, and development environments.

## Core Features

The module provides:

- **Monospaced programming fonts** optimized for code readability
- **Nerd Font variants** with icon and glyph support
- **System-wide installation** via Homebrew Cask
- **Terminal compatibility** for modern terminal emulators

## Installation Components

**Homebrew casks installed:**
- font-fira-code - Monospaced font with programming ligatures
- font-hack-nerd-font - Hack font with Nerd Font icons
- font-inconsolata - Google's open-source monospaced font
- font-inconsolata-nerd-font - Inconsolata with Nerd Font icons
- font-input - Customizable programming font

**Configuration files:**
- None (fonts are installed system-wide, no configuration needed)

## Installed Fonts

### Fira Code
- **Features:** Programming ligatures (==, =>, !=, etc.)
- **Best for:** Modern code editors supporting ligatures
- **Style:** Clean, highly readable monospaced
- **Ligatures:** Yes

### Hack Nerd Font
- **Features:** Developer icons and glyphs from Nerd Fonts
- **Best for:** Terminal prompts, file managers, status lines
- **Style:** Clear and readable monospaced
- **Icons:** Git, folders, languages, cloud providers, etc.

### Inconsolata
- **Features:** Classic programming font by Raph Levien
- **Best for:** Terminals and editors preferring traditional styling
- **Style:** Distinctive, clear monospaced
- **Ligatures:** No (standard variant)

### Inconsolata Nerd Font
- **Features:** Inconsolata with Nerd Font icon additions
- **Best for:** Terminals using icon-based prompts
- **Style:** Classic Inconsolata with extended glyphs
- **Icons:** Full Nerd Font icon set

### Input
- **Features:** Customizable programming font family
- **Best for:** Developers wanting fine-tuned readability
- **Style:** Modern, multiple weights and styles
- **Customization:** Various width and weight options

## Using the Fonts

### In Terminal Applications

After installation, fonts are available in:
- iTerm2
- Terminal.app
- Alacritty
- Kitty
- Warp
- Other terminal emulators

**To configure:**
1. Open terminal preferences
2. Navigate to font settings
3. Select your preferred font (e.g., "Hack Nerd Font Mono")

### In Code Editors

Fonts work in all major editors:
- VSCode
- Sublime Text
- Atom
- Vim/Neovim (in GUI mode)
- Emacs

**VSCode example:**
```json
{
  "editor.fontFamily": "Fira Code, monospace",
  "editor.fontLigatures": true
}
```

## Nerd Fonts Icons

Nerd Font variants include thousands of icons and glyphs useful for:
- Shell prompts (Powerlevel10k, Starship, etc.)
- File type indicators
- Git status symbols
- Language/framework logos
- Cloud provider icons

**Example icons:**
-  Git branch
-  Modified files
-  Node.js
-  Python
-  Docker

## Font Recommendations

**For ligature lovers:**
- Use Fira Code in your editor with ligatures enabled

**For terminal/shell prompts:**
- Use Hack Nerd Font or Inconsolata Nerd Font for icon support

**For classic aesthetics:**
- Use standard Inconsolata or Input

**For customization:**
- Explore Input font's various width and weight combinations

## Troubleshooting

**Fonts not appearing:**
```bash
# Verify installation
ls ~/Library/Fonts/
brew list --cask | grep font
```

**Restart applications:**
Close and reopen your terminal or editor after font installation.

**Icons not displaying (boxes/question marks):**
Ensure you're using a Nerd Font variant (not the standard version) and your terminal/editor supports Unicode.

**Ligatures not working:**
- Verify your editor supports ligatures
- Enable ligature support in editor settings
- Ensure you're using Fira Code (other fonts may not have ligatures)

**Font looks wrong:**
Check you've selected the correct font variant:
- "Hack Nerd Font Mono" for monospaced (recommended for terminals)
- "Hack Nerd Font" for proportional spacing
