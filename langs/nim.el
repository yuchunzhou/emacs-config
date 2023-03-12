;;-*- lexical-binding: t; -*-

;; build nimlangserver from source: https://github.com/nim-lang/langserver

(use-package nim-mode
  :bind
  (:map nim-mode-map
	("C-c b" . nim-compile))
  :hook
  (nim-mode . lsp-deferred))

(provide 'nim)
