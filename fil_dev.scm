;FIL v1.5 alpha2
;ЛИПС (Лаборатория имитации пленочных снимков) = FIL;
;Список задач (ver. 1.5):
; - переработка спецификаций;
; - добавление возвращаемых значений в процедуры;
; - добавление процедур регистрации;
;История версий:
;===============================================================================================================
;ver. 0.3 (19 декабря 2009)
; - рабочая сборка скрипта с начальным набором процедур.
; - определение спецификаций к модулям версии ядра ЛИПС 0.3.
;===============================================================================================================
;ver. 0.5 (22 декабря 2009)
; - раздельное выполнение цветового и зернового процесса.
; - Вывод имени учвствовавших в обработке процессов в имя итогового слоя.
; - модификация спецификаций.
; - устанвка классов расширений.
;===============================================================================================================
;ver 0.8 (24 декабря 2009)
; - смена ядра на модифицированное (NG).
; - виньетирование как препроцесс.
; - усиление зернистости (нерекомендуется при использовании Простой Зернистости).
; - работа с видимым.
; - новый процесс зернистости (Зерно+).
;===============================================================================================================
;ver. 1.0 (11 января 2010)
; - существенные модификации ядра для независимого запуска обьектов ядра.
; - исправления множества ошибок.
; - модернизация цветовых и других процедур.
; - реализация усиления зернистости на уровне процесса зернистоисти.
; - реализация эффекта плохого объектива.
; - модернизирован интерфейс.
; - реализация радиуса виньетирования (в сторону увеличения).
;===============================================================================================================
;ver. 1.0r1 (17 февраля 2010)
; - модернизирован процесс виньетирования;
; - добавлена поддержка мягкости виньетирования;
; - модернизация процедур получения источника для обработки;
;===============================================================================================================
;ver. 1.0r2 (24 марта 2010)
; - мелкие исправления в сепии;
; - относительный значения размытия в Зерно+;
; - значительная оптимизация процесса Зерно+;
;===============================================================================================================
;ver 1.0r3 (26 марта 2010)
; - первый публичный релиз;
;===============================================================================================================
;Процедуры:			Статус		Версия
;=======================ЯДРО==========================
;fil-ng-core			stable		1.0
;fil-clr-handle			rc		---
;fil-grain-handle		rc		---
;fil-source-handle		stable		---
;===================ПРЕ-ПРОЦЕССЫ======================
;fil-pre-vignette		stable		1.0
;fil-pre-badblur		stable		1.0
;=================ЦВЕТОВЫЕ_ПРОЦЕССЫ===================
;fil-int-sov			stable		1.0
;fil-int-gray			stable		1.0
;fil-int-lomo			stable		1.0
;fil-int-sepia			stable		1.0
;===============ПРОЦЕССЫ_ЗЕРНИСТОСТИ==================
;fil-int-simplegrain		stable		1.0
;fil-int-grain_plus		stable		1.0
;=======================================Классы модуей ЛИПС======================================================
; -pre - пре-процесс.
; -int - внутрення процедура (в файле основного скрипта).
; -ext - внешняя процедура (вне основного скрипта).
; -dep - внешняя процедура требующая внешних плагинов.
;================================Набор требований к модулям ЛИПС 1.0============================================
; * теперь процессы могут брать параметры изображения непосредственно из ядра (c_imh, c_imw и c_fore).
; * теперь усиление зернистости должен поддерживать сам процесс.
; * цветовой процесc должен совмещать результатв один итоговой слой.
; * по окончании цветового процесса итоговый слой должен быть активным.
; * процесс зернистости также должен совмещать слои в один итоговый.
; * итоговым слоям должны быть присвоены имена процессов.
;===============================================================================================================

