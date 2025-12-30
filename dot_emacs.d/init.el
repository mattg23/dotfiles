;; --- perf ---
(setq gc-cons-threshold (* 50 1000 1000)) ;; 50mb

(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; do not annoy me pls, ty
(setq native-comp-async-report-warnings-errors nil)

;; Store custom-file (the auto-generated settings) in a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Load it if it exists, but don't error if it doesn't
(when (file-exists-p custom-file)
  (load custom-file))
;; --- package archives ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)

(package-initialize)

;; bootstrap 'use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(setq use-package-always-ensure t)

;; GARBAGE COLLECTOR MAGIC HACK (GCMH)
(use-package gcmh
  :diminish gcmh-mode
  :hook (after-init . gcmh-mode)
  :config
  ;; Threshold when active (100MB) - Keeps it from triggering while you work
  (setq gcmh-high-cons-threshold (* 100 1024 1024))
  ;; Idle timer (5s) - If you stop for 5s, it cleans up memory
  (setq gcmh-idle-delay 5))

;; stop emacs from polluting folders with random files
(setq backup-directory-alist '(("." . "~/.config/emacs/backups")))
(setq auto-save-file-name-transforms `((".*" "~/.config/emacs/backups/" t)))

;; steal PATH from shell
(use-package exec-path-from-shell
  :config
  ;; Only run this if we are in a GUI (X11, Wayland, Mac)
  (when (memq window-system '(mac ns x pgtk))
    (exec-path-from-shell-initialize)))

;; no "Active processes exist" warning on exit
(setq confirm-kill-processes nil)

;; revert buffers automatically when the file changes on disk
(global-auto-revert-mode t)

;; i do like me some utf-8
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;; --- basic ui ---

(setq inhibit-startup-message t)  ; No splash screen
(tool-bar-mode -1)                ; No toolbar buttons
(menu-bar-mode -1)                ; No menu bar
(set-fringe-mode 10)              ; Add 10px breathing room on sides

;; Nice scrolling (No jumpy visuals)
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; why is this even a thing?
(setq ring-bell-function 'ignore)

;; Display column numbers in the modeline (Line numbers come in the Evil module next)
(column-number-mode)

;; repeat repeat repeat
(repeat-mode 1)

;; --- Recent Files ---
(use-package recentf
  :init
  (recentf-mode 1)
  :config
  ;; Save more files (default is 20, which is too low)
  (setq recentf-max-menu-items 100)
  (setq recentf-max-saved-items 250))

;; =========================================================
;; 😈
;; =========================================================

(use-package evil
  :init
  ;; Must be set before loading evil
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil) ; Needed for evil-collection
  (setq evil-want-C-u-scroll t)
  :config
  (setq evil-undo-system 'undo-redo) ; Emacs 28+ native undo
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; --- line numbers ---

(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; Switch to absolute in Insert mode, back to relative in Normal mode
(add-hook 'evil-insert-state-entry-hook
          (lambda () (setq display-line-numbers t)))

(add-hook 'evil-insert-state-exit-hook
          (lambda () (setq display-line-numbers 'relative)))

;; --- keybindings ---

;; Use 'ESC' to quit prompts (like the minibuffer)
(global-set-key [escape] 'keyboard-escape-quit)

;; Better window movement
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "C-h") 'evil-window-left)
  (define-key evil-motion-state-map (kbd "C-j") 'evil-window-down)
  (define-key evil-motion-state-map (kbd "C-k") 'evil-window-up)
  (define-key evil-motion-state-map (kbd "C-l") 'evil-window-right))

(with-eval-after-load 'evil
  ;; In Insert Mode, make TAB insert spaces (like a normal editor)
  ;; instead of trying to auto-align the line syntax.
  (define-key evil-insert-state-map (kbd "TAB") 'tab-to-tab-stop))


;; =========================================================
;; themes/ui 🖌
;; =========================================================

;; Theme
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-ir-black t)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; Modeline
(use-package nerd-icons) ; Required for doom-modeline

(use-package doom-modeline
  :after nerd-icons
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 30)
  (setq doom-modeline-icon t)
  (setq doom-modeline-vcs-max-length 15))

;; Fonts
;; Main Font (Iosevka Medium 140)
(set-face-attribute 'default nil :font "Iosevka Medium" :height 140)

;; Fallback Fonts (Emojis & Symbols)
(defun my/setup-fonts ()
  (let ((emoji-font "Noto Color Emoji") ; Linux standard
        (symbol-font "Fira Code Nerd Font"))
    (set-fontset-font t 'emoji (font-spec :family emoji-font) nil 'prepend)
    (set-fontset-font t 'unicode (font-spec :family symbol-font) nil 'append)))

;; Run font setup on startup and for every new frame (daemon mode support)
(my/setup-fonts)
(add-hook 'after-make-frame-functions (lambda (f) (with-selected-frame f (my/setup-fonts))))

;; Transparency (90%)
(set-frame-parameter nil 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; --- The "Rice" ---

;; Nyan Cat Scrollbar
(use-package nyan-mode
  :config
  (setq nyan-wavy-trail t)
  (nyan-mode 1))

;; Parrot Mode (Thumbs up on rotation)
(use-package parrot
  :config
  (parrot-mode)
  (parrot-set-parrot-type 'thumbsup)
  ;; Trigger on buffer switch
  (add-hook 'buffer-list-update-hook
            (lambda ()
              (parrot-stop-animation)
              (parrot-start-animation))))

;; Highlighting TODO/FIXME comments
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config (setq hl-todo-keyword-faces
                '(("TODO"   . "#FF0000")
                  ("FIXME"  . "#FF0000")
                  ("DEBUG"  . "#A020F0")
                  ("GOTCHA" . "#FF4500")
                  ("STUB"   . "#1E90FF"))))

;; =========================================================
;; navigation / search
;; =========================================================

;; --- vertico (Vertical Completion UI) ---
(use-package vertico
  :init
  (vertico-mode)
  :config
  ;; Cycle through candidates
  (setq vertico-cycle t))

;; --- marginalia ---
;; Adds file modes, permissions, and descriptions to the completion list
(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

;; --- orderless (fuzzy matching) ---
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; --- consult ---
;; Enhanced search commands (ripgrep, git grep, etc.)
(use-package consult
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)

  :config
  ;; Use ripgrep for searching projects
  (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))

  :bind
  ;; C-c bindings (mode-specific-map)
  ("C-c M-x" . consult-mode-command)
  ("C-c h" . consult-history)
  ("C-c k" . consult-kmacro)
  ("C-c m" . consult-man)
  ("C-c i" . consult-info)

  ;; C-x bindings (ctl-x-map)
  ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
  ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
  ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
  ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
  ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
  ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer

  ;; Custom M-g bindings (goto-map)
  ("M-g e" . consult-compile-error)
  ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
  ("M-g g" . consult-goto-line)             ;; orig. goto-line
  ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
  ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
  ("M-g m" . consult-mark)
  ("M-g k" . consult-global-mark)
  ("M-g i" . consult-imenu)
  ("M-g I" . consult-imenu-multi)

  ;; M-s bindings (search-map)
  ("M-s d" . consult-find)                  ;; Alternative: consult-fd
  ("M-s D" . consult-locate)
  ("M-s g" . consult-grep)
  ("M-s G" . consult-git-grep)
  ("M-s r" . consult-ripgrep)
  ("M-s l" . consult-line)
  ("M-s L" . consult-line-multi)
  ("M-s k" . consult-keep-lines)
  ("M-s u" . consult-focus-lines)

  ;; Isearch integration
  ("M-s e" . consult-isearch-history)
  (:map isearch-mode-map
	("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
	("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
	("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
	("M-s L" . consult-line-multi)))          ;; needed by consult-line to detect isearch

;; --- Which-Key (The Cheat Sheet) ---
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.5))

;; =========================================================
;; coding
;; =========================================================

;; ---  Corfu (In-Buffer Completion) ---
;; The modern replacement for Company mode.
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-cycle t)                ; Enable cycling for `corfu-next/previous'
  (corfu-auto t)                 ; Enable auto completion
  (corfu-auto-delay 0.2)         ; Short delay before showing
  (corfu-auto-prefix 2)          ; Show after 2 chars
  (corfu-quit-no-match 'separator)
  :bind
  (:map corfu-map
        ("SPC" . corfu-insert-separator))) ; Use Space to filter (e.g. "file txt")

;; Add icons to the completion popup 
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-style '(:padding 0 :stroke 0 :margin 0 :radius 0 :height 0.8 :scale 1.0))
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; --- treesitter setup ---

(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")
        (rust "https://github.com/tree-sitter/tree-sitter-rust" "v0.23.3")
        (c-sharp "https://github.com/tree-sitter/tree-sitter-c-sharp")))

;; Remap legacy modes to their modern Treesitter equivalents (Emacs 29+)
(setq major-mode-remap-alist
      '((rust-mode . rust-ts-mode)
        (csharp-mode . csharp-ts-mode)
        (js-json-mode . json-ts-mode)
        (typescript-mode . typescript-ts-mode)))

