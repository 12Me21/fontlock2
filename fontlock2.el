;(defface terminfo-escape-percent
                                        ;  '((t . (:foreground "#808080")))
                                        ;  "face for terminfo escape sequences")

(defface terminfo-escape-percent
  '((t . (:inherit 'font-lock-string-face :background "#EEEEEE" :underline t)))
  "face for terminfo escape sequences")

(defface terminfo-string-face
  '((t . (:inherit 'font-lock-string-face)))
  "copy of font-lock-string-face. do not modify this")

(defface terminfo-escape
  '((t . (:inherit 'font-lock-string-face :background "#E8F0FF" :bold t :underline t)))
  "face for terminfo escape sequences")

                                        ;(defface terminfo-escape
                                        ;  '((t . (:foreground "#2050FF" :bold t)))
                                        ;  "face for terminfo escape sequences")

(defvar terminfo-booleans '("bw" "am" "bce" "ccc" "xhp" "xhpa" "cpix"
                            "crxm" "xt" "xenl" "eo" "gn" "hc" "chts" "km" "daisy" "hs" "hls"
                            "in" "lpix" "da" "db" "mir" "msgr" "nxon" "xsb" "npc" "ndscr"
                            "nrrmc" "os" "mc5i" "xvpa" "sam" "eslok" "hz" "ul" "xon"))

(defvar terminfo-numeric '("cols" "it" "lh" "lw" "lines" "lm" "xmc"
                           "ma" "colors" "pairs" "wnum" "ncv" "nlab" "pb" "vt" "wsl" "bitwin"
                           "bitype" "bufsz" "btns" "spinh" "spinv" "maddr" "mjump" "mcs" "mls"
                           "npins" "orc" "orhi" "orl" "orvi" "cps" "widcs"))

(defvar terminfo-string '("acsc" "cbt" "bel" "cr" "cpi" "lpi" "chr"
                          "cvr" "csr" "rmp" "tbc" "mgc" "clear" "el1" "el" "ed" "hpa" "cmdch"
                          "cwin" "cup" "cud1" "home" "civis" "cub1" "mrcup" "cnorm" "cuf1"
                          "ll" "cuu1" "cvvis" "defc" "dch1" "dl1" "dial" "dsl" "dclk" "hd"
                          "enacs" "smacs" "smam" "blink" "bold" "smcup" "smdc" "dim" "swidm"
                          "sdrfq" "smir" "sitm" "slm" "smicm" "snlq" "snrmq" "prot" "rev"
                          "invis" "sshm" "smso" "ssubm" "ssupm" "smul" "sum" "smxon" "ech"
                          "rmacs" "rmam" "sgr0" "rmcup" "rmdc" "rwidm" "rmir" "ritm" "rlm"
                          "rmicm" "rshm" "rmso" "rsubm" "rsupm" "rmul" "rum" "rmxon" "pause"
                          "hook" "flash" "ff" "fsl" "wingo" "hup" "is1" "is2" "is3" "if"
                          "iprog" "initc" "initp" "ich1" "il1" "ip" "ka1" "ka3" "kb2" "kbs"
                          "kbeg" "kcbt" "kc1" "kc3" "kcan" "ktbc" "kclr" "kclo" "kcmd" "kcpy"
                          "kcrt" "kctab" "kdch1" "kdl1" "kcud1" "krmir" "kend" "kent" "kel"
                          "ked" "kext" "kf0" "kf1" "kf10" "kf11" "kf12" "kf13" "kf14" "kf15"
                          "kf16" "kf17" "kf18" "kf19" "kf2" "kf20" "kf21" "kf22" "kf23" "kf24"
                          "kf25" "kf26" "kf27" "kf28" "kf29" "kf3" "kf30" "kf31" "kf32" "kf33"
                          "kf34" "kf35" "kf36" "kf37" "kf38" "kf39" "kf4" "kf40" "kf41" "kf42"
                          "kf43" "kf44" "kf45" "kf46" "kf47" "kf48" "kf49" "kf5" "kf50" "kf51"
                          "kf52" "kf53" "kf54" "kf55" "kf56" "kf57" "kf58" "kf59" "kf6" "kf60"
                          "kf61" "kf62" "kf63" "kf7" "kf8" "kf9" "kfnd" "khlp" "khome" "kich1"
                          "kil1" "kcub1" "kll" "kmrk" "kmsg" "kmov" "knxt" "knp" "kopn" "kopt"
                          "kpp" "kprv" "kprt" "krdo" "kref" "krfr" "krpl" "krst" "kres"
                          "kcuf1" "ksav" "kBEG" "kCAN" "kCMD" "kCPY" "kCRT" "kDC" "kDL" "kslt"
                          "kEND" "kEOL" "kEXT" "kind" "kFND" "kHLP" "kHOM" "kIC" "kLFT" "kMSG"
                          "kMOV" "kNXT" "kOPT" "kPRV" "kPRT" "kri" "kRDO" "kRPL" "kRIT" "kRES"
                          "kSAV" "kSPD" "khts" "kUND" "kspd" "kund" "kcuu1" "rmkx" "smkx"
                          "lf0" "lf1" "lf10" "lf2" "lf3" "lf4" "lf5" "lf6" "lf7" "lf8" "lf9"
                          "fln" "rmln" "smln" "rmm" "smm" "mhpa" "mcud1" "mcub1" "mcuf1"
                          "mvpa" "mcuu1" "nel" "porder" "oc" "op" "pad" "dch" "dl" "cud"
                          "mcud" "ich" "indn" "il" "cub" "mcub" "cuf" "mcuf" "rin" "cuu"
                          "mcuu" "pfkey" "pfloc" "pfx" "pln" "mc0" "mc5p" "mc4" "mc5" "pulse"
                          "qdial" "rmclk" "rep" "rfi" "rs1" "rs2" "rs3" "rf" "rc" "vpa" "sc"
                          "ind" "ri" "scs" "sgr" "setb" "smgb" "smgbp" "sclk" "scp" "setf"
                          "smgl" "smglp" "smgr" "smgrp" "hts" "smgt" "smgtp" "wind" "sbim"
                          "scsd" "rbim" "rcsd" "subcs" "supcs" "ht" "docr" "tsl" "tone" "uc"
                          "hu" "u0" "u1" "u2" "u3" "u4" "u5" "u6" "u7" "u8" "u9" "wait"
                          "xoffc" "xonc" "zerom" "use" "scesa" "bicr" "binel" "birep" "csnm"
                          "csin" "colornm" "defbi" "devt" "dispc" "endbi" "smpch" "smsc"
                          "rmpch" "rmsc" "getm" "kmous" "minfo" "pctrm" "pfxl" "reqmp" "scesc"
                          "s0ds" "s1ds" "s2ds" "s3ds" "setab" "setaf" "setcolor" "smglr"
                          "slines" "smgtb" "meml" "memu"))

