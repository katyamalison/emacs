;; -*- lexical-binding: t; -*-
;; =============================================================================
;;    ___ _ __ ___   __ _  ___ ___
;;   / _ \ '_ ` _ \ / _` |/ __/ __|
;;  |  __/ | | | | | (_| | (__\__ \
;; (_)___|_| |_| |_|\__,_|\___|___/ (actually init.el...)
;; =============================================================================
;;
;; katya malison
;;

(setq user-full-name
      (replace-regexp-in-string "\n$" "" (shell-command-to-string
                                          "git config --get user.name")))
(setq user-mail-address
      (replace-regexp-in-string "\n$" "" (shell-command-to-string
                                          "git config --get user.email")))

;; =============================================================================
;;                                                  general options and disables
;; =============================================================================

;; turn off mouse interface early in startup 
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(custom-set-variables
 '(inhibit-startup-screen t))

;; am i going to regret this? likely.
(setq backup-inhibited t)
(setq make-backup-files nil)
(setq auto-save-default nil)

;; mode line
(column-number-mode t)
(line-number-mode t)
(global-linum-mode t)

(show-paren-mode 1)
(setq visible-bell t)

(setq c-subword-mode t)
(global-subword-mode)


(setq-default major-mode 'text-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
;;(setq-default indent-tabs-mode nil)

(global-set-key "\C-x\C-b" 'buffer-menu)

;; =============================================================================
;;                                                                      packages
;; =============================================================================

(require 'package)

(setq package-archives nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; (add-to-list 'package-archives
;;              '("marmalade" . "http://marmalade-repo.org/packages/") t)
;; (add-to-list 'package-archives '("elpa" . "https://tromey.com/elpa/") t)
;; (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

(defun ensure-packages-installed (packages)
  (unless package-archive-contents
    (package-refresh-contents))
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         package
       (progn (message (format "installing package: %s." package))
              (package-install package))))
   packages))

(package-initialize)

(ensure-packages-installed '(epl use-package))

(use-package diminish)
(use-package bind-key)
(use-package server
  :config
  (progn
    (unless (server-running-p) (server-start))))
(use-package list-environment
  :ensure t)
(use-package paradox
  :config
  (progn
    (setq paradox-execute-asynchronously t)))
(use-package smartparens
  :config
  (progn
    (require 'smartparens-config)
    (smartparens-global-mode 1)
    (sp-use-smartparens-bindings)
    (unbind-key "C-<backspace>" smartparens-mode-map)
    (unbind-key "M-<backspace>" smartparens-mode-map)
    (bind-key "C-)" 'sp-forward-slurp-sexp smartparens-mode-map)
    (bind-key "C-}" 'sp-forward-barf-sexp smartparens-mode-map)
    (bind-key "C-(" 'sp-backward-slurp-sexp smartparens-mode-map)
    (bind-key "C-{" 'sp-backward-barf-sexp smartparens-mode-map)))

;; =============================================================================
;;                                                                        python
;; =============================================================================

(defvar use-python-tabs nil)

(defun python-tabs ()
  (setq tab-width 4 indent-tabs-mode t python-indent-offset 4))

(use-package jedi
  :commands (jedi:goto-definition jedi-mode)
  :config
  (progn
    (setq jedi:complete-on-dot t)
    (setq jedi:imenu-create-index-function 'jedi:create-flat-imenu-index))
  :bind (("M-." . jedi:goto-definition)
         ("M-," . jedi:goto-definition-pop-marker)))

(use-package python
  :commands python-mode
  :mode ("\\.py\\'" . python-mode)
  :config
  (progn
    (fset 'main "if __name__ == '__main__':")
    (fset 'sphinx-class ":class:`~")
  :init
  (progn
    (use-package pymacs :ensure t)
    (use-package sphinx-doc :ensure t)
    (defun kmalison:python-mode ()
      (setq show-trailing-whitespace t)
      (if use-python-tabs (python-tabs))
      (subword-mode t)
      (jedi:setup)
      (remove-hook 'completion-at-point-functions
                   'python-completion-complete-at-point 'local)))))

;; =============================================================================
;;                                                                     smalltalk
;; =============================================================================

 ;; This package is terrible! As is smalltalk, really. TODO: remove after 105
(setq auto-mode-alist
           (append  '(("\\.smt\\'" . smalltalk-mode))
                    auto-mode-alist))
(autoload 'smalltalk-mode "/usr/local/share/emacs/site-lisp/smalltalk-mode.el" "" t)

;; =============================================================================
;;                                                                     functions
;; =============================================================================

;; TODO: 


;; =============================================================================
;;                                                                    appearance
;; =============================================================================

(defvar packages-appearance
  '(monokai-theme solarized-theme zenburn-theme base16-theme molokai-theme
    tango-2-theme gotham-theme sublime-themes ansi-color rainbow-delimiters
    ample-theme material-theme zerodark-theme color-theme-modern))

(ensure-packages-installed packages-appearance)

(blink-cursor-mode -1)

;; make whitespace-mode use just basic coloring
(setq whitespace-style (quote (spaces tabs newline space-mark
                                      tab-mark newline-mark)))
(setq whitespace-display-mappings
      '((space-mark 32 [183] [46])
        (tab-mark 9 [9655 9] [92 9])))

(defun colorize-compilation-buffer ()
  (read-only-mode)
  (ansi-color-apply-on-region (point-min) (point-max))
  (read-only-mode))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(use-package window-number)

;; =============================================================================
;;                                                                        themes
;; =============================================================================

;; TODO: fix dark theme, orange is ugly but the rest of gotham is dope!
(defvar kmalison:light-theme 'solarized-light)
(defvar kmalison:dark-theme 'gotham)

(use-package theme-changer
  :config
  (progn
    (destructuring-bind (latitude longitude)
        (kmalison:get-lat-long)
      (setq calendar-latitude latitude)
      (setq calendar-longitude longitude))))

(defvar kmalison:linum-format)

(make-variable-buffer-local 'kmalison:linum-format)
(defun kmalison:linum-before-numbering-hook ()
  (setq kmalison:linum-format
        (concat "%" (number-to-string
                     (max (length (number-to-string
                                   (count-lines (point-min) (point-max))))
                          3)) "d")))

(defun kmalison:format-linum (line-text)
  (propertize (format kmalison:linum-format line-text) 'face 'linum))

(defun kmalison:remove-fringe-and-hl-line-mode (&rest stuff)
  (interactive)
  (if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
  (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
  (if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
  ;; (set-fringe-mode 0) ;; Lets reenable fringes. They seem useful
  (defvar linum-format 'kmalison:format-linum)
  (add-hook 'linum-before-numbering-hook 'kmalison:linum-before-numbering-hook)
  (setq left-margin-width 0)
  (defvar hl-line-mode nil))

(defun kmalison:appearance (&optional frame)
  (interactive)
  (message "calling set appearance")
  (if (display-graphic-p)
      (progn
        (set-face-attribute 'default nil :font "Source Code Pro")
        (set-face-attribute 'default nil :weight 'semi-bold)
        (set-face-attribute 'default nil :height 135))
    (progn
      (load-theme 'source-code-pro t)
      (message "not setting font")))
  (load-theme kmalison:light-theme t)
  (kmalison:remove-fringe-and-hl-line-mode)
  (message "finished set appearance"))

(add-hook 'after-init-hook 'kmalison:appearance)

