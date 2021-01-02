(require 'fl2)

(defface terminfo-escape-percent
  '((t . (:inherit 'font-lock-string-face :background "#EEEEEE" :underline t)))
  "face for terminfo escape sequences")

(defface terminfo-string-face
  '((t . (:inherit 'font-lock-string-face)))
  "copy of font-lock-string-face. do not modify this")

(defface terminfo-escape
  '((t . (:inherit 'font-lock-string-face :background "#E8F0FF" :bold t :underline t)))
  "face for terminfo escape sequences")

(defvar terminfo-booleans '("bw""am""bce""ccc""xhp""xhpa""cpix""crxm""xt""xenl""eo""gn""hc""chts""km""daisy""hs""hls""in""lpix""da""db""mir""msgr""nxon""xsb""npc""ndscr""nrrmc""os""mc5i""xvpa""sam""eslok""hz""ul""xon"))

(defvar terminfo-user-booleans '("AX""G0""XT""RGB"
                                 "OTpt""OTbs""OTnc""OTbc"))

(defvar terminfo-numeric '("cols""it""lh""lw""lines""lm""xmc""ma""colors""pairs""wnum""ncv""nlab""pb""vt""wsl""bitwin""bitype""bufsz""btns""spinh""spinv""maddr""mjump""mcs""mls""npins""orc""orhi""orl""orvi""cps""widcs"))

(defvar terminfo-user-numeric '("CO""U8""OTkn""OTug""OTdN"))

(defvar terminfo-user-string '("E0""S0"
                               "kDC3""kDC4""kDC5""kDC6""kDC7""kDN""kDN3""kDN4""kDN5""kDN6""kDN7""kEND3""kEND4""kEND5""kEND6""kEND7""kHOM3""kHOM4""kHOM5""kHOM6""kHOM7""kIC3""kIC4""kIC5""kIC6""kIC7""kLFT3""kLFT4""kLFT5""kLFT6""kLFT7""kNXT3""kNXT4""kNXT5""kNXT6""kNXT7""kPRV3""kPRV4""kPRV5""kPRV6""kPRV7""kRIT3""kRIT4""kRIT5""kRIT6""kRIT7""kUP""kUP3""kUP4""kUP5""kUP6""kUP7""ka2""kb1""kb3""kc2""kF1""kF2""kF3""kF4""kF5""kF6""kF7""kF8""kF9""kF10""kF11""kF12""kF13""kF14""kF15""kF16"
                               "Cr""Cs""Ms""TS""XM""xm""E3"
                               "gsbom""grbom""rmxx""smxx""Smulx"
                               "OTnl"
                               "kEND8""kHOM8"
                               "kp1""kp2""kp3""kp4""kp5""kp6""kp7""kp8""kp9""kpADD""kpDIV""kpDOT""kpMUL""kpNUM""kpSUB""kpZRO"
                               "setal""opaq""Rmol""Smol""blink2""norm""smul2"
                               "kpCMA""Se""Ss""OTi2""OTma""C0""XC""WS""Z1"
                               ))

;; I want to put this on one line but it lags emacs lol
(defvar terminfo-string'("acsc""cbt""bel""cr""cpi""lpi""chr"
"cvr""csr""rmp""tbc""mgc""clear""el1""el""ed""hpa""cmdch"
"cwin""cup""cud1""home""civis""cub1""mrcup""cnorm""cuf1"
"ll""cuu1""cvvis""defc""dch1""dl1""dial""dsl""dclk""hd"
"enacs""smacs""smam""blink""bold""smcup""smdc""dim""swidm"
"sdrfq""smir""sitm""slm""smicm""snlq""snrmq""prot""rev"
"invis""sshm""smso""ssubm""ssupm""smul""sum""smxon""ech"
"rmacs""rmam""sgr0""rmcup""rmdc""rwidm""rmir""ritm""rlm"
"rmicm""rshm""rmso""rsubm""rsupm""rmul""rum""rmxon""pause"
"hook""flash""ff""fsl""wingo""hup""is1""is2""is3""if"
"iprog""initc""initp""ich1""il1""ip""ka1""ka3""kb2""kbs"
"kbeg""kcbt""kc1""kc3""kcan""ktbc""kclr""kclo""kcmd""kcpy"
"kcrt""kctab""kdch1""kdl1""kcud1""krmir""kend""kent""kel"
"ked""kext""kf0""kf1""kf10""kf11""kf12""kf13""kf14""kf15"
"kf16""kf17""kf18""kf19""kf2""kf20""kf21""kf22""kf23""kf24"
"kf25""kf26""kf27""kf28""kf29""kf3""kf30""kf31""kf32""kf33"
"kf34""kf35""kf36""kf37""kf38""kf39""kf4""kf40""kf41""kf42"
"kf43""kf44""kf45""kf46""kf47""kf48""kf49""kf5""kf50""kf51"
"kf52""kf53""kf54""kf55""kf56""kf57""kf58""kf59""kf6""kf60"
"kf61""kf62""kf63""kf7""kf8""kf9""kfnd""khlp""khome""kich1"
"kil1""kcub1""kll""kmrk""kmsg""kmov""knxt""knp""kopn""kopt"
"kpp""kprv""kprt""krdo""kref""krfr""krpl""krst""kres"
"kcuf1""ksav""kBEG""kCAN""kCMD""kCPY""kCRT""kDC""kDL""kslt"
"kEND""kEOL""kEXT""kind""kFND""kHLP""kHOM""kIC""kLFT""kMSG"
"kMOV""kNXT""kOPT""kPRV""kPRT""kri""kRDO""kRPL""kRIT""kRES"
"kSAV""kSPD""khts""kUND""kspd""kund""kcuu1""rmkx""smkx"
"lf0""lf1""lf10""lf2""lf3""lf4""lf5""lf6""lf7""lf8""lf9"
"fln""rmln""smln""rmm""smm""mhpa""mcud1""mcub1""mcuf1"
"mvpa""mcuu1""nel""porder""oc""op""pad""dch""dl""cud"
"mcud""ich""indn""il""cub""mcub""cuf""mcuf""rin""cuu"
"mcuu""pfkey""pfloc""pfx""pln""mc0""mc5p""mc4""mc5""pulse"
"qdial""rmclk""rep""rfi""rs1""rs2""rs3""rf""rc""vpa""sc"
"ind""ri""scs""sgr""setb""smgb""smgbp""sclk""scp""setf"
"smgl""smglp""smgr""smgrp""hts""smgt""smgtp""wind""sbim"
"scsd""rbim""rcsd""subcs""supcs""ht""docr""tsl""tone""uc"
"hu""u0""u1""u2""u3""u4""u5""u6""u7""u8""u9""wait"
"xoffc""xonc""zerom""scesa""bicr""binel""birep""csnm""csin"
"colornm""defbi""devt""dispc""endbi""smpch""smsc""rmpch"
"rmsc""getm""kmous""minfo""pctrm""pfxl""reqmp""scesc""s0ds"
"s1ds""s2ds""s3ds""setab""setaf""setcolor""smglr""slines"
"smgtb""meml""memu"))

