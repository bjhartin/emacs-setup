;; per http://ensime.github.io/editors/emacs/install

;; refresh packages
(package-refresh-contents)

;; global variables
(setq
 inhibit-startup-screen t
 create-lockfiles nil
 make-backup-files nil
 column-number-mode t
 scroll-error-top-bottom t
 show-paren-delay 0.5
 use-package-always-ensure t
 sentence-end-double-space nil)

;; buffer local variables
(setq-default
 indent-tabs-mode nil
 tab-width 4
 c-basic-offset 4)

;; global font
(set-frame-font "Menlo:pixelsize=15")
(set-face-attribute 'default t :font "Menlo:pixelsize=15")

;; Increase memory threshold at which point garbage collection occurs.
;; This is an attempt to fix an issue in which helm-projectile causes emacs
;; to crash.
(setq gc-cons-threshold 100000000)

;; modes
(electric-indent-mode 0)

;; global keybindings
(global-unset-key (kbd "C-z"))

;; setup the required packages
(setq package-list '(pkg-info with-editor darcula-theme helm-projectile ensime auto-complete magit))

;; setup the package manager
(require 'package)
(setq
 use-package-always-ensure t
 package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                    ("org" . "http://orgmode.org/elpa/")
                    ("melpa" . "http://melpa.org/packages/")
                    ("melpa-stable" . "http://stable.melpa.org/packages/")))

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents)
  (package-install 'use-package)
)
(require 'use-package)

;; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;;(use-package ensime
;;  :pin melpa-stable
;;  :commands ensime ensime-mode)

(add-hook 'scala-mode-hook 'ensime-mode)

(setq exec-path (append exec-path '("/usr/local/bin")))

;; per http://company-mode.github.io/ - not sure completely necessary to enable global completion
(add-hook 'after-init-hook 'global-company-mode)

(projectile-global-mode)

(cd (getenv "HOME"))

;; fast helm searches
(global-set-key (kbd "C-f")
                (lambda() (interactive) (helm-projectile-find-file)))
(global-set-key (kbd "C-S-f")
                (lambda() (interactive) (helm-projectile-ag)))
(global-set-key (kbd "C-p")
                (lambda() (interactive) (helm-projectile-switch-project)))

;; Make helm-ag search for the symbol on which the point rests by default
(setq helm-ag-insert-at-point 'symbol)(setq helm-ag-insert-at-point 'symbol)

;; fast switch between buffers in window
(defvar xah-switch-buffer-ignore-dired t "If t, ignore dired buffer when calling `xah-next-user-buffer' or `xah-previous-user-buffer'")
(setq xah-switch-buffer-ignore-dired t)

(defun xah-next-user-buffer ()
  "Switch to the next user buffer.
 “user buffer” is a buffer whose name does not start with “*”.
If `xah-switch-buffer-ignore-dired' is true, also skip directory buffer.
2015-01-05 URL `http://ergoemacs.org/emacs/elisp_next_prev_user_buffer.html'"
  (interactive)
  (next-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (or
           (string-equal "*" (substring (buffer-name) 0 1))
           (if (string-equal major-mode "dired-mode")
               xah-switch-buffer-ignore-dired
             nil
             ))
          (progn (next-buffer)
                 (setq i (1+ i)))
        (progn (setq i 100))))))

(defun xah-previous-user-buffer ()
  "Switch to the previous user buffer.
 “user buffer” is a buffer whose name does not start with “*”.
If `xah-switch-buffer-ignore-dired' is true, also skip directory buffer.
2015-01-05 URL `http://ergoemacs.org/emacs/elisp_next_prev_user_buffer.html'"
  (interactive)
  (previous-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (or
           (string-equal "*" (substring (buffer-name) 0 1))
           (if (string-equal major-mode "dired-mode")
               xah-switch-buffer-ignore-dired
             nil
             ))
          (progn (previous-buffer)
                 (setq i (1+ i)))
        (progn (setq i 100))))))

;; keybindings for fast switch between buffers in window
(global-set-key (kbd "s-`")
                (lambda() (interactive) (xah-next-user-buffer)))
(global-set-key (kbd "s-~")
                (lambda() (interactive) (xah-previous-user-buffer)))

;; fast switch between windows
(global-set-key (kbd "s-{")
                (lambda() (interactive) (other-window -1)))
(global-set-key (kbd "s-}")
                (lambda() (interactive) (other-window 1)))


;; Map escape to cancel (like C-g)...
(global-set-key [escape] 'keyboard-quit) 
(define-key isearch-mode-map [escape] 'isearch-abort)   ;; isearch
(define-key isearch-mode-map "\e" 'isearch-abort)   ;; \e seems to work better for terminals
(global-set-key [escape] 'keyboard-escape-quit)         ;; everywhere else

;; Move line up/down
(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "s-S-<up>") 'move-line-up)
(global-set-key (kbd "s-S-<down>") 'move-line-down)

;; Quick commenting
(defun comment-or-uncomment-region-or-line ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
        (if (region-active-p)
            (setq beg (region-beginning) end (region-end))
            (setq beg (line-beginning-position) end (line-end-position)))
        (comment-or-uncomment-region beg end)))

(global-set-key (kbd "s-/") 'comment-or-uncomment-region-or-line)
;;(global-set-key (kbd "s-?") 'uncomment-region)


;; Add custom org mode 'TODO' types
(setq org-todo-keywords
'((sequence "TODO" "INPROGRESS" "COMMITTED" "PUSHED" "PR" "MERGED" "DONE")))

;; Save all on exit
(defun save-all ()
  (interactive)
  (save-some-buffers t))


(add-hook 'focus-out-hook 'save-all)

(require 'darcula-theme)

;; for agda workshop at lambda-conf
;;(load-file (let ((coding-system-for-read 'utf-8))
;;                (shell-command-to-string "agda-mode locate")))

;; enable current line highlighting
(global-hl-line-mode)
(set-face-background hl-line-face "gray13")

;; ensime keys
(global-set-key (kbd "s-i") 'ensime-errors-at-point)

;; directories to ignore when searching
(add-to-list 'projectile-globally-ignored-directories "coverage")
(add-to-list 'projectile-globally-ignored-directories "logs")
(add-to-list 'projectile-globally-ignored-directories "target")
(add-to-list 'projectile-globally-ignored-directories "project/target")

;; Magit keybindings
(global-set-key (kbd "C-x g") 'magit-status)

;; Auto-complete
(ac-config-default)

;; Navigation
(global-set-key (kbd "s-<up>") 'beginning-of-buffer)
(global-set-key (kbd "s-<down>") 'end-of-buffer)

(helm-projectile)
