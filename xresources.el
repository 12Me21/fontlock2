(require 'fl2)

;;NOTE: does not support C comments inside ! comments currently
(setq
 xresources-syntax
 '(
   ;; todo: we currently don't handle /* */ comments too well
   ;; the c preprocessor replaces them with a space, so anywhere a space is valid, a comment should be allowed as well. good luck!
   ( ;state 0 (start of line)
    ("^!\\(\\\\\n\\|[^\n\0]\\)*" 0 font-lock-comment-face) ;comment
    ("^#[\t ]*include[\t ]*.*[\t ]*" 0 font-lock-preprocessor-face) ;include
    ("^[\t ]*$" 0) ;blank lines
    ("^[\t ]*[.*]*" 3) ;variable
    )
   ( ;state 1 (after varname)
    ("[.*]+" 3) ;binding
    ("[\t ]*:[\t ]*" 4) ;colon
    )
   ( ;state 2 (after colon)
    ("\\\\\n" 2) ;escaped newline
    ("\\\\\\([0-7][0-7][0-7]\\|[\tn \\]\\)" 2 font-lock-constant-face) ;backslash escape
    ("\\\\" 2 warning) ;invalid \ (treated as single backslash)
    ("[^\\\n\0/]+" 2 font-lock-string-face) ;normal part of string
    ;; technically xrdb uses the c preprocessor
    ;; so /* */ comments can exist almost anywhere
    ;; however, that's annoying to support...
    ("/\\*\\(a\\|[^a]\\)*?\\*/" 2 font-lock-comment-face) ;/* c comment */
    ("/" 2 font-lock-string-face) ;normal slash
    ("\n" 0) ;end of string (dont ask me what happens at end of file)
    )
   ( ;state 3 (after start of varname)
    ;;todo: ? is not valid as last item
    ("translations" 5 font-lock-variable-name-face)
    ("\\([A-Z][a-zA-Z0-9_-]+\\|\\?\\)" 1 font-lock-type-face) ;uppercased name
    ("\\([a-zA-Z0-9_-]+\\|\\?\\)" 1 font-lock-variable-name-face) ;name
    )
   ( ;state 4 (immediately after colon)
    ("[0-9][0-9.e]*" 2 font-lock-constant-face) ;number
    ("" 2) ;not number
    )
   ( ;state 5 (might be translations!)
    ("[\t ]*:[\t ]*" 8) ; yeahhhh
    ("" 1) ;nope
    )
   () ;reserved space
   ()
   ;; the rest of the states are for parsing x translations
   ( ;state 8 (start of x translations string)
    ("#[a-z]+[\t ]*" 9 font-lock-keyword-face);#override or whatev
    )
   ( ;state 9 (translation end of line)
    ("\\\\n" 10 font-lock-constant-face)
    ("\n" 0 font-lock-constant-face)
    )
   ( ;state 10 (trans. start of line)
    ("\\\\\n" 10) ; escaped newline
    ("[\t ]*\\([^:\n\\/]\\|\\\\\\([0-7][0-7][0-7]\\|[\tn \\]\\)\\|\\\\\n\\)+" 10 font-lock-variable-name-face) ; normal
    (":[\t ]*" 11)
    ("/\\*\\(a\\|[^a]\\)*?\\*/" 10 font-lock-comment-face) ;/* c comment */
    ("/" 10 font-lock-variable-name-face)
    )
   ( ; state 11 (after colon)
    ("\\([^\n\\]\\|\\\\\\([0-7][0-7][0-7]\\|[\t \\]\\)\\|\\\\\n\\)*" 9 font-lock-string-face)
    ("\\\\n" 10 font-lock-constant-face) ;backslash n
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