;Ядро
(define (fil-ng-core	;имя процедуры;
	image		;перменная изображения;
	clr_ex		;переключатель исполнения цветового процесса;
	color_proc	;номер цветового процесса;
	grain_ex	;переключатель исполнения процесса зернистости;
	grain_proc	;номер процесса зернистости;
	boost_ex	;переключатель усиления зернистости;
	vign_ex		;переключатель активации виньетирования;
	vign_rad	;радиус виньетирования в процентах;
	vign_soft	;мягкость виньетирования;
	vign_opc	;плотность виньетирования;
	blur_ex		;переключатель исполнения размытия
	blur_xt		;регулятор размытия
	viz		;переключатель использования видимого;
	)

  ;Старт скрипта
  (gimp-context-push)
  (gimp-image-undo-disable image)

  ;Декларация переменных;
  (let* (
	(c_imh (car (gimp-image-height image)))			;системная переменная высоты изображения
	(c_imw (car (gimp-image-width image)))			;системная переменная ширины изображения
	(c_fore (car (gimp-context-get-foreground)))		;системная переменная цвета переднего плана
	(pref_core "-p ")					;префикс для обозначения обработки ядром
	(pref_clr "-c ")					;префикс для обозначения обработки цветовым процессом
	(pref_grain "-g ")					;префикс для обозначения обработки процессом зернистости
	(core_ex FALSE)						;свитч исполнения обьектов ядра
	(core_tar)						;слой для обработки обьектами ядра
	(core_res)						;результирующий слой после стадии обработки обьектами ядра
	(clr_tar)						;слой для обработки цветовым процессом
	(clr_res)						;результирующий слой по выходу из цветового процесса
	(grain_tar)						;слой обработки зерновым процессом
	(grain_res)						;результирующий слой по выходу из процесса зернистости
	(clr_str)						;имя результирующего цветового слоя
	(grain_str)						;имя результирующего слоя зернистости
	(res_str "")						;имя итогового слоя
	(grain_boost)						;слой усиливающий зернистость
	(v_str "(V) ")						;приставка для отображения итогового слоя с виньетированием
	(blur_str (string-append "Blur x" (number->string (+ blur_xt 1))))
	)

	;Секция активации исполнения обьектов ядра
	(cond
	  ((= blur_ex TRUE) (set! core_ex TRUE))
	  ((and (= vign_ex TRUE) (> vign_opc 0)) (set! core_ex TRUE))
	)

	;Инициализация секции обьектов ядра
	(if (= core_ex TRUE)
	  (begin

	    ;Копирование слоя
	    (set! core_tar (fil-source-handle image viz))
	    (set! res_str (string-append res_str pref_core))
	    (gimp-image-set-active-layer image core_tar)

	    ;Запуск виньетирования
	    (if (= vign_ex TRUE)
	      (if (> vign_opc 0)
		(begin
		  (fil-pre-vignette image c_imh c_imw vign_opc vign_rad vign_soft c_fore)
		  (set! res_str (string-append res_str v_str))
		  (set! core_tar (car (gimp-image-get-active-layer image)))
		)
	      )
	    )
	    
	    ;Запуск размытия
	    (if (= blur_ex TRUE)
	      (begin
		(fil-pre-badblur image core_tar c_imh c_imw blur_xt)
		(set! res_str (string-append res_str blur_str " "))
	      )
	    )
	    (set! core_res (car (gimp-image-get-active-layer image)))
	    (gimp-drawable-set-name core_res res_str)
	  )
	)

	;Запуск цветового процесса
	(if (= clr_ex TRUE)
	  (begin

	    ;Переназначение слоя или его копирование
	    (if (= core_ex TRUE)
	      (set! clr_tar (car (gimp-image-get-active-layer image)))
	      (begin
		(set! clr_tar (fil-source-handle image viz))
		(gimp-image-set-active-layer image clr_tar)
	      )
	    )

	    ;Инициализация листа процессов
	    (eval (fil-clr-handle FALSE color_proc))

	    ;Захват готового слоя и его имени
	    (set! clr_res
	      (car (gimp-image-get-active-layer image))
	    )
	    (set! clr_str
	      (car 
		(gimp-drawable-get-name clr_res)
	      )
	    )
	    (set! res_str (string-append res_str pref_clr clr_str " "))
	    (gimp-drawable-set-name clr_res res_str)
	  )
	)

	;Запуск процесса генерации зерна
	(if (= grain_ex TRUE)
	  (begin

	    (if (= core_ex TRUE)
	      (set! clr_ex TRUE)
	    )

	    ;Копирование слоя-источника в случае независимого запуска
	    (if (= clr_ex FALSE)
	      (begin
		(set! grain_tar (fil-source-handle image viz))
		(gimp-image-set-active-layer image grain_tar)
	      )
	    )

	    ;Инициализация листа процессов зернистости
	    (eval (fil-grain-handle FALSE grain_proc))

	    ;Захват готового слоя зерна и дальнейшее сведение слоев
	    (set! grain_res
	      (car 
		(gimp-image-get-active-layer image)
	      )
	    )
	    (set! grain_str
	      (car 
		(gimp-drawable-get-name grain_res)
	      )
	    )

	    ;Завершение сборки имени итогового слоя
	    (set! res_str (string-append res_str pref_grain grain_str))
	    (gimp-drawable-set-name grain_res res_str)
	  )
	)

	;Возвращение исходного цвета переднего плана
	(gimp-context-set-foreground c_fore)
	(gimp-displays-flush)
  )

  ;Завершение скрипта
  (gimp-image-undo-enable image)
  (gimp-context-pop)
)

