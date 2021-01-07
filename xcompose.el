(require 'fl2)

;; Sources:
;; libX11/modules/im/ximcp/imLcPrs.c


(setq
 xcompose-syntax
 `[
   ( ; state 0: start of line
    ("[ \t]+" 0) ; observation: if a regexp is the first one in a state, and it does not change the state, it could effectively be prepended to every regex in the state (excluding ones starting with ^, \b, etc)
    ("include\\(?9:[^A-Za-z0-9_-]\\|$\\)" 1 font-lock-preprocessor-face) ;todo: validate
    ("#.*" 0 font-lock-comment-face)
    ("\n" 0)
    ("" 5) ;todo: maybe have this encoded as (5) or 5 instead.
    )
   ( ; state 1: after `include`
    ("[ \t]+" 1) ;todo: make state num optional here?
    ("\"" 2 font-lock-string-face)
    ("[A-Za-z0-9_-]+" 4 font-lock-string-face)
    )
   ( ; state 2: inside include string
    ("\\(\\\\\\([\\\"nrt]\\|[0-7]\\{,3\\}\\|[xX][0-9A-Fa-f]\\{1,2\\}\\)\\|[^\\\"\n]\\)*" 3 font-lock-string-face)
    )
   ( ; state 3: after include string (honestly this could have been one state)
    ("\"" 4 font-lock-string-face)
    )
   ( ; state 4: end of line
    ("[ \t]+" 4)
    ("#.*\\(\n\\|$\\)" 0 font-lock-comment-face)
    ("\n" 0)
    )
   ( ; state 5 start of modifiers
    ("[ \t]+" 5)
    ("None\\(?9:[^A-Za-z0-9_-]\\)" 8 font-lock-constant-face)
    ("!" 6 font-lock-constant-face)
    ("" 6)
    )
   ( ;state 6
    ("[ \t]+" 6)
    ("~" 7 font-lock-constant-face)
    ("" 7)
    )
   ( ;state 7: modifiers
    ("[ \t]+" 7)
    ("\\(Ctrl\\|Lock\\|Caps\\|Shift\\|Alt\\|Meta\\)\\(?9:[^A-Za-z0-9_-]\\)" 6 font-lock-constant-face)
    ("" 8)
    )
   ( ;state 8: key
    ("[ \t]+" 8)
    ("<" 12 fl2-dim-face)
    )
   (; state 9: next press
    ("[ \t]+" 9)
    (":" 10)
    ("" 5)
    )
   (; state 10: after keyLIST!!!
    ("[ \t]+" 10)
    ("\"" 14 font-lock-string-face)
    ("[A-Za-z0-9_-]+" 4)
    )
   ( ;state 11
    ("[ \t]+" 11)
    ("[A-Za-z0-9_-]+" 4 font-lock-function-name-face) ;todo: validate?
    ("" 4)
    )
   ( ;state 12
    ("[ \t]+" 12)
    ("[A-Za-z0-9_-]+" 13 font-lock-variable-name-face) ;todo: validate?
    )
   (;state 13
    ("[ \t]+" 12)
    (">" 9 fl2-dim-face)
    )
   (;state 14
    ("\\(\\\\\\([\\\"nrt]\\|[0-7]\\{,3\\}\\|[xX][0-9A-Fa-f]\\{1,2\\}\\)\\|[^\\\"\n]\\)*" 15 font-lock-string-face)
    )
   (;state 15
    ("\"" 11 font-lock-string-face)
    )
   ])


(define-derived-mode xcompose-mode fundamental-mode "xcompose"
  "mode for x compose files"
  (setq font-lock-defaults (fl2-font-lock-defaults xcompose-syntax))
  )

(add-to-list 'auto-mode-alist '("Compose\\'" . xcompose-mode))

(provide 'xcompose)
