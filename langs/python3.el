;;-*- lexical-binding: t; -*-

;; pip3 install jedi-language-server isort black black-macchiato autoflake

(use-package python-mode
  :straight
  (:host nil :type git :repo "https://gitlab.com/python-mode-devs/python-mode/")
  :init
  (defun python-remove-unused-imports ()
    (interactive)
    (when (executable-find "autoflake")
      (progn
	(let ((output (shell-command-to-string (format "autoflake -i --remove-all-unused-imports %s" (buffer-file-name)))))
	  (unless (string-empty-p output)
	    (display-message-buffer "*autoflake*" output)))
	(revert-buffer t t t))))
  (advice-add 'python-remove-unused-imports :around #'buffer-save-2)
  (defun python-remove-unused-variables ()
    (interactive)
    (when (executable-find "autoflake")
      (progn
	(let ((output (shell-command-to-string (format "autoflake -i --remove-unused-variables %s" (buffer-file-name)))))
	  (unless (string-empty-p output)
	    (display-message-buffer "*autoflake*" output)))
	(revert-buffer t t t))))
  (advice-add 'python-remove-unused-variables :around #'buffer-save-2)
  (defun python-format ()
    (interactive)
    (let ((inhibit-message t))
      (if (region-active-p)
	  (progn
	    (py-isort-region)
	    (python-black-region (region-beginning) (region-end) t))
	(progn
	  (py-isort-buffer)
	  (python-black-buffer)))))
  (advice-add 'python-format :around #'buffer-save-2)
  :hook
  (python-mode . (lambda ()
		   (define-key python-mode-map (kbd "M-\\") 'python-format)
		   (with-eval-after-load "lsp-mode"
		     (add-to-list 'lsp-enabled-clients 'jedi))
		   (lsp-deferred)))
  :config
  (use-package lsp-jedi)
  (use-package py-isort)
  (use-package python-black))

(provide 'python3)
