;;-*- lexical-binding: t; -*-

;; 1.install haskell with ghcup: https://www.haskell.org/ghcup/
;; 2.stack install hindent

(use-package haskell-mode
  :init
  (advice-add 'hindent-reformat-region :around #'buffer-save-2)
  (advice-add 'hindent-reformat-buffer :around #'buffer-save-2)
  :hook
  ((haskell-mode . lsp-deferred)
   (haskell-literate-mode . lsp-deferred))
  :bind
  (:map haskell-mode-map
	("C-c b" . haskell-compile)
	("M-\\" . (lambda ()
		    (interactive)
		    (if (region-active-p)
			(hindent-reformat-region (region-beginning) (region-end))
		      (hindent-reformat-buffer)))))
  :config
  (use-package hindent)
  (use-package lsp-haskell)
  (use-package haskell-snippets))

(provide 'haskell)
