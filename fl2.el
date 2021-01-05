(defun fl2-fontify-region (beg end &optional loudly)
  "To be used as `font-lock-fontify-region-function'.
Applies highlighting to the text between BEG and END
using the syntax table defined in `fl2-syntax'."
  ;; I'm not sure entirely how this works, but this is what font-lock does
  (let ((inhibit-point-motion-hooks t))
    (with-silent-modifications
      (let ((ret (fl2-fontify beg end fl2-syntax)))
        `(jit-lock-bounds ,beg . ,(cadr ret))))))

(defsubst fl2-checkrules (rules)
  "Process RULES at point, apply syntax highlighting, move point forward depending on match.
Returns the new state."
  (catch 'found
    (let ((pos (point)))
      ;; iterate over rules
      (dolist (rule rules)
        (catch 'matched
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
                  (add-text-properties (match-beginning i) (match-end i) (list 'face face))
                  (setq i (1+ i)))
                (goto-char (match-end 0))
                (throw 'found newstate)))))))
      ;; not found (syntax error)
      ;; todo: this adds a new text properties marker to each individual CHAR oh god
      (add-text-properties pos (1+ pos) '(face font-lock-warning-face))
      (goto-char (1+ pos))
      nil))

(defsubst fl2-pick-start (rstart)
  "Search backwards in the buffer for the previous fl2-state change.
Move point to the start of this property, and return the state.
This search is limited to 1000 characters for performance reasons.
If a boundary is not found, the point is still moved, and the function returns nil."
  (let* ((limit (max (point-min) (- rstart 1000)))
         (start (previous-single-char-property-change rstart 'fl2-state nil limit)))
    (goto-char start)
    (if (= start limit)
        nil
      (get-text-property start 'fl2-state))))

(defun fl2-fontify (rstart end syntax)
  ;; todo: if we do find a valid boundary to start highlighting at, we should return the true starting point maybe
  (let ((emptymatches 0)
        (state (fl2-pick-start rstart)))
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
            )))))
  (list rstart (point)))
  ;;(remove-text-properties (point) (point-max) '(state nil))

  ;; Note: the highlighter can backtrack a significant distance
  ;; before starting to highlight.
  ;; however, the beginning of this region will most likely be wrong,
  ;; because it'll start in the middle of something
  ;; to compensate for this,
  ;; we lie to font-lock about where we really started at.
  ;; but this is probably bad, because it means text could be mishighlighted without font lock knowing...

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
  (text-property-search-forward 'face 'font-lock-warning-face t t))

;; this doesn;t work!
(defun fl2-check-definition (def)
  (unless (arrayp def)
    (signal 'wrong-type-argument (list 'arrayp def)))
  (dotimes (i (length def))
    (setq rules (aref def i))
    (unless (listp rules)
      (error "state %d: state was type %s (expected list)" i (type-of rules)))
    (setq j 0)
    (dolist (rule rules)
      (if (and (consp rule) (not (listp rule)))
          ;; function rule
          (unless (and (stringp (car rule)) (functionp (cdr rule)))
            (error "state %d, rule %d: cons rule had types %s . %s (expected string . function)" i j (type-of (car rule)) (type-of (cdr rule))))
        ;; normal rule
        (unless (listp rule)
          (error "state %d, rule %d: rule was type %s (expected list or cons)" i j (type-of rule)))
        (setq regexp (pop rule))
        (unless (stringp regexp)
          (error "state %d, rule %d: first item in rule was type %s (expected string)" i j (type-of regexp)))
        ;;todo: check if regexp is valid
        (setq num (pop rule))
        (unless (numberp num)
          (error "state %d, rule %d: second item in rule was type %s (expected number)" i j (type-of num)))
        (setq k 0)
        (dolist (face rule)
          (unless (facep face)
            (error "state %d, rule %d, face %d: face was type %s (expected face)" i j k (type-of face)))
          (setq k (1+ k))))
        (setq j (1+ j))))
  t)

(provide 'fl2)
