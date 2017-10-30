;; TAREA PROGRAMADA II
;;
;; Escuela​ ​ de​ ​ Ciencias​ ​ de​ ​ la​ ​ Computación​ ​ e Informática
;; CI-1441​ ​ - ​ ​ Paradigmas​ ​ Computacionales
;; Prof.​ ​ Alvaro​ ​ de​ ​ la​ ​ Ossa​ ​ O.
;;
;; Estudiantes:
;; Leonardo​ ​ Jiménez​ ​ Quijano,​ ​ 961611
;; Daniel​ ​ Orozco​ ​ Venegas,​ ​ B24882
;; Fanny​ ​ Porras​ ​ Zúñiga,​ ​ A34045



;; Procesamiento de arboles y conjuntos ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Busqueda por profundidad primero ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: documentacion estandar
(defun bpp (N A))


;; Busqueda anchura primero ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: documentacion estandar
(defun bap (N A))


;; Potencia ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: documentacion estandar
(defun potencia (C)
  (if (null C)
      (list nil)
      (let ((prev (potencia (cdr C))))
        (append (mapcar #'(lambda (elt) (cons (car C) elt)) prev)
          prev))))


;; Producto cartesiano ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Función auxiliar
(defun distribuidor (m N)
  (cond
   ((null N) nil)
   (t (cons (list m (car N))
            (distribuidor m (cdr N))))))

;; TODO: documentacion estandar
(defun cartesiano (A B)
  (cond((null A) nil)
   (t (append (distribuidor (car A) B)
              (cartesiano (cdr A) B)))))


;; La maquina encriptadora ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Encripta ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: documentacion estandar
(defun encripta (H Ae As))

;; Decripta ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: documentacion estandar
(defun decripta (H Ae As Ef))
