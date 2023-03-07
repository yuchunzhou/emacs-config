;;-*- lexical-binding: t; -*-

;; 1.install clangd bear and clang-format with system package manager
;; 2.generate Makefile with PyMake: https://github.com/Melinysh/PyMake

(use-package cc-mode
  :init
  (advice-add 'clang-format-region :around #'buffer-save-2)
  (advice-add 'clang-format-buffer :around #'buffer-save-2)
  :hook
  (c-mode . (lambda ()
	      (setq-local compile-command "bear -- make")
	      (lsp-deferred)))
  :bind
  (:map c-mode-map
	("C-c b" . compile)
	("M-\\" . (lambda ()
		    (interactive)
		    (if (region-active-p)
			(clang-format-region (region-beginning) (region-end))
		      (clang-format-buffer)))))
  :config
  (use-package clang-format))

(provide 'c)
