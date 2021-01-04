(defun fl2-fontify-region (beg end &optional loudly)
  "To be used as `font-lock-fontify-region-function'.
Applies highlighting to the text between BEG and END
using the syntax table defined in `fl2-syntax'."
  (let ((inhibit-point-motion-hooks t))
    (with-silent-modifications
      (setq ret (fl2-fontify beg end fl2-syntax))
      `(jit-lock-bounds ,beg . ,(cadr ret)))))

(defsubst fl2-checkrules (rules)
  "Process RULES at point, apply syntax highlighting, move point forward depending on match.
Returns the new state."
  (catch 'found
    (setq pos (point))
    ;; iterate over rules
    (while (setq rule (pop rules))
      (when (looking-at (car rule))
        ;; found
        (setq face (caddr rule))
        (if (functionp face)
            (setq face (funcall face (match-string 0))))
        (add-text-properties (match-beginning 0) (match-end 0) `(face ,(or face 'default)))
        ;; this is silly and bad
        (if (setq face (cadddr rule))
            (add-text-properties (match-beginning 1) (match-end 1) `(face ,(or face 'default))))
        (if (setq face (cadddr (cdr rule)))
            (add-text-properties (match-beginning 2) (match-end 2) `(face ,(or face 'default))))
        (goto-char (match-end 0))
        (throw 'found (cadr rule))))
    ;; not found (syntax error)
    ;; todo: this adds a new text properties marker to each individual CHAR oh god
    (add-text-properties pos (1+ pos) '(face font-lock-warning-face))
    (goto-char (1+ pos))
    nil))

(defun fl2-fontify (rstart end syntax)

  (setq case-fold-search nil)
  ;; todo: if we hit this limit, we should try to minimize the chance of failure
  ;; by searching for a linebreak (maybe make this configureable?)
  ; i use setq waaaay too much here
  (setq start (previous-single-char-property-change rstart 'fl2-state nil (max (point-min) (- rstart 1000))))
  ;; todo: if we do find a valid boundary to start highlighting at, we should return the true starting point.
  ;; also, if we don't we should NOT use this text property 
  (setq state (get-text-property start 'fl2-state))
  ;(message "initial state: %s\n" state)
  (remove-text-properties start end '('fl2-state nil 'face nil))
  (goto-char start)
  (setq emptymatches 0)
  ;; iterate over characters
  (while (< (point) end)
    (setq pos (point))
    (setq old-state state) ;messy messy...
    ;; we could instead just apply the state property to
    ;; the first char,
    ;; I also wonder if it is more efficient to apply the state+face properties at the same time...
    (setq state (fl2-checkrules (aref syntax (or state 0))))
    (add-text-properties pos (point) (list 'fl2-state old-state))
    ;; prevent 0 length matches from hanging
    (if (> (point) pos)
        (setq emptymatches 0)
      (setq emptymatches (1+ emptymatches))
      (when (> emptymatches 10) ;if too many empty matches in a row, exit
        (warn "Encountered too many empty matches in a row at %s\n Exiting to prevent an infinite loop!\n" pos)
        (goto-char end)
        ))
    )
  ;;(remove-text-properties (point) (point-max) '(state nil))

  ;; Note: the highlighter can backtrack a significant distance
  ;; before starting to highlight.
  ;; however, the beginning of this region will most likely be wrong,
  ;; because it'll start in the middle of something
  ;; to compensate for this,
  ;; we lie to font-lock about where we really started at.
  '(rstart (point))
  )

(defsubst fl2-font-lock-defaults (syntax)
  "Generate a value for `font-lock-defaults' using syntax table SYNTAX.

Use when defining a mode. Ex:

(define-derived-mode example-mode fundamental-mode \"example\"
 (setq font-lock-defaults (fl2-font-lock-defaults `[
   <your syntax table>
  ])))"
  `((nil)
    nil nil nil nil
    (font-lock-fontify-region-function . fl2-fontify-region)
    (font-lock-extra-managed-props . (fl2-state))
    (fl2-syntax . ,syntax)))

(defun fl2-next-error ()
  (interactive)
  (goto-char (1+ (point)))
  (gnus-text-property-search 'fl2-state nil t t nil))

(defun fl2-next-warning ()
  (interactive)
  (goto-char (1+ (point)))
  (gnus-text-property-search 'face 'font-lock-warning-face t t nil))

(defun fl2-next-token ()
  (interactive)
  (goto-char (next-single-char-property-change (1+ (point)) 'fl2-state)))

(defun fl-delete-token ()
  (interactive)
  (kill-region
   (point)
   (previous-single-char-property-change (point) 'face)))

                                        ;(goto-char (text-property-any (1+ (point)) (point-max) 'fl2-state -1)))
;; todo: write function that scans for next error token
;; maybe you can give out debug info too?
;; like, we have regexes for what to expect?
;; or maybe hand write a description of the syntax?
;; mmmm

(provide 'fl2)
