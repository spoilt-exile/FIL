;FIL v1.6.0
;
;This program is free software; you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation; either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;http://www.gnu.org/licenses/gpl-3.0.html
;
;FIL = Film Imitation Lab;
;TO-DO (ver. 1.6.1):
; - port some processes;
;Version history:
;===============================================================================================================
;ver. 0.3 (December 19 2009)
; - working script with small amount of procedures.
; - FIL 0.3 specifications definition.
;===============================================================================================================
;ver. 0.5 (December 22 2009)
; - separate execution of color and grain processes.
; - option indicaion output into final layer's name.
; - specs modification.
; - module classes introduction.
;===============================================================================================================
;ver 0.8 (December 24 2009)
; - new core (NG).
; - vignette as pre-process.
; - grian amplification as part of core (not recomended with Simple Grian process).
; - work woth visible.
; - new grain process (Grain+).
;===============================================================================================================
;ver. 1.0 (January 11 2010)
; - core independ process execution enhancement.
; - bugfixes.
; - color process and etc modification.
; - grain amplification in grain process.
; - border blur (like bad lenses).
; - interface modification.
; - vignette radius (may be increased).
;===============================================================================================================
;ver. 1.0r1 (February 17 2010)
; - vignette process modification;
; - vignette softness support;
; - fil-source-handle improved;
;===============================================================================================================
;ver. 1.0r2 (March 24 2010)
; - some fixes in sepia process;
; - relative blur in Grian+;
; - significant optimization in Grain+ process;
;===============================================================================================================
;ver 1.0r3 (March 26 2010)
; - first public release;
;===============================================================================================================
;ver 1.5.0 (May 3 2010)
; - total revision of all core stages;
; - new specs;
; - register procedures for color and grain processes;
; - whole core variables classification;
; - new color process Duotone (based on Split Studio 3);
; - exposure correction as new pre-process;
;===============================================================================================================
;ver 1.5.1 (June 5 2010)
; - FIL core batch execution;
; - new grain process "Sulfide"
;===============================================================================================================
;ver 1.6.0 (June 9 2010)
; - script's core modification;
; - optional option output;
; - launching processes with custome options;
; - Grunge filter included in Sulfide process.
; - stable release status;
;===============================================================================================================
;Procedures:			Status		Revision	Specs version
;==========================================CORE PROCEDURES======================================================
;fil-ng-core			stable		---		1.6
;fil-stage-handle		stable		---		---
;fil-source-handle		stable		---		---
;fil-ng-batch			stable		---		---
;===========================================PRE-PROCESSES=======================================================
;fil-pre-xps			stable		r0		1.6
;fil-pre-vignette		stable		r3		1.6
;fil-pre-badblur		stable		r1		1.6
;==========================================COLOR PROCESSES======================================================
;fil-int-sov			stable		r5		1.6
;fil-int-gray			stable		r2		1.6
;fil-int-lomo			stable		r1		1.6
;fil-int-sepia			stable		r4		1.6
;fil-int-duo			stable		r1		1.6
;==========================================GRAIN PROCESSES======================================================
;fil-int-simplegrain		stable		r2		1.6
;fil-int-grain_plus		stable		r4		1.6
;fil-int-sulfide		stable		r2		1.6
;=====================================FIL module classification=================================================
; -pre - pre-process.
; -int - internal procedure (locate in this file).
; -ext - externel procedure (somewhere out of this file).
; -dep - external procedure which depend on binary plug-ins.
;=================================FIL 1.6 modules requirements list:============================================
; * processes can't call other FIL processes from itself but it can call private additional procedures.
; * processes shouldn't change image dimensions or it's color depth.
; * procceses able to take some image option from FIL core by itself (variable class fc_*).
; * register stage should be defined by it's variable and should be included in fk-stages-list.
; * processes (except pre-proccesses) should be register in fk-clr-stage and fk-grain-stage variables.
; * processes should return final layer to core (if processes use many layers).
; * processes could have special launch options.
;========================================FIL 1.6 core stages====================================================
;Stage			Register?			Stage number (stage_id)
;pre-stage		NO				0
;fk-clr-stage		YES				1
;fk-grain-stage		YES				2
;===============================================================================================================

;Core global variables