;fil-clr-handle
;МОДУЛЬ ЯДРА
;Входные переменные:
;КОМБИНАЦИЯ - TRUE если требуется возвратить лист процессов / номер процесса для возвращения блока кода;
;ЦЕЛОЕ - номер выбранного процесса (занулить если нужно возвратить список);
;Возвращаемые значения:
;КОМБИНАЦИЯ - лист с текстовыми названиями процессов / блок кода для исполнения;
(define (fil-clr-handle param clr_id)
(define clr-handle)
(define clr-list)

;Список с именами цветовых процессов
(set! clr-list
  (list
  
  ;Процесс "СОВ" с id=0
  "СОВ"

  ;Процесс "Ч/Б" с id=1
  "Ч/Б"
  
  ;Процесс "Ломо" с id=2
  "Ломо"

  ;Процесс "Сепия" id=3
  "Сепия"
  )
)
(if (= param TRUE)
  (set! clr-handle clr-list)
  (begin
    
    ;Список с блоками запуска цветовых процессов
    (cond

      ;Блок запуска процесса "СОВ"
      ((= clr_id 0) (set! clr-handle (quote (fil-int-sov image clr_tar c_imh c_imw))))

      ;Блок запуска процесса "Ч/Б"
      ((= clr_id 1) (set! clr-handle (quote (fil-int-gray image clr_tar))))

      ;Блок запуска процесса "Ломо"
      ((= clr_id 2) (set! clr-handle (quote (fil-int-lomo image clr_tar))))

      ;Блок запуска процесса "Сепия"
      ((= clr_id 3) (set! clr-handle (quote (fil-int-sepia image clr_tar c_imh c_imw c_fore))))
    )
  )
)
clr-handle
)

;fil-grain-handle
;МОДУЛЬ ЯДРА
;Входные переменные:
;КОМБИНАЦИЯ - TRUE если требуется возвратить лист процессов / номер процесса для возвращения блока кода;
;ЦЕЛОЕ - номер выбранного процесса (занулить если нужно возвратить список);
;Возвращаемые значения:
;КОМБИНАЦИЯ - лист с текстовыми названиями процессов / блок кода для исполнения;
(define (fil-grain-handle param grain_id)
(define grain-handle)
(define grain-list)

;Список с именами процессов зернистости
(set! grain-list
  (list
  
  ;Процесс "Простая зернистость" с id=0
  "Простая зернистость"

  ;Процесс "Зерно+" с id=1
  "Зерно+"
  )
)
(if (= param TRUE)
  (set! grain-handle grain-list)
  (begin

    ;Список с блоками запуска процессов зернистости
    (cond

      ;Блок запуска процесса "Простая зернистость"
      ((= grain_id 0) (set! grain-handle (quote (fil-int-simplegrain image))))

      ;Блок запуска процесса "Зерно+"
      ((= grain_id 1) (set! grain-handle (quote (fil-int-adv_grain image c_imh c_imw c_fore boost_ex))))
    )
  )
)
grain-handle
)

(script-fu-register
"fil-ng-core"
"_ЛИПС v1.0"
"Лаборатория имитации пленочных снимков"
"Непочатов Станислав"
"GPLv2"
"Январь 2010"
"*"
SF-IMAGE	"Изображение"			0
SF-TOGGLE	"Исполение процесса"		TRUE
SF-OPTION 	"Цветовой процесс" 		(fil-clr-handle TRUE 0)
SF-TOGGLE	"Создание зерна"		TRUE
SF-OPTION	"Процесс зерна"			(fil-grain-handle TRUE 0)
SF-TOGGLE	"Супер зерно (если возможно)"	FALSE
SF-TOGGLE	"Включить виньетирование"	FALSE
SF-ADJUSTMENT	"Радиус виньетирования (%)"	'(100 85 125 5 10 1 0)
SF-ADJUSTMENT	"Мягкость виньтирования (%)"	'(33 20 45 2 5 1 0)
SF-ADJUSTMENT	"Плотность виньетирования"	'(100 0 100 10 25 1 0)
SF-TOGGLE	"Плохой обьектив (медленно)"	FALSE
SF-OPTION	"Cтепень размытия"		'("x1" "x2" "x3")
SF-TOGGLE	"Работать с видимым"		FALSE
)

(script-fu-menu-register
"fil-ng-core"
_"<Image>/Filters/RED STORM FX"
)

