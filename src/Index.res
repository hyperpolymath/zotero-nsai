/**
 * Index.res - NSAI Plugin Entry Point
 * "What can be said at all can be said clearly." - Tractatus
 *
 * This is the background script entry point for the Zotero 7 WebExtension.
 */

open Atomic
open Validator

/** Initialize the NSAI plugin */
let init = () => {
  Js.Console.log("[NSAI] Neurosymbolic Research Validator initialized")
  Js.Console.log("[NSAI] Zotero 7+ WebExtension mode")
  Js.Console.log("[NSAI] Tractarian validation engine ready")
}

/** Handle messages from popup or content scripts */
let handleMessage = (message: {..}, _sender: {..}, sendResponse: {..} => unit) => {
  let action = message["action"]

  switch action {
  | "validate" => {
      let citations = message["citations"]
      Js.Console.log2("[NSAI] Validating", Js.Array2.length(citations), "citations")

      // Convert and validate
      let results = validateBatch(citations, ())
      sendResponse({"success": true, "results": results})
    }
  | "getConfig" => {
      sendResponse({"success": true, "config": defaultConfig})
    }
  | "ping" => {
      sendResponse({"success": true, "message": "NSAI is ready"})
    }
  | _ => {
      sendResponse({"success": false, "error": "Unknown action"})
    }
  }

  true // Keep channel open for async response
}

/** Register message listener */
let setupMessageListener = () => {
  // Browser runtime message listener
  %raw(`
    if (typeof browser !== 'undefined' && browser.runtime) {
      browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
        return handleMessage(message, sender, sendResponse);
      });
    }
  `)
}

// Initialize on load
init()
setupMessageListener()
