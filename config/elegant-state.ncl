# elegant-STATE Integration Configuration
# Defines how this project syncs with the ecosystem coordination layer

let ElegantState = {
  # Connection to elegant-STATE instance
  endpoint : String,
  project_id : String,

  # Sync behavior
  sync : {
    on_commit : Bool,
    on_push : Bool,
    on_pr : Bool,
    interval_minutes : Number,
  },

  # What to sync
  exports : {
    state_scm : Bool,
    ecosystem_scm : Bool,
    compliance_status : Bool,
    language_violations : Bool,
  },

  # Query templates for Claude sessions
  session_context : {
    query : String,
    include_ecosystem : Bool,
    include_interfaces : Bool,
    include_blockers : Bool,
  },
}

in {
  elegant_state : ElegantState = {
    endpoint = "https://elegant-state.hyperpolymath.dev/graphql",
    project_id = "zotero-nsai",

    sync = {
      on_commit = true,
      on_push = true,
      on_pr = true,
      interval_minutes = 60,
    },

    exports = {
      state_scm = true,
      ecosystem_scm = true,
      compliance_status = true,
      language_violations = true,
    },

    session_context = {
      query = m%"
        query SessionContext($projectId: ID!) {
          project(id: $projectId) {
            name
            status
            priority
            mvpTasks {
              id
              description
              completed
            }
            blockedBy {
              id
              name
              reason
            }
            interfaces {
              name
              version
              contract
            }
          }
          ecosystem {
            languagePolicy {
              allowed
              banned
            }
            rsrStandardForm {
              version
              requiredFiles
            }
            activeProposals {
              id
              author
              description
              status
            }
          }
        }
      "%,
      include_ecosystem = true,
      include_interfaces = true,
      include_blockers = true,
    },
  },

  # Fallback when elegant-STATE unavailable
  fallback = {
    use_ecosystem_scm = true,
    use_state_scm = true,
    warn_on_fallback = true,
  },

  # Proposal configuration (for multi-agent coordination)
  proposals = {
    require_approval_for = [
      "interface_change",
      "language_policy_exception",
      "dependency_addition",
    ],
    auto_approve = [
      "documentation_update",
      "test_addition",
      "comment_change",
    ],
    reviewers = ["hyperpolymath"],
  },
}
