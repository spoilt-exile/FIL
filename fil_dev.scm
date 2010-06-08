;FIL v1.6 RC1
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
;ЛИПС (Лаборатория имитации пленочных снимков) = FIL;
;Список задач (ver. 1.6):
; - переработка API;				(СДЕЛАНО)
; - оциональный вывод индикации опций;		(СДЕЛАНО)
; - ввод глобальных переменных ядра;		(СДЕАЛНО)
; - ввод парадигмы параметров исполнения;	(СДЕЛАНО)
; - опциональное совмещение слоев и гипервизор	(ОТБРОШЕНО)
; - режим "Гранж" в процесс "Сульфид"		(СДЕЛАНО)
; - реализовать поддержку стека отмены;		(ОТБРОШЕНО)
;История версий:
;===============================================================================================================
;ver. 0.3 (19 декабря 2009)
; - рабочая сборка скрипта с начальным набором процедур.
; - определение спецификаций к модулям версии ядра ЛИПС 0.3.
;===============================================================================================================
;ver. 0.5 (22 декабря 2009)
; - раздельное выполнение цветового и зернового процесса.
; - вывод имени учвствовавших в обработке процессов в имя итогового слоя.
; - модификация спецификаций.
; - устанвка классов расширений.
;===============================================================================================================
;ver 0.8 (24 декабря 2009)
; - смена ядра на модифицированное (NG).
; - виньетирование как пре-процесс.
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
;ver 1.5.0 (3 мая 2010)
; - полная переработка всех стадий ядра;
; - новые спецификации;
; - регистрирующие процедуры для процессов цветокорректировки и зернистости;
; - классификация всех переменных ядра;
; - добавлен цветовой процесс "Двутон" (базируется на Split Studio 3);
; - добавлен пре-процесс коррекции экспозиции;
;===============================================================================================================
;ver 1.5.1 (5 июня 2010)
; - конвеерное исполнение ядра FIL;
; - новый процесс зернистости "Сульфид"
;===============================================================================================================
;Процедуры:			Статус		Ревизия		Спецификации
;==========================================ПРОЦЕДУРЫ ЯДРА=======================================================
;fil-ng-core			стаб		---		1.6
;fil-stage-handle		стаб		---		---
;fil-source-handle		стаб		---		---
;fil-ng-batch			стаб		---		---
;============================================ПРЕПРОЦЕССЫ========================================================
;fil-pre-xps			стаб		r0		1.6
;fil-pre-vignette		стаб		r3		1.6
;fil-pre-badblur		стаб		r1		1.6
;=========================================ЦВЕТОВЫЕ ПРОЦЕССЫ=====================================================
;fil-int-sov			стаб		r5		1.6
;fil-int-gray			стаб		r2		1.6
;fil-int-lomo			стаб		r1		1.6
;fil-int-sepia			стаб		r4		1.6
;fil-int-duo			стаб		r1		1.6
;=======================================ПРОЦЕССЫ ЗЕРНИСТОСТИ====================================================
;fil-int-simplegrain		стаб		r2		1.6
;fil-int-grain_plus		стаб		r4		1.6
;fil-int-sulfide		стаб		r2		1.6
;=======================================Классы модуей ЛИПС======================================================
; -pre - пре-процесс.
; -int - внутрення процедура (в файле основного скрипта).
; -ext - внешняя процедура (вне основного скрипта).
; -dep - внешняя процедура требующая внешних плагинов.
;================================Набор требований к процессам ЛИПС 1.6:=========================================
; * процессы не могут вызывать процессы ЛИПС от своего имени, но могут обращатся к дополнительным процедурам.
; * процессы не должны изменять размеры изорбражения и его параметры (глубина цвета).
; * процессы могут брать параметры изображения непосредственно из ядра (переменные с префиксом fc).
; * регистрируемые стадии должны быть определены собственной переменной и включены в состав fk-stages-list.
; * процессы должны быть зарегестрированы в переменных fk-clr-stage и fk-grain-stage для работоспособности.
; * процессы должны по окончанию работы возвращать итоговый слой ядру (если процесс оперирует слоями).
; * процессы могут иметь специальные параметры запуска тем самым реализуя запуск с определенными параметрами.
;========================================Стадии ядра ЛИПС 1.6===================================================
;Стадия			Регистрируемая			Номер стадии (stage_id)
;pre-stage		НЕТ				0
;fk-clr-stage		ДА				1
;fk-grain-stage		ДА				2
;===============================================================================================================

