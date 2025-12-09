# Rhodibot Configuration for NSAI
# RSR compliance enforcement settings

let LanguagePolicy = {
  allowed : Array String,
  banned : Array String,
  exceptions : Array { pattern : String, context : String, reason : String },
}

let RhodiConfig = {
  project : String,
  rsr_tier : String,
  categories : {
    enabled : Array Number,
    level : String,
  },
  language_policy : LanguagePolicy,
  elegant_state_sync : Bool,
}

in {
  rhodibot : RhodiConfig = {
    project = "zotero-nsai",
    rsr_tier = "Rhodium",

    categories = {
      # All 12 categories enabled
      enabled = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
      level = "strict",
    },

    language_policy = {
      allowed = [
        "rescript",   # Primary language
        "guile",      # Tooling, STATE files
        "scheme",     # Configuration
        "rust",       # WASM modules
        "lean4",      # Formal verification
        "julia",      # Analysis (v2.0)
        "scss",       # Styles
        "cue",        # Config generation
        "nickel",     # Type-safe config
        "shell",      # Basic scripts
        "svg",        # Vector graphics
        "html",       # Markup
        "css",        # Compiled from SCSS only
        "json",       # Data/config
        "toml",       # Config
        "yaml",       # CI/funding
        "adoc",       # Documentation
        "md",         # Limited docs (LICENSE, SECURITY)
      ],

      banned = [
        "typescript",    # Use ReScript
        "coffeescript",  # Obsolete
        "go",            # Not in stack
        "python",        # See exceptions
        "javascript",    # Only as ReScript output (.res.js)
      ],

      exceptions = [
        {
          pattern = "*.py",
          context = "salt/*",
          reason = "Salt automation requires Python"
        },
        {
          pattern = "*.res.js",
          context = "src/**",
          reason = "ReScript compiler output"
        },
        {
          pattern = "*.js",
          context = "lib/**",
          reason = "Compiled ReScript output"
        },
      ],
    },

    elegant_state_sync = true,
  },

  # CI configuration
  ci = {
    block_on_violation = true,
    generate_report = true,
    badge_endpoint = "https://rhodibot.hyperpolymath.dev/badge",
  },

  # Pre-commit hook behavior
  hooks = {
    pre_commit = {
      enabled = true,
      categories = [12],  # Language policy on every commit
      fast_fail = true,
    },
    pre_push = {
      enabled = true,
      categories = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],  # Full check
      fast_fail = true,
    },
  },
}