;fil-source-handle
;МОДУЛЬ ЯДРА
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;ЛОГИЧ. - значение viz;
;Вовращаемые значения:
;СЛОЙ - готовый слой;
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
	    (gimp-drawable-set-name exit-layer "Source = Visisble")
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

;fil-pre-vignette
;ПРЕ-ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦЕЛОЕ - значение прозрачности виньтирования;
;ЦЕЛОЕ - значение резкости границы виньетирования;
;ЦЕЛОЕ - значение радиуса виньетирования;
;ЦВЕТ - цвет переднего плана;
(define (fil-pre-vignette image imh imw vign_opc vign_rad vign_soft fore)
  (let* (
	(src (car (gimp-image-get-active-layer image)))
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
	(gimp-drawable-set-name norm_vign "Normal Vignette")
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
	(gimp-image-set-active-layer image src)
  )
)

;fil-pre-badblur
;ПРЕ-ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦЕЛОЕ - значение степени размытия;
(define (fil-pre-badblur image layer imh imw ext)
  (set! ext (+ ext 1))
  (plug-in-mblur 1 image layer 2 (/ (+ (/ imh (/ 1500 ext)) (/ imw (/ 1500 ext))) 2) 0 (/ imw 2) (/ imh 2))
)

;fil-int-sov
;ЦВЕТОВОЙ ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
(define (fil-int-sov image layer imh imw)
  (let* (
	(first (car (gimp-layer-copy layer FALSE)))
	(red (car (gimp-layer-new image imw imh 0 "Mask tone" 100 0)))
	(red_mask)
	)
	(gimp-hue-saturation layer 0 5 0 -30)
	(gimp-image-add-layer image first -1)
	(gimp-image-add-layer image red -1)
	(gimp-drawable-set-name first "Global tone")
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
	(gimp-layer-set-opacity first 60)
	(gimp-layer-set-opacity red 65)
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
	(gimp-image-set-active-layer image layer)
  )
)

;fil-int-gray
;ЦВЕТОВОЙ ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
(define (fil-int-gray image layer)
  (plug-in-colors-channel-mixer 1 image layer TRUE 0 0.3 0.6 0 0 0 0 0 0)
  (gimp-drawable-set-name layer "B/W")
)

;fil-int-lomo
;ЦВЕТОВОЙ ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
(define (fil-int-lomo image layer)
  ;code by Donncha O Caoimh (donncha@inphotos.org) and elsamuko (elsamuko@web.de)
  ;http://registry.gimp.org/node/7870
  (gimp-curves-spline layer 1 10 #(0 0 80 84 149 192 191 248 255 255))
  (gimp-curves-spline layer 2 8 #(0 0 70 81 159 220 255 255))
  (gimp-curves-spline layer 3 4 #(0 27 255 213))
  (gimp-drawable-set-name layer "Lomo")
)

;fil-int-sepia
;ЦВЕТОВОЙ ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦВЕТ - цвет переднего плана;
(define (fil-int-sepia image layer imh imw foreground)
  (let* (
	(paper (car (gimp-layer-new image imw imh 0 "Photo Paper" 100 0)))
	)
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
	(gimp-colorize layer 34 30 0)
	(gimp-drawable-set-name layer "Sepia")
	(gimp-image-set-active-layer image layer)
  )
)

;fil-int-simplegrain
;ПРОЦЕСС ЗЕРНИСТОСТИ
;Входные переменные
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
(define (fil-int-simplegrain image)
  (let* (
	(clr_res (car (gimp-image-get-active-layer image)))
	)
	(plug-in-hsv-noise 1 image clr_res 2 3 0 25)
	(gimp-drawable-set-name clr_res "Simple Grain")
	(gimp-image-set-active-layer image clr_res)
  )
)

;fil-int-adv_grain
;ПРОЦЕСС ЗЕРНИСТОСТИ
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦВЕТ - цвет переднего плана;
;ЛОГИЧЕСКОЕ - значение установки усиления зернистости;
(define (fil-int-adv_grain image imh imw foreground boost)
  (let* (
	(clr_res (car (gimp-image-get-active-layer image)))
	(grain_boost)
	(name "Grain+")
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
	    (gimp-drawable-set-name grain_boost "Boost")
	    (set! name (string-append name " boosted"))
	  )
	)
	(set! clr_res (car (gimp-image-merge-down image grain 0)))
	(if (= boost TRUE)
	  (set! clr_res (car (gimp-image-merge-down image grain_boost 0)))
	)
	(plug-in-gauss-iir2 1 image clr_res rel_step rel_step)
	(gimp-drawable-set-name clr_res name)
	(gimp-image-set-active-layer image clr_res)
  )
)