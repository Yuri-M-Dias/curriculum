# CLAUDE.md

This file helps Claude Code understand the project layout, build commands, and conventions.

## Project Overview

LaTeX-based bilingual (English/Portuguese) CV for Yuri Matheus Dias Pereira.
Two templates are maintained in parallel:

| Template | Directory | Fonts | Status |
|----------|-----------|-------|--------|
| Deedy Resume (OpenFonts) | `OpenFonts/` | Lato + Raleway (bundled) | **Primary** |
| Plasmati Graduate CV | `plasmati/` | Fontin (system) | Legacy |

Both templates use **XeLaTeX** and are built with `latexmk`.

---

## Building PDFs Locally

### Prerequisites

```bash
# Debian/Ubuntu
sudo apt-get install texlive-xetex texlive-fonts-extra texlive-latex-extra latexmk

# Install Fontin (Plasmati template only)
./install_fonts.sh
```

### Compile OpenFonts CV (primary)

```bash
cd OpenFonts
latexmk -pdf deedy_resume-openfont.tex
# Output: deedy_resume-openfont.pdf
```

### Compile Plasmati CV

```bash
cd plasmati
latexmk -pdf CV_YuriMatheusDias_01.tex
# Output: CV_YuriMatheusDias_01.pdf
```

Both directories have a `.latexmkrc` that configures `xelatex --shell-escape` automatically.

---

## Language Switching

Content is defined in per-template i18n files using `\def` macros.
Switch languages by editing the main `.tex` file to comment/uncomment the appropriate `\input`.

### OpenFonts (`OpenFonts/deedy_resume-openfont.tex`)

```latex
% Uncomment one:
%\input{i18n/cv_en.tex}   ← English
\input{i18n/cv_pt.tex}    ← Portuguese (current default)
```

Also swap the "last updated" date command on the following lines:

```latex
%\lastupdated        ← English
\ultimaatualizacao   ← Portuguese (current default)
```

### Plasmati (`plasmati/CV_YuriMatheusDias_01.tex`)

```latex
% Uncomment one block:
\selectlanguage{english}
\input{i18n/cv_en.tex}    ← English (current default)

%\selectlanguage{brazil}
%\input{i18n/cv_pt.tex}   ← Portuguese
```

---

## Editing Content

All user-visible text lives in the i18n files. **Do not edit the main `.tex` files** for content changes.

| File | Purpose |
|------|---------|
| `OpenFonts/i18n/cv_en.tex` | OpenFonts – English content |
| `OpenFonts/i18n/cv_pt.tex` | OpenFonts – Portuguese content |
| `plasmati/i18n/cv_en.tex` | Plasmati – English content |
| `plasmati/i18n/cv_pt.tex` | Plasmati – Portuguese content |

Content macros follow this pattern:

```latex
\def\education{Education}
\def\professional{Professional Experience}
```

---

## Publications

BibTeX entries for the publications section live in `OpenFonts/publications.bib`.
Add new entries there; they are rendered with `ieeetr` style via `\bibliography{publications}`.

---

## File Structure

```
curriculum/
├── CLAUDE.md
├── README.md
├── install_fonts.sh          # Installs Fontin font to the system
├── CV_YuriMatheusDias_en.pdf # Latest compiled EN output
├── CV_YuriMatheusDias_pt.pdf # Latest compiled PT output
├── OpenFonts/                # Primary template
│   ├── deedy_resume-openfont.tex  # Main document (edit language \input here)
│   ├── deedy-resume-openfont.cls  # Template class (layout/typography)
│   ├── .latexmkrc                 # Build config: xelatex --shell-escape
│   ├── publications.bib           # BibTeX references
│   ├── fonts/lato/                # Bundled Lato font files
│   ├── fonts/raleway/             # Bundled Raleway font files
│   └── i18n/
│       ├── cv_en.tex              # English content macros
│       └── cv_pt.tex              # Portuguese content macros
├── plasmati/                 # Legacy template
│   ├── CV_YuriMatheusDias_01.tex
│   ├── .latexmkrc
│   └── i18n/
│       ├── cv_en.tex
│       └── cv_pt.tex
├── fonts/fontin/             # Fontin font files (for Plasmati)
└── bibtex/                   # Additional bibliography sources
```

---

## CI/CD

A GitHub Actions workflow at `.github/workflows/build-pdf.yml` compiles both language
variants of the OpenFonts template on every push to `master`.
Compiled PDFs are uploaded as workflow artifacts (retained for 90 days).
