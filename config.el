;;; .config/doom/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(setq user-full-name "Vikram Venkataramanan"
      user-mail-address "vikram.venkataramanan@mail.utoronto.ca")

;; ---------------------------------------------------------------------------------------------------------------------
;; Appearence
;; ---------------------------------------------------------------------------------------------------------------------

(doom/set-frame-opacity 95)

(setq doom-theme 'doom-opera

      ;; Preferred Fonts
      doom-font (font-spec :family "JetBrains Mono" :size 12)
      doom-big-font (font-spec :family "JetBrains Mono" :size 30)

      ;; Modeline
      doom-modeline-icon (display-graphic-p)
      doom-modeline-major-mode-icon t

      ;; Hide encoding, but show indent info
      doom-modeline-buffer-encoding nil
      doom-modeline-indent-info t)

(custom-set-faces! '(font-lock-comment-face :family "Fantasque Sans Mono" :slant italic))

(when IS-MAC
  (mac-auto-operator-composition-mode)
  (setq ns-use-thin-smoothing t)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))

(add-hook!    (prog-mode) #'rainbow-delimiters-mode)
(remove-hook! (prog-mode text-mode) #'hl-line-mode)

(add-hook 'dired-after-readin-hook 'hl-line-mode)
(remove-hook 'dired-after-readin-hook 'hl-line-mode)

(add-hook! (dired-mode) 'dired-hide-details-mode)
(global-git-gutter-mode)
(whitespace-mode nil)

(add-hook 'markdown-mode-hook #'doom-disable-line-numbers-h)

;; ---------------------------------------------------------------------------------------------------------------------
;; Pretty Symbols
;; ---------------------------------------------------------------------------------------------------------------------

(add-hook! brewfile-mode
  (set-pretty-symbols! 'brewfile-mode
    :return "tap"
    :def "brew"
    :lambda "cask"))

(add-hook! python-mode (nuke-pretty-symbols 'python-mode)
  (set-pretty-symbols! 'python-mode
    :lambda "lambda"
    :in "in"
    :not_in "not in"
    :sum "sum"
    :sum "sum()"))

(add-hook! c-mode (nuke-pretty-symbols 'c-mode))
(add-hook! c++-mode (nuke-pretty-symbols 'c++-mode))
(add-hook! js-mode (nuke-pretty-symbols 'js-mode))
(add-hook! haskell-mode (nuke-pretty-symbols 'haskell-mode))

;; ---------------------------------------------------------------------------------------------------------------------
;; Custom functions
;; ---------------------------------------------------------------------------------------------------------------------

(defun arrayify (start end quote)
  "Turn strings on newlines into a QUOTEd, comma-separated one-liner."
  (interactive "r\nMQuote: ")
  (let ((insertion
         (mapconcat
          (lambda (x) (format "%s%s%s" quote x quote))
          (split-string (buffer-substring start end)) ", ")))
    (delete-region start end)
    (insert insertion)))

(defun magit-just-amend ()
  (interactive)
  (save-window-excursion
    (magit-with-refresh
     (shell-command "git --no-pager commit --amend --reuse-message=HEAD"))))

(defun nuke-pretty-symbols (mode)
  "Pretty symbols are nice, but I choose when and where!"
  (setq +pretty-code-symbols-alist
        (delq (assq mode +pretty-code-symbols-alist)
              +pretty-code-symbols-alist)))

(defun save-word ()
  "Add word to dictionary"
  (interactive)
  (let ((current-location (point))
        (word (flyspell-get-word)))
    (when (consp word)
      (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location))))

(defun smart-tab-leap-out (&optional arg)
  "Smart tab behavior. Jump out quote or brackets, or indent.
  Source : https://www.reddit.com/r/emacs/comments/3n1j4x/anyway_to_tab_out_of_parentheses/"
  (interactive "P")
  (if (-contains? (list "\"" "'" ")" "}" ";" "|" ">" "]" ) (make-string 1 (char-after)))
      (forward-char 1)
    (indent-for-tab-command arg)))

(defun yadm ()
  "Can use magit and tramp to manage dotfiles!"
  (interactive)
  (magit-status  "/yadm::"))

;;---------------------------------------------------------------------------------------------------------------------
;; Local Leader
;; ---------------------------------------------------------------------------------------------------------------------

(map! :v "s-c" #'evil-yank)

(map! :localleader
      :map LaTeX-mode-map
      :desc "build pdf"     "b" 'TeX-command-run-all
      :desc "clean"         "c" 'TeX-clean)

(map! :localleader
      :map markdown-mode-map
      :prefix ("i" . "Insert")
      :desc "Blockquote"    "q" 'markdown-insert-blockquote
      :desc "Bold"          "b" 'markdown-insert-bold
      :desc "Code"          "c" 'markdown-insert-code
      :desc "Emphasis"      "e" 'markdown-insert-italic
      :desc "Footnote"      "f" 'markdown-insert-footnote
      :desc "Code Block"    "s" 'markdown-insert-gfm-code-block
      :desc "Image"         "i" 'markdown-insert-image
      :desc "Link"          "l" 'markdown-insert-link
      :desc "List Item"     "n" 'markdown-insert-list-item
      :desc "Pre"           "p" 'markdown-insert-pre
      (:prefix ("h" . "Headings")
        :desc "One"   "1" 'markdown-insert-atx-1
        :desc "Two"   "2" 'markdown-insert-atx-2
        :desc "Three" "3" 'markdown-insert-atx-3
        :desc "Four"  "4" 'markdown-insert-atx-4
        :desc "Five"  "5" 'markdown-insert-atx-5
        :desc "Six"   "6" 'markdown-insert-atx-6))

;; ---------------------------------------------------------------------------------------------------------------------
;; Misc
;; ---------------------------------------------------------------------------------------------------------------------

(setenv  "SHELL" "/bin/bash")

(setq eldoc-idle-delay 0

      ;; Backup files? Sorry, but what year are we in?
      make-backup-files nil
      auto-save-default nil)

(when IS-MAC
  (setq mac-pass-command-to-system nil))

;; Move between panes
(map! :n "s-h" 'windmove-left
      :n "s-l" 'windmove-right
      :n "s-k" 'windmove-up
      :n "s-j" 'windmove-down)

(map! :n "DEL" 'dired-jump)

(define-derived-mode brewfile-mode ruby-mode "Brewfile")

(setq evil-ex-search-persistent-highlight nil)
(vimish-fold-global-mode 1)
(add-hook 'after-init-hook 'global-company-mode)

(add-hook 'js2-mode-hook
          (defun my-js2-mode-setup ()
            (flycheck-mode t)
            (when (executable-find "eslint")
              (flycheck-select-checker 'javascript-eslint))))

(global-set-key [remap indent-for-tab-command] 'smart-tab-leap-out)

(eval-after-load "magit"
  '(define-key magit-status-mode-map (kbd "C-c C-a") 'magit-just-amend))

;; ---------------------------------------------------------------------------------------------------------------------
;; Packages
;; ---------------------------------------------------------------------------------------------------------------------

;; (use-package! aggressive-indent
;;   :config
;;   (global-aggressive-indent-mode 1)
;;   (add-to-list 'aggressive-indent-excluded-modes 'shell-mode)
;;   (add-to-list 'aggressive-indent-excluded-modes 'c-mode)
;;   )

(use-package! all-the-icons-ivy
  :config
  (all-the-icons-ivy-setup))

(use-package! atomic-chrome
  :config
  (setq atomic-chrome-default-major-mode 'markdown-mode)
  (setq atomic-chrome-url-major-mode-alist
        '(("github\\.com" . gfm-mode)))
  (setq atomic-chrome-buffer-open-style 'split)
  (atomic-chrome-start-server))

(use-package! carbon-now-sh
  :commands carbon-now-sh)

(use-package! counsel
  :bind
  (("s-P" . counsel-M-x)
   ("s-p" . counsel-find-file)))

(use-package! counsel-dash
  ;; https://github.com/dash-docs-el/counsel-dash
  :after (counsel)
  :bind
  (("s-d" . counsel-dash-at-point))
  :config
  (setq counsel-dash-docsets-path "/Volumes/vikram/docsets"
        counsel-dash-common-docsets '("Bash"))
  ;; TODO: Should probably clear this up later
  (add-hook! (emacs-lisp) (setq-local counsel-dash-docsets '("Emacs Lisp")))
  (add-hook! (c-mode) (setq-local counsel-dash-docsets '("C")))
  (add-hook! (r-mode ess-r-mode) (setq-local counsel-dash-docsets '("R")))
  (add-hook! (julia-mode ess-julia-mode) (setq-local counsel-dash-docsets '("Julia")))
  (add-hook! (cpp-mode) (setq-local counsel-dash-docsets '("C++" "Boost")))
  (add-hook! (css-mode) (setq-local counsel-dash-docsets '("CSS")))
  (add-hook! (haskell-mode) (setq-local counsel-dash-docsets '("Haskell")))
  (add-hook! (python)
    (setq-local counsel-dash-docsets '("Python 2" "Python 3" "OpenCV Python" "NumPy" "Pandas" "Matplotlib"))))

(use-package! company-quickhelp
  :config
  (company-quickhelp-mode))

(use-package! deadgrep

  :bind
  (("s-r" . deadgrep)))

(use-package! electric-operator
  :hook ((sh-mode . electric-operator-mode)
         (ess-mode . electric-operator-mode)
         (python-mode . electric-operator-mode)))

(use-package! evil-mc
  :config
  (global-evil-mc-mode  1)
  :bind
  (("s-j" . evil-mc-make-and-goto-next-match)
   ("s-k" . evil-mc-make-and-goto-prev-match)
   ("s-J" . evil-mc-skip-and-goto-next-match)
   ("s-K" . evil-mc-skip-and-goto-prev-match)))

(use-package! evil-vimish-fold
  :after vimish-fold
  :hook ((prog-mode conf-mode text-mode) . evil-vimish-fold-mode))

(use-package! exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(use-package! highlight-indent-guides
  :commands highlight-indent-guides-mode
  :hook
  (prog-mode . highlight-indent-guides-mode))

(use-package! key-chord
  ;;Exit out of insert mode with 'jj' in place of escape
  :init
  (setq-default evil-escape-key-sequence "jj")
  (setq key-chord-two-keys-delay 0.5)
  :config
  (key-chord-define evil-insert-state-map "jj" 'evil-normal-state)
  (key-chord-mode 1))

(use-package! magithub
  :after magit
  :init
  (setq magithub-clone-default-directory "/Volumes/vikram/projects")
  :config
  (magithub-feature-autoinject t))

(use-package! openwith
  :config
  (setq openwith-associations '(("\\.pdf\\'" "preview" (file))))
  (openwith-mode t))

(use-package! olivetti
  :init (setq olivetti-body-width 150)
  :hook
  ((markdown-mode) . olivetti-mode))

(use-package! pipenv
  :hook (python-mode . pipenv-mode)
  :init
  (setq
   pipenv-projectile-after-switch-function
   #'pipenv-projectile-after-switch-extended))

;; (use-package! poly-markdown
;;   :mode (("\\.[jJ]md" . poly-markdown+julia-mode))
;;   :after polymode
;;   :config
;;   (add-to-list 'polymode-mode-name-override-alist '(julia . ess-julia))
;;   (define-polymode poly-markdown+julia-mode pm-poly/markdown
;;     :name "Vikram's Julia Markdown Mode"
;;     :lighter " PM-jmd"))

(use-package! tramp
  ;; Allow tramp to connect to yadm's git shell
  :init
  (setq tramp-default-method "ssh")
  (setq projectile-mode-line "Projectile")
  (setq remote-file-name-inhibit-cache nil)
  (setq vc-ignore-dir-regexp
        (format "%s\\|%s"
                vc-ignore-dir-regexp
                tramp-file-name-regexp))
  (setq tramp-verbose 1)
  :config
  (add-to-list 'tramp-methods
               '("yadm"
                 (tramp-login-program "yadm")
                 (tramp-login-args (("enter")))
                 (tramp-login-env (("SHELL") ("/bin/sh")))
                 (tramp-remote-shell "/bin/sh")
                 (tramp-remote-shell-args ("-c")))))

(use-package! prettier-js
  :hook ((js2-mode . prettier-js-mode)
         (rjsx-mode . prettier-js-mode)))

(use-package! undo-tree
  :config
  (global-undo-tree-mode))

(use-package! vimrc-mode
  :config
  ;; vim files
  (add-to-list 'auto-mode-alist '("\\.vim\\(rc\\)?\\'" . vimrc-mode)))

(use-package! vimish-fold
  :after evil)

(use-package! ws-butler
  :hook
  ((prog-mode markdown-mode) . ws-butler-mode))

;; ---------------------------------------------------------------------------------------------------------------------
