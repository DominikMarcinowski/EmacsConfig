;;; init.el -*- lexical-binding: t; -*-

(setq straight-base-dir (expand-file-name "var/" user-emacs-directory))
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" straight-base-dir))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory)

(straight-use-package '(setup :type git :host nil :repo "https://git.sr.ht/~pkal/setup"))
(require 'setup)

(defun dm/filter-straight-recipe (recipe)
  (let* ((plist (cdr recipe))
	 (name (plist-get plist :straight)))
    (cons (if (and name (not (equal name t)))
	      name
	    (car recipe))
	  (plist-put plist :straight nil))))

(setup-define :pkg
  (lambda (&rest recipe)
    `(straight-use-package ',(dm/filter-straight-recipe recipe)))
  :documentation "Install RECIPE via straight.el"
  :shorthand #'cadr)

(setup (:pkg no-littering)
  (setq create-lockfiles nil)
  (setq make-backup-files nil)
  (setq auto-save-default nil)
  (setq auto-save-file-name-transforms `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))
  (setq server-auth-dir (no-littering-expand-var-file-name "server/")))

(setup emacs
  ;; My Information
  (setq user-full-name "Dominik Marcinowski")
  (setq user-mail-address "dmarcinowski@zoho.com")
  ;; Clock settings
  (setq display-time-24hr-format t)
  (setq display-time-load-average -1)
  ;; Autorevert settings
  (setq auto-revert-verbose nil)
  (setq auto-revert-use-notify nil)
  (setq auto-revert-interval 3)
  (setq global-auto-revert-non-file-buffers t)
  ;; Other settins
  (setq custom-file (make-temp-file ""))
  (setq bite-compile-warnings '(not free-vars unresolved noroutine lexical make-local))
  (setq large-file-warning-threshold nil)
  (setq vc-follow-symlinks t)
  (setq ad-redefinition-action 'accept)
  (setq load-prefer-newer t)
  (setq mouse-wheel-progressive-speed nil)
  (setq fast-but-imprecise-scrolling nil)
  (setq custom-safe-themes t)
  (setq enable-local-variables :all)
  (setq jit-lock-defer-time 0)
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  (:global "<escape>" 'keyboard-escape-quit
	   "C-=" 'text-scale-increase
	   "C-+" 'text-scale-increase
	   "C--" 'text-scale-decrease)
  (defalias 'yes-or-no-p 'y-or-n-p)
  (add-hook 'after-init-hook #'electric-pair-mode)
  (add-hook 'after-init-hook #'electric-layout-mode)
  (add-hook 'after-init-hook #'global-auto-revert-mode)
  (add-hook 'after-init-hook #'global-subword-mode)
  (add-hook 'after-init-hook #'column-number-mode)
  (add-hook 'after-init-hook #'save-place-mode))

(setup recentf
  (setq recentf-max-saved-items 2048)
  (setq recentf-exclude '("/tmp/" "/ssh:" "/sudo:"
			  "/.emacs.d/etc/*" "/.emacs.d/var/*"
			  "/agenda/*" "/roam/*"
			  "recentf$"
			  "\\.mkv$" "\\.mp[34]$" "\\.avi$" "\\.pdf$" "\\.docx?$" "\\.xlsx?$"
			  "\\.sub$" "\\.srt$" "\\.ass$"))
  (run-at-time nil (* 5 60) #'recentf-save-list)
  (add-hook 'after-init-hook #'recentf-mode))

(setup dired
  (setq dired-listing-switches "-lah --group-directories-first"
	dired-recursive-copies 'always
	dired-recursive-deletes 'always
	dired-dwim-target t
	delete-by-moving-to-trash t))

(setq dm/font-monospace "Cascadia Code")
(setq dm/font-variable "Segoe UI")

(setup (:pkg undo-tree))
(setup (:pkg evil-collection))
(setup (:pkg evil-commentary))

(setup (:pkg evil)
  (setq undo-tree-auto-save-history t
	evil-undo-system 'undo-tree)
  (setq evil-want-C-u-scroll t
	evil-want-C-d-scroll t
	evil-want-C-i-jump nil
	evil-want-integration t
	evil-want-keybinding nil
	evil-split-window-below t
	evil-split-window-right t
	evil-respect-visual-line-mode 1)
  (setq evil-collection-outline-bind-tab-p t)

  (evil-mode)
  (global-undo-tree-mode)
  (evil-collection-init)
  (evil-commentary-mode)
  (setq evil-want-keybinding t))

(setup (:pkg general)
  (general-evil-setup)
  (general-create-definer dm/general-leader
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")
  (dm/general-leader
    "C-SPC" #'(execute-extended-command :wk "command")
    "SPC"   #'(execute-extended-command :wk "command")
    "."     #'(find-file :wk "find file")
    "h"     #'(:keymap help-map t :wk "help")
    "u"     #'(universal-argument :wk "universal prefix")
    "q"     #'(evil-quit :wk "quit")
    "Q"     #'(evil-quit-all :wk "quit all")
    "f"     #'(:ignore t :wk "file")
    "ff"    #'(find-file :wk "find file")
    "fd"    #'(dired-at-point :wk "dired at file")
    "fs"    #'(save-buffer :wk "save file")
    "fc"    #'(find-file "~/.emacs.d/" :wk "config")
    "b"     #'(:ignore t :wk "buffer")
    "bi"    #'(ibuffer-jump :wk "ibuffer")
    "bb"    #'(switch-to-buffer :wk "switch buffer")
    "bk"    #'(kill-this-buffer :wk "kill this buffer")
    "br"    #'(revert-buffer :wk "reload buffer")
    "c"     #'(:ignore t :wk "code")
    "s"     #'(:ignore t :wk "search")))

(setup (:pkg which-key)
  (setq which-key-idle-delay 0.3)
  (which-key-mode))

(setup (:pkg dashboard)
  (setq dashboard-center-content t
	dashboard-startup-banner (no-littering-expand-etc-file-name "dashboard/logo.png")
	;; dashboard-items '((projects . 10)
	;; 		  (recents  . 5)
	;; 		  (agenda   . 5))
	dashboard-banner-logo-title nil
	dashboard-set-footer nil
	dashboard-set-file-icons t
	dashboard-set-heading-icons t
	dashboard-set-navigator t
	dashboard-week-agenda t
	dashboard-filter-agenda-entry 'dashboard-filter-agenda-by-todo
	initial-buffer-choice (lambda () (get-buffer dashboard-buffer-name)))
  (dashboard-setup-startup-hook)
  (dashboard-modify-heading-icons '((recents . "file-text")
				    (bookmarks . "book"))))

;; (setup (:pkg solaire-mode))
(setup (:pkg rainbow-mode))
(setup (:pkg rainbow-delimiters))
(setup (:pkg hl-todo))
(setup (:pkg all-the-icons))
(setup (:pkg all-the-icons-dired))
(setup (:pkg all-the-icons-ibuffer))
(setup (:pkg all-the-icons-completion))
;; (setup (:pkg twilight-bright-theme))

(setup (:pkg doom-themes)
  (setq doom-themes-enable-bold t)
  (setq doom-themes-enable-italic t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(setup (:pkg doom-modeline)
  (setq doom-modeline-height 28)
  (setq doom-modeline-bar-width 6)
  (setq doom-modeline-hud nil)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-buffer-modification-icon t)
  (setq doom-modeline-buffer-state-icon t)
  (setq doom-modeline-indent-info t)
  (setq doom-modeline-minor-modes nil)
  (setq doom-modeline-buffer-file-name-style 'truncate-except-project)
  (add-hook 'after-init-hook #'size-indication-mode)
  (add-hook 'after-init-hook #'display-time-mode))

(defun dm/setup--font-faces nil
  "Sets basic font faces."
  (set-face-attribute 'default nil :font (font-spec :family dm/font-monospace :size 14 :weight 'regular))
  (set-face-attribute 'fixed-pitch nil :font (font-spec :family dm/font-monospace :size 14 :weight 'regular))
  (set-face-attribute 'variable-pitch nil :font (font-spec :family dm/font-variable :size 14 :weight 'regular))
  (set-fontset-font t 'unicode dm/font-monospace))

(defun dm/setup--utf8-encoding nil
  "Sets UTF-8 encoding everywhere."
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (set-file-name-coding-system 'utf-8)
  (set-clipboard-coding-system 'utf-8)
  (set-buffer-file-coding-system 'utf-8)
  (setq locale-coding-system 'utf-8)
  (setq coding-system-for-read 'utf-8)
  (setq coding-system-for-write 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix)))

(defun dm/setup-fonts nil
  (dm/setup--font-faces)
  (dm/setup--utf8-encoding))

(defun dm/set-theme (&optional dark-theme)
  "Set theme depending on system preferences."
  (interactive)
  ;; (load-theme 'modus-vivendi t)
  (or dark-theme (setq dark-theme nil))
  (if (or (= (w32-read-registry 'HKCU "Software/Microsoft/Windows/CurrentVersion/Themes/Personalize" "AppsUseLightTheme") 0)
	  dark-theme)
      (load-theme 'doom-one t)
    (load-theme 'doom-one-light t))
  (dm/setup-fonts))

(defun dm/setup-theme nil
  (doom-modeline-mode)
  (global-hl-todo-mode)
  ;; (solaire-global-mode 1)
  (all-the-icons-ibuffer-mode 1)
  (all-the-icons-completion-mode 1)
  (dm/set-theme))

(defun dm/setup-file-theme nil
  (rainbow-mode 1)
  (rainbow-delimiters-mode 1)
  (hl-todo-mode 1)
  (display-line-numbers-mode 1))

(add-hook 'after-init-hook #'dm/setup-theme)
(add-hook 'server-after-make-frame-hook #'dm/setup-theme)
(add-hook 'prog-mode-hook #'dm/setup-file-theme)
(add-hook 'text-mode-hook #'dm/setup-file-theme)
(add-hook 'conf-mode-hook #'dm/setup-file-theme)
(add-hook 'dired-mode-hook #'all-the-icons-dired-mode)

(setup (:pkg vertico)
  (setq vertico-cycle t)
  (setq vertico-resize nil)
  (setq vertico-sort-function 'vertico-sort-history-alpha)
  (setq vertico-count-format '("%-6s " . "(%s/%s)"))
  (setq vertico-count 15)
  (add-hook 'after-init-hook #'vertico-mode))

(setup (:pkg save-history)
  (add-hook 'vertico-mode-hook #'savehist-mode))

(setup (:pkg marginalia)
  (add-hook 'vertico-mode-hook #'marginalia-mode))

(setup (:pkg orderless)
  (setq completion-styles '(orderless))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file) (styles partial-completion))))
