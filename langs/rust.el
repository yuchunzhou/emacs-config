;;-*- lexical-binding: t; -*-

;; rustup component add rust-analyzer && cp `rustup which rust-analyzer` ~/.cargo/bin

(use-package rustic
  :init
  (advice-add 'rust-toggle-mutability :around #'buffer-save-2)
  :bind
  (:map rustic-mode-map
	("C-c b" . rustic-cargo-build)
	("C-c c" . rustic-cargo-check)
	("C-c m" . rust-toggle-mutability)
	("C-c r" . rustic-cargo-run)
	("C-c t c" . rustic-cargo-current-test)
	("C-c t a" . rustic-cargo-test)
	("M-\\" . (lambda ()
		    (interactive)
		    (save-buffer)
		    (if (region-active-p)
			(progn
			  (rustic-format-region (region-beginning) (region-end))
			  (set-process-sentinel (get-process rustic-format-process-name)
						#'(lambda (proc output)
						    (rustic-format-file-sentinel proc output)
						    (save-buffer))))
		      (progn
			(rustic-format-buffer)
			(set-process-sentinel (get-process rustic-format-process-name)
					      #'(lambda (proc output)
						  (rustic-format-sentinel proc output)
						  (save-buffer))))))))
  :hook
  (rustic-mode . lsp-deferred))

(provide 'rust)