;; this doesn't work, I can't get it to pass input
;; through stdin
(defun terminfo-tic ()
  (interactive)
  (let ((process (start-process "tic" nil "tic" "-x" "-")))
    (process-send-string process (buffer-string))
    (process-send-eof process)))

(setq terminfo-string-regexp
      "\\(?:\\^.\\|\\\\.\\|[^,\n]\\)*")

(setq terminfo-value-regexp ; outputs to regexp groups 4,5
      (concat "[ \t\n]*\\(?:#\\(?4:[a-zA-Z0-9]*\\)\\|=\\(?5:" terminfo-string-regexp "\\)\\|\\)"))

(setq terminfo-escape-regexp ;outputs to groups 1,2,3
      "\\(?1:\\\\.\\|\\^.\\)\\|\\(?:\\(?2:%\\)\\(?3:[%csl+\\-\\*/&|^=><AO!~i?te;]\\|[\\-+# ]?[0-9]*\\(?:\\.[0-9]*\\)?[doxXs]\\|p[0-9]\\|[Pg][A-Za-z]\\|'.'\\|{[0-9]*}\\)\\)\\|\\(?4:\\$<.*>\\)")

(defmacro terminfo-subhighlight (regexp inside)
  "Generate a lambda which highlights tokens matching REGEXP if they are inside of a token with face INSIDE"
  ;; this is taken from `lisp-mode.el'
  `(lambda (bound)
     (catch 'found
       (while (re-search-forward ,regexp bound t)
         ;; what does `point' mean here?
         (let ((face (get-text-property (1- (point)) 'face)))
           (when (or (and (listp face)
                          (memq ,inside face))
                     (eq ,inside face))
             (throw 'found t)))))))

(setq terminfo-highlights
      `(
        ("^\\(#[^\n]*\\)" (1 'font-lock-comment-face))
        ("^\\([0-9a-zA-Z][0-9a-zA-Z\\-]*\\)|" (1 'font-lock-type-face))
        (,(concat "\\(?1:\\.[0-9a-zA-Z_]+" terminfo-value-regexp "\\)") (1 'font-lock-comment-face))
        (,(concat "\\b" "\\(?1:[a-zA-Z0-9_]+\\)" terminfo-value-regexp)
         (1 'font-lock-variable-name-face)
         (4 'font-lock-string-face nil t)
         (5 'terminfo-string-face nil t)
         (t 5 (
                ("\\(%\\)" (1 'terminfo-escape-percent t t))
                 ))
         )
        ("." (0 'error))
        ))

(defmacro save-buffer-state (&rest body)
  "Bind variables according to VARLIST and eval BODY restoring buffer state."
  (declare (indent 0) (debug t))
  `(let ((inhibit-point-motion-hooks t))
     (with-silent-modifications
       ,@body)))

(defun terminfo-fontify-region (beg end loudly)
  "Fontify the text between BEG and END.
If LOUDLY is non-nil, print status messages while fontifying.
This function is the default `font-lock-fontify-region-function'."
  
  (save-buffer-state
   ;; Use the fontification syntax table, if any.
   (with-syntax-table (or font-lock-syntax-table (syntax-table))
     ;; Extend the region to fontify so that it starts and ends at
     ;; safe places.
     (let ((funs font-lock-extend-region-functions)
           (font-lock-beg beg)
           (font-lock-end end))
       (while funs
         (setq funs (if (or (not (funcall (car funs)))
                            (eq funs font-lock-extend-region-functions))
                        (cdr funs)
                      ;; If there's been a change, we should go through
                      ;; the list again since this new position may
                      ;; warrant a different answer from one of the fun
                      ;; we've already seen.
                      font-lock-extend-region-functions)))
       (setq beg font-lock-beg end font-lock-end))
     ;; Now do the fontification.
     (font-lock-unfontify-region beg end)
     ;;(terminfo-fontify-region2 beg end loudly)
     (fl2-fontify-region beg end fl2-syntax-terminfo 0)
     `(jit-lock-bounds ,beg . ,end))))



(defun fontlock2-fontify-region (start end keywords)
  "heck"
  (message "%s\n" keywords)
  (goto-char start)
  (while (and (< (point) end))
    (let ((matchers keywords))
      (while matchers
        (when (looking-at (caar matchers))
          (setq highlights (cdr (car matchers)))
          (while highlights
            (setq highlight (car highlights))
            (if (numberp (car highlight))
              (font-lock-apply-highlight highlight)
              (setq extra (nth 3 highlights)))
            (when (eq (car highlight) t)
              (setq m (car (cdr highlight)))
              (when (match-beginning m)
                (setq pt (point))
                (fontlock2-fontify-region (match-beginning m) (match-end m) (car (cdr (cdr highlight))))
                (goto-char pt))
              )
            (setq highlights (cdr highlights)))
          (setq matchers nil)
          (goto-char (- (match-end 0) 1)))
        (setq matchers (cdr matchers))))
    (goto-char (1+ (point)))))

(defun terminfo-fontify-region2 (start end &optional loudly)
  "eee"
  (unless (eq (car font-lock-keywords) t)
    (setq font-lock-keywords
          (font-lock-compile-keywords font-lock-keywords)))
  (fontlock2-fontify-region start end (cddr font-lock-keywords)))

(define-derived-mode terminfo-mode fundamental-mode "terminfo"
  "mode for highlighting terminfo files"
  (setq font-lock-defaults
        '((terminfo-highlights)
          nil nil nil nil
          (font-lock-fontify-region-function . terminfo-fontify-region))))

(add-to-list 'auto-mode-alist '("\\.term\\'" . terminfo-mode))

(defun fl2-fontify-region (start end syntax)
  (setq start (previous-char-property-change start))
  (setq state (or (get-text-property start 'state) 0))
  (remove-text-properties start (point-max) '(state nil 'face nil))
  (goto-char start)
  ;; iterate over characters
  (while (< (point) end)
    (setq pos (point))
    (setq rules (nth (car state) syntax))
    (catch 'found
      ;; iterate over rules
      (while (setq rule (pop rules))
        (when (looking-at (car rules))
          ;; found
          (add-text-properties
           (match-start 0) (match-end 0)
           (list 'state (car state) 'face (caddr rules)))
          (goto-char (match-end 0))
          (setcar state (cadr rules))
          (throw 'found)))
      ;; not found (syntax error)
      (add-text-properties
           (point) (point)
           (list 'state -1 'face 'error))
      ;;(goto-char (1+ (point)))
      )
    ;; prevent 0 length matches from hanging
    (unless (> (point) pos)
      (goto-char (1+ (point))))
    )
  ;;(remove-text-properties (point) (point-max) '(state nil))
  )


;; 1: move start backwards to the next face change
;; 2: set parser initial state to this face
;; 3: parse until end of region
;; 4: if parser exit state does not match the face at the end of the region[where?], then invalidate the data after the region, after a timeout

