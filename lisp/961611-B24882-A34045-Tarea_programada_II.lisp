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

;; (encripta H Ae As) -> el resultado de encriptar la hilera de entrada H con un
;;   engranaje formado por los alfabetos de entrada (Ae) y salida (As), y el
;;   estado final de la máquina, formado por el par (ae . as), donde ae y as son
;;   los simbolos de los alfabetos de entrada y salida, respectivamente, en los
;;   que quedo la máquina luego de encriptar H
;;
;; Ejemplo: (encripta '(h i e c a) '(a b c d e f g h i j) '(0 1 2 3 4 5 6 7 8 9))
;;            -> ((7 8 4 2 0) . (a . 0))
(defun encripta (H Ae As)
  (cond
    ; cuando llega al fin de la busqueda
    ( (null H) (cons (last Ae)(last As)) )

    ; cuando el simbolo coincide con la cabeza del alfabeto de entrada
    ( (equal (car H)(car Ae)) (cons (car As) (encripta (cdr H)(rota Ae)(rota As))) )

    ; cuando no hay coincidencia del simbolo con la cabeza del alfabeto
    ( t (encripta H (rota Ae) (rota As)) )
  )
)

;; Decripta ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (decripta H Ae As Ef) -> el resultado de decodificar la hilera encriptada H
;;   usando los alfabetos Ae y As, iniciando en la posición del engranaje
;;   descrita por el estado final de la máquina (Ef) cuando se encriptó la
;;   hilera que produjo la hilera H
;;
;; Ejemplo:
;;  (decripta '(7 8 4 2 0) '(a b c d e f g h i j) '(0 1 2 3 4 5 6 7 8 9) '(a 0))
;;         -> (h i e c a)
(defun decripta (H Ae As Ef)
  ; el resultado viene invertido asi que lo reversa para mostrarlo
  (reversa
    ; invierte las hileras para decriptar de atras para adelante
    (decripta*
      (reversa H)
      (configura (reversa As) (reversa Ef)) ; rota los alfabetos hasta coincidir
      (configura (reversa Ae) Ef)           ; con estado final de encriptacion
    )
  )
)

;; (decripta* HR AeR AsR) -> el resultado de decofificar la hilera de entrada H
;;   previamente invertida, con un engranaje formado por los alfabetos de
;;   entrada (Ae) y salida (As), que tambien fueron invertidos.
(defun decripta* (HR AeR AsR)
  (cond
    ; cuando llega al fin de la busqueda
    ( (null HR) nil )

    ; cuando el simbolo coincide con la cabeza del alfabeto de entrada
    ( (equal (car HR)(car AeR)) (cons (car AsR) (decripta* (cdr HR)(rota AeR)(rota AsR))) )

    ; cuando no hay coincidencia del simbolo con la cabeza del alfabeto
    ( t (decripta* HR (rota AeR) (rota AsR)) )
  )
)

;; (rota lista) -> El resultado de rotar lista, simulando una lista circular
(defun rota (lista)
  (append (cdr lista) (cons (car lista) nil)))

;; (reversa lista) -> El resultado de invertir los valores de la hilera lista
(defun reversa (lista)
  (cond ((null lista) '())
        (t (append (reversa (cdr lista))(list (car lista)))) ) )

;; (configura Ae Ef) -> El resultado de rotar la hilera (Ae) hasta coincidir con
;;   estado final (Ef)
(defun configura (Ae Ef)
  (cond ((equal (car Ae)(car Ef)) Ae)
        (t (configura (rota Ae) Ef)) )
)