;Core stage register with stage_id=1 (color stage);
(define fk-clr-stage)
(set! fk-clr-stage
  (list
    
    ;Process "SOV: normal" with proc_id=0
    (list "SOV: normal" 		(quote (set! fp_clr_layer (fil-int-sov fm_image fp_clr_layer fc_imh fc_imw 60 65))))

    ;Process "SOV: light" with proc_id=1
    (list "SOV: light"			(quote (set! fp_clr_layer (fil-int-sov fm_image fp_clr_layer fc_imh fc_imw 30 35))))

    ;Process "B/W" with proc_id=2
    (list "B/W" 			(quote (fil-int-gray fm_image fp_clr_layer)))

    ;Process "Lomo" with proc_id=3
    (list "Lomo" 			(quote (fil-int-lomo fm_image fp_clr_layer)))

    ;Process "Sepia: normal" with proc_id=4
    (list "Sepia: normal" 		(quote (set! fp_clr_layer (fil-int-sepia fm_image fp_clr_layer fc_imh fc_imw fc_fore FALSE))))

    ;Process "Sepia: with imitation" with proc_id=5
    (list "Sepia: with imitaion"	(quote (set! fp_clr_layer (fil-int-sepia fm_image fp_clr_layer fc_imh fc_imw fc_fore TRUE))))

    ;Process "Duotone: normal" with proc_id=6
    (list "Duotone: normal" 		(quote (set! fp_clr_layer (fil-int-duo fm_image fp_clr_layer 75 '(200 175 140) '(80 102 109)))))

    ;Process "Duotone: soft" with proc_id=7
    (list "Duotone: soft" 		(quote (set! fp_clr_layer (fil-int-duo fm_image fp_clr_layer 30 '(200 175 140) '(80 102 109)))))

    ;Process "Duotone: user colors" with proc_id=8
    (list "Duotone: user colors"	(quote (set! fp_clr_layer (fil-int-duo fm_image fp_clr_layer 55 fc_fore fc_back))))
  )
)

;Core stage register with stage_id=2 (grain stage);
(define fk-grain-stage)
(set! fk-grain-stage
  (list

    ;Process "Simple grain" with proc_id=0
    (list "Simple grain"		(quote (fil-int-simplegrain fm_image fp_grain_layer)))

    ;Process "Grain+: normal" with proc_id=1
    (list "Grain+: normal" 		(quote (set! fp_grain_layer (fil-int-adv_grain fm_image fp_grain_layer fc_imh fc_imw fc_fore FALSE))))

    ;Process "Grain+: amplified" with proc_id=2
    (list "Grain+: amplified" 		(quote (set! fp_grain_layer (fil-int-adv_grain fm_image fp_grain_layer fc_imh fc_imw fc_fore TRUE))))

    ;Process "Sulfide: normal" with proc_id=3
    (list "Sulfide: normal"		(quote (set! fp_grain_layer (fil-int-sulfide fm_image fp_grain_layer fc_imh fc_imw fc_fore 2.5 FALSE))))

    ;Process "Sulfide: large scale" with proc_id=4
    (list "Sulfide: large scale"	(quote (set! fp_grain_layer (fil-int-sulfide fm_image fp_grain_layer fc_imh fc_imw fc_fore 3.1 FALSE))))

    ;Process "Sulfide: grunge" with proc_id=5
    (list "Sulfide: grunge"		(quote (set! fp_grain_layer (fil-int-sulfide fm_image fp_grain_layer fc_imh fc_imw fc_fore 2.7 TRUE))))
  )
)

;Global stage list
(define fk-stages-list 
  (list 
    FALSE			;Pre-process stage marked as FALSE (not register stage)
    fk-clr-stage		;Color process stage;
    fk-grain-stage		;Grain process stage;
  )
)

;Core stage counter
(define fk-stage-counter 0)

