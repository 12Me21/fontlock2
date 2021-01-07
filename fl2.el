(defvar fl2-syntax nil)

(defface fl2-error-face
  '((t . (:background "#FF9966" :foreground "#000000"))) "face for fl2 errors"
  )

(defface fl2-dim-face
  '((t . (:foreground "#AAAAAA"))) "dim face"
  )

(defsubst fl2-checkrules (rules)
  "Process RULES at point, apply syntax highlighting, move point forward depending on match.
Returns the new state."
  (let ((pos (point)))
    (catch 'found
      ;; iterate over rules
      (dolist (rule rules)
        (catch 'matched
;          (if (integerp rule) ;;fallthrough
;              (throw 'found rule))
          (when (looking-at (car rule))
            ;; found
            (let ((faces (cdr rule)))
              (when (functionp faces)
                (setq faces (funcall faces (match-string 0)))
                (unless faces ;if function returns nil, this match failed actually
                  (throw 'matched nil)))
              (let ((newstate (pop faces))
                    (i 0))
                (dolist (face (or faces '(default)))
                  (put-text-property (match-beginning i) (match-end i) 'face face)
                  (setq i (1+ i)))
                (goto-char (or (match-beginning 9) (match-end 0)))
                ;;(goto-char (match-end 0))
                (throw 'found newstate))))))
      ;; not found (syntax error)
      ;; todo: this adds a new text properties marker to each individual CHAR oh god
      (put-text-property pos (1+ pos) 'face 'fl2-error-face)
      (goto-char (1+ pos))
      nil)))

(defsubst fl2-pick-start (rstart)
  "Search backwards in the buffer for the previous fl2-state change.
Move point to the start of this property, and return the state.
This search is limited to 100000 characters for performance reasons.
If a boundary is not found, the point is still moved, and the function returns nil."
  (let* ((limit (max (point-min) (- rstart 100000)))
         (start (previous-single-char-property-change rstart 'fl2-state nil limit)))
    (goto-char start)
    (if (= start limit)
        nil
      (get-text-property start 'fl2-state))))

(defsubst fl2-fontify (rstart end syntax)
  ;; todo: if we do find a valid boundary to start highlighting at, we should return the true starting point maybe
  (let ((start-time (current-time))
        (emptymatches 0)
        (state (fl2-pick-start rstart))
        (start-point (point)))
    (remove-text-properties (point) end '(fl2-state nil face nil))
    ;; iterate over characters
    (setq case-fold-search nil)
    (while (< (point) end)
      (let ((pos (point))
            (old-state state))
        ;; we could instead just apply the state property to
        ;; the first char,
        ;; I also wonder if it is more efficient to apply the state+face properties at the same time...
        (setq state (fl2-checkrules (aref syntax (or state 0))))
        (put-text-property pos (point) 'fl2-state old-state)
        ;; prevent 0 length matches from hanging
        (if (> (point) pos)
            (setq emptymatches 0)
          (setq emptymatches (1+ emptymatches))
          (when (> emptymatches 10) ;if too many empty matches in a row, exit
            (warn "Encountered too many empty matches in a row at %s\n Exiting to prevent an infinite loop!\n" pos)
            (goto-char end)
            ))))
    ;(message "fontify: %s to %s\n%s chars in %s" start-point (point) (- (point) start-point) (float-time (time-subtract (current-time) start-time)))
    )
  (list rstart (point)))
  ;;(remove-text-properties (point) (point-max) '(state nil))

  ;; Note: the highlighter can backtrack a significant distance
  ;; before starting to highlight.
  ;; however, the beginning of this region will most likely be wrong,
  ;; because it'll start in the middle of something
  ;; to compensate for this,
  ;; we lie to font-lock about where we really started at.
  ;; but this is probably bad, because it means text could be mishighlighted without font lock knowing...

(defun fl2-fontify-region (beg end &optional loudly)
  "To be used as `font-lock-fontify-region-function'.
Applies highlighting to the text between BEG and END
using the syntax table defined in `fl2-syntax'."
  ;; I'm not sure entirely how this works, but this is what font-lock does
  (let ((inhibit-point-motion-hooks t))
    (with-silent-modifications
      (let ((ret (fl2-fontify beg end fl2-syntax)))
        `(jit-lock-bounds ,beg . ,(cadr ret))))))

(defun fl2-syntax-error (staten rulen message ext)
  (error
   "fl2: Error in syntax definition
state: %s, rule: %s\n%s: %s"
   staten rulen
   message ext))

(defun fl2-check-syntaxdef (syntax)
  "Check if a syntax definition is valid. Throws an error if not."
  (unless (arrayp syntax)
    (signal 'wrong-type-argument `(arrayp ,syntax)))
  (let ((max-state (1- (length syntax))))
    (unless (>= max-state 1)
      (fl2-syntax-error 0 nil "Need at least one state" max-state))
    ;; For each state
    (dotimes (i (length syntax))
      (let ((state (aref syntax i))
            (j -1))
        (unless (listp state)
          (fl2-syntax-error i nil "State should be list" state))
          ;; For each rule
          (dolist (rule state)
            (setq j (1+ j))
       ;     (unless (integerp rule)
              (unless (consp rule)
                (fl2-syntax-error i j "Rule should be list (or cons)" rule))
              (let ((regexp (car rule))
                    (rest (cdr rule)))
                (unless (stringp regexp)
                  (fl2-syntax-error i j "First item in rule should be regexp string" regexp))
                ;; Check if regexp is valid
                (condition-case err
                    (progn
                      (when (string-match regexp " " 1)
                        ;;If a rule matches the empty string, rules after it will never run
                        ;; (UNLESS maybe if it uses a validator function)
                        ;; empty-matching rules at the end of the list are fine,
                        ;; _as long as they change the state_.
                        ;; However, we should also check if there are any cycles.
                        ;;(unless (= j (1- (length state)))
                        ;; todo: if the rule uses anchors (or \b?), it might still be valid. we need to account for this before enabling this test.
                        ;;(fl2-syntax-error i j "Rule matches empty string and isn't final rule" regexp)
                        ;;)
                        ))
                  (invalid-regexp
                   (fl2-syntax-error i j "Invalid regexp" regexp)))
                ;; todo: check if regexp is valid
                ;; if rule was a list:
                (if (listp rest)
                    ;; normal rule
                    (let ((new-state (pop rest)))
                      (unless (integerp new-state)
                        (fl2-syntax-error i j "Second item in list rule should be state number" new-state))
                      (unless (>= new-state 0)
                        (fl2-syntax-error i j "New state number should be >= 0" new-state))
                      (unless (<= new-state max-state)
                        (fl2-syntax-error i j "New state number out of range" new-state))
                      ;; For each face
                      (dolist (face rest)
                        (unless (facep face)
                          (fl2-syntax-error i j "Invalid face" face))))
                  ;; function rule
                  (unless (functionp rest)
                    (fl2-syntax-error i j "Car of cons rule should be function" rest)));)
              )))))
  t)


(defun fl2-font-lock-defaults (syntax)
  "Generate a value for `font-lock-defaults' using syntax table SYNTAX.

Use when defining a mode. Ex:

(define-derived-mode example-mode fundamental-mode \"example\"
 (setq font-lock-defaults (fl2-font-lock-defaults `[
   <your syntax table>
  ])))"
  (fl2-check-syntaxdef syntax)
  `((nil)
    nil nil nil nil
    (font-lock-fontify-region-function . fl2-fontify-region)
    (font-lock-extra-managed-props . (fl2-state))
    (fl2-syntax . ,syntax)))

;; (defun fl2-next-warning ()
;;   (interactive)
;;   (goto-char (1+ (point)))
;;   (text-property-search-forward 'fl2-state 'font-lock-warning-face t t))

(provide 'fl2)
