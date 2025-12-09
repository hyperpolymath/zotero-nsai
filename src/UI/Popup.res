/**
 * Popup.res - NSAI Popup Controller
 * "The limits of my language mean the limits of my world." - Tractatus 5.6
 *
 * Controls the popup UI for validation results display.
 */

open Atomic
open FogbinderInterface
open Validator
open Handoff

/** DOM element bindings */
type element

@val @scope("document")
external getElementById: string => Js.Nullable.t<element> = "getElementById"

@val @scope("document")
external querySelector: string => Js.Nullable.t<element> = "querySelector"

@send external setInnerHTML: (element, string) => unit = "innerHTML"
@send external setTextContent: (element, string) => unit = "textContent"
@send external addEventListener: (element, string, unit => unit) => unit = "addEventListener"
@send external setAttribute: (element, string, string) => unit = "setAttribute"
@send external setStyleWidth: (element, string) => unit = "style.width"

/** Update the certainty meter */
let updateCertaintyMeter = (certainty: float) => {
  let meterFill = getElementById("certainty-meter-fill")
  let percentStr = Js.Float.toString(certainty *. 100.0) ++ "%"

  switch Js.Nullable.toOption(meterFill) {
  | Some(el) => {
      %raw(`el.style.width = percentStr`)
    }
  | None => ()
  }
}

/** Update status display */
let updateStatus = (validated: int, uncertain: int, certainty: float) => {
  let validatedEl = getElementById("validated-count")
  let uncertainEl = getElementById("uncertain-count")
  let certaintyEl = getElementById("certainty-score")

  switch Js.Nullable.toOption(validatedEl) {
  | Some(el) => setTextContent(el, Js.Int.toString(validated))
  | None => ()
  }

  switch Js.Nullable.toOption(uncertainEl) {
  | Some(el) => setTextContent(el, Js.Int.toString(uncertain))
  | None => ()
  }

  switch Js.Nullable.toOption(certaintyEl) {
  | Some(el) => {
      let pct = Js.Math.round(certainty *. 100.0)->Js.Float.toString
      setTextContent(el, pct ++ "%")
    }
  | None => ()
  }

  updateCertaintyMeter(certainty)
}

/** Render a single result item */
let renderResultItem = (result: validationResult): string => {
  let stateClass = switch result.state {
  | #VALID => "valid"
  | #UNCERTAIN => "uncertain"
  | #INCOMPLETE => "uncertain"
  | #INVALID => "error"
  }

  let stateLabel = switch result.state {
  | #VALID => "Valid"
  | #UNCERTAIN => "Uncertain"
  | #INCOMPLETE => "Incomplete"
  | #INVALID => "Invalid"
  }

  let certaintyPct = Js.Math.round(result.certainty.score *. 100.0)->Js.Float.toString

  `<div class="result-item ${stateClass}" role="listitem">
    <div class="result-title">${result.citation.title}</div>
    <div class="result-meta">${stateLabel}</div>
    <div class="result-certainty">Certainty: ${certaintyPct}%</div>
  </div>`
}

/** Render all results */
let renderResults = (results: array<validationResult>) => {
  let resultsList = getElementById("results-list")

  switch Js.Nullable.toOption(resultsList) {
  | Some(el) => {
      if Js.Array2.length(results) == 0 {
        setInnerHTML(el, `<p class="results-empty">No citations to validate.</p>`)
      } else {
        let html = results
          ->Js.Array2.map(renderResultItem)
          ->Js.Array2.joinWith("")
        setInnerHTML(el, html)
      }
    }
  | None => ()
  }
}

/** Show/hide Fogbinder section */
let updateFogbinderSection = (uncertainCount: int) => {
  let section = getElementById("fogbinder-section")
  let countEl = getElementById("uncertainty-count")

  switch Js.Nullable.toOption(section) {
  | Some(el) => {
      if uncertainCount > 0 {
        setAttribute(el, "hidden", "")
        // Actually remove hidden attribute
        %raw(`el.removeAttribute("hidden")`)
      }
    }
  | None => ()
  }

  switch Js.Nullable.toOption(countEl) {
  | Some(el) => setTextContent(el, Js.Int.toString(uncertainCount))
  | None => ()
  }
}

