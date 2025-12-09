# Claude Session Handover: zotero-nsai

> **This document bootstraps Claude sessions when elegant-STATE is available.**
> If elegant-STATE is unavailable, fall back to ECOSYSTEM.scm + STATE.scm.

## Quick Start

```graphql
# Query elegant-STATE for session context
query {
  project(id: "zotero-nsai") {
    status
    mvpTasks { description completed }
    blockedBy { name }
  }
  ecosystem {
    languagePolicy { allowed banned }
  }
}
```

## Project Identity

| Field | Value |
|-------|-------|
| Name | NSAI - Neurosymbolic Research Validator |
| Repo | https://github.com/hyperpolymath/zotero-nsai |
| Purpose | Tractarian validation, certainty scoring for Zotero citations |
| Philosophy | Early Wittgenstein - "What can be said clearly" |
| Companion | Fogbinder (uncertainty navigation) |
| Priority | 3 (after templater, voyant-export) |

## Language Policy (ENFORCED BY RHODIBOT)

### Allowed
```
ReScript (.res, .resi)    ← PRIMARY
Guile/Scheme (.scm)       ← Tooling, STATE
SCSS (.scss)              ← Styles
CUE (.cue)                ← Config
Nickel (.ncl)             ← Type-safe config
Rust (.rs)                ← WASM
Lean 4 (.lean)            ← Verification
Shell (.sh)               ← Scripts
```

### BANNED (CI will reject)
```
TypeScript (.ts, .tsx)    ✗ BLOCKED
CoffeeScript (.coffee)    ✗ BLOCKED
Go (.go)                  ✗ BLOCKED
npm (package.json)        ✗ BLOCKED
Python (.py)              ✗ BLOCKED (except Salt)
```

## Current State

Query elegant-STATE or read STATE.scm for current status:

```scheme
;; From STATE.scm
(current-position
  (status . "rescript-migration-complete")
  (summary . "ReScript core done, RSR aligned, needs build/test"))
```

## Interface Contracts

### NSAI → Fogbinder (v1.0.0)
- Format: JSON
- Trigger: certainty < 0.7
- Schema: src/Types/FogbinderInterface.res

### Zotero Plugin
- Format: WebExtension manifest v2
- Target: Zotero 7+ only (strict_min_version: "7.0")

## MVP Tasks (Query elegant-STATE for current status)

1. ☐ ReScript compilation test
2. ☐ SCSS compilation
3. ☐ XPI packaging
4. ☐ Zotero 7 integration test
5. ☐ Fogbinder handoff test

## DO NOT

- **Add TypeScript** - Rhodibot will block
- **Add npm/package.json** - Rhodibot will block
- **Change interfaces** without updating ECOSYSTEM.scm
- **Ignore blockers** - Check what this project is blocked by
- **Diverge from RSR** - Must have all required files

## Coordination Protocol

1. **Before making changes**: Query elegant-STATE for current ecosystem state
2. **For interface changes**: Submit proposal to elegant-STATE for review
3. **After completing work**: Update STATE.scm, sync to elegant-STATE
4. **If blocked**: Check blocker status before proceeding

## Files to Read First

1. `ECOSYSTEM.scm` - Cross-project coordination
2. `STATE.scm` - Project checkpoint
3. `.rhodibot.ncl` - Compliance config
4. `config/elegant-state.ncl` - Coordination config
5. `RSR-STANDARD-FORM.adoc` - Required structure

## Fallback Mode

If elegant-STATE is unavailable:

```scheme
;; Read these files directly
(fallback-context
  (ecosystem . "ECOSYSTEM.scm")
  (state . "STATE.scm")
  (language-policy . ".rhodibot.ncl")
  (warn . "Operating without coordination - sync when available"))
```

## Session End Protocol

Before ending session:
1. Commit all changes
2. Push to branch
3. Update STATE.scm with session accomplishments
4. Sync to elegant-STATE (if available)
5. Note any blockers discovered for next session

---

*"What can be said at all can be said clearly, and what we cannot talk about we must pass over in silence... to Fogbinder."*
