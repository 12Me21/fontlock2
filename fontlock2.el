(defmacro save-buffer-state (&rest body)
  "Bind variables according to VARLIST and eval BODY restoring buffer state."
  (declare (indent 0) (debug t))
  `(let ((inhibit-point-motion-hooks t))
     (with-silent-modifications
       ,@body)))

(defun fl2-fontify-region (beg end loudly)
  "Fontify the text between BEG and END.
If LOUDLY is non-nil, print status messages while fontifying.
This function is the default `font-lock-fontify-region-function'."
  (save-buffer-state
    (fl2-fontify beg end fl2-syntax))
    `(jit-lock-bounds ,beg . ,end));)

(defun fl2-fontify (start end syntax)
  ;(message "run %s - %s" start end)
  (setq case-fold-search nil)
  ;; todo: if we hit this limit, we should try to minimize the chance of failure
  ;; by searching for a linebreak (maybe make this configureable?)
  (setq start (previous-single-char-property-change start 'fl2-state nil (max (point-min) (- start 100000))))
  
  (setq state (or (get-text-property start 'fl2-state) 0))
  (remove-text-properties start end '('fl2-state nil 'face nil))
  (goto-char start)
  ;; iterate over characters
  (while (< (point) end)
    (setq pos (point))
    (setq rules (nth state syntax))
    (setq last-state state)
    (catch 'found
      ;; iterate over rules
      (while (setq rule (pop rules))
        (when (looking-at (car rule))
          ;; found
          (setq face (caddr rule))
          (if (functionp face)
              (setq face (funcall face (match-string 0))))
          (add-text-properties
           (match-beginning 0) (match-end 0)
           (list 'fl2-state state 'face (or face 'default)))
          (if (setq face (cadddr rule))
              (add-text-properties
               (match-beginning 1) (match-end 1)
               (list 'face (or face 'default))))
          (goto-char (match-end 0))
          (setq state (cadr rule))
          (throw 'found nil)))
      ;; not found (syntax error)
      (add-text-properties
           pos (1+ pos)
           (list 'fl2-state -1 'face 'font-lock-warning-face))
      (setq state 0)
      (goto-char (1+ pos))
      ;;(goto-char (1+ (point)))
      )
    ;; prevent 0 length matches from hanging
    ;; we also see if the state has changed, because that might matter too
    ;; however it is still possible to get in a loop if 2 states have 0 length matches which lead into each other, so be careful! I should fix this
    (unless (or (> (point) pos) (/= state last-state))
      (goto-char (1+ pos)))
    )
  ;;(remove-text-properties (point) (point-max) '(state nil))
  )

;; 1: move start backwards to the next face change
;; 2: set parser initial state to this face
;; 3: parse until end of region
;; 4: if parser exit state does not match the face at the end of the region[where?], then invalidate the data after the region, after a timeout

;;(defun fl2-next-error ()
;; todo: write function that scans for next error token
;; maybe you can give out debug info too?
;; like, we have regexes for what to expect?
;; or maybe hand write a description of the syntax?
;; mmmm

(provide 'fl2)