/** Announce to screen readers */
let announce = (message: string) => {
  let announcer = getElementById("sr-announcements")
  switch Js.Nullable.toOption(announcer) {
  | Some(el) => setTextContent(el, message)
  | None => ()
  }
}

/** Get selected items from Zotero */
let getSelectedCitations = (): array<atomicCitation> => {
  // This will be replaced with actual Zotero API call
  %raw(`
    if (typeof Zotero !== 'undefined' && Zotero.getActiveZoteroPane) {
      const pane = Zotero.getActiveZoteroPane();
      const items = pane.getSelectedItems();
      return items.map(item => ({
        id: item.key,
        itemType: item.itemType,
        title: item.getField('title') || 'Untitled',
        creators: item.getCreators() || [],
        date: item.getField('date'),
        publisher: item.getField('publisher'),
        publicationTitle: item.getField('publicationTitle'),
        doi: item.getField('DOI'),
        isbn: item.getField('ISBN'),
        url: item.getField('url'),
        tags: item.getTags() || []
      }));
    }
    return [];
  `)
}

/** Run validation on selected citations */
let runValidation = () => {
  announce("Validating citations...")

  let citations = getSelectedCitations()
  let results = validateBatch(citations, ())

  // Calculate stats
  let validCount = results->Js.Array2.filter(r => r.state == #VALID)->Js.Array2.length
  let uncertainCount = results->Js.Array2.filter(r =>
    r.state == #UNCERTAIN || r.state == #INCOMPLETE
  )->Js.Array2.length

  let totalCertainty = results->Js.Array2.reduce((acc, r) => acc +. r.certainty.score, 0.0)
  let avgCertainty = if Js.Array2.length(results) > 0 {
    totalCertainty /. Belt.Int.toFloat(Js.Array2.length(results))
  } else {
    0.0
  }

  // Update UI
  updateStatus(validCount, uncertainCount, avgCertainty)
  renderResults(results)
  updateFogbinderSection(uncertainCount)

  announce(`Validation complete. ${Js.Int.toString(validCount)} valid, ${Js.Int.toString(uncertainCount)} uncertain.`)
}

/** Export to Fogbinder */
let exportToFogbinderUI = () => {
  let citations = getSelectedCitations()
  let results = validateBatch(citations, ())
  let export = createFogbinderExport(results)

  // Convert to JSON and trigger download
  let json = Js.Json.stringifyAny(export)
  switch json {
  | Some(jsonStr) => {
      %raw(`
        const blob = new Blob([jsonStr], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'nsai-fogbinder-export.json';
        a.click();
        URL.revokeObjectURL(url);
      `)
      announce("Exported to Fogbinder format")
    }
  | None => announce("Export failed")
  }
}

/** Initialize popup */
let init = () => {
  // Validate button
  let validateBtn = getElementById("validate-btn")
  switch Js.Nullable.toOption(validateBtn) {
  | Some(el) => addEventListener(el, "click", runValidation)
  | None => ()
  }

  // Export button
  let exportBtn = getElementById("export-fogbinder")
  switch Js.Nullable.toOption(exportBtn) {
  | Some(el) => addEventListener(el, "click", exportToFogbinderUI)
  | None => ()
  }

  // Keyboard shortcuts
  %raw(`
    document.addEventListener('keydown', (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'v') {
        e.preventDefault();
        runValidation();
      }
      if ((e.metaKey || e.ctrlKey) && e.key === 'e') {
        e.preventDefault();
        exportToFogbinderUI();
      }
    });
  `)

  Js.Console.log("[NSAI] Popup initialized")
}

// Initialize on DOM ready
%raw(`
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
`)
