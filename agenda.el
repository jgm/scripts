;; Invoke with:
;; emacs -batch -l /path/to/agenda.el 2>/dev/null

(require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(org-batch-agenda "a"
  org-agenda-include-diary nil
  org-agenda-files (quote ("~/org/todo.org")))