;; --- Eglot (LSP Client) ---
;; Built-in, zero-config LSP.
(use-package eglot
  :ensure nil ; Built-in
  :hook
  ;; Hook Eglot into the programming modes we care about
  ((rust-ts-mode
    csharp-ts-mode
    typescript-ts-mode) . eglot-ensure)

  :config
  ;; Optimization: Don't log every single JSON event (improves speed)
  (setq eglot-events-buffer-size 0)

  ;; Keybindings (Eglot reuses standard Emacs keys, but we can add shortcuts)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "g r") #'xref-find-references)
    (define-key evil-normal-state-map (kbd "g d") #'xref-find-definitions)
    (define-key evil-normal-state-map (kbd "g b") #'xref-go-back)
    (define-key evil-normal-state-map (kbd "g a") #'eglot-code-actions)
    (define-key evil-normal-state-map (kbd "g R") #'eglot-rename)
    (define-key evil-normal-state-map (kbd "K")   #'eldoc))) ; Hover doc

;; --- 4. Language Specifics ---

;; RUST
(use-package rust-ts-mode
  :ensure nil ; Built-in
  :mode "\\.rs\\'"
  :config
  ;; Auto-format on save using Eglot (rustfmt)
  (add-hook 'before-save-hook (lambda () (when (derived-mode-p 'rust-ts-mode) (eglot-format-buffer)))))

;; C# / .NET
(use-package csharp-mode
  :ensure nil
  :mode "\\.cs\\'")

;; WEB / TYPESCRIPT
(use-package typescript-ts-mode
  :ensure nil
  :mode "\\.ts\\'"
  :config
  (setq typescript-ts-mode-indent-offset 2))

;; DOCKER
(use-package dockerfile-mode)

;; CONFIG FILES (YAML/TOML/Markdown)
(use-package markdown-mode)
(use-package yaml-mode)

;; --- Git Integration ---
;; best package in emacs ❤
(use-package magit
  :bind ("C-x g" . magit-status))

;; Git Gutter (Show diffs in the sidebar)
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02))


