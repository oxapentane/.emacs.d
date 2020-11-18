;;; init.el --- emacs configuration  -*- lexical-binding: t; -*-
;;; Commentary:
;;; M-x 🦋
;;; Code:
;; bug in emacs<26.3
(if (version< emacs-version "26.3")
    (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3"))

;; package management with straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Use use-package for sugar, but use straight.el under the hood
(straight-use-package 'use-package)
(require 'use-package)

(menu-bar-mode 1) ; menu-bar is underrated
(tool-bar-mode -1)
(toggle-scroll-bar 1)
(global-display-line-numbers-mode)
(column-number-mode 1)
(setq inhibit-startup-screen t)
(setq auto-save-default nil)
(setq visible-bell t)

;; declutter modeline with diminish
(straight-use-package 'diminish)

;; magic in the world of idiotic defaults...
(fset 'yes-or-no-p 'y-or-n-p)
(setq confirm-nonexistent-file-or-buffer nil)

;; readline prevails
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)

(defadvice term-handle-exit
    (after term-kill-buffer-on-exit activate)
  "Advice term to kill buffer after shell exits."
  (kill-buffer))

(defun my-whitespace-hook ()
  "Hook to show trailing whitespace and empty lines."
  (setq show-trailing-whitespace t
        indicate-empty-lines t))
(add-hook 'prog-mode-hook #'my-whitespace-hook)
(add-hook 'text-mode-hook #'my-whitespace-hook)

;; let's try to fix the pile of burning garbage that emacs calls a
;; tab. If anyone reading actually knows why mixing tabs and spaces or
;; deleting the tab one space at a time is a good idea, please drop me
;; an email. I want to know.
(require 'whitespace)
(setq whitespace-style '(face tabs tab-mark))
(setq whitespace-display-mappings
      '((tab-mark 9 [187 9] [92 9])))
(add-hook 'prog-mode-hook #'whitespace-mode)
(diminish 'whitespace-mode)

;; let's delete a tab as a whole...
(setq backward-delete-char-untabify-method 'nil)

;; smarttabs!
(straight-use-package 'smart-tabs-mode)
(smart-tabs-insinuate 'c 'c++)

;; radical way to fix emacs mixing tabs and spaces
(setq-default indent-tabs-mode nil)

;;helper functions to switch tab expansion on and off
(defun tabs-yay ()
  "Function to enable tab indentation in buffer."
  ;;(local-set-key (kbd "TAB") 'tab-to-tab-stop)
  (setq indent-tabs-mode t))
(defun tabs-nay ()
  "Function to enable space indentation in buffer."
  (setq indent-tabs-mode nil))

;; wasteland of hooks regarding tabs behavior Remember how it "Just
;; worked"™ in vim? That's what you pay with for org mode
(add-hook 'cc-mode-hook 'tabs-yay)

;; pdftools ftw, docview is shit that needs to be left in the past
(require 'pdf-tools)
(pdf-loader-install)

;; highlight the parens
(setq show-paren-delay 0)
(show-paren-mode 1)

;; follow symlinks to version-controlled files
(setq vc-follow-symlinks t)

;; mac-emacs spooky path shit
(when (eq system-type 'darwin)
  (use-package exec-path-from-shell
    :straight t
    :config
    (exec-path-from-shell-initialize)))

;; backup management
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; color theme
(set-face-italic 'font-lock-comment-face t)
(set-face-italic 'font-lock-comment-delimiter-face nil)

;; CC mode default styles
(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (c-mode . "linux")
                        (c++-mode . "stroustrup")
                        (other . "linux")))

;; swiper for search
(straight-use-package 'swiper)
(global-set-key "\C-s" 'swiper)
;; ivy for completion
(straight-use-package 'ivy)
(ivy-mode 1)
(diminish 'ivy-mode)

;; ignore substring order, except for swiper
(setq ivy-re-builders-alist
      '((swiper . ivy--regex-plus)
        (t      . ivy--regex-ignore-order)))
;; do not use caret, quite often we want start typing from the middle
(eval-after-load 'counsel ;counsel modifies this var
  (setq ivy-initial-inputs-alist nil))

;; counsel for ivy-powered alternatives
(straight-use-package 'counsel)
(counsel-mode 1)
(diminish 'counsel-mode)

;; completion by default - welcome to 2020
(straight-use-package 'company)
(straight-use-package 'company-auctex)
(add-hook 'after-init-hook 'global-company-mode)
(diminish 'company-mode)

;; healthy people weeks are starting on Monday
(use-package calendar
  :init (setq calendar-week-start-day 1))

(use-package tex-site
  :defer t
  :mode ("\\.tex\\'" . latex-mode)
  :straight auctex
  :config
  (setq TeX-parse-self t)
  ;; completion for LaTeX
  (use-package company-auctex
    :config
    (company-auctex-init)))

(use-package latex-preview-pane
  :straight t)

(use-package rainbow-delimiters
  :straight t
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (lisp-mode . rainbow-delimiters-mode)
         (scheme-mode . rainbow-delimiters-mode)
         (cc-mode . rainbow-delimiters-mode)))

(use-package org
  :straight org-plus-contrib
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link)
         :map org-mode-map
         ("C-c 1" . org-time-stamp-inactive))
  :init
  ;; we need indentation
  (setq org-startup-indented t
        org-startup-folded 'content)
  ;; default agenda files
  (setq org-agenda-files '("~/nextcloud/org/"
                           "~/nextcloud/org/phone/"
                           "~/Seafile/ORG/"))
  ;; templates
  (setq org-capture-templates
        '(("t" "TODO" entry
           (file+headline "~/nextcloud/org/inbox.org" "tasks-inbox")
           "** TODO %?\n %i")
          ("T" "TODO+file" entry
           (file+headline "~/nextcloud/org/inbox.org" "tasks-inbox")
           "** TODO %?\n %i\n %a")
          ("n" "note" entry
           (file+headline "~/nextcloud/org/inbox.org" "Notes")
           "** %U\n%?\n")
          ("i" "IFW TODO" entry
           (file+headline "~/Seafile/ORG/ifw.org" "Tasks")
           "** TODO %?\n %i \n%U")
          ("j" "Journal" entry
           (file+datetree "~/nextcloud/org/log.org.gpg")
           "**** %U %?\n")
          ("b" "Bookmark" entry
           (file+headline "~/nextcloud/org/inbox.org" "bookmarks-inbox")
           "** TODO [[%x]]%?\n:PROPERTIES:\n:CREATED: %U\n:END:\n[[%x]]\n")))
  ;; autosave advises for agenda and org-capture
  (advice-add 'org-agenda-quit :before 'org-save-all-org-buffers)
  (advice-add 'org-capture-finalize :after 'org-save-all-org-buffers)

  ;; refile everywhere where agenda lives
  (setq org-refile-targets
        '((nil :maxlevel . 1)
          (org-agenda-files :maxlevel . 1)))
  ;; babel stuff
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (dot . t)
     (emacs-lisp .t)
     (python . t)
     (scheme . t)))
  ;; latex preview settings
  (add-to-list 'org-latex-packages-alist '("" "braket" t)) ; Dirac brakets
  (setq org-preview-latex-image-directory "~/.emacs.d/org-latex-preview/") ; Hide all previews in one place
  :config
  ;; abbrev expansion in org-mode
  (require 'org-tempo))

(use-package org-roam
  :straight t
  :hook ('after-init-hook . 'org-roam-mode)
  :init (setq org-roam-directory "~/nextcloud/org/roam"
              org-roam-db-update-method 'immediate))

(use-package magit
  :straight t
  :bind (("C-x C-g" . magit-dispatch)
         ("C-x g" . magit-status)))

(use-package undo-tree
  :straight t
  :diminish
  :config
  (global-undo-tree-mode 1))

;; I positively cannot spell :D
(use-package ispell
  :config
  (setq-default ispell-program-name "hunspell")
  (setq ispell-dictionary "en_US,de_DE,ru_RU")
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "en_US,de_DE,ru_RU"))

(use-package flyspell
  :straight t
  :hook (('text-mode . (lambda () (flyspell-mode 1)))
         ('change-log-mode . (lambda () (flyspell-mode -1)))
         ('log-edit-mode . (lambda () (flyspell-mode -1)))
         ('prog-mode . 'flyspell-prog-mode)))

(use-package comment-tags
  :straight t
  :hook (('prog-mode . 'comment-tags-mode)
         ('markdown-mode . 'comment-tags-mode)
         ('tex-mode . 'comment-tags-mode))
  :init
  (setq comment-tags-require-colon 0))

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer))

(use-package expand-region
  :straight t
  :bind ("C-=" . er/expand-region))

(use-package vterm
  :bind ("C-c t" . vterm)
  :init
  (setq vterm-kill-buffer-on-exit t))

(use-package geiser
  :straight t
  :init
  (setq geiser-active-implementations '(racket)))

(use-package flycheck
  :straight t
  :init (global-flycheck-mode))

(use-package nix-mode
  :straight t
  :mode "\\.nix\\'")

(use-package markdown-mode
  :straight t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(use-package direnv
  :straight t
  :config
  (direnv-mode))

(use-package which-key
  :straight t
  :diminish
  :config
  (which-key-mode))

;; throw away all the list-of-custom-shit!
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

(provide 'init)
;;; init.el ends here
