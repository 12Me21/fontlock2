(require 'fl2)

(setq
 xresources-translation-events
 '("KeyPress""Key""KeyDown""Ctrl""Shift""Meta""KeyUp""KeyRelease""ButtonPress""BtnDown""Btn1Down""Btn2Down""Btn3Down""Btn4Down""Btn5Down""ButtonRelease""BtnUp""Btn1Up""Btn2Up""Btn3Up""Btn4Up""Btn5Up""MotionNotify""PtrMoved""Motion""MouseMoved""BtnMotion""Btn1Motion""Btn2Motion""Btn3Motion""Btn4Motion""Btn5Motion""EnterNotify""Enter""EnterWindow""LeaveNotify""LeaveWindow""Leave""FocusIn""FocusOut""KeymapNotify""Keymap""Expose""GraphicsExpose""GrExp""NoExpose""NoExp""VisibilityNotify""Visible""CreateNotify""Create""DestroyNotify""Destroy""UnmapNotify""Unmap""MapNotify""Map""MapRequest""MapReq""ReparentNotify""Reparent""ConfigureNotify""Configure""ConfigureRequest""ConfigureReq""GravityNotify""Grav""ResizeRequest""ResReq""CirculateNotify""Circ""CirculateRequest""CircReq""PropertyNotify""Prop""SelectionClear""SelClr""SelectionRequest""SelReq""SelectionNotify""Select""ColormapNotify""Clrmap""ClientMessage""Message""MappingNotify""Mapping"))

(setq
 xresources-translation-modifiers
 '("Shift""Lock""Ctrl""Mod1""Mod2""Mod3""Mod4""Mod5""Meta""m""h""su""a""Hyper""Super""Alt""Button1""Button2""Button3""Button4""Button5""c""s""l"))

(defun xresources-check-modifier (name)
  (if (member name xresources-translation-modifiers)
      'font-lock-builtin-face
    'font-lock-builtin-face)) ;'font-lock-warning-face))


;;NOTE: does not support C comments inside ! comments currently
(setq
 xresources-syntax
 `[
   ;; todo: we currently don't handle /* */ comments too well
   ;; the c preprocessor replaces them with a space, so anywhere a space is valid, a comment should be allowed as well. good luck!

   ( ;state 0 (start of line)
    ("^\\(!\\)\\(?:\\\\\n\\|[^\n\0]\\)*" 0 font-lock-comment-face font-lock-comment-delimiter-face) ;comment
    ("^#[\t ]*include[\t ]*.*[\t ]*" 0 font-lock-preprocessor-face) ;include
    ("\n" 0) ;eh
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
    ("/\\*\\(a\\|[^a]\\)*?\\*/" 2 font-lock-comment-delimiter-face font-lock-comment-face) ;/* c comment */
    ("/" 2 font-lock-string-face) ;normal slash
    ("\n" 0) ;end of string (dont ask me what happens at end of file)
    )

   ( ;state 3 (after start of varname)
    ;;todo: ? is not valid as last item
    ("[tT]ranslations" 5 font-lock-variable-name-face) ;(not sure if this should be case insensitive)
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
    ("/\\*[^z-a]*?\\*/" 10 font-lock-comment-face)
    ("\\\\\n" 10) ; escaped newline
    ("[\t ]*" 15)
    ("[!:]" 10 font-lock-builtin-face)
    ("" 15)
    )
   ;todo: some indicator that \ directly before colon must be fully escaped to \\\\

   ( ; state 11 (after colon)
    ("[a-zA-Z0-9_-]+" 12 font-lock-function-name-face) ;action name (technl. can be 0 chars but ehhhh)
    ("\\([ \t]\\|\\\\[t ]\\)+" 11)
    ("\\\\n" 10 font-lock-constant-face) ;backslash n
    )

   ( ;state 12 (after action name)
    ("([ \t]*" 13)
    )

   ( ;state 13 (after action open-paren)
    ;; todo: escapes in here
    ("\\(?:\".*\"\\|[^\n)\"][^\n),]*\\)?" 14 font-lock-string-face)
    )

   ( ;state 14 (after action string) 
    ("[ \t]*)" 11) ;this all seems silly but I promise it's not!
    ("[ \t]*,[ \t]*" 13) ;(I added this the next day when I found out about arguments! see i told you~!)
    )

   ( ;state 15 (modifier zone)
    ;; todo: there's also a quoted string form, which appears to be like "keysym": actions. see ParseQuotedStringEvent
    ("~?@?\\(\\$\\|\\^\\|[A-Za-z0-9][A-Za-z0-9$_-]*\\)[\t ]*" 15 xresources-check-modifier)
    ;; todo: parse the section after > properly
    ;; it uses a different parser depending on the event type
    (,(concat "<" (regexp-opt xresources-translation-events) ">\\(?:([0-9]+\\+?)\\)?[^:]*") 16 font-lock-builtin-face)
    )
   ( ;state 16 (after key sequence)
    ("[ \t]*:" 11)
    ("[ \t]*,[ \t]*" 10) ;comma: another key! ?
    )
   ])

    ;; notes: w/o parens, " is allowed anywhere except the first char
    ;; remember that \" is also ", but \\" is \"
    ;; note: chars are ignored after the closing " but we don't want to encourage that.
    ;; inside quoted strings, \\" becomes " (and remember, \" is still a real " and closes the string)
    ;; ) cannot be escaped outside of strings (I TOLD YOU! \) is literally ). \\) is \)  and on that day, many parentheses were closed.
    ;; inside strings ) doesn't need to be escpd, of course. \\) and \) are the same as outside.
    ;; newlines (remember, that's \n) are allowed in strings.
    ;; as far as I know the only \\ escape is \\"
    ;; inserting real backslashes is... difficult. if the next char is not ", you can use \\. otherwise, lol get fucked it's impossible!



(define-derived-mode xresources-mode fundamental-mode "xresources"
  "mode for x resources files"
  (setq font-lock-defaults (fl2-font-lock-defaults xresources-syntax)))

(add-to-list 'auto-mode-alist '("\\.ad\\'" . xresources-mode))
(add-to-list 'auto-mode-alist '(".Xresources\\'" . xresources-mode))

(provide 'xresources)