;FIL core procedure
(define (fil-ng-core		;procedure name;

	;Launching main atributes
	fm_image		;image variable;

	;Color stage control
	fm_clr_flag		;color proceess execution switch;
	fm_clr_id		;color process number;

	;Grain stage control
	fm_grain_flag		;grain proceess execution switch;
	fm_grain_id		;grain process number;

	;Pre-process control
	fm_pre_vign_flag	;vignette activation switch;
	fm_pre_vign_rad		;vignette radius in percents;
	fm_pre_vign_soft	;vignette softness;
	fm_pre_vign_opc		;vingette opacity;
	fm_pre_blur_step	;border blur control;
	fm_pre_xps_control	;exposure correction control;

	;Additional options
	fm_misc_logout		;option output swtitch;
	fm_misc_visible		;visible switch;
	)

  ;Core start
  (gimp-context-push)
  (gimp-image-undo-disable fm_image)

  ;Variables declaration;
  (let* (

	;System variables
	(fc_imh (car (gimp-image-height fm_image)))		;image height system variable
	(fc_imw (car (gimp-image-width fm_image)))		;image width system variable
	(fc_fore (car (gimp-context-get-foreground)))		;foreground color system variable
	(fc_back (car (gimp-context-get-background)))		;background color system variable

	;Stages control
	(fl_pre_flag FALSE)					;pre-stage execution flag

	;Result variables recieved from stage handler
	(fx_clr_list)						;List of variables recived from fil-stage-handle while color stage
	(fx_clr_exp)						;Color stage execution code block
	(fx_grain_list)						;List of variables recived from fil-stage-handle while grain stage
	(fx_grain_exp)						;grain stage execution code block

	;Stages I/O layers
	(fp_pre_layer)						;pre-stage layer
	(fp_clr_layer)						;color stage layer
	(fp_grain_layer)					;grain stage layer

	;Option indication string prefixes
	(fs_pref_pre "-p ")					;pre-stage option prefix
	(fs_pref_clr "-c ")					;color stage option prefix
	(fs_pref_grain "-g ")					;grain stage option prefix

	;Additional string variables
	(fs_clr_str)						;color stage layer name
	(fs_grain_str)						;grain stage layer name
	(fs_res_str "")						;final layer name
	(fs_xps_str "Exp. ")					;exposure correction string mark
	(fs_vign_str "(V) ")					;vignette string mark
	(fs_blur_str "Scale x")					;border blur (bad lenses) string mark
	(fs_default_str "FIL 1.6.0 processing result")		;final layer default string
	)

	;Pre-stage activation section
	(cond
	  ((> fm_pre_blur_step 0) (set! fl_pre_flag TRUE))
	  ((and (= fm_pre_vign_flag TRUE) (> fm_pre_vign_opc 0)) (set! fl_pre_flag TRUE))
	  ((not (= fm_pre_xps_control 0)) (set! fl_pre_flag TRUE))
	)

	;Pre-stage initalization
	(if (= fl_pre_flag TRUE)
	  (begin

	    ;Copying layer
	    (set! fp_pre_layer (fil-source-handle fm_image fm_misc_visible))
	    (set! fs_res_str (string-append fs_res_str fs_pref_pre))

	    ;Exposure correction launching
	    (if (not (= fm_pre_xps_control 0))
	      (begin
		(fil-pre-xps fm_image fp_pre_layer fm_pre_xps_control)
		(set! fs_xps_str (string-append fs_xps_str (if (> fm_pre_xps_control 0) "+" "-") (number->string fm_pre_xps_control)))
		(if (> (string-length fs_xps_str) 10)
		  (set! fs_xps_str (substring fs_xps_str 0 11))
		)
		(set! fs_res_str (string-append fs_res_str fs_xps_str " "))
	      )
	    )

	    ;Vignette launching
	    (if (= fm_pre_vign_flag TRUE)
	      (if (> fm_pre_vign_opc 0)
		(begin
		  (set! fp_pre_layer (fil-pre-vignette fm_image fp_pre_layer fc_imh fc_imw fm_pre_vign_opc fm_pre_vign_rad fm_pre_vign_soft fc_fore))
		  (set! fs_res_str (string-append fs_res_str fs_vign_str))
		)
	      )
	    )
	    
	    ;Blur launching
	    (if (> fm_pre_blur_step 0)
	      (begin
		(fil-pre-badblur fm_image fp_pre_layer fc_imh fc_imw fm_pre_blur_step)
		(set! fs_res_str (string-append fs_res_str fs_blur_str (number->string (+ fm_pre_blur_step 1)) " "))
	      )
	    )

	    (if (= fm_misc_logout TRUE)
	      (gimp-drawable-set-name fp_pre_layer fs_res_str)
	      (gimp-drawable-set-name fp_pre_layer fs_default_str)
	    )
	  )
	)

	;Layer transfering between stages and stage counter correction
	(set! fp_clr_layer fp_pre_layer)
	(set! fk-stage-counter (+ fk-stage-counter 1))

	;Color stage initalization
	(if (= fm_clr_flag TRUE)
	  (begin

	    ;Recieved layer checking
	    (if (null? fp_clr_layer)
	      (set! fp_clr_layer (fil-source-handle fm_image fm_misc_visible))
	    )

	    ;Process list initalization
	    (set! fx_clr_list (fil-stage-handle FALSE fk-stage-counter fm_clr_id))
	    (set! fs_clr_str (car fx_clr_list))
	    (set! fx_clr_exp (cadr fx_clr_list))

	    ;Color process execution
	    (eval fx_clr_exp)

	    ;String modification and layer renaming
	    (set! fs_res_str (string-append fs_res_str fs_pref_clr fs_clr_str " "))
	    (if (= fm_misc_logout TRUE)
	      (gimp-drawable-set-name fp_clr_layer fs_res_str)
	      (gimp-drawable-set-name fp_clr_layer fs_default_str)
	    )
	  )
	)

	;Layer transfering between stages and stage counter correction
	(set! fp_grain_layer fp_clr_layer)
	(set! fk-stage-counter (+ fk-stage-counter 1))

	;Grain stage initalization
	(if (= fm_grain_flag TRUE)
	  (begin

	    ;Recieved layer checking
	    (if (null? fp_grain_layer)
	      (set! fp_grain_layer (fil-source-handle fm_image fm_misc_visible))
	    )

	    ;Process list initalization
	    (set! fx_grain_list (fil-stage-handle FALSE fk-stage-counter fm_grain_id))
	    (set! fs_grain_str (car fx_grain_list))
	    (set! fx_grain_exp (cadr fx_grain_list))

	    ;Grain process execution
	    (eval fx_grain_exp)

	    ;String modification and layer renaming
	    (set! fs_res_str (string-append fs_res_str fs_pref_grain fs_grain_str))
	    (if (= fm_misc_logout TRUE)
	      (gimp-drawable-set-name fp_grain_layer fs_res_str)
	      (gimp-drawable-set-name fp_grain_layer fs_default_str)
	    )
	  )
	)

	;Returning original foreground and background colors
	(gimp-context-set-foreground fc_fore)
	(gimp-context-set-background fc_back)
	(gimp-displays-flush)
  )

  ;Stage counter reset
  (set! fk-stage-counter 0)

  ;End of execution
  (gimp-image-undo-enable fm_image)
  (gimp-context-pop)
)

