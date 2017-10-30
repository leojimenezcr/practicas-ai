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
;; Produce el producto potencia de C (lista).
;;
;; Ejemplo: (potencia '(a b c)) -> (nil (a) (b) (c) (a b) (a c) (b c) (a b c))
;;
;; -->
(defun potencia (C)
  (cond ((null C) (list nil))
        (t (let ((prev (potencia (cdr C))))
             (append (mapcar #'(lambda (elt) (cons (car C) elt)) prev) prev)
           )
        )
  )
)

;; Producto cartesiano ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Produce el producto cartesiano de A y B (listas).
;;
;; Ejemplo:  (cartesiano '(a b c) '(d e)) -> ((a d) (a e) (b d) (b e) (c d) (c e))
;;
;; -->
(defun cartesiano (A B)
  (cond((null A) nil)
    (t (append (distribuidor (car A) B)
              (cartesiano (cdr A) B)
       )
    )
  )
)


;; Función auxiliar
;; Crea una lista con las combinaciones de m y los elementos de N
;;
;; Ejemplo:  (distribuidor 'a '(b c)) -> ((a b) (a c))
;;
;; -->
(defun distribuidor (m N)
  (cond ((null N) nil)
        (t (cons (list m (car N))
             (distribuidor m (cdr N))
           )
        )
  )
)


;; La maquina encriptadora ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Encripta ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: documentacion estandar
;; Ejemplo: (encripta '(h i e c a) '(a b c d e f g h i j) '(0 1 2 3 4 5 6 7 8 9))
;;            -> ((7 8 4 2 0) . (a . 0))
(defun encripta (H Ae As)
  (cond
    ; cuando llega al fin de la busqueda
    ( (null H) (cons (last Ae) (last As)) )

    ; cuando el simbolo coincide con la cabeza del alfabeto de entrada
    ( (equal (car H)(car Ae)) (cons (car As) (encripta (cdr H)(rota Ae)(rota As))) )

    ; cuando no hay coincidencia del simbolo con la cabeza del alfabeto
    ( t (encripta H (rota Ae) (rota As)) )
  )
)

;; Decripta ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: documentacion estandar
(defun decripta (H Ae As Ef))

;; Rota
(defun rota (lista)
      (append (cdr lista) (cons (car lista) nil)))
