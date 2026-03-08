# CLAUDE.md

This file helps Claude Code understand the project layout, build commands, and conventions.

## Project Overview

LaTeX-based multilingual CV for Yuri Matheus Dias Pereira, built with the Deedy Resume
(OpenFonts) template. The active languages are **English** and **Portuguese**; **Bulgarian**
is a prepared skeleton ready to activate.

Template directory: `OpenFonts/` — uses Lato + Raleway (bundled), compiled with XeLaTeX.

---

## Building PDFs Locally

### Prerequisites

```bash
# Debian/Ubuntu
sudo apt-get install texlive-xetex texlive-fonts-extra texlive-latex-extra latexmk
```

### Compile a specific language

```bash
cd OpenFonts

# English
printf '\\def\\langcode{en}\\input{deedy_resume-openfont}\n' > cv_en.tex
latexmk -pdf cv_en.tex
# Output: cv_en.pdf

# Portuguese
printf '\\def\\langcode{pt}\\input{deedy_resume-openfont}\n' > cv_pt.tex
latexmk -pdf cv_pt.tex
# Output: cv_pt.pdf
```

The `.latexmkrc` in `OpenFonts/` configures `xelatex --shell-escape` automatically.

---

## Adding a New Language

1. Create `OpenFonts/i18n/cv_XX.tex` (copy any existing file and translate all `\def` macros).
   Every file **must** define `\lastupdatedtext` (the "Last Updated" phrase in that language).
2. Add `XX` to the `lang` matrix in `.github/workflows/build-pdf.yml` under both the `test`
   and `build` jobs.
3. That's it — CI will compile, test, and release the new language automatically.

### i18n macro pattern

```latex
\def\lastupdatedtext{Last Updated on}   % required in every i18n file
\def\education{Education}
\def\professional{Professional Experience}
% ... etc.
```

### Optional per-language macros (conditionally rendered)

```latex
\def\languagesPT{Portuguese: Native}   % shown only when defined
\def\languagesBG{Bulgarian: ...}       % shown only when defined
```

---

## Language Architecture

The main document (`OpenFonts/deedy_resume-openfont.tex`) reads `\langcode` to select the
i18n file at compile time:

```latex
\ifdefined\langcode
  \edef\cvlangfile{i18n/cv_\langcode.tex}
  \expandafter\input\expandafter{\cvlangfile}
\else
  \input{i18n/cv_en.tex}   % default for local compilation without a wrapper
\fi
```

CI generates a tiny per-language wrapper that sets `\langcode` before loading the main file:

```
\def\langcode{en}\input{deedy_resume-openfont}
```

---

## Editing Content

All user-visible text lives in the i18n files. **Do not edit the main `.tex` file** for
content changes — edit only the i18n files.

| File | Purpose |
|------|---------|
| `OpenFonts/i18n/cv_en.tex` | English content |
| `OpenFonts/i18n/cv_pt.tex` | Portuguese content |
| `OpenFonts/i18n/cv_bg.tex` | Bulgarian content (skeleton — not yet compiled in CI) |

---

## Publications

BibTeX entries live in `OpenFonts/publications.bib`. Additional research bibliography
sources are in `bibtex/`. Add new entries to `publications.bib`; they render with the
`ieeetr` style via `\bibliography{publications}`.

`install_fonts.sh` installs the Fontin font family (kept for potential future use).

---

## File Structure

```
curriculum/
├── CLAUDE.md
├── README.md
├── install_fonts.sh          # Installs Fontin font (kept for future use)
├── bibtex/                   # Additional bibliography sources
│   └── siimi.bib
├── fonts/fontin/             # Fontin font files (kept for future use)
├── OpenFonts/                # CV template (Deedy Resume, OpenFonts)
│   ├── deedy_resume-openfont.tex   # Main document — do not edit content here
│   ├── deedy-resume-openfont.cls   # Template class (layout, typography)
│   ├── .latexmkrc                  # Build config: xelatex --shell-escape
│   ├── publications.bib            # BibTeX publication references
│   ├── fonts/lato/                 # Bundled Lato font files
│   ├── fonts/raleway/              # Bundled Raleway font files
│   └── i18n/
│       ├── cv_en.tex               # English content macros
│       ├── cv_pt.tex               # Portuguese content macros
│       └── cv_bg.tex               # Bulgarian content macros (skeleton)
└── .github/
    └── workflows/
        └── build-pdf.yml           # CI: test → build → release
```

---

## CI/CD

Workflow: `.github/workflows/build-pdf.yml`

### Jobs

| Job | Trigger | What it does |
|-----|---------|--------------|
| `test` | All events | Compiles each language; fails on any LaTeX error |
| `build` | All events (push + PRs) | Compiles final PDFs; uploads as 90-day artifacts — available on PRs too |
| `latexdiff` | PRs only | Generates a visual diff PDF (additions underlined, deletions struck through) vs the base branch |
| `release` | Push to `master` or `v*` tag | Publishes PDFs to GitHub Releases |

### Reviewing a Pull Request

When a PR is opened or updated, CI uploads three sets of artifacts visible under the
**"Artifacts"** section of the Actions run linked from the PR:

- `cv-en` — compiled English CV as it will look after merge
- `cv-pt` — compiled Portuguese CV as it will look after merge
- `cv-diff-en` — English diff PDF: new text underlined, removed text struck through
- `cv-diff-pt` — Portuguese diff PDF (same)

### Release strategy

- **Every push to `master`** → updates the rolling **"Latest CV Build"** pre-release
  (tag `latest`) with freshly compiled PDFs.
- **Pushing a `v*` tag** (e.g. `git tag v2.1 && git push origin v2.1`) → creates a
  permanent versioned GitHub Release with auto-generated release notes.

### Adding a language to CI

In `.github/workflows/build-pdf.yml`, find the three `matrix:` blocks (in `test`, `build`,
and `latexdiff`) and add your language code to all three:

```yaml
matrix:
  lang: [en, pt, bg]   # ← add new code here
```

---

## Cutting a Versioned Release

```bash
git tag v2.1
git push origin v2.1
```

GitHub Actions will compile both languages and attach the PDFs to a new GitHub Release
named `v2.1`.