;fil-stage-handle
;CORE MODULE
;Input variables:
;BOOLEAN - TRUE returning name list of specified stage / FALSE returning list with execution variables;
;INTEGER - core stage number (required option);
;INTEGER - selected process number (zero if need to return list of process);
;Returning variables:
;LIST - list with strings of the processes names / list with process name and with block of code;
(define (fil-stage-handle param stage_id proc_id)
(define stage-handle)
(let* (
      (stage_error (string-append "FIL can't find a stage with specified number:\nstage_id=" (number->string stage_id)))
      (proc_error (string-append "FIL can't find a process with specified number:\nstage_id=" (number->string stage_id) "\nproc_id=" (number->string proc_id)))
      (curr_error (string-append "Current FIL stage isn't registrable:\nstage_id=" (number->string stage_id)))
      (stage_counter -1)
      (proc_counter -1)
      (current_stage_list)
      (name_list '())
      (proc_list)
      (temp_list)
      (temp_entry)
      )
      (set! temp_list fk-stages-list)

      ;Recieving list of current stage
      (if (not (or (< stage_id 0) (> stage_id (- (length fk-stages-list) 1))))
	(while (< stage_counter stage_id)
	  (begin
	    (set! current_stage_list (car temp_list))
	    (set! stage_counter (+ stage_counter 1))
	    (set! temp_list (cdr temp_list))
	  )
	)
	(gimp-message stage_error)
      )

      ;Error message if current stage return FALSE
      (if (not (list? current_stage_list))
	(gimp-message curr_error)
      )

      ;Stage processing
      (if (= param TRUE)

	;Nmae list generation
	(begin
	  (while (not (null? current_stage_list))
	    (set! temp_entry (car current_stage_list))
	    (set! name_list (append name_list (list (car temp_entry))))
	    (set! current_stage_list (cdr current_stage_list))
	  )
	  (set! stage-handle name_list)
	)

	;Recieving list with name of process and code block
	(begin
	  (if (not (or (< proc_id 0) (> proc_id (- (length current_stage_list) 1))))
	    (begin
	      (while (< proc_counter proc_id)
		(set! proc_list (car current_stage_list))
		(set! proc_counter (+ proc_counter 1))
		(set! current_stage_list (cdr current_stage_list))
	      )
	    )
	    (gimp-message proc_error)
	  )
	  (set! stage-handle proc_list)
	)
      )
)
stage-handle
)

;FIL registation part resposible for author rights
(define fil-credits
  (list
  "Nepochatov Stanislav"
  "GPLv3"
  "June 9 2010"
  )
)

;FIL registation part responsible for procedure tuning
(define fil-controls
  (list
  SF-TOGGLE	"Colorcorrection stage"		TRUE
  SF-OPTION 	"Color process" 		(fil-stage-handle TRUE 1 0)
  SF-TOGGLE	"Grain stage"			TRUE
  SF-OPTION	"Grain process"			(fil-stage-handle TRUE 2 0)
  SF-TOGGLE	"Enable vignette"		FALSE
  SF-ADJUSTMENT	"Vignette radius (%)"		'(100 85 125 5 10 1 0)
  SF-ADJUSTMENT	"Vignette softness (%)"		'(33 20 45 2 5 1 0)
  SF-ADJUSTMENT	"Vignette opacity"		'(100 0 100 10 25 1 0)
  SF-OPTION	"Border blur"			'("Disabled" "x1" "x2" "x3")
  SF-ADJUSTMENT	"Exposure correction"		'(0 -2 2 0.1 0.3 1 0)
  SF-TOGGLE	"Write options in layer's name"	FALSE
  )
)

;fil-ng-core procedure registration
(apply script-fu-register
  (append
    (list
    "fil-ng-core"
    _"<Image>/Filters/RSS/_FIL 1.6"
    "Film Imitation Lab"
    )
    fil-credits
    (list
    "RGB,RGBA*"
    SF-IMAGE	"Image"				0
    )
    fil-controls
    (list
    SF-TOGGLE	"Work with visible"		FALSE
    )
  )
)

;Batch core procedure
(define (fil-ng-batch		;procedure name

	;Batch execution control
	fb_dir_in		;input directory address
	fb_input_format		;input format;
	fb_dir_out		;output directory address;
	fb_out_format		;output format;

	;Color stage control
	fbm_clr_flag		;color proceess execution switch;
	fbm_clr_id		;color process number;

	;Grain stage control
	fbm_grain_flag		;grain proceess execution switch;
	fbm_grain_id		;grain process number;

	;Управление пре-процессами
	fbm_pre_vign_flag	;vignette activation switch;;
	fbm_pre_vign_rad	;vignette radius in percents;
	fbm_pre_vign_soft	;vignette softness;
	fbm_pre_vign_opc	;vingette opacity;
	fbm_pre_blur_step	;border blur control;
	fbm_pre_xps_control	;exposure correction control;
	
	;Additional options
	fbm_misc_logout		;visible switch;
	)

  ;Input format definition
  (define input-ext)
  (cond
    ((= fb_input_format 0) (set! input-ext "*"))
    ((= fb_input_format 1) (set! input-ext "[jJ][pP][gG]"))
    ((= fb_input_format 2) (set! input-ext "[bB][mM][pP]"))
    ((= fb_input_format 3) (set! input-ext "[xX][cC][fF]"))
  )

  ;Output format definition
  (define out-ext)
  (cond
    ((= fb_out_format 0) (set! out-ext "jpg"))
    ((= fb_out_format 1) (set! out-ext "png"))
    ((= fb_out_format 2) (set! out-ext "tif"))
    ((= fb_out_format 3) (set! out-ext "bmp"))
    ((= fb_out_format 4) (set! out-ext "xcf"))
    ((= fb_out_format 5) (set! out-ext "psd"))
  )

  ;Declaration of variables
  (let*	(
	(dir_os (if (equal? (substring gimp-dir 0 1) "/") "/" "\\"))
	(pattern (string-append fb_dir_in dir_os "*." input-ext))
	(filelist (cadr (file-glob pattern 1)))
	(run_mode 1)
	)

	;Cycle begin
	(while (not (null? filelist))
	  (let* (
		(cur_target (car filelist))
		(img (car (gimp-file-load 1 cur_target cur_target)))
		(srclayer)
		(filename (car (gimp-image-get-filename img)))
		(target_out)
		(file)
		(res_layer)
		)

		;Preliminary layer merging
		(if (> fb_input_format 2)
		  (begin
		    (set! srclayer (car (gimp-image-get-active-layer img)))
		    (gimp-edit-copy-visible img)
		    (set! srclayer (car (gimp-edit-paste srclayer TRUE)))
		    (gimp-floating-sel-to-layer srclayer)
		    (gimp-drawable-set-name srclayer "Viz-src")
		    (gimp-image-raise-layer-to-top img srclayer)
		  )
		  (set! srclayer (car (gimp-image-get-active-layer img)))
		)

		;fil-ng-core launching
		(fil-ng-core 
		  img				;>>fm_image
		  fbm_clr_flag			;>>fm_clr_flag
		  fbm_clr_id			;>>fm_clr_id
		  fbm_grain_flag		;>>fm_grain_flag
		  fbm_grain_id			;>>fm_grain_id
		  fbm_pre_vign_flag		;>>fm_pre_vign_flag
		  fbm_pre_vign_rad		;>>fm_pre_vign_rad
		  fbm_pre_vign_soft		;>>fm_pre_vign_soft
		  fbm_pre_vign_opc		;>>fm_pre_vign_opc
		  fbm_pre_blur_step		;>>fm_pre_blur_step
		  fbm_pre_xps_control		;>>fm_pre_xps_control
		  fbm_misc_logout		;>>fm_misc_logout
		  FALSE				;>>fm_misc_visible
		)

		;Final layers merging
		(if (< fb_out_format 4)
		  (set! res_layer (car (gimp-image-merge-visible-layers img 0)))
		  (set! res_layer (car (gimp-image-get-active-layer img)))
		)

		;String proceessting and construction output path
		(set! file (substring filename (string-length fb_dir_in) (- (string-length filename) 4 )))
		(set! target_out (string-append fb_dir_out "/" file "_FIL." out-ext))

		;File saving
		(cond
		  ((= fb_out_format 0) (file-jpeg-save 1 img res_layer target_out target_out 1 0 1 1 "" 2 1 0 0))
		  ((= fb_out_format 1) (file-png-save-defaults 1 img res_layer target_out target_out))
		  ((= fb_out_format 2) (file-tiff-save 1 img res_layer target_out target_out 1))
		  ((= fb_out_format 3) (file-bmp-save 1 img res_layer target_out target_out))
		  ((= fb_out_format 4) (gimp-xcf-save 1 img res_layer target_out target_out))
		  ((= fb_out_format 5) (file-psd-save 1 img res_layer target_out target_out 1 0))
		)

		;Image remocing
		(gimp-image-delete img)
	  )

	  ;List offset and cycle's stage ending
	  (set! filelist (cdr filelist))
	)
  )
)

;fil-ng-batch procedure registration
(apply script-fu-register
  (append
    (list
    "fil-ng-batch"
    _"<Image>/Filters/RSS/FIL 1.6 Batch"
    "FIL batch mode"
    )
    fil-credits
    (list
    ""
    SF-DIRNAME	"Input folder"		""
    SF-OPTION	"Input format"		'(
					"*"
					"JPG"
					"TIFF"
					"XCF"
					)
    SF-DIRNAME	"Output folder"		""
    SF-OPTION	"Output format"		'(
					"JPG"
					"PNG"
					"TIF"
					"BMP"
					"XCF"
					"PSD"
					)
    )
    fil-controls
  )
)