;Глобальные переменные ядра

;Регистрация процедур стадии ядра с stage_id=1 (стадия цветовых процессов);
(define fk-clr-stage)
(set! fk-clr-stage
  (list
    
    ;Процесс "СОВ: обычный" с proc_id=0
    (list "СОВ: обычный" 	(quote (set! fp_clr_layer (fil-int-sov fm_image fp_clr_layer fc_imh fc_imw 60 65))))

    ;Процесс "СОВ: легк." с proc_id=1
    (list "СОВ: легкий" 	(quote (set! fp_clr_layer (fil-int-sov fm_image fp_clr_layer fc_imh fc_imw 30 35))))

    ;Процесс "Ч/Б" с proc_id=2
    (list "Ч/Б" 		(quote (fil-int-gray fm_image fp_clr_layer)))

    ;Процесс "Ломо" с proc_id=3
    (list "Ломо" 		(quote (fil-int-lomo fm_image fp_clr_layer)))

    ;Процесс "Сепия:  обычная" proc_id=4
    (list "Сепия: обычная" 	(quote (set! fp_clr_layer (fil-int-sepia fm_image fp_clr_layer fc_imh fc_imw fc_fore FALSE))))

    ;Процесс "Сепия: с имитацией" proc_id=5
    (list "Сепия: с имитацией"	(quote (set! fp_clr_layer (fil-int-sepia fm_image fp_clr_layer fc_imh fc_imw fc_fore TRUE))))

    ;Процесс "Двутон: обычный" proc_id=6
    (list "Двутон: обычный" 	(quote (set! fp_clr_layer (fil-int-duo fm_image fp_clr_layer 75 '(200 175 140) '(80 102 109)))))

    ;Процесс "Двутон: низ. контраст" proc_id=7
    (list "Двутон: мягкий" 	(quote (set! fp_clr_layer (fil-int-duo fm_image fp_clr_layer 30 '(200 175 140) '(80 102 109)))))

    ;Процесс "Двутон: низ. контраст" proc_id=8
    (list "Двутон: свои цвета" 	(quote (set! fp_clr_layer (fil-int-duo fm_image fp_clr_layer 55 fc_fore fc_back))))
  )
)

;Регистрация процедур стадии ядра с stage_id=2 (стадия процессов зернистости);
(define fk-grain-stage)
(set! fk-grain-stage
  (list

    ;Процесс "Простая зернистость" с proc_id=0
    (list "Простая зернистость"	(quote (fil-int-simplegrain fm_image fp_grain_layer)))

    ;Процесс "Зерно+" с proc_id=1
    (list "Зерно+: обыч." 	(quote (set! fp_grain_layer (fil-int-adv_grain fm_image fp_grain_layer fc_imh fc_imw fc_fore FALSE))))

    ;Процесс "Зерно+ усиленное" с proc_id=2
    (list "Зерно+: усил." 	(quote (set! fp_grain_layer (fil-int-adv_grain fm_image fp_grain_layer fc_imh fc_imw fc_fore TRUE))))

    ;Процесс "Сульфид: обычный" с proc_id=3
    (list "Сульфид: обычный"	(quote (set! fp_grain_layer (fil-int-sulfide fm_image fp_grain_layer fc_imh fc_imw fc_fore 2.5 FALSE))))

    ;Процесс "Сульфид: крупный" с proc_id=4
    (list "Сульфид: крупный"	(quote (set! fp_grain_layer (fil-int-sulfide fm_image fp_grain_layer fc_imh fc_imw fc_fore 3.1 FALSE))))

    ;Процесс "Сульфид: обычный" с proc_id=5
    (list "Сульфид: гранж"	(quote (set! fp_grain_layer (fil-int-sulfide fm_image fp_grain_layer fc_imh fc_imw fc_fore 2.7 TRUE))))
  )
)

