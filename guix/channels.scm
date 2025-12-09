;; Guix Channel for NSAI
;; Add to ~/.config/guix/channels.scm:
;;
;; (cons* (channel
;;          (name 'hyperpolymath)
;;          (url "https://github.com/hyperpolymath/guix-channel")
;;          (branch "main"))
;;        %default-channels)

(define-module (hyperpolymath nsai)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system deno)
  #:use-module (gnu packages)
  #:use-module ((guix licenses) #:prefix license:))

(define-public nsai
  (package
    (name "nsai")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/Hyperpolymath/zotero-nsai")
             (commit (string-append "v" version))))
       (sha256
        (base32 "0000000000000000000000000000000000000000000000000000"))))
    (build-system deno-build-system)
    (arguments
     '(#:phases
       (modify-phases %standard-phases
         (add-before 'build 'compile-rescript
           (lambda _
             (invoke "rescript" "build"))))))
    (home-page "https://github.com/Hyperpolymath/zotero-nsai")
    (synopsis "Neurosymbolic Research Validator for Zotero")
    (description
     "NSAI validates research citations using Tractarian logical analysis,
providing certainty scoring and Fogbinder integration for uncertainty
navigation.")
    (license license:agpl3+)))