;fil-source-handle
;CORE MODULE
;Input variables:
;IMAGE - processing image;
;BOOLEAN. - fm_misc_visible raw value;
;Returned variables:
;LAYER - ready layer;
(define (fil-source-handle image viz)
(define exit)
  (let* (
	(active (car (gimp-image-get-active-layer image)))
	(exit-layer)
	)
	(if (= viz TRUE)
	  (begin
	    (gimp-edit-copy-visible image)
	    (set! exit-layer 
	      (car
		(gimp-edit-paste active TRUE)
	      )
	    )
	    (gimp-floating-sel-to-layer exit-layer)
	    (gimp-drawable-set-name exit-layer "Source = Visible")
	    (gimp-image-raise-layer-to-top image exit-layer)
	  )
	  (begin
	    (set! exit-layer (car (gimp-layer-copy active FALSE)))
	    (gimp-image-add-layer image exit-layer -1)
	    (gimp-drawable-set-name exit-layer "Source = Copy")
	  )
	)
	(set! exit exit-layer)
  )
exit
)

;Core section end

;fil-pre-xps
;PRE-PROCESS
;Input variables:
;LAYER - processing layer;
;INTEGER - exposure correction value;
(define (fil-pre-xps image layer control)
  (let* (
	(low_input (- 0 (* control 25)))
	(high_input (- 255 (* control 25)))
	)
	(if (> high_input 255)
	  (set! high_input 255)
	)
	(if (< low_input 0)
	  (set! low_input 0)
	)
	(gimp-levels layer 0 low_input high_input 1.0 0 255)
  )
)