;Единая переменная листа регистрируемых стадий процессов
(define fk-stages-list 
  (list 
    FALSE			;Стадия пре-процессов (нерегистрируемая) обозначается как FALSE;
    fk-clr-stage		;Стадия цветовых процессов;
    fk-grain-stage		;Стадия процессов зернистости;
    )
)

;Счетчик стадий для ядра
(define fk-stage-counter 0)

;Процедура ядра FIL
(define (fil-ng-core		;имя процедуры;

	;Главные атрибуты запуска
	fm_image		;перменная изображения;

	;Управление цветовыми процессами
	fm_clr_flag		;переключатель исполнения цветового процесса;
	fm_clr_id		;номер цветового процесса;

	;Управление процессами зернистости
	fm_grain_flag		;переключатель исполнения процесса зернистости;
	fm_grain_id		;номер процесса зернистости;

	;Управление пре-процессами
	fm_pre_vign_flag	;переключатель активации виньетирования;
	fm_pre_vign_rad		;радиус виньетирования в процентах;
	fm_pre_vign_soft	;мягкость виньетирования;
	fm_pre_vign_opc		;плотность виньетирования;
	fm_pre_blur_step	;регулятор размытия;
	fm_pre_xps_control	;регулятор корректировки экспозиции;

	;Дополнительные параметры
	fm_misc_logout		;переключатель опционального вывода опций;
	fm_misc_visible		;переключатель использования видимого;
	)

  ;Старт ядра
  (gimp-context-push)
  (gimp-image-undo-disable fm_image)

  ;Декларация переменных;
  (let* (

	;Переменные для передачи процессам
	(fc_imh (car (gimp-image-height fm_image)))		;системная переменная высоты изображения
	(fc_imw (car (gimp-image-width fm_image)))		;системная переменная ширины изображения
	(fc_fore (car (gimp-context-get-foreground)))		;системная переменная цвета переднего плана
	(fc_back (car (gimp-context-get-background)))		;системная переменная цвета заднего плана

	;Управления стадиями
	(fl_pre_flag FALSE)					;флаг исполнения пре-процессов

	;Результирующие переменные полученные от процессов регистрации
	(fx_clr_list)						;Лист с переменными после исполнения fil-clr-handle
	(fx_clr_exp)						;Выражение для исполнения стадии цветвого процессами
	(fx_grain_list)						;Лист с переменными после исполнения fil-grain-handle
	(fx_grain_exp)						;Выражение для исполнения стадии процесса зернистости

	;Слои взаимодействия с процессами
	(fp_pre_layer)						;единый слой для пре-стадии
	(fp_clr_layer)						;единый слой для цветовых процессов
	(fp_grain_layer)					;единый слой для процессов зернистости

	;Префиксы индикации опций
	(fs_pref_pre "-п ")					;префикс для обозначения обработки пре-процессами
	(fs_pref_clr "-ц ")					;префикс для обозначения обработки цветовым процессом
	(fs_pref_grain "-з ")					;префикс для обозначения обработки процессом зернистости

	;Вспомогательные строковые переменные
	(fs_clr_str)						;имя результирующего цветового слоя
	(fs_grain_str)						;имя результирующего слоя зернистости
	(fs_res_str "")						;имя итогового слоя
	(fs_xps_str "Эксп. ")					;метка индикации корректировки экспозиции
	(fs_vign_str "(В) ")					;приставка для отображения итогового слоя с виньетированием
	(fs_blur_str "Разм. x")					;приставка для отображения итогового слоя с размытием
	(fs_default_str "Результат обработки ЛИПС")		;имя конечного слоя без индикации переменных
	)

	;Секция активации исполнения пре-процессов
	(cond
	  ((> fm_pre_blur_step 0) (set! fl_pre_flag TRUE))
	  ((and (= fm_pre_vign_flag TRUE) (> fm_pre_vign_opc 0)) (set! fl_pre_flag TRUE))
	  ((not (= fm_pre_xps_control 0)) (set! fl_pre_flag TRUE))
	)

	;Инициализация секции пре-процессов
	(if (= fl_pre_flag TRUE)
	  (begin

	    ;Копирование слоя
	    (set! fp_pre_layer (fil-source-handle fm_image fm_misc_visible))
	    (set! fs_res_str (string-append fs_res_str fs_pref_pre))

	    ;Запуск корректировки экспозиции
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

	    ;Запуск виньетирования
	    (if (= fm_pre_vign_flag TRUE)
	      (if (> fm_pre_vign_opc 0)
		(begin
		  (set! fp_pre_layer (fil-pre-vignette fm_image fp_pre_layer fc_imh fc_imw fm_pre_vign_opc fm_pre_vign_rad fm_pre_vign_soft fc_fore))
		  (set! fs_res_str (string-append fs_res_str fs_vign_str))
		)
	      )
	    )
	    
	    ;Запуск размытия
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

	;Передача слоя между стадиями и корректировка счетчика стадий
	(set! fp_clr_layer fp_pre_layer)
	(set! fk-stage-counter (+ fk-stage-counter 1))

	;Запуск цветового процесса
	(if (= fm_clr_flag TRUE)
	  (begin

	    ;Проверка передаваемого слоя
	    (if (null? fp_clr_layer)
	      (set! fp_clr_layer (fil-source-handle fm_image fm_misc_visible))
	    )

	    ;Инициализация листа процессов
	    (set! fx_clr_list (fil-stage-handle FALSE fk-stage-counter fm_clr_id))
	    (set! fs_clr_str (car fx_clr_list))
	    (set! fx_clr_exp (cadr fx_clr_list))

	    ;Запуск исполнения процесса
	    (eval fx_clr_exp)

	    ;Захват готового слоя и его имени
	    (set! fs_res_str (string-append fs_res_str fs_pref_clr fs_clr_str " "))
	    (if (= fm_misc_logout TRUE)
	      (gimp-drawable-set-name fp_clr_layer fs_res_str)
	      (gimp-drawable-set-name fp_clr_layer fs_default_str)
	    )
	  )
	)

	;Передача слоя между стадиями и корректировка счетчика стадий
	(set! fp_grain_layer fp_clr_layer)
	(set! fk-stage-counter (+ fk-stage-counter 1))

	;Запуск процесса генерации зерна
	(if (= fm_grain_flag TRUE)
	  (begin

	    ;Проверка передаваемого слоя
	    (if (null? fp_grain_layer)
	      (set! fp_grain_layer (fil-source-handle fm_image fm_misc_visible))
	    )

	    ;Инициализация листа процессов зернистости
	    (set! fx_grain_list (fil-stage-handle FALSE fk-stage-counter fm_grain_id))
	    (set! fs_grain_str (car fx_grain_list))
	    (set! fx_grain_exp (cadr fx_grain_list))

	    ;Запуск исполнения процесса
	    (eval fx_grain_exp)

	    ;Завершение сборки имени итогового слоя
	    (set! fs_res_str (string-append fs_res_str fs_pref_grain fs_grain_str))
	    (if (= fm_misc_logout TRUE)
	      (gimp-drawable-set-name fp_grain_layer fs_res_str)
	      (gimp-drawable-set-name fp_grain_layer fs_default_str)
	    )
	  )
	)

	;Возвращение исходного цвета переднего плана
	(gimp-context-set-foreground fc_fore)
	(gimp-context-set-background fc_back)
	(gimp-displays-flush)
  )

  ;Обнуление счетчика стадий
  (set! fk-stage-counter 0)

  ;Завершение исполнения
  (gimp-image-undo-enable fm_image)
  (gimp-context-pop)
)

;fil-stage-handle
;МОДУЛЬ ЯДРА
;Входные переменные:
;БУЛЕВОЕ - TRUE если требуется возвратить лист процессов / FALSE для возвращения лист с переменными запуска;
;ЦЕЛОЕ - номер стадии ядра (обязательный параметр);
;ЦЕЛОЕ - номер выбранного процесса (занулить если нужно возвратить список);
;Возвращаемые значения:
;ЛИСТ - лист с текстовыми названиями процессов / лист с именем процесса и блоком кода;
(define (fil-stage-handle param stage_id proc_id)
(define stage-handle)
(let* (
      (stage_error (string-append "ЛИПС не нашел стадию с указанным номером:\nstage_id=" (number->string stage_id)))
      (proc_error (string-append "ЛИПС не нашел процесс с указанным номером:\nstage_id=" (number->string stage_id) "\nproc_id=" (number->string proc_id)))
      (stage_counter -1)
      (proc_counter -1)
      (current_stage_list)
      (name_list '())
      (proc_list)
      (temp_list)
      (temp_entry)
      )
      (set! temp_list fk-stages-list)

      ;Получение листа текущей стадии
      (if (not (or (= stage_id 0) (> stage_id (- (length fk-stages-list) 1))))
	(while (< stage_counter stage_id)
	  (begin
	    (set! current_stage_list (car temp_list))
	    (set! stage_counter (+ stage_counter 1))
	    (set! temp_list (cdr temp_list))
	  )
	)
	(gimp-message stage_error)
      )

      (if (= param TRUE)

	;Генерирование листа с именами прцессов
	(begin
	  (while (not (null? current_stage_list))
	    (set! temp_entry (car current_stage_list))
	    (set! name_list (append name_list (list (car temp_entry))))
	    (set! current_stage_list (cdr current_stage_list))
	  )
	  (set! stage-handle name_list)
	)

	;Получени листа с именем процесс и блоком запуска
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

;Часть регистрации процедуры FIL, отвечающей за данные автора
(define fil-credits
  (list
  "Непочатов Станислав"
  "GPLv3"
  "Июнь 2010"
  )
)

;Часть регистрации процедуры FIL, отвечающий за настройку процедуры
(define fil-controls
  (list
  SF-TOGGLE	"Стадия цветокорректировки"	TRUE
  SF-OPTION 	"Цветовой процесс" 		(fil-stage-handle TRUE 1 0)
  SF-TOGGLE	"Стадия зернистости"		TRUE
  SF-OPTION	"Процесс зернистости"		(fil-stage-handle TRUE 2 0)
  SF-TOGGLE	"Включить виньетирование"	FALSE
  SF-ADJUSTMENT	"Радиус виньетирования (%)"	'(100 85 125 5 10 1 0)
  SF-ADJUSTMENT	"Мягкость виньетирования (%)"	'(33 20 45 2 5 1 0)
  SF-ADJUSTMENT	"Плотность виньетирования"	'(100 0 100 10 25 1 0)
  SF-OPTION	"Cтепень размытия краев"	'("Отключено" "x1" "x2" "x3")
  SF-ADJUSTMENT	"Коррекция экспозиции"		'(0 -2 2 0.1 0.3 1 0)
  SF-TOGGLE	"Записать опции в имя слоя"	FALSE
  )
)

;Регистрация процедуры ядра fil-ng-core
(apply script-fu-register
  (append
    (list
    "fil-ng-core"
    _"<Image>/Filters/RSS Devel/_ЛИПС 1.6 RC1"
    "Лаборатория имитации пленочных снимков"
    )
    fil-credits
    (list
    "RGB,RGBA*"
    SF-IMAGE	"Изображение"			0
    )
    fil-controls
    (list
    SF-TOGGLE	"Работать с видимым"		FALSE
    )
  )
)

;Процедура конвеерного исполнения ядра
(define (fil-ng-batch		;имя процедуры

	;Управление конвейерным исполненнием
	fb_dir_in		;адрес входящей директории;
	fb_input_format		;входящий формат;
	fb_dir_out		;адрес выходящей директории;
	fb_out_format		;выходящий формат;

	;Управление цветовыми процессами
	fbm_clr_flag		;переключатель исполнения цветового процесса;
	fbm_clr_id		;номер цветового процесса;

	;Управление процессами зернистости
	fbm_grain_flag		;переключатель исполнения процесса зернистости;
	fbm_grain_id		;номер процесса зернистости;

	;Управление пре-процессами
	fbm_pre_vign_flag	;переключатель активации виньетирования;
	fbm_pre_vign_rad	;радиус виньетирования в процентах;
	fbm_pre_vign_soft	;мягкость виньетирования;
	fbm_pre_vign_opc	;плотность виньетирования;
	fbm_pre_blur_step	;регулятор размытия;
	fbm_pre_xps_control	;регулятор корректировки экспозиции;
	
	;Дополнительные элементы управления
	fbm_misc_logout		;переключатель опционального вывода опций;
	)

  ;Определение входящего формата
  (define input-ext)
  (cond
    ((= fb_input_format 0) (set! input-ext "*"))
    ((= fb_input_format 1) (set! input-ext "[jJ][pP][gG]"))
    ((= fb_input_format 2) (set! input-ext "[bB][mM][pP]"))
    ((= fb_input_format 3) (set! input-ext "[xX][cC][fF]"))
  )

  ;Определение выходящего формата
  (define out-ext)
  (cond
    ((= fb_out_format 0) (set! out-ext "jpg"))
    ((= fb_out_format 1) (set! out-ext "png"))
    ((= fb_out_format 2) (set! out-ext "tif"))
    ((= fb_out_format 3) (set! out-ext "bmp"))
    ((= fb_out_format 4) (set! out-ext "xcf"))
    ((= fb_out_format 5) (set! out-ext "psd"))
  )

  ;Декларация переменных
  (let*	(
	(dir_os (if (equal? (substring gimp-dir 0 1) "/") "/" "\\"))
	(pattern (string-append fb_dir_in dir_os "*." input-ext))
	(filelist (cadr (file-glob pattern 1)))
	(run_mode 1)
	)

	;Начало цикла
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

		;Предварительное сведение слоев
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

		;Непосредственно процедура запуска процедуры ядра fil-ng-core
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

		;Полседующее сведение слоев
		(if (< fb_out_format 4)
		  (set! res_layer (car (gimp-image-merge-visible-layers img 0)))
		  (set! res_layer (car (gimp-image-get-active-layer img)))
		)

		;Обработка строковых переменных и получение выходящего пути
		(set! file (substring filename (string-length fb_dir_in) (- (string-length filename) 4 )))
		(set! target_out (string-append fb_dir_out "/" file "_FIL." out-ext))

		;Сохранение файла
		(cond
		  ((= fb_out_format 0) (file-jpeg-save 1 img res_layer target_out target_out 1 0 1 1 "" 2 1 0 0))
		  ((= fb_out_format 1) (file-png-save-defaults 1 img res_layer target_out target_out))
		  ((= fb_out_format 2) (file-tiff-save 1 img res_layer target_out target_out 1))
		  ((= fb_out_format 3) (file-bmp-save 1 img res_layer target_out target_out))
		  ((= fb_out_format 4) (gimp-xcf-save 1 img res_layer target_out target_out))
		  ((= fb_out_format 5) (file-psd-save 1 img res_layer target_out target_out 1 0))
		)

		;Удаление изображения
		(gimp-image-delete img)
	  )

	  ;Сдвиг списка имен файлов и завершение этапа цикла
	  (set! filelist (cdr filelist))
	)
  )
)

;Регистрация процедуры пакетной обработки ядра fil-ng-batch
(apply script-fu-register
  (append
    (list
    "fil-ng-batch"
    _"<Image>/Filters/RSS Devel/ЛИПС 1.6 RC1 _Конвейер"
    "Конвейерное исполнение ЛИПС"
    )
    fil-credits
    (list
    ""
    SF-DIRNAME	"Папка-источник"	"/home/spoilt/Документы/Batch/IN"
    SF-OPTION	"Входящий формат"	'(
					"*"
					"JPG"
					"TIFF"
					"XCF"
					)
    SF-DIRNAME	"Папка-назначение"	"/home/spoilt/Документы/Batch/OUT"
    SF-OPTION	"Формат сохранения"	'(
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
;МОДУЛЬ ЯДРА
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;ЛОГИЧ. - значение fm_misc_visible;
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

;Завершение области ядра

;fil-pre-xps
;ПРЕ-ПРОЦЕСС
;Входные переменные:
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - величина корректировки экспозиции;
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
;ПРЕ-ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦЕЛОЕ - значение прозрачности виньтирования;
;ЦЕЛОЕ - значение резкости границы виньетирования;
;ЦЕЛОЕ - значение радиуса виньетирования;
;ЦВЕТ - цвет переднего плана;
;Возвращаемые значения:
;СЛОЙ - обработанный слой;
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
	(set! vign-exit src)
  )
vign-exit
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
  (gimp-image-undo-freeze image)
  (plug-in-mblur 1 image layer 2 (/ (+ (/ imh (/ 1500 ext)) (/ imw (/ 1500 ext))) 2) 0 (/ imw 2) (/ imh 2))
  (gimp-image-undo-thaw image)
)

;fil-int-sov
;ЦВЕТОВОЙ ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦЕЛОЕ - значение плотности тонирования;
;ЦЕЛОЕ - значение плотности красной вуали;
;Возвращаемые значения:
;СЛОЙ - обработанный слой;
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
;БУЛЕВОЕ - переключатель режима имитации фотобумаги;
;Возвращаемые значения:
;СЛОЙ - обработанный слой;
(define (fil-int-sepia image layer imh imw foreground paper_switch)
(define sepia-exit)
  (let* (
	(paper 0)
	)
	(if (= paper_switch TRUE)
	  (begin
	    (set! paper (car (gimp-layer-new image imw imh 0 "Photo Paper" 100 0)))
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
;ЦВЕТОВОЙ ПРОЦЕСС
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение плотности слоя аффекта;
;ЦВЕТ - цвет для светлой области;
;ЦВЕТ - цвет для темно области;
;Возвращаемые переменные:
;СЛОЙ - ббработанный слой;
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
	(gimp-drawable-set-name dark "Темный тон")
	(gimp-drawable-set-name light "Светлый тон")
	(gimp-drawable-set-name affect "Аффект")
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
;ПРОЦЕСС ЗЕРНИСТОСТИ
;Входные переменные
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
(define (fil-int-simplegrain image clr_res)
  (plug-in-hsv-noise 1 image clr_res 2 3 0 25)
  (gimp-drawable-set-name clr_res "Simple Grain")
)

;fil-int-adv_grain
;ПРОЦЕСС ЗЕРНИСТОСТИ
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦВЕТ - цвет переднего плана;
;ЛОГИЧЕСКОЕ - значение установки усиления зернистости;
;Возвращаемые значения:
;СЛОЙ - обработанный слой;
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
	(set! adv-exit clr_res)
  )
adv-exit
)

;fil-int-sulfide
;ПРОЦЕСС ЗЕРНИСТОСТИ
;Входные переменные:
;ИЗОБРАЖЕНИЕ - обрабатываемое изображение;
;СЛОЙ - обрабатываемый слой;
;ЦЕЛОЕ - значение высоты изображения;
;ЦЕЛОЕ - значение ширины изображения;
;ЦВЕТ - цвет переднего плана;
;Возвращаемые значения:
;СЛОЙ - обработанный слой;
(define (fil-int-sulfide image layer imh imw foreground scale_step grunge_switch)
(define sulf-exit)
  (let* (
	;(scale_step 2.8)
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
	    (gimp-layer-new image imw imh 0 "Normal grain" 100 0)
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
		(gimp-layer-new image imw imh 0 "Grunge Overlay" 100 0)
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