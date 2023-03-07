;;-*- lexical-binding: t; -*-

;; install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent
	 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; install use-package
(straight-use-package 'use-package)

;; straight.el configuration
(use-package straight
  :custom
  (straight-use-package-by-default t)
  (straight-vc-git-default-protocol 'ssh))

;; hide welcome message
(customize-set-value 'inhibit-startup-screen t)

;; performance tuning
(setq read-process-output-max (* 1024 1024)
      gc-cons-threshold (* 100 1024 1024))

;; custom file
(customize-set-value 'custom-file (expand-file-name "custom.el" user-emacs-directory))

;; backup related configuration
(setq backup-directory (expand-file-name "backup" user-emacs-directory))
(custom-set-variables '(backup-directory-alist `((".*" . ,backup-directory)))
		      '(delete-old-versions t)
		      '(version-control t))

;; disable lockfiles function
(customize-set-value 'create-lockfiles nil)

;; electric modes
(electric-indent-mode)
(electric-layout-mode)
(electric-quote-mode)
(electric-pair-mode)

;; auto reverting buffers
(auto-revert-mode)

;; basic compilation configuration
(custom-set-variables '(compilation-ask-about-save nil)
		      '(compilation-scroll-output t))

;; close menu bar
(menu-bar-mode -1)

;; display line number
(global-display-line-numbers-mode)

;; highlight current line
(global-hl-line-mode)

;; display column number on modeline
(column-number-mode)

;; remember the last visited position of visited files
(save-place-mode)

;; ignore ring bell
(setq ring-bell-function 'ignore)

;; answer yes or no question with y or n
(customize-set-value 'use-short-answers t)

;; set the safe file local variables
(customize-set-value 'enable-local-variables :safe)

;; directly open the file that the symlink points to
(customize-set-value 'vc-follow-symlinks nil)

;; don’t confirm killing processes when exit
(customize-set-value 'confirm-kill-processes nil)

;; define some toolkit functions
(defun buffer-save-1 () (save-buffer))
(defun buffer-save-2 (orig-func &rest args) (save-buffer) (apply orig-func args) (save-buffer))
(defun display-message-buffer (buffer-name message)
  (let ((buffer (get-buffer-create buffer-name)))
    (with-current-buffer buffer
      (goto-char (point-max))
      (insert message))
    (display-buffer buffer)))

;; define some keybindings
(global-set-key (kbd "M-a") 'beginning-of-line-text)
(global-set-key (kbd "M-e") #'(lambda ()
				(interactive)
				(let* ((line (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
				       (clean-line (string-trim-right line)))
				  (goto-char (+ (line-beginning-position) (length clean-line))))))
(global-set-key (kbd "M-g") #'(lambda (line) (interactive "ngoto line: ") (goto-line line)))
(global-set-key (kbd "M-p") #'(lambda () (interactive) (message (buffer-file-name))))
(global-set-key (kbd "S-<up>") 'windmove-up)
(global-set-key (kbd "S-<down>") 'windmove-down)
(global-set-key (kbd "S-<left>") 'windmove-left)
(global-set-key (kbd "S-<right>") 'windmove-right)
(define-key emacs-lisp-mode-map (kbd "M-\\") #'(lambda ()
						 (interactive)
						 (save-buffer)
						 (if (region-active-p)
						     (indent-region (region-beginning) (region-end))
						   (indent-region (point-min) (point-max)))
						 (save-buffer)))
(define-key prog-mode-map (kbd "M-,") 'pop-global-mark)

;; eshell mode related configuration
(add-hook 'eshell-mode-hook #'(lambda () (global-hl-line-mode -1)))
(add-hook 'eshell-exit-hook 'global-hl-line-mode)

;; org mode related configuration
(use-package pangu-spacing :hook (org-mode . pangu-spacing-mode))

;; more configuration

(use-package doom-themes
  :init
  (setq python-shell-interpreter "python")
  :custom
  (doom-modeline-buffer-file-name-style 'relative-to-project)
  :config
  (use-package all-the-icons)
  (load-theme 'doom-molokai t)
  (doom-themes-neotree-config)
  (use-package doom-modeline)
  (doom-modeline-def-modeline 'my-modeline
    '(buffer-info buffer-position)
    '(buffer-encoding))
  (defun setup-custom-doom-modeline ()
    (doom-modeline-set-modeline 'my-modeline t))
  (add-hook 'doom-modeline-mode-hook 'setup-custom-doom-modeline)
  (advice-add 'doom-modeline-set-modeline :before-while #'(lambda (key &optional default)
							    (if (string-equal (symbol-name key) "my-modeline")
								t
							      nil)))
  (doom-modeline-mode))

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

(use-package super-save
  :custom
  (super-save-auto-save-when-idle t)
  (auto-save-default nil)
  :config
  (add-to-list 'super-save-triggers 'compile)
  (super-save-mode))

(use-package undo-tree
  :init
  (setq undo-tree-history-directory (expand-file-name "undo-tree-history" user-emacs-directory))
  :custom
  (undo-tree-history-directory-alist `(("." . ,undo-tree-history-directory)))
  :config
  (global-undo-tree-mode))

(use-package expand-region
  :custom-face
  (region ((t (:background "#666"))))
  :bind
  ("M-m" . er/expand-region)
  :hook
  (after-init . delete-selection-mode))

(use-package hungry-delete
  :custom
  (hungry-delete-join-reluctantly t)
  :config
  (global-hungry-delete-mode))

(use-package neotree
  :custom
  (neo-create-file-auto-open t)
  (neo-auto-indent-point t)
  (neo-smart-open t)
  (neo-show-hidden-files t)
  (neo-autorefresh t)
  (neo-window-fixed-size nil)
  (neo-theme 'arrow)
  (neo-mode-line-type 'none)
  :hook
  (neo-after-create . (lambda (arg) (display-line-numbers-mode -1)))
  :bind
  ("<f8>" . neotree-toggle))

(use-package helm
  :custom
  (enable-recursive-minibuffers t)
  (projectile-indexing-method 'alien)
  (helm-display-source-at-screen-top nil)
  (helm-display-header-line nil)
  (helm-split-window-inside-p t)
  (helm-move-to-line-cycle-in-source t)
  (helm-follow-mode-persistent t)
  (helm-mini-default-sources '(helm-source-buffers-list))
  (helm-follow-mode-persistent t)
  :bind
  (("C-f" . helm-projectile-find-file)
   ("C-p" . helm-projectile-rg)
   ("C-s" . helm-occur)
   ("C-x b" . helm-mini)
   ("M-x" . helm-M-x)
   :map helm-projectile-find-file-map
   ("<up>" . helm-follow-action-backward)
   ("<down>" . helm-follow-action-forward)
   ("<left>" . left-char)
   ("<right>" . right-char)
   :map helm-rg-map
   ("<up>" . helm-follow-action-backward)
   ("<down>" . helm-follow-action-forward)
   ("<left>" . left-char)
   ("<right>" . right-char)
   :map helm-occur-map
   ("<left>" . left-char)
   ("<right>" . right-char))
  :hook
  (after-init . projectile-mode)
  :config
  (use-package helm-rg)
  (use-package helm-projectile))

(use-package smart-comment
  :bind
  (:map prog-mode-map
	("C-\\" . (lambda (arg) (interactive "*P") (smart-comment arg) (next-line)))))

(use-package exec-path-from-shell
  :custom
  (exec-path-from-shell-arguments nil)
  :hook
  (prog-mode . exec-path-from-shell-initialize))

(use-package company
  :custom
  (company-tooltip-limit 10)
  (company-tooltip-align-annotations t)
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  (company-selection-wrap-around t)
  (company-global-modes '(not eshell-mode))
  :custom-face
  (company-tooltip-selection ((t (:background "#666"))))
  :config
  (global-company-mode))

(use-package lsp-mode
  :custom
  (lsp-modeline-code-actions-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-diagnostics-provider :none)
  (lsp-headerline-breadcrumb-icons-enable nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-lens-enable nil)
  (lsp-signature-render-documentation nil)
  (lsp-session-file (expand-file-name "lsp-session" user-emacs-directory))
  :bind
  (:map lsp-mode-map
	("C-c C-f" . lsp-find-references)
	("C-c C-h" . lsp-describe-thing-at-point)
	("C-c C-r" . lsp-rename)
	("M-." . lsp-find-definition)
	("M-;" . lsp-find-type-definition))
  :hook
  (lsp-mode . yas-minor-mode)
  :config
  (use-package yasnippet))

(add-to-list 'load-path (expand-file-name "langs" user-emacs-directory))

(require 'c)
(require 'python3)
(require 'nim)
(require 'go)
(require 'haskell)
(require 'rust)
