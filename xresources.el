(require 'fl2)

;;NOTE: does not support C comments inside ! comments currently
(setq
 xresources-syntax
 '(
   ( ;state 0
    ("/\\*\\(a\\|[^a]\\)*?\\*/" 0 font-lock-comment-face)
    ("^!" 3 font-lock-comment-face)
    ("^[ \n	]+" 0)
    ("[A-Z][A-Za-z0-9.*]*" 1 font-lock-variable-name-face)
    ("[a-z][A-Za-z0-9.*]+" 1 font-lock-variable-name-face)
    ("\\\\\n" 0)
    )
   ( ;state 1
    ("/\\*\\(a\\|[^a]\\)*?\\*/" 1 font-lock-comment-face)
    ("\\\\\n" 1)
    (":" 2)
    )
   ( ;state 2
    ("/\\*\\(a\\|[^a]\\)*?\\*/" 2 font-lock-comment-face)
    ("\\\\\n" 2)
    ;("\\\\\\(?:\\\\\\|\n\\|n\\|[0-9]+\\)" 2 font-lock-constant-face)
    ("[^\n]" 2 font-lock-string-face)
    ("" 0)
    )
   ( ;state 3
    ("[^\n\0]*\\\\\n" 3 font-lock-comment-face)
    ("[^\n\0]" 0 font-lock-comment-face)
    )
   ))

(define-derived-mode xresources-mode fundamental-mode "xresources"
  "mode for x resources files"
  (setq font-lock-defaults
        `((nil)
          nil nil nil nil
          (font-lock-fontify-region-function . fl2-fontify-region)
          (fl2-syntax . ,xresources-syntax))))

(add-to-list 'auto-mode-alist '("\\.ad\\'" . xresources-mode))
(add-to-list 'auto-mode-alist '(".Xresources\\'" . xresources-mode))