;fil-pre-vignette
;PRE-PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
;INTEGER - image height value;
;INTEGER - image width value;
;INTEGER - vignette opacity value;
;INTEGER - vignette softness value;
;INTEGER - vignette radius value;
;COLOR - foreground color;
;Returned variables:
;LAYER - processed layer;
(define (fil-pre-vignette image src imh imw vign_opc vign_rad vign_soft fore)
(define vign-exit)
  (let* (
	(p_imh (* (/ imh 100) vign_rad))
	(p_imw (* (/ imw 100) vign_rad))
	(soft_min (if (> imw imh) imh imw))
	(p_soft (* (/ soft_min 100) vign_soft))
	(off_x)
	(off_y)
	(p_big)
	(d_diff)
	(vign (car (gimp-layer-new image imw imh 1 "Vignette" 100 0)))
	(norm_vign)
	)
	(if (> p_imh p_imw)
	  (begin
	    (set! p_big p_imh)
	    (set! d_diff (/ (- p_imh p_imw) 2))
	    (if (< vign_rad 100)
	      (begin
		(set! off_x (- (/ (- imw p_imw) 2) d_diff))
		(set! off_y (/ (- imh p_imh) 2))
	      )
	      (begin
		(set! off_x (- (/ (- p_imw imw) -2) d_diff))
		(set! off_y (/ (- p_imh imh) -2))
	      )
	    )
	  )
	  (begin
	    (set! p_big p_imw)
	    (set! d_diff (/ (- p_imw p_imh) 2))
	    (if (< vign_rad 100)
	      (begin
		(set! off_x (/ (- imw p_imw) 2))
		(set! off_y (- (/ (- imh p_imh) 2) d_diff))
	      )
	      (begin
		(set! off_x (/ (- p_imw imw) -2))
		(set! off_y (- (/ (- p_imh imh) -2) d_diff))
	      )
	    )
	  )
	)
	(gimp-image-add-layer image vign -1)
	(gimp-drawable-fill vign 3)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-ellipse-select image off_x off_y p_big p_big 0 TRUE TRUE 0)
	(gimp-selection-invert image)
	(gimp-selection-feather image p_soft)
	(gimp-edit-bucket-fill vign 0 0 100 0 FALSE 0 0)
	(gimp-selection-none image)
	(gimp-context-set-foreground fore)
	(set! norm_vign (car (gimp-layer-copy vign TRUE)))
	(gimp-image-add-layer image norm_vign -1)
	(gimp-drawable-set-name norm_vign "Normal vignette")
	(gimp-layer-set-mode vign 5)
	(gimp-layer-set-mode norm_vign 3)
	(gimp-layer-set-opacity vign vign_opc)
	(gimp-layer-set-opacity norm_vign (/ vign_opc 5))
	(set! src
	  (car
	    (gimp-image-merge-down image vign 0)
	  )
	)
	(set! src
	  (car
	    (gimp-image-merge-down image norm_vign 0)
	  )
	)
	(plug-in-autocrop-layer 1 image src)
	(set! vign-exit src)
  )
vign-exit
)

;fil-pre-badblur
;PRE-PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
;INTEGER - image height value;
;INTEGER - image width value;
;INTEGER - blur step value;
(define (fil-pre-badblur image layer imh imw ext)
  (set! ext (+ ext 1))
  (gimp-image-undo-freeze image)
  (plug-in-mblur 1 image layer 2 (/ (+ (/ imh (/ 1500 ext)) (/ imw (/ 1500 ext))) 2) 0 (/ imw 2) (/ imh 2))
  (gimp-image-undo-thaw image)
)

