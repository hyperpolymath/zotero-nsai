# Contributing to NSAI

Thank you for your interest in contributing to NSAI (Neurosymbolic Research Validator)!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Tri-Perimeter Contribution Framework (TPCF)](#tri-perimeter-contribution-framework-tpcf)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Philosophical Guidelines](#philosophical-guidelines)

## Code of Conduct

This project follows a Code of Conduct to ensure a welcoming environment. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Tri-Perimeter Contribution Framework (TPCF)

NSAI uses the **TPCF model** for graduated trust and contribution access. See [TPCF.md](TPCF.md) for complete details.

**Current Perimeter**: **Perimeter 3 (Community Sandbox)** - Fully open contribution

All contributors are welcome to:
- Report issues
- Submit pull requests
- Improve documentation
- Add tests
- Refactor code

## Getting Started

### Prerequisites

- **Node.js 18+**
- **npm/pnpm/yarn**
- **Git**
- **Zotero 6.0+** (for testing)

### Setup

```bash
# Fork the repository on GitHub
#Clone your fork
git clone https://github.com/YOUR-USERNAME/zotero-nsai.git
cd zotero-nsai

# Add upstream remote
git remote add upstream https://github.com/Hyperpolymath/zotero-nsai.git

# Install dependencies
npm install

# Run tests
npm test

# Build the project
npm run build
```

## Development Workflow

### 1. Create a Branch

```bash
# Fetch latest changes
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name
```

**Branch naming**:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation only
- `refactor/` - Code refactoring
- `test/` - Test additions/improvements

### 2. Make Changes

- Write code following our [Coding Standards](#coding-standards)
- Add tests for new functionality
- Update documentation
- Run `npm run typecheck` and `npm run lint`

### 3. Commit Changes

```bash
git add .
git commit -m "Brief description of changes"
```

**Commit message format**:
```
<type>: <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Example**:
```
feat: Add ISBN-13 validation support

Implement ISBN-13 checksum validation in addition to existing
ISBN-10 validation. Adds support for hyphenated and non-hyphenated
formats.

Closes #42
```

### 4. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## Coding Standards

### TypeScript

- **Strict mode**: Always use TypeScript strict mode
- **No `any`**: Avoid `any` type; use `unknown` if necessary
- **Explicit types**: Prefer explicit type annotations for public APIs
- **Zod schemas**: Use Zod for runtime validation of external data

### Code Style

- **ESLint**: Follow `.eslintrc.json` rules
- **2-space indentation**
- **Single quotes** for strings
- **Semicolons required**
- **Max line length**: 100 characters

### File Organization

```
src/
  types/          # Type definitions
  validation/     # Validation logic
  fogbinder/      # Fogbinder integration
  ui/             # User interface
  test-utils/     # Testing utilities
```

### Naming Conventions

- **Classes**: `PascalCase` (e.g., `TractarianValidator`)
- **Functions**: `camelCase` (e.g., `validateCitation`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_CERTAINTY`)
- **Interfaces**: `PascalCase` (e.g., `ValidationResult`)
- **Files**: `kebab-case` (e.g., `citation-factory.ts`)

## Testing Requirements

### Test Coverage

- **All new features** must have tests
- **Bug fixes** should include regression tests
- **Aim for 80%+ coverage** for new code

### Running Tests

```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# Coverage report
npm run test:coverage

# Specific test file
npm test validator.test.ts
```

### Writing Tests

Use Vitest with descriptive test names:

```typescript
import { describe, it, expect } from 'vitest';

describe('TractarianValidator', () => {
  describe('validateCitation', () => {
    it('validates a complete book citation', () => {
      // Test implementation
    });

    it('detects missing required fields', () => {
      // Test implementation
    });
  });
});
```

### Test Utilities

Use `citation-factory.ts` for generating test data:

```typescript
import { createValidBook } from '../test-utils/citation-factory';

const citation = createValidBook({ title: 'Custom Title' });
```

## Documentation

### Code Comments

- **Explain "why"**, not "what"
- Use JSDoc for public APIs
- Keep comments up-to-date with code changes

```typescript
/**
 * Validate an atomic citation
 *
 * Performs truth-functional analysis of citation structure
 * following Tractarian logic.
 *
 * @param citation - The citation to validate
 * @returns Validation result with certainty score
 */
validate(citation: AtomicCitation): ValidationResult {
  // Implementation
}
```

### Documentation Files

Update relevant documentation:

- **README.md**: User-facing features
- **PHILOSOPHY.md**: Philosophical changes
- **FOGBINDER-HANDOFF.md**: Integration changes
- **CHANGELOG.md**: All changes (see [Pull Request Process](#pull-request-process))

## Pull Request Process

### Before Submitting

- [ ] Tests pass (`npm test`)
- [ ] Type checking passes (`npm run typecheck`)
- [ ] Linting passes (`npm run lint`)
- [ ] Build succeeds (`npm run build`)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (see below)

### CHANGELOG Updates

Add an entry to `CHANGELOG.md` under `[Unreleased]`:

```markdown
## [Unreleased]

### Added
- ISBN-13 validation support (#42)

### Fixed
- Incorrect certainty calculation for missing DOI (#43)
```

Categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`

### PR Description Template

```markdown
## Description
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- Bullet list of changes

## Testing
How was this tested?

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Follows coding standards
```

### Review Process

1. **Automated checks** must pass (tests, linting, type checking)
2. **At least one maintainer** must approve
3. **No unresolved conversations**
4. **Squash and merge** (maintainers will handle this)

## Philosophical Guidelines

### Tractarian Principles

NSAI is grounded in Wittgenstein's *Tractatus*. Contributions should respect:

1. **Formal Validation Only**: NSAI validates structure, not semantics
2. **Certainty Boundary**: Know what NSAI can and cannot validate
3. **Handoff to Fogbinder**: Low certainty → Fogbinder exploration
4. **Type Safety**: Logical structure enforced at compile time
5. **Privacy-First**: No tracking, local-first processing

### What Belongs in NSAI

✅ **Yes**:
- Structural validation (required fields, formats)
- Consistency checking (internal coherence)
- Certainty scoring (formal confidence metrics)
- Fogbinder handoff (uncertainty detection)

❌ **No**:
- Semantic validation (does DOI point to correct work?)
- Contradiction detection (conflicting claims) → Fogbinder
- Mood/tone analysis → Fogbinder
- External API calls (network requests)

### Accessibility First

All UI contributions must maintain WCAG AA compliance:

- Semantic HTML
- ARIA labels
- Keyboard navigation
- Screen reader support
- High contrast mode

## Questions?

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Email**: [MAINTAINER-EMAIL] for private inquiries

## Recognition

Contributors will be:
- Listed in `humans.txt`
- Credited in CHANGELOG.md
- Added to GitHub contributors page

Thank you for contributing to NSAI!

---

**"What can be validated clearly, we validate. What cannot be validated, we hand to Fogbinder."**
