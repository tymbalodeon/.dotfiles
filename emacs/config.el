;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Ben Rosen"
      user-mail-address "benjamin.j.rosen@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;; (setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(defvar tymbalodeon--desktop-p nil)

(setq org-directory "~/Dropbox/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(defun tymbalodeon--directory-exists-and-not-empty-p (directory)
  (and (file-directory-p directory)
       (not (directory-empty-p directory))))

;; ChucK
(let ((chuck-el-files "~/dev/chuck-mode"))
  (when (tymbalodeon--directory-exists-and-not-empty-p chuck-el-files)
    (add-load-path! chuck-el-files)
    (use-package! chuck-mode
      :config (add-hook! 'chuck-mode-hook
                (display-line-numbers-mode)
                (vi-tilde-fringe-mode)))))

;; Circadian
(use-package! circadian
  :config
  (setq calendar-latitude 39.952583)
  (setq calendar-longitude -75.165222)
  (setq circadian-themes
        '((:sunrise . doom-gruvbox)
          (:sunset  . doom-gruvbox-dark-variant)))
  (circadian-setup))

;; Dired
(require 'ls-lisp)
(setq ls-lisp-use-insert-directory-program nil)
(setq ls-lisp-ignore-case t)
(setq ls-lisp-use-string-collate nil)
(setq ls-lisp-dirs-first t)

;; EdgeDB
(let ((esdl-el-files "~/dev/esdl-mode/"))
  (when (tymbalodeon--directory-exists-and-not-empty-p esdl-el-files)
    (add-load-path! esdl-el-files)
    (dolist (file '("esdl-mode.el"))
      (let ((filepath (concat esdl-el-files file)))
        (when (file-exists-p filepath)
          (load file))))))
(add-to-list 'auto-mode-alist '("\\.edgeql\\'" . esdl-mode))

;; LilyPond
(let ((lilypond-el-files
       (concat (string-replace
                "bin/lilypond\n"
                ""
                (shell-command-to-string "which lilypond"))
               "share/emacs/site-lisp")))
  (when (tymbalodeon--directory-exists-and-not-empty-p lilypond-el-files)
    (add-load-path! lilypond-el-files)
    (autoload 'LilyPond-mode "lilypond-mode" "LilyPond Editing Mode" t)
    (add-to-list 'auto-mode-alist '("\\.ly$" . LilyPond-mode))
    (add-to-list 'auto-mode-alist '("\\.ily$" . LilyPond-mode))
    (add-hook! 'LilyPond-mode-hook
      (turn-on-font-lock)
      (display-line-numbers-mode))))
(set-formatter! 'ly-format '("ly" "reformat") :modes '(LilyPond-mode))

;; LSP
(setq lsp-ui-doc-enable nil)
(setq lsp-enable-file-watchers nil)

;; Markdown
(add-to-list 'auto-mode-alist '("\\.mdx$" . markdown-mode))

;; Messages
(defun tymbalodeon--tail-message (&rest _)
  "Make *Messages* buffer auto-scroll to the end after each message."
  (let* ((name "*Messages*")
         (buffer (get-buffer-create name)))
    (when (not (string= name (buffer-name)))
      (dolist (window (get-buffer-window-list name nil :all-frames))
        (with-selected-window window
          (goto-char (point-max))))
      (with-current-buffer buffer
        (goto-char (point-max))))))

(advice-add 'message :after #'tymbalodeon--tail-message)

;; Multicursor
(map! :leader
      "d" #'evil-multiedit-match-and-next
      "D" #'evil-multiedit-match-and-prev)

;; Org
(defun tymbalodeon--expand-as-org-directory-file (path)
  (concat (file-name-as-directory org-directory)
          path
          ".org"))

(defun tymbalodeon--expand-as-org-directory-files (paths)
  (mapcar #'tymbalodeon--expand-as-org-directory-file paths))

(after! org
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"
           "INPROGRESS(i)"
           "WAITING(w)"
           "NEXT(n)"
           "|"
           "DONE(d)"
           "CANCELLED(c)")))
  (setq org-startup-folded t)
  (when (display-graphic-p)
    (setq org-hide-emphasis-markers t))
  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file-other-window)
  (setq org-archive-location "../org-archive/%s_archive::datetree/")
  (setq org-agenda-files
        (tymbalodeon--expand-as-org-directory-files
         '("computer-science"
           "jobs"
           "music"
           "personal"
           "projects"
           "reminders"
           "work")))
  (setq org-refile-targets
        (append org-refile-targets
                `((,(tymbalodeon--expand-as-org-directory-file "backlog")
                   :maxlevel . 3))))
  (setq org-super-agenda-groups
        '((:name "Today"
           :time-grid t
           :scheduled today
           (:name "Due today"
            :deadline today)
           (:name "Important"
            :priority "A")
           (:name "Overdue"
            :deadline past)
           (:name "Due soon"
            :deadline future)))))

(after! org-capture
  (setq org-capture-templates
        '(("c" "Computer Science"
           entry
           (file (lambda ()
                   (tymbalodeon--expand-as-org-directory-file "computer-science")))
           "* TODO %i%?\n"
           :kill-buffer t)
          ("d" "Dev Projects"
           entry
           (file (lambda ()
                   (tymbalodeon--expand-as-org-directory-file "projects")))
           "* TODO %i%?\n"
           :kill-buffer t)
          ("j" "Jobs"
           entry
           (file (lambda ()
                   (tymbalodeon--expand-as-org-directory-file "jobs")))
           "* TODO %i%?\n"
           :kill-buffer t)
          ("m" "Music"
           entry
           (file (lambda ()
                   (tymbalodeon--expand-as-org-directory-file "music")))
           "* TODO %i%?\n"
           :kill-buffer t)
          ("p" "Personal"
           entry
           (file (lambda ()
                   (tymbalodeon--expand-as-org-directory-file "personal")))
           "* TODO %i%?\n"
           :kill-buffer t)
          ("r" "Reminders"
           entry
           (file (lambda ()
                   (tymbalodeon--expand-as-org-directory-file "reminders")))
           "* %?\nSCHEDULED: <%(org-read-date t nil \"+1d\")>"
           :time-prompt t
           :kill-buffer t)
          ("w" "Work"
           entry
           (file (lambda ()
                   (tymbalodeon--expand-as-org-directory-file "work")))
           "* TODO %i%?\n"
           :kill-buffer t))))

(use-package! org-agenda
  :config
  (setq org-agenda-custom-commands
        (append org-agenda-custom-commands
                '(("c" "Computer Science" todo ""
                   ((org-agenda-overriding-header "Computer Science")
                    (org-agenda-files
                     (tymbalodeon--expand-as-org-directory-files '("computer-science")))))
                  ("d" "Dev Projects" todo ""
                   ((org-agenda-overriding-header "Dev Projects")
                    (org-agenda-files
                     (tymbalodeon--expand-as-org-directory-files '("projects")))))
                  ("j" "Jobs" todo ""
                   ((org-agenda-overriding-header "Jobs")
                    (org-agenda-files
                     (tymbalodeon--expand-as-org-directory-files '("jobs")))))
                  ("m" "Music" todo ""
                   ((org-agenda-overriding-header "Music")
                    (org-agenda-files
                     (tymbalodeon--expand-as-org-directory-files '("music")))))
                  ("p" "Personal" todo ""
                   ((org-agenda-overriding-header "Personal")
                    (org-agenda-files
                     (tymbalodeon--expand-as-org-directory-files '("personal")))))
                  ("w" "Work" todo ""
                   ((org-agenda-overriding-header "Work")
                    (org-agenda-files
                     (tymbalodeon--expand-as-org-directory-files '("work")))))))))

;; Persp
;; don't create new workspace when opening with emacsclient
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override "main"))

;; Registers
(map! :leader
      "r c" #'copy-to-register
      "r v" #'view-register
      "r f" #'frameset-to-register
      "r i" #'insert-register
      "r j" #'jump-to-register
      "r l" #'list-registers
      "r n" #'number-to-register
      "r r" #'counsel-register
      "r v" #'view-register
      "r w" #'window-configuration-to-register
      "r +" #'increment-register
      "r SPC" #'point-to-register)

;; Roam
(setq org-roam-directory
      (concat (file-name-as-directory org-directory) "roam"))

;; Scheme
(setq geiser-active-implementations '(guile))

;; Save
(defun tymbalodeon--before-save-hook ()
  "Auto-format sclang and elisp files."
  (when (eq major-mode 'sclang-mode)
    (untabify (point-min) (point-max))
    (indent-region (point-min) (point-max)))
  (when (eq major-mode 'emacs-lisp-mode)
    (format-all-buffer))
  (when (eq major-mode 'LilyPond-mode)
    (+format/region-or-buffer)))

(add-hook 'before-save-hook 'tymbalodeon--before-save-hook)

;; SQL
(setq sqlformat-command 'sqlfluff)
(setq sqlformat-args '("--dialect" "mysql"))
(add-hook 'sql-mode-hook 'sqlformat-on-save-mode)

;; SuperCollider
(let ((super-collider "/Applications/SuperCollider.app/Contents/MacOS")
      (scel "~/Library/Application Support/SuperCollider/downloaded-quarks/scel/el")
      (flucoma "~/dev/flucoma"))
  (when (and (tymbalodeon--directory-exists-and-not-empty-p super-collider)
             (tymbalodeon--directory-exists-and-not-empty-p scel))
    (setq exec-path
          (append exec-path '(super-collider)))
    (add-load-path! scel)
    (require 'sclang)
    (add-hook 'sclang-mode-hook 'display-line-numbers-mode)
    (custom-set-variables
     '(sclang-auto-scroll-post-buffer t)
     '(case-fold-search t)
     '(global-font-lock-mode t nil (font-lock))
     '(show-paren-mode t nil (paren))
     '(transient-mark-mode t)
     '(sclang-eval-line-forward nil))
    (when (tymbalodeon--directory-exists-and-not-empty-p flucoma)
      (add-load-path! flucoma)
      (require 'flucoma-sclang-indent))))

;;; Text
(add-hook! '(org-mode-hook markdown-mode-hook)
  (flycheck-mode -1)
  (auto-fill-mode))

;;; Typst
(use-package! typst-mode)

;; Zen
(add-hook! 'writeroom-mode-hook
  (when (eq major-mode 'org-mode)
    (display-line-numbers-mode (if writeroom-mode -1 +1))
    (variable-pitch-mode (if writeroom-mode +1 -1))
    (auto-fill-mode (if writeroom-mode +1 -1)))
  (setq visual-fill-column-width 112)
  (setq visual-fill-column-adjust-for-text-scale nil)
  (setq visual-fill-column-extra-text-width nil)
  (when (not tymbalodeon--desktop-p)
    (setq +zen-text-scale 1)))
