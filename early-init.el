;;; early-init.el -*- lexical-binding: t; -*-

(setq gc-cons-threshold most-positive-fixnum) ; 2^61 bytes
(setq gc-cons-percentage 0.6)

(defun dm/hook--after-startup-gc nil
  "Hook function which optimizes garbage collection after emacs initializes."
  (defvar dm/gc-cons-threshold 134217728) ; 128mb

  ;; Lower the garbage collection values.
  (setq gc-cons-threshold dm/gc-cons-threshold)
  (setq gc-cons-percentage 0.1)

  ;; Collect garbage after focus has changed.
  (if (boundp 'after-focus-change-function)
      (add-function :after after-focus-change-function
		    (lambda ()
		      (unless (frame-focus-state)
			(garbage-collect))))
    (add-hook 'after-focus-change-function #'garbage-collect))

  ;; Collect garbage in minibuffer.
  (defun gc-minibuffer-setup-hook nil
    (setq gc-cons-threshold (* dm/gc-cons-threshold 2)))
  (defun gc-minibuffer-exit-hook nil
    (garbage-collect)
    (setq gc-cons-threshold dm/gc-cons-threshold))
  (add-hook 'minibuffer-setup-hook #'gc-minibuffer-setup-hook)
  (add-hook 'minibuffer-exit-hook #'gc-minibuffer-exit-hook))

(add-hook 'emacs-startup-hook #'dm/hook--after-startup-gc)

(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun dm/hook--after-startup-file-name-alist nil
  (setq file-name-handler-alist default-file-name-handler-alist)
  (makunbound 'default-file-name-handler-alist))

(add-hook 'emacs-startup-hook #'dm/hook--after-startup-file-name-alist)

(setq inhibit-startup-message t)
(setq use-file-dialog nil)
(setq inhibit-compacting-font-caches t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(alpha . (100 . 100)))
(add-to-list 'default-frame-alist '(width . 200))
(add-to-list 'default-frame-alist '(height . 50))

(setq package-enable-at-startup nil)

(when (boundp 'native-comp-eln-load-path)
  (startup-redirect-eln-cache
   (expand-file-name "var/eln-cache/" user-emacs-directory)))

(setq native-comp-async-report-warnings-errors nil)

(setq native-comp-speed 2)
(setq native-comp-deferred-compilation t)