;fil-int-sov
;COLOR PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
;INTEGER - image height value;
;INTEGER - image width value;
;INTEGER - tone opacity value;
;INTEGER - red veil opacity value;
;Returned variables:
;LAYER - processed layer;
(define (fil-int-sov image layer imh imw opc_tone opc_red)
(define sov-exit)
  (let* (
	(first (car (gimp-layer-copy layer FALSE)))
	(red (car (gimp-layer-new image imw imh 0 "Mask tone" 100 0)))
	(red_mask)
	)
	(gimp-hue-saturation layer 0 5 0 -30)
	(gimp-image-add-layer image first -1)
	(gimp-image-add-layer image red -1)
	(gimp-drawable-set-name first "Gloval tone")
	(set! red_mask
	  (car
	    (gimp-layer-create-mask layer 5)
	  )
	)
	(gimp-layer-add-mask red red_mask)
	(gimp-colorize first 48 18 0)
	(gimp-colorize red 0 75 20)
	(gimp-levels red_mask 0 33 120 1.0 0 255)
	(gimp-levels red 0 0 255 1.0 20 255)
	(gimp-invert red_mask)
	(gimp-layer-set-opacity first opc_tone)
	(gimp-layer-set-opacity red opc_red)
	(set! layer
	  (car
	    (gimp-image-merge-down image first 0)
	  )
	)
	(set! layer
	  (car
	    (gimp-image-merge-down image red 0)
	  )
	)
	(gimp-hue-saturation layer 0 0 0 30)
	(gimp-drawable-set-name layer "SOV")
	(set! sov-exit layer)
  )
sov-exit
)

;fil-int-gray
;COLOR PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
(define (fil-int-gray image layer)
  (plug-in-colors-channel-mixer 1 image layer TRUE 0 0.3 0.6 0 0 0 0 0 0)
  (gimp-drawable-set-name layer "B/W")
)