;; ============================================================
;; other stuff
;; ============================================================

;; --- PDF Tools (Better PDF Viewer) ---
;; Compiles a local server to render PDFs sharply inside Emacs.
(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  ;; Open PDFs fitted to the window width by default
  (setq-default pdf-view-display-size 'fit-width))

;; --- Multiple Cursors ---
;; Edit multiple lines at once. (Restoring your old bindings)
(use-package multiple-cursors
  :bind (("C-M-n" . mc/mark-next-like-this)      ; Next occurrence
         ("C-M-p" . mc/mark-previous-like-this)  ; Previous occurrence
         ("C-c C-e" . mc/edit-lines)             ; Edit lines
         ("C-c C-r" . mc/mark-all-in-region)))   ; Mark all in selection

;; ---  Text Manipulation Helpers ---
;; Move lines up/down 

(defun move-line-up ()
  "Move the current line up."
  (interactive)
  (let ((col (current-column)))
    (transpose-lines 1)
    (previous-line 2)
    (move-to-column col)))

(defun move-line-down ()
  "Move the current line down."
  (interactive)
  (let ((col (current-column)))
    (forward-line 1)
    (transpose-lines 1)
    (previous-line 1)
    (move-to-column col)))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)

;; --- Auto-Commit Notes ---
;; Automatically git commit/push when saving files in ~/notes/
(defun my/auto-commit-notes ()
  (when (and buffer-file-name
             (string-prefix-p (expand-file-name "~/notes/") buffer-file-name))
    (let ((default-directory "~/notes/"))
      (when (not (string-empty-p (shell-command-to-string "git status --porcelain")))
        (message "Auto-committing note...")
        (shell-command "git add . && git commit -m \"auto: update notes\" --quiet && git push")
        (message "Note pushed!")))))

(add-hook 'after-save-hook #'my/auto-commit-notes)

;; Send HTTP requests directly from org.
(use-package verb
  :after org)

;; Auto-enable verb-mode ONLY for files named like "api.verb.org"
(add-hook 'org-mode-hook
	  (lambda ()
	    (when (and buffer-file-name
		       (string-match-p "\\.verb\\.org\\'" buffer-file-name))
	      (verb-mode 1)
	      (message "Verb mode enabled (Filename Match)"))))


;; ==================================
;; Startup
;; ==================================

(add-hook 'emacs-startup-hook
          (lambda ()
            (let ((default-directory "~/"))
              (eshell))))

(with-eval-after-load 'eshell
  (add-hook 'eshell-mode-hook
            (lambda ()
              (eshell/alias "ll" "ls -alh"))))