;; this doesn't work, I can't get it to pass input
;; through stdin
(defun terminfo-tic ()
  (interactive)
  (let ((process (start-process "tic" nil "tic" "-x" "-")))
    (process-send-string process (buffer-string))
    (process-send-eof process)))

(defun terminfo-checkvar (name)
  (if (member name terminfo-booleans)
      'font-lock-variable-name-face
    (if (member name terminfo-numeric)
        'font-lock-variable-name-face
      (if (member name terminfo-string)
          'font-lock-variable-name-face
        (if (string-equal name "use")
            'font-lock-variable-name-face
          (if (member name terminfo-user-string)
              'font-lock-variable-name-face
            (if (member name terminfo-user-numeric)
                'font-lock-variable-name-face
              (if (member name terminfo-user-booleans)
                  'font-lock-variable-name-face
                ;(message "unknown: %s\n" name)
                'warning))))))))

(defvar
 terminfo-syntax
 '(
   ( ;state 0
    ("^#.*" 0 font-lock-comment-face)
    ("^[a-zA-Z0-9+._-]+" 8 font-lock-type-face)
    ("use\\b" 6 font-lock-variable-name-face)
    ("[ \n	]+" 0)
    ("[a-zA-Z0-9]+" 1 terminfo-checkvar)
    ("\\.[a-zA-Z0-9]+" 1 font-lock-comment-face)
    ;("\\.\\(?:[^\n,]\\|\n[ 	]+\\|\\\\\\\\\\|\\\\,\\)*" 5 font-lock-comment-face) ;this should be more complex but it's probably fine except we should check for \, and similar
    )
   ( ;state 1
    ("=" 2) ("#" 4) ("," 0) ("@" 5)
    )
   ( ;state 2
    ("^#.*" 0 font-lock-comment-face)
    ;; todo: highlight escapes
    ("\\\\\\(?:[0-9][0-9][0-9]\\|.\\)" 2 font-lock-constant-face)
    ("%" 11 font-lock-regexp-grouping-backslash)
    ("\\$" 12 font-lock-regexp-grouping-backslash)
    ("\\(?:[^,$\n\\\\%]\\)*" 5 font-lock-string-face) ;DANGER! can be length 0! make sure state 5 cannot match len 0 as well
    )
   ( ;state 3
    ("^#.*" 0 font-lock-comment-face)
    ("[^,\n]*" 5 font-lock-string-face)
    )
   ( ;state 4
    ("^#.*" 0 font-lock-comment-face)
    ("[^,\n]*" 5 font-lock-string-face)
    )
   ( ;state 5
    ("," 0)
    ("\n[	 ]+" 2)
    ("\\\\\\(?:[0-9][0-9][0-9]\\|.\\)" 2 font-lock-constant-face)
    ("%" 11 font-lock-regexp-grouping-backslash)
    ("\\$" 12 font-lock-regexp-grouping-backslash)
    )
   ( ;state 6
    ("=" 7)
    )
   ( ;state 7
    ("[a-zA-Z0-9+._-]+" 5 font-lock-type-face)
    )
   ( ;state 8
    ("|" 9)
    ("[,\n]" 0)
    )
   ( ;state 9
    ("[^|,\n]*" 8 font-lock-type-face)
    )
   ( ;state 10
    
    )
   ( ;state 11
    ("\\(?:[-%csl+*/m&|^=><AO!~i?te;]\\|:?[-+#]?[0-9]*\\(?:\\.[0-9]+\\)?[doxXs]\\|p[1-9]\\|[Pg][a-zA-Z]\\|'\\\\?.'\\|{[0-9]+}\\|\\[\\(?:[^]]\\|\\\\.\\)*\\]\\)" 2 font-lock-function-name-face)
    )
   ( ;state 12
    ("<[0-9]+[*/]*>" 2 font-lock-function-name-face)
    )
   ))
;; we are still having issues with multiline
;; see:
;; linux-m1b|Linux Minitel 1B "like" Monochrome (Gris/Blanc/Noir+Dim),
;; 	ccc@,
;; 	colors@, ncv@, pairs@,
;; 	acsc@, bold=\E[33m, enacs@, initc@,
;; 	is2=\E]R\E]P1A9A9A9\E]P2A9A9A9\E]P3FFFFFF\E]P4A9A9A9\E]P5A9A
;; 	    9A9\E]P6A9A9A9\E]P9FFFFFF\E]PAFFFFFF\E]PBFFFFFF\E]PCFFFF
;; 	    FF\E]PDFFFFFF\E]PEFFFFFF\E[?2c,
;; 	oc@, op@, rmacs@, setab=^A, setaf=^A, smacs@, .setab@, .setaf@,
;; 	.smcup=\E]R\E]P1A9A9A9\E]P2A9A9A9\E]P3FFFFFF\E]P4A9A9A9\E]P5
;; 	       A9A9A9\E]P6A9A9A9\E]P9FFFFFF\E]PAFFFFFF\E]PBFFFFFF\E]
;; 	       PCFFFFFF\E]PDFFFFFF\E]PEFFFFFF\E[?2c,
;; 	use=linux-m1,

(define-derived-mode terminfo-mode fundamental-mode "terminfo"
  "mode for highlighting terminfo files"
  (setq font-lock-defaults
        `((nil)
          nil nil nil nil
          (font-lock-fontify-region-function . fl2-fontify-region)
          (font-lock-extra-managed-props . ,(list 'fl2-state))
          (fl2-syntax . ,terminfo-syntax))))

(add-to-list 'auto-mode-alist '("\\.term\\'" . terminfo-mode))

