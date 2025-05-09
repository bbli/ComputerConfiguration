;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Source Code Pro" :size 19 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "ETBembo" :size 19 :weight 'medium))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;(setq doom-font (font-spec :family "Source Code Pro" :size 18 :weight 'medium))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!


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

(if (eq system-type 'darwin)
        ; Mac specific things
        (progn
                (setq org-directory "~/Documents/Org")
                (setq launcher-name "spotlight")
                ; (add-to-list process-environment "LD_LIBRARY_PATH=/usr/local/lib")
        )
        ; Linux specific things
        (progn
                (setq org-directory "~/Dropbox/Org")
                (setq launcher-name "krunner")
        )
)

(keyboard-translate ?\C-c ?\C-e)
(keyboard-translate ?\C-e ?\C-c)
(setq source-directory "~/Software/emacs")
(map! :leader :prefix "h" "b" 'describe-keymap)

(after! org
        (setq org-todo-keywords
        '((sequence "TODO"  "|" "FUTURE" "DEAD_END" "DONE")))
        (add-to-list 'org-emphasis-alist '("_" (:inherit org-code :height 1.3)))
        (add-to-list 'org-emphasis-alist '("=" (:inherit org-verbatim :height 0.85 :box nil)))
        (push '(tags-tree . local) org-show-context-detail)
        (custom-set-faces! '(org-tag :height 0.6))
        (custom-set-faces! '(org-block :height 0.7))
        (custom-set-faces! '(org-meta-line :height 0.7))
        (custom-set-faces! '(org-block-begin-line :height 0.7))
        (custom-set-faces! '(org-block-end-line :height 0.7))
        (custom-set-faces! '(org-code :height 0.9))
        (set-face-attribute 'org-level-1 nil :height 1.0)
        (set-face-attribute 'org-level-2 nil :height 1.4)
        (set-face-attribute 'org-level-3 nil :height 1.2)
        (setq org-ident-mode nil)
)

(defun add-pretty-symbols-org ()
  (mapcar (lambda (cons-cell) (add-to-list 'prettify-symbols-alist cons-cell))
          '(
            ;; ("lambda" . 955)
            ("[ ]" .  "☐")
            ("[X]" . "☑" )
            ("[-]" . "❍" )
        ("#+BEGIN_SRC" . "λ")
        ("#+END_SRC" . "λ")
        ("#+begin_src" . "λ")
        ("#+end_src" . "λ")
        ("#+results:" . "»")
        ;; ("#+name:"          . "-")
            )
        )
)
;(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
;(add-hook 'prog-mode-hook 'prettify-symbols-mode)
;; (add-hook 'prog-mode-hook (lambda () (doom-modeline-mode 1)))
;; NOTE: mode call needs to be added to list first -> so it can be "later" in the list
(add-hook 'org-mode-hook 'prettify-symbols-mode)
(add-hook 'org-mode-hook 'org-toggle-pretty-entities)
(add-hook 'org-mode-hook 'add-pretty-symbols-org)
(add-hook 'org-mode-hook 'variable-pitch-mode)
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(defun benson/toggle-narrow-to-subtree ()
        (interactive)
        (if (buffer-narrowed-p)
                (progn
                        (org-toggle-narrow-to-subtree)
                        (text-scale-decrease 1)
                )
                (progn
                        (org-toggle-narrow-to-subtree)
                        (text-scale-increase 1)
                )
        )
)
(after! org
        (map! :map org-mode-map
                "C-h" nil "C-a" nil "o" nil "O" nil
                ;; :desc "open branches below subtree" "C-c o" (lambda () (interactive) (outline-show-children 10))
                :n "o" 'end-of-line-and-indented-new-line
                :n "O" 'end-of-line-and-indented-new-line-above
                ;; :desc "open branches below subtree" "C-c o" #'org-show-subtree
                ;; :desc "open ALL branches up to level two" "C-c O" #'(lambda () (interactive) (org-content 2))
                ;; :desc "close current branch" "C-c c" #'outline-hide-body

                :desc "next visible heading" "C-c C-n" #'outline-next-visible-heading
                :desc "previous visible heading" "C-c C-p" #'outline-previous-visible-heading
                :desc "go up a heading" "C-c C-u" #'outline-up-heading
                :desc "toggle narrow of subtree" "C-c n" 'benson/toggle-narrow-to-subtree
                ;; :desc "hide source blocks of current subtree" "C-c h" #'benson/org-hide-block-subtree
                ;; :desc "hide source blocks of current subtree" "C-c c"
                ;; #'flyspell-correct-at-point

                ;; :desc "find tag" "C-c C-u" #'outline-up-heading
                :desc "refile headline" "C-c r" #'org-refile
                ;; :desc "ediff two regions" "C-c e" #'ediff-regions-linewise
        )
)

(setq projectile-project-search-path `(org-directory))

(defun benson/switch-to-previous-buffer ()
        "Switch to the last open buffer of the current window."
        (interactive)
        :repeat nil
        (let ((previous-place (car (window-prev-buffers))))
                (when previous-place (switch-to-buffer (car previous-place)))))
(defun benson/rename-buffer (new-name)
        (interactive "sNew buffer name: ")
        (rename-buffer new-name)
)
(defun benson/consult-buffer-horizontal-window ()
        (interactive)
        (split-window-below)
        (evil-window-down 1)
        (consult-buffer)
)
(define-prefix-command 'benson/buffer-keymap)
(map! :map benson/buffer-keymap
        :desc "switch to alternate file"           "s" #'benson/switch-to-previous-buffer
        :desc "zen toggle"           "z" #'+zen/toggle
        :desc "open all buffer" "b" #'consult-buffer
        :desc "fuzzy select buffer + open in vertical split" "v" #'consult-buffer-other-window
        :desc "horizontal split + fuzzy select buffer" "h" 'benson/consult-buffer-horizontal-window
        :desc "kill current buffer" "k" #'kill-this-buffer
      :desc "delete workspace" "K" #'+workspace/close-window-or-workspace
        :desc "kill current buffer" "r" 'benson/rename-buffer
        ;; :desc "choose a buffer to delete" "d" #'ido-kill-buffer
        ;; :desc "cycle outshine mode" "c" #'outshine-cycle-buffer
)
(map! :leader
      "b" nil
      :desc "buffer keymap" "b" 'benson/buffer-keymap
)

(map! "M-TAB" 'benson/switch-to-previous-buffer)
(defun benson/open-current-buffer-in-new-workspace ()
        (interactive)
        (let ((buf (current-buffer)))
                (+workspace/new)
                (switch-to-buffer buf)
        )
)
(defun benson/switch-window ()
  (interactive)
  (when-let ((mru-window (get-mru-window nil nil 'non-nil)))
    (select-window mru-window)
    )
)
(define-prefix-command 'benson/workspace-map)
(map! :map benson/workspace-map
      "n" nil
      :desc "new workspace" "c" #'+workspace/new
      :desc "tear off current window into new workspace" "o" 'benson/open-current-buffer-in-new-workspace
      :desc "fuzzy search workspace" "s" #'+workspace/switch-to
      :desc "delete workspace" "k" #'+workspace/delete
      :desc "rename workspaces" "r" #'+workspace/rename
      :desc "next workspace" "n" #'+workspace/switch-right
      :desc "previous workspace" "p" #'+workspace/switch-left
      :desc "switch to last workspace" "m" #'+workspace/other
      :desc "switch to last workspace" ";" #'+workspace/other
      :desc "display workspaces" "p" #'+workspace/display
      :desc "display workspaces" "w" #'+workspace/switch-to
      )
(map! :leader
      "w" nil
      :desc "workspace keymap" "w" 'benson/workspace-map
)
(map! :map evil-normal-state-map "C-t" nil)
(after! ace-window
        (setq aw-keys '(?1 ?2 ?3 ?4 ?5))
)

(map! :map evil-window-map
        "o" 'delete-other-windows
        "b" 'benson/buffer-keymap
        ;"s" 'ace-window
        "f" 'doom-leader-file-amp
        "w" 'benson/workspace-map
        "C-w" 'evil-window-next
        "C-a" 'evil-window-next
        ";" 'benson/switch-window
        ":" 'evil-ex
)

(defun benson/insert-semicolon ()
  (interactive)
  (insert ";")
  )
(map! :i "; ;" 'benson/insert-semicolon)
(map! :niv "; c" 'evil-normal-state)
(defun benson/write-file ()
  (interactive)
  (evil-force-normal-state)
  (save-buffer)
  )
(map! :niv "; w" 'benson/write-file)
(map! :niv "; q" (progn
        'evil-quit
        'evil-normal-state
        )
)
(map! :niv "; d" 'kill-this-buffer)
(map! :niv "; n" 'projectile-next-project-buffer)
(map! :niv "; N" 'projectile-previous-project-buffer)

(map! :leader
      :prefix "g"
      :desc "next hunk" "n" #'git-gutter:next-hunk
      :desc "next hunk" "p" #'git-gutter:previous-hunk
)

(map! :leader
      :prefix "j"
      :desc "evil-goto-last-change" "c" #'evil-goto-last-change
)

(defun benson/insert-current-date ()
  (interactive)
  (insert (format-time-string "%m-%d-%Y"))
)
(map! :map evil-insert-state-map
      "C-i d" 'benson/insert-current-date)

(map! :map emacs-lisp-mode-map
      "C-c C-c" 'eval-last-sexp)

(require 'exwm)
(require 'exwm-config)
(defun benson/disable-keymaps-for-exwm ()
        (set (make-local-variable 'evil-motion-state-map) nil)
        (set (make-local-variable 'evil-normal-state-map) nil)
)
(defun benson/send-C-f ()
        (interactive)
        (exwm-input-send-simulation-key "C-f")
)
(defun benson/apply-exwm-mapping ()
        (map! :map exwm-mode-map
                "C-a" nil
                "C-c" nil
                ;"C-q" nil
                ;"C-d" 'exwm-input-send-next-key
                ;"C-t" 'exwm-input-send-next-key
                "C-f" 'exwm-input-send-next-key
                "C-b" 'exwm-input-send-next-key
                ;"C-n" 'exwm-input-send-next-key
                ;"C-p" 'exwm-input-send-next-key
                ;"C-v" 'exwm-input-send-next-key
                ; Simulation key version of this didn't work
                "C-u" 'exwm-input-send-next-key
                ;"C-w" 'exwm-input-send-next-key

                ;"C-c C-l" #'exwm-layout-toggle-mode-line
                ;"C-c C-f" #'exwm-floating-toggle-floating
                ;"C-c C-c" #'exwm-input-send-next-key
                ;"C-c C-q" #'exwm-input-send-next-key
                "C-g" #'doom/escape
                ;; The following keymaps need to be duplicated for non-EXWM buffers
                ;; TODO should I still keep the C-e key translation?
                "C-a" 'evil-window-map
                "C-SPC" 'doom/leader
        )
)

(global-set-key (kbd "C-a") 'evil-window-map)
(define-key exwm-mode-map (kbd "C-a") 'evil-window-map)
(exwm-input-set-key [?\C-a] 'evil-window-map)
(global-set-key (kbd "C-SPC") #'doom/leader)
(add-hook 'exwm-mode-hook 'benson/disable-keymaps-for-exwm)
(add-hook 'exwm-mode-hook 'benson/apply-exwm-mapping);Need to do this as late as possible. (after! exwm ....) still didn't work

;(exwm-input-set-key (kbd "s-r") #'exwm-reset)
;(exwm-input-set-key (kbd "s-s") #'exwm-workspace-switch)
;(exwm-input-set-key (kbd "s-h") #'windmove-left)
;(exwm-input-set-key (kbd "s-j") #'windmove-down)
;(exwm-input-set-key (kbd "s-k") #'windmove-up)
;(exwm-input-set-key (kbd "s-l") #'windmove-right)

;(require 'exwm-randr)
;(setq exwm-randr-workspace-output-plist '(0 "HDMI-1"))
;(add-hook 'exwm-randr-screen-change-hook (lambda () (start-process-shell-cmd "xrandr" nil "xrandr --output HDMI-1 --mode 1920x1080")))
;(exwm-randr-enable)
;(require 'exwm-systemtray)
;(exwm-systemtray-enable)

(map! :map doom-leader-map
      ":" 'evil-ex
      "C-w" 'evil-window-map
      "x" 'execute-extended-command
)

(exwm-input-set-simulation-key [?\C-f] [?\C-f])
(exwm-input-set-simulation-key [?\C-b] [?\C-b])
(exwm-input-set-simulation-key [?\C-j] [?\C-j])
(exwm-input-set-simulation-key [?\C-k] [?\C-k])
(exwm-input-set-simulation-key [?\C-d] [?\C-d])
(exwm-input-set-simulation-key [?\C-t] [?\C-t])
(exwm-input-set-simulation-key [?\C-n] [?\C-n])
(exwm-input-set-simulation-key [?\C-p] [?\C-p])
(exwm-input-set-simulation-key [?\C-v] [?\C-v])
(exwm-input-set-simulation-key [?\C-e] [?\C-c])
(exwm-input-set-simulation-key [?\C-u] [?\C-u])
(exwm-input-set-simulation-key [?\C-w] [?\C-w])
(exwm-input-set-simulation-key [?\C-l] [?\C-l])
(exwm-input-set-simulation-key [?\C-c] [?\C-e])
; Emacs doesn't bind to this, so should be safe
;(exwm-input-set-simulation-key [?\C-q] [?\C-q])

(add-to-list 'exwm-manage-configurations
             '((string-match-p launcher-name exwm-class-name) floating t
               )
)
(defun benson/launcher ()
  (interactive)
  (start-process-shell-command "launcher" nil launcher-name))

(map! :map doom-leader-map "SPC" 'benson/launcher)
(global-set-key (kbd "M-SPC") #'benson/launcher)

; BREAK DOWN: see if buffer name exists
(defun benson/jumpapp-kitty ()
        (interactive)
        (start-process-shell-command "kitty" nil "kitty")
)
(defun benson/jumpapp-neovim ()
    (interactive)
    (if (get-buffer "neovim")
        (switch-to-buffer (get-buffer "neovim"))
        (start-process-shell-command "neovim" nil "kitty")
    )
)
(defun benson/jumpapp-chrome ()
        (interactive)
        (start-process-shell-command "Google-chrome" nil "chrome")
)
(defun benson/jumpapp-obsidian ()
  (interactive)
  (if (get-buffer "obsidian")
        (switch-to-buffer (get-buffer "obsidian"))
        (start-process-shell-command "obsidian" nil "Obsidian")
  )
)
(defun benson/jumpapp-write-ahead-log ()
  (interactive)
  (switch-to-buffer "Write_Ahead_Logging.org"))
;(after! exwm
;        (global-set-key (kbd "C-M-k") #'benson/jumpapp-kitty)
;        (global-set-key (kbd "C-M-c") #'benson/jumpapp-chrome)
;        (global-set-key (kbd "C-M-o") #'benson/jumpapp-obsidian)
;)
(exwm-input-set-key (kbd "C-M-k") #'benson/jumpapp-kitty)
(exwm-input-set-key (kbd "C-M-c") #'benson/jumpapp-chrome)
(exwm-input-set-key (kbd "C-M-o") #'benson/jumpapp-obsidian)
(exwm-input-set-key (kbd "C-M-n") #'benson/jumpapp-neovim)
(exwm-input-set-key (kbd "C-M-l") #'benson/jumpapp-write-ahead-log)

(exwm-config-example)

(defun ssh-and-copy-file ()
        (interactive)
        (let ((file-content (shell-command-to-string "ssh irdv-beli -X -l ir 'cat ~/copy.txt'")))
                (with-current-buffer (current-buffer) (insert file-content))
        )
)
(map! :n "P" 'ssh-and-copy-file)

(defun benson-clock-start ()
        (interactive)
        (if (> (org-current-level) 1)
                (org-clock-in)
                ;(org-timer-set-timer 30)
                ;(org-timer-start)
        )
)

(map! :map org-mode-map
      :desc "start org timer" "C-c s" 'org-clock-in
      :desc "start org timer" "C-c d" 'org-clock-out
)

;(add-hook 'org-insert-heading-hook 'benson-clock-start)
;(advice-add 'org-toggle-heading :after 'benson-clock-start)
(map! :map evil-window-map "d" 'org-clock-out)

(if (display-graphic-p)
        (add-hook 'after-init-hook (lambda () (find-file (concat org-directory "/Write_Ahead_Logging.org"))))
)

(setq window-delta 30)
(defun benson/increase-height ()
  (interactive)
  (evil-window-increase-height (/ window-delta 3))
)
(defun benson/decrease-height ()
  (interactive)
  (evil-window-decrease-height (/ window-delta 3))
)
(defun benson/increase-width ()
  (interactive)
  (evil-window-increase-width window-delta)
)
(defun benson/decrease-width ()
  (interactive)
  (evil-window-decrease-width window-delta)
)

(map! :map evil-window-map
        "<up>" 'benson/increase-height
        "<down>" 'benson/decrease-height
        "<right>" 'benson/increase-width
        "<left>" 'benson/decrease-width
        "C-<up>" 'benson/increase-height
        "C-<down>" 'benson/decrease-height
        "C-<right>" 'benson/increase-width
        "C-<left>" 'benson/decrease-width
)

(defun benson/open-write-ahead-log ()
        (interactive)
        (switch-to-buffer "Write_Ahead_Logging.org")
)
(defun benson/open-scratch-buffer ()
        (interactive)
        (find-file "~/Downloads/scratch")
)
(define-prefix-command 'benson/open-keymap)
(map! :map benson/open-keymap
        :desc "switch to alternate file"           "h" 'consult-recent-file
        :desc "open write ahead log"           "w" 'benson/open-write-ahead-log
        :desc "toggle terminal" "t" #'+vterm/toggle
        :desc "open scratch buffer" "s" #'benson/open-scratch-buffer
)
(map! :leader
      "o" nil
      :desc "open keymap" "o" 'benson/open-keymap
)

(after! org
        (setq org-default-notes-file (concat org-directory "/Write_Ahead_Logging.org"))
        (setq org-capture-templates
        '(("t" "Todo" entry (file+headline org-default-notes-file "Refile Targets")
                "* TODO %?\n  %i\n ")
                )
        )
)
;(setq +org-capture-frame-parameters '((name . "doom-capture")
;                                      (width . 170)
;                                      (height . 110)
;                                      (transient . t)
;                                      (menu-bar-lines . 1)))
;         "* TODO %?\n  %i\n ")


(defun benson/org-capture ()
        (interactive)
        (org-capture nil "t")
)
(map! :map evil-window-map "c" 'benson/org-capture)
(map! :map doom-leader-map "c" 'benson/org-capture)

(defun benson/split-window-advice ()
        (interactive)
        (other-window 1)
)
(advice-add 'evil-window-vsplit :after 'benson/split-window-advice)
(advice-add 'evil-window-split :after 'benson/split-window-advice)

(defun benson/zen-toggle ()
        (interactive)
        (delete-other-windows)
        (evil-window-vsplit)
        (other-window 1)
        (switch-to-buffer "Write_Ahead_Logging.org")
        (benson/decrease-width)
        (benson/decrease-width)
        (benson/decrease-width)
)
(map! :map evil-window-map
      "m" 'benson/zen-toggle
)

(defun prompt-user-to-move-note ()
        (posframe-show " *posframe-buffer"
                       :string "See if any notes should be moved to Obsidian"
                       :position (point)
                       :timeout 5
                       :foreground-color "green"
        )
)
(defun benson/ask-user-to-move-to-obsidian ()
        (when (string-equal org-state "DONE")
          (prompt-user-to-move-note)
        )
)
(add-hook 'org-after-todo-state-change-hook 'benson/ask-user-to-move-to-obsidian)