;fil-int-lomo
;COLOR PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
(define (fil-int-lomo image layer)
  ;code by Donncha O Caoimh (donncha@inphotos.org) and elsamuko (elsamuko@web.de)
  ;http://registry.gimp.org/node/7870
  (gimp-curves-spline layer 1 10 #(0 0 80 84 149 192 191 248 255 255))
  (gimp-curves-spline layer 2 8 #(0 0 70 81 159 220 255 255))
  (gimp-curves-spline layer 3 4 #(0 27 255 213))
  (gimp-drawable-set-name layer "Lomo")
)

;fil-int-sepia
;COLOR PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
;INTEGER - image height value;
;INTEGER - image width value;
;COLOR - foreground color;
;BOOLEAN - paper imitation switch;
;Returned variables:
;LAYER - processed layer;
(define (fil-int-sepia image layer imh imw foreground paper_switch)
(define sepia-exit)
  (let* (
	(paper 0)
	)
	(if (= paper_switch TRUE)
	  (begin
	    (set! paper (car (gimp-layer-new image imw imh 0 "Paper" 100 0)))
	    (gimp-image-add-layer image paper -1)
	    (gimp-context-set-foreground '(224 213 184))
	    (gimp-drawable-fill paper 0)
	    (gimp-image-lower-layer image paper)
	    (gimp-layer-set-mode layer 9)
	    (set! layer
	      (car
		(gimp-image-merge-down image layer 0)
	      )
	    )
	  )
	)
	(gimp-colorize layer 34 30 0)
	(gimp-drawable-set-name layer "Sepia")
	(set! sepia-exit layer)
  )
sepia-exit
)

;fil-int-duo
;COLOR PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
;INTEGER - affect opacity value;
;COLOR - light area color;
;COLOR - dark area color;
;Returned variables:
;LAYER - processed layer;
(define (fil-int-duo image layer opc_affect light_color dark_color)
(define duo-exit)
  (let* (
	(affect (car (gimp-layer-copy layer FALSE)))
	(light (car (gimp-layer-copy layer FALSE)))
	(dark (car (gimp-layer-copy layer FALSE)))
	(lightmask)
	)
	(gimp-image-add-layer image dark -1)
	(gimp-image-add-layer image affect -1)
	(gimp-image-add-layer image light -1)
	(gimp-drawable-set-name dark "Dark tone")
	(gimp-drawable-set-name light "Light Tone")
	(gimp-drawable-set-name affect "Affect")
	(gimp-desaturate affect)
	(gimp-levels affect 0 60 195 1.0 0 255)
	(set! lightmask
	  (car
	    (gimp-layer-create-mask affect 5)
	  )
	)
	(gimp-layer-add-mask light lightmask)
	(plug-in-colorify 1 image light light_color)
	(plug-in-colorify 1 image dark dark_color)
	(gimp-layer-set-mode light 13)
	(gimp-layer-set-mode dark 13)
	(gimp-layer-set-mode affect 5)
	(gimp-hue-saturation light 0 0 0 100)
	(gimp-layer-set-opacity affect opc_affect)
	(set! layer (car (gimp-image-merge-down image dark 0)))
	(set! layer (car (gimp-image-merge-down image affect 0)))
	(set! layer (car (gimp-image-merge-down image light 0)))
	(gimp-hue-saturation layer 0 0 0 25)
	(set! duo-exit layer)
  )
duo-exit
)

;fil-int-simplegrain
;GRAIN PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
(define (fil-int-simplegrain image clr_res)
  (plug-in-hsv-noise 1 image clr_res 2 3 0 25)
  (gimp-drawable-set-name clr_res "Simple grain")
)

;fil-int-adv_grain
;GRAIN PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
;INTEGER - image height value;
;INTEGER - image width value;
;COLOR - foreground color;
;BOOLEAN - grain amplification switch;
;Returned variables:
;LAYER - processed layer;
(define (fil-int-adv_grain image clr_res imh imw foreground boost)
(define adv-exit)
  (let* (
	(name "Grain+")
	(grain_boost)
	(rel_step (if (> imh imw) (/ imh 800) (/ imw 800)))
	(grain)
	(grain_mask)
	)
	(set! grain 
	  (car 
	    (gimp-layer-new image imw imh 0 "Grain+" 100 0)
	  )
	)
	(gimp-image-add-layer image grain -1)
	(gimp-context-set-foreground '(128 128 128))
	(gimp-drawable-fill grain 0)
	(plug-in-hsv-noise 1 image grain 2 3 0 25)
	(gimp-brightness-contrast grain 0 80)
	(gimp-layer-set-mode grain 5)
	(gimp-brightness-contrast grain 0 55)
	(gimp-context-set-foreground foreground)
	(set! grain_mask
	  (car
	    (gimp-layer-create-mask clr_res 5)
	  )
	)
	(gimp-layer-add-mask grain grain_mask)
	(gimp-curves-spline grain_mask 0 6 #(0 80 128 128 255 80))
	(gimp-brightness-contrast grain_mask 50 60)
	(if (= boost TRUE)
	  (begin
	    (set! grain_boost (car (gimp-layer-copy grain FALSE)))
	    (gimp-image-add-layer image grain_boost -1)
	    (gimp-drawable-set-name grain_boost "Amplification")
	    (set! name (string-append name " amp."))
	  )
	)
	(set! clr_res (car (gimp-image-merge-down image grain 0)))
	(if (= boost TRUE)
	  (set! clr_res (car (gimp-image-merge-down image grain_boost 0)))
	)
	(plug-in-gauss-iir2 1 image clr_res rel_step rel_step)
	(gimp-drawable-set-name clr_res name)
	(set! adv-exit clr_res)
  )
adv-exit
)

;fil-int-sulfide
;GRAIN PROCESS
;Input variables:
;IMAGE - processing image;
;LAYER - processing layer;
;INTEGER - image height value;
;INTEGER - image width value;
;COLOR - foreground color;
;REAL - grain scale;
;BOOLEAN - grunge-mode switch;
;Returned variables:
;LAYER - processed layer;
(define (fil-int-sulfide image layer imh imw foreground scale_step grunge_switch)
(define sulf-exit)
  (let* (
	(sc_imh (/ imh scale_step))
	(sc_imw (/ imw scale_step))
	(scale_layer)
	(grain_layer)
	(grunge_layer)
	(grain_mask)
	(rel_step (if (> imh imw) (/ imh 1100) (/ imw 1100)))
	)
	(set! scale_layer
	  (car 
	    (gimp-layer-new image sc_imw sc_imh 0 "Scale layer" 100 0)
	  )
	)
	(gimp-image-add-layer image scale_layer -1)
	(gimp-context-set-foreground '(128 128 128))
	(gimp-drawable-fill scale_layer 0)
	(plug-in-hsv-noise 1 image scale_layer 2 3 0 25)
	(gimp-layer-set-mode scale_layer 5)
	(gimp-brightness-contrast scale_layer 0 75)
	(set! grain_mask
	  (car
	    (gimp-layer-create-mask layer 5)
	  )
	)
	(set! grain_layer 
	  (car 
	    (gimp-layer-new image imw imh 0 "Normal Grain" 100 0)
	  )
	)
	(gimp-image-add-layer image grain_layer -1)
	(gimp-layer-add-mask grain_layer grain_mask)
	(gimp-curves-spline grain_mask 0 6 #(0 80 128 128 255 80))
	(gimp-drawable-fill grain_layer 0)
	(plug-in-hsv-noise 1 image grain_layer 2 3 0 25)
	(gimp-brightness-contrast grain_layer 0 80)
	(gimp-layer-set-mode grain_layer 5)
	(gimp-layer-scale-full scale_layer imw imh FALSE 1)
	(gimp-brightness-contrast scale_layer 0 35)
	(gimp-layer-set-opacity scale_layer 45)
	(gimp-layer-resize-to-image-size scale_layer)
	(gimp-context-set-foreground foreground)

	(if (= grunge_switch TRUE)
	  (begin
	    (set! grunge_layer 
	      (car 
		(gimp-layer-new image imw imh 0 "Grunge" 100 0)
	      )
	    )
	    (gimp-image-add-layer image grunge_layer -1)
	    (gimp-image-lower-layer image grunge_layer)
	    (gimp-image-lower-layer image grunge_layer)
	    (plug-in-plasma 1 image grunge_layer 0 5.0)
	    (gimp-desaturate grunge_layer)
	    (gimp-layer-set-mode grunge_layer 5)
	    (gimp-layer-set-opacity grunge_layer 45)
	    (set! layer
	      (car
		(gimp-image-merge-down image grunge_layer 0)
	      )
	    )
	  )
	)

	(set! layer
	  (car
	    (gimp-image-merge-down image scale_layer 0)
	  )
	)
	(set! layer
	  (car
	    (gimp-image-merge-down image grain_layer 0)
	  )
	)
	(plug-in-gauss-iir2 1 image layer rel_step rel_step)
	(set! sulf-exit layer)
  )
sulf-exit
)