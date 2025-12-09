/**
 * CitationFormats.res - Academic Citation Format Support
 *
 * Supports export to major citation styles:
 * - Harvard (author-date)
 * - OSCOLA (Oxford Standard for Citation of Legal Authorities)
 * - MLA (Modern Language Association)
 * - Cahiers de Journalisme (journalism studies)
 * - Dublin Core (PKP/OJS compatible metadata)
 */

open Atomic

/** Citation format types */
type citationFormat = [
  | #harvard
  | #oscola
  | #mla
  | #cahiersJournalisme
  | #dublinCore
  | #bibtex
  | #ris
]

/** Format creator name based on style */
let formatCreatorHarvard = (creator: creator): string => {
  switch creator.firstName {
  | Some(first) => `${creator.lastName}, ${Js.String2.charAt(first, 0)}.`
  | None => creator.lastName
  }
}

let formatCreatorMLA = (creator: creator): string => {
  switch creator.firstName {
  | Some(first) => `${creator.lastName}, ${first}`
  | None => creator.lastName
  }
}

let formatCreatorOSCOLA = (creator: creator): string => {
  switch creator.firstName {
  | Some(first) => `${Js.String2.charAt(first, 0)} ${creator.lastName}`
  | None => creator.lastName
  }
}

/** Get primary authors string */
let getAuthorsString = (creators: array<creator>, format: citationFormat): string => {
  let authors = creators->Js.Array2.filter(c => c.creatorType == #author)

  if Js.Array2.length(authors) == 0 {
    "Unknown"
  } else {
    let formatter = switch format {
    | #harvard | #cahiersJournalisme => formatCreatorHarvard
    | #mla => formatCreatorMLA
    | #oscola => formatCreatorOSCOLA
    | _ => formatCreatorHarvard
    }

    if Js.Array2.length(authors) == 1 {
      formatter(authors[0])
    } else if Js.Array2.length(authors) == 2 {
      `${formatter(authors[0])} and ${formatter(authors[1])}`
    } else {
      `${formatter(authors[0])} et al.`
    }
  }
}

/** Extract year from date string */
let getYear = (date: option<string>): string => {
  switch date {
  | None => "n.d."
  | Some(d) => Js.String2.slice(d, ~from=0, ~to_=4)
  }
}

/** Format citation in Harvard style */
let toHarvard = (citation: atomicCitation): string => {
  let authors = getAuthorsString(citation.creators, #harvard)
  let year = getYear(citation.date)
  let title = citation.title

  switch citation.itemType {
  | #book => {
      let publisher = citation.publisher->Belt.Option.getWithDefault("Publisher")
      let place = citation.place->Belt.Option.getWithDefault("")
      `${authors} (${year}) _${title}_. ${place}: ${publisher}.`
    }
  | #journalArticle => {
      let journal = citation.publicationTitle->Belt.Option.getWithDefault("Journal")
      let vol = citation.volume->Belt.Option.getWithDefault("")
      let pages = citation.pages->Belt.Option.getWithDefault("")
      `${authors} (${year}) '${title}', _${journal}_, ${vol}, pp. ${pages}.`
    }
  | _ => `${authors} (${year}) '${title}'.`
  }
}

/** Format citation in OSCOLA style (legal) */
let toOSCOLA = (citation: atomicCitation): string => {
  let authors = getAuthorsString(citation.creators, #oscola)
  let title = citation.title
  let year = getYear(citation.date)

  switch citation.itemType {
  | #book => {
      let publisher = citation.publisher->Belt.Option.getWithDefault("Publisher")
      `${authors}, _${title}_ (${publisher} ${year})`
    }
  | #journalArticle => {
      let journal = citation.publicationTitle->Belt.Option.getWithDefault("Journal")
      let vol = citation.volume->Belt.Option.getWithDefault("")
      let pages = citation.pages->Belt.Option.getWithDefault("")
      `${authors}, '${title}' (${year}) ${vol} ${journal} ${pages}`
    }
  | _ => `${authors}, '${title}' (${year})`
  }
}

/** Format citation in MLA style */
let toMLA = (citation: atomicCitation): string => {
  let authors = getAuthorsString(citation.creators, #mla)
  let title = citation.title
  let year = getYear(citation.date)

  switch citation.itemType {
  | #book => {
      let publisher = citation.publisher->Belt.Option.getWithDefault("Publisher")
      `${authors}. _${title}_. ${publisher}, ${year}.`
    }
  | #journalArticle => {
      let journal = citation.publicationTitle->Belt.Option.getWithDefault("Journal")
      let vol = citation.volume->Belt.Option.getWithDefault("")
      let issue = citation.issue->Belt.Option.getWithDefault("")
      let pages = citation.pages->Belt.Option.getWithDefault("")
      `${authors}. "${title}." _${journal}_, vol. ${vol}, no. ${issue}, ${year}, pp. ${pages}.`
    }
  | _ => `${authors}. "${title}." ${year}.`
  }
}

/** Format for Cahiers de Journalisme (French journalism studies) */
let toCahiersJournalisme = (citation: atomicCitation): string => {
  let authors = getAuthorsString(citation.creators, #cahiersJournalisme)
  let title = citation.title
  let year = getYear(citation.date)

  switch citation.itemType {
  | #book => {
      let publisher = citation.publisher->Belt.Option.getWithDefault("Éditeur")
      let place = citation.place->Belt.Option.getWithDefault("")
      `${authors} (${year}), _${title}_, ${place}, ${publisher}.`
    }
  | #journalArticle => {
      let journal = citation.publicationTitle->Belt.Option.getWithDefault("Revue")
      let vol = citation.volume->Belt.Option.getWithDefault("")
      let pages = citation.pages->Belt.Option.getWithDefault("")
      `${authors} (${year}), « ${title} », _${journal}_, n° ${vol}, p. ${pages}.`
    }
  | _ => `${authors} (${year}), « ${title} ».`
  }
}

/** Export to Dublin Core XML (PKP/OJS compatible) */
let toDublinCoreXML = (citation: atomicCitation): string => {
  let authors = citation.creators
    ->Js.Array2.filter(c => c.creatorType == #author)
    ->Js.Array2.map(c => {
      switch c.firstName {
      | Some(first) => `    <dc:creator>${first} ${c.lastName}</dc:creator>`
      | None => `    <dc:creator>${c.lastName}</dc:creator>`
      }
    })
    ->Js.Array2.joinWith("\n")

  let year = getYear(citation.date)

  let identifier = switch citation.doi {
  | Some(doi) => `    <dc:identifier>doi:${doi}</dc:identifier>`
  | None => switch citation.isbn {
    | Some(isbn) => `    <dc:identifier>isbn:${isbn}</dc:identifier>`
    | None => `    <dc:identifier>${citation.id}</dc:identifier>`
    }
  }

  `<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/"
          xmlns:dcterms="http://purl.org/dc/terms/">
    <dc:title>${citation.title}</dc:title>
${authors}
    <dc:date>${year}</dc:date>
    <dc:type>${(citation.itemType :> string)}</dc:type>
${identifier}
    <dc:rights>See original source</dc:rights>
</metadata>`
}

/** Export to Dublin Core JSON (PKP API compatible) */
let toDublinCoreJSON = (citation: atomicCitation): string => {
  let authors = citation.creators
    ->Js.Array2.filter(c => c.creatorType == #author)
    ->Js.Array2.map(c => {
      switch c.firstName {
      | Some(first) => `"${first} ${c.lastName}"`
      | None => `"${c.lastName}"`
      }
    })
    ->Js.Array2.joinWith(", ")

  let year = getYear(citation.date)

  `{
  "dc:title": "${citation.title}",
  "dc:creator": [${authors}],
  "dc:date": "${year}",
  "dc:type": "${(citation.itemType :> string)}",
  "dc:identifier": "${citation.doi->Belt.Option.getWithDefault(citation.id)}",
  "dc:source": "${citation.publicationTitle->Belt.Option.getWithDefault("")}"
}`
}

/** Format citation to specified style */
let formatCitation = (citation: atomicCitation, format: citationFormat): string => {
  switch format {
  | #harvard => toHarvard(citation)
  | #oscola => toOSCOLA(citation)
  | #mla => toMLA(citation)
  | #cahiersJournalisme => toCahiersJournalisme(citation)
  | #dublinCore => toDublinCoreJSON(citation)
  | #bibtex => toBibtex(citation)
  | #ris => toRIS(citation)
  }
}

/** Export to BibTeX */
and toBibtex = (citation: atomicCitation): string => {
  let entryType = switch citation.itemType {
  | #book => "book"
  | #journalArticle => "article"
  | #conferencePaper => "inproceedings"
  | #thesis => "phdthesis"
  | _ => "misc"
  }

  let key = citation.id->Js.String2.slice(~from=0, ~to_=8)
  let authors = citation.creators
    ->Js.Array2.filter(c => c.creatorType == #author)
    ->Js.Array2.map(c => {
      switch c.firstName {
      | Some(first) => `${c.lastName}, ${first}`
      | None => c.lastName
      }
    })
    ->Js.Array2.joinWith(" and ")

  `@${entryType}{${key},
  author = {${authors}},
  title = {${citation.title}},
  year = {${getYear(citation.date)}},
  publisher = {${citation.publisher->Belt.Option.getWithDefault("")}},
  journal = {${citation.publicationTitle->Belt.Option.getWithDefault("")}},
  doi = {${citation.doi->Belt.Option.getWithDefault("")}}
}`
}

/** Export to RIS format */
and toRIS = (citation: atomicCitation): string => {
  let risType = switch citation.itemType {
  | #book => "BOOK"
  | #journalArticle => "JOUR"
  | #conferencePaper => "CONF"
  | #thesis => "THES"
  | _ => "GEN"
  }

  let authors = citation.creators
    ->Js.Array2.filter(c => c.creatorType == #author)
    ->Js.Array2.map(c => {
      switch c.firstName {
      | Some(first) => `AU  - ${c.lastName}, ${first}`
      | None => `AU  - ${c.lastName}`
      }
    })
    ->Js.Array2.joinWith("\n")

  `TY  - ${risType}
${authors}
TI  - ${citation.title}
PY  - ${getYear(citation.date)}
PB  - ${citation.publisher->Belt.Option.getWithDefault("")}
JO  - ${citation.publicationTitle->Belt.Option.getWithDefault("")}
DO  - ${citation.doi->Belt.Option.getWithDefault("")}
ER  -`
}

/** Generate shareable reference block (HTML) */
let toShareBlock = (citation: atomicCitation): string => {
  let harvard = toHarvard(citation)
  let oscola = toOSCOLA(citation)
  let mla = toMLA(citation)

  `<div class="citation-share-block" itemscope itemtype="https://schema.org/CreativeWork">
  <meta itemprop="name" content="${citation.title}">
  <meta itemprop="datePublished" content="${getYear(citation.date)}">

  <h4>Cite this work:</h4>

  <details>
    <summary>Harvard</summary>
    <pre>${harvard}</pre>
  </details>

  <details>
    <summary>OSCOLA (Legal)</summary>
    <pre>${oscola}</pre>
  </details>

  <details>
    <summary>MLA</summary>
    <pre>${mla}</pre>
  </details>

  <details>
    <summary>BibTeX</summary>
    <pre>${toBibtex(citation)}</pre>
  </details>
</div>`
}
