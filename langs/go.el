;;-*- lexical-binding: t; -*-

;; go install golang.org/x/tools/cmd/goimports@latest
;; go install github.com/fatih/gomodifytags@latest
;; go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
;; go install github.com/cweill/gotests/...@latest
;; go install golang.org/x/tools/gopls@latest

(use-package go-mode
  :init
  (advice-add 'gofmt :around #'buffer-save-2)
  (advice-add 'go-tag-add :around #'buffer-save-2)
  (advice-add 'go-tag-remove :around #'buffer-save-2)
  (advice-add 'go-test-current-test :before #'buffer-save-1)
  (advice-add 'go-test-current-file :before #'buffer-save-1)
  (advice-add 'go-test-current-project :before #'buffer-save-1)
  :custom
  (gofmt-command "goimports")
  (go-tag-args '("-transform" "camelcase"))
  :bind
  (:map go-mode-map
	("C-c b" . compile)
	("C-c t c" . go-test-current-test)
	("C-c t f" . go-test-current-file)
	("C-c t p" . go-test-current-project)
	("M-\\" . gofmt))
  :hook
  (go-mode . (lambda ()
	       (setq-local tab-width 4
			   compile-command "go build")
	       (lsp-deferred)))
  :config
  (use-package go-tag)
  (use-package go-fill-struct :straight (:host github :repo "yuchunzhou/go-fill-struct"))
  (use-package go-gen-test)
  (use-package gotest :straight (:host github :repo "nlamirault/gotest.el")))

(provide 'go)
