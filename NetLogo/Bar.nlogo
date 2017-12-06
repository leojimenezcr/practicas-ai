;; "Buscando mesa" "En el baño" "Esperando baño" "Esperando ser atendido" ""

globals[
  caja             ;;Punto de cobro
  ubicacion-mesas  ;;lista de la ubicacion de las mesas
  ubicacion-bannos ;;lista de la ubicacion de los baños
  ubicacion-caja   ;;ubicacion de la caja
  cant-mesas       ;;cantidad de mesas
  insatisfechos    ;;cantidad de insatisfechos
]

breed[consumidores consumidor]
breed[empleados empleado]
breed[mesas mesa]
breed[bannos banno]


consumidores-own[
  estado                       ;;"Buscando mesa", "Socializando", "Llendo al baño", "Esperando ser atendido"
  satisfaccion
  tolerancia                   ;;Dependiendo de que tan tolerante es el consumidor, tiene mayor o menor impacto los eventos negativos en su atencion
  cuota-cervezas               ;;Indica cuando un consumidor debe ir al banno
  sed                          ;;Indica cuando debe pedir 0-10 0 es recien servido
  mi-mesa                      ;;Mesa en la que el consumidor esta ubicado
]

empleados-own[
  espera-limpiar-baño          ;;Indica cada cuantos ticks limpia el baño el empleado
  puesto                       ;;Si es 0 es salonero, si es 1 es cajero
  mesas-asignadas              ;;Las mesas asignadas para servir
  estado                       ;; Limpiar baño y servir
]

mesas-own[
  capacidad                    ;;La cantidad de consumidores que le caben
  limpieza                     ;;El grado de limpieza de la mesa
]

bannos-own[
  capacidad                    ;;La cantidad de consumidores que le caben
  limpieza                     ;;El grado de limpieza del baño
]

patches-own[
  libre                        ;; 1 si está vacio, 0 si no
]

to setup
  clear-all
  ask patches[
    set pcolor brown + 3
    set libre 1
  ]
  set-default-shape consumidores "person"
  set-default-shape empleados "person"
  set insatisfechos 0

  ;; crear las mesas
  ;; Creacion estatica de las mesas **SI HACEMOS VARIAS LISTAS DE UBICACION PODEMOS OFRECER VARIAS OPCIONES**
  crear_mesas

  ;; crear la caja
  set caja patches with [pxcor >= 11 and pxcor <= 14 and pycor >= -13 and pycor <= -5]
  ask caja [set pcolor gray]

  ;; crear el baño
  crear_bannos

  ;;  This will make the outermost patches blue.  This is to prevent the turtles
  ;;  from wrapping around the world.  Notice it uses the number of neighbor patches rather than
  ;;  a location. This is better because it will allow you to change the behavior of the turtles
  ;; by changing the shape of the world (and it is less mistake-prone)
  ask patches with [count neighbors != 8] [ set pcolor magenta ]

  ;; crear los empleados
  crear_empleados


  ;; crear los consumidores
  create-consumidores cantidad-de-consumidores
  [
    set color black
    ;; el mas exigente se acerca a 0 y el menos exigente a 1
    set tolerancia exigencia             ;;Los consumidores cuentan con una tolerancia medida en el rango de enteros [0,1] porcentual en la evalución de satisfaccion
    set satisfaccion 80            ;;Los consumidores cuentan con una satisfacción medida en el rango de enteros [0,100]
    set estado "Buscando mesa"     ;;Los consumidores comienzan buscando una mesa
    set cuota-cervezas one-of [4 5 6 7 8 9 10]   ;;Se les inicializa con un número aleatorio de cervezas, para efectos de ir al baño
    set label-color red
    set mi-mesa nobody       ;;Al consumidor se le asigna una mesa
    set sed one-of [4 5 6 7 8 9 10] ;; se les inicializa con numero aleatorio de sed
    mover-a-un-espacio-vacio-de patches with [ pcolor = brown + 3 ]
  ]

  reset-ticks
end

;; Crea las mesas, como tortugas y visualmente
to crear_mesas
  set ubicacion-mesas [-10 2 -10 11 -10 -7 -1 11 -1 2 -1 -7 9 2]
  set cant-mesas 7
  let cont 0
  repeat cant-mesas[
    create-mesas 1[
      setxy item cont ubicacion-mesas item (cont + 1) ubicacion-mesas
      set color blue set heading 0 set size 1
      set capacidad capacidad-mesas      ;;Cada mesa tiene capacidad para 6 consumidores
      set limpieza 10       ;;Cada mesa tiene un rango de limpieza medido entre 0 y 10
      ;set hidden? true     ;;Se esconden las tortugas "mesa" para evitar el solapamiento entre mesas y consumidores
    ;;Se crean las mesas como vecindarios de Moore con radio 3
      let cercanos [list pxcor pycor] of patches with [abs pxcor <= 3 and abs pycor <= 3]
      ask patches at-points cercanos [
        set pcolor blue
      ]
    ]
    set cont cont + 2
  ]

end

to crear_bannos
  set ubicacion-bannos [12 11]
  create-bannos 1[
    setxy item 0 ubicacion-bannos item 1 ubicacion-bannos
    set color green set heading 0 set size 2
    set capacidad capacidad-baño      ;;Cada baño tiene capacidad para 6 consumidores
    ;; el baño se encuenta limpio en 0 y sucio en 18
    set limpieza 0       ;;Cada baño tiene un rango de limpieza medido entre 0 y 18 **POR CADA 18 USOS BAÑO SUCIO**
    set hidden? true     ;;Se esconden las tortugas "banno" para evitar el solapamiento entre baños y consumidores
    ;;Se crean los baños como vecindarios de Moore con radio 3
    let cercanos [list pxcor pycor] of patches with [abs pxcor <= 3 and abs pycor <= 3]
    ask patches at-points cercanos [
        set pcolor green
      ]
  ]
end

to crear_empleados
  create-empleados cantidad-de-empleados[
    set color yellow
    set espera-limpiar-baño one-of [7 8 9]
    set puesto 0
    set estado "Limpiando baño"
    mover-a-un-espacio-vacio-de patches with [ pcolor = brown + 3 ]
  ]

  ask one-of empleados [
    set puesto 1
    setxy 13 -9
    set color magenta
  ]
end

to go
  if not any? consumidores [stop]
  ask consumidores [
    set sed sed + 1
    set label satisfaccion
  ]
  ask empleados [
    set espera-limpiar-baño espera-limpiar-baño - 1
  ]
  verificar-estados
  ;actualizar-satisfaccion
  ;eliminar-insatisfechos
  tick
end

to verificar-estados
  ask consumidores [
    if estado = "Buscando mesa"[
      buscar-mesa
    ]
    if estado = "En el baño"[
      ask bannos [set capacidad capacidad + 1]
      set estado "Volver a mesa"
      buscar-mesa
    ]
  ]

  ask empleados [
    if estado = "Limpiando baño"[
      set estado "Servir"
    ]
  ]
  limpiar-baño
  ir-al-baño
  pedir
  servir
  eliminar-insatisfechos

end

;; Dirige al agente hacia el baño de manera natural, un paso a la vez
;; En implementación
;; Basado en el ejemplo de codigo de la Biblioteca de Modelos llamado "Move Towards Target"
to mover-al-baño [banno-seleccionado]
  ;;Se encamina al baño escogido
  ;;Si esta cerca del baño
    ;;Se posiciona en el baño
  let espacio-mi-banno nobody
  ask banno-seleccionado [ set espacio-mi-banno neighbors ]
  move-to one-of espacio-mi-banno
  while [any? other turtles-here] [
     fd 1
  ]
  set cuota-cervezas one-of [4 5 6 7 8 9 10]     ;;Se reanuda la cuenta de las cervezas para volver a ir al baño
end

to hablar
  let pareja 0
  set pareja one-of other consumidores-here    ;;Busca otro consumidor que este en su misma posición
  set satisfaccion satisfaccion + 4            ;;Aumenta la satisfacción como resultado de la socialización
  ask pareja [ set satisfaccion satisfaccion + 4 ]  ;;Igualmente mejora la satisfacción para el otro consumidor
end

to actualizar-parametros-banno [banno-escogido]
  ask banno-escogido [ (set capacidad capacidad - 1) (set limpieza limpieza + 1)]
end

to ir-al-baño
  ask consumidores[
    show cuota-cervezas
    ;;tengo que ir al baño?
    if cuota-cervezas <= 0[
      let bannos-con-campo bannos with [capacidad > 0]   ;;Determina cuales baños tienen campo
      ifelse any? bannos-con-campo[
        let banno-escogido one-of bannos-con-campo
        set estado "En el baño"
        ;;Se mantiene en el baño hasta que termina de posicionarse
        mover-al-baño banno-escogido  ;;Se posiciona en el baño
        ;;Registra la actual capacidad del baño
        actualizar-parametros-banno banno-escogido
        ifelse [limpieza] of banno-escogido <= floor (18 * tolerancia)[
          set satisfaccion satisfaccion - floor (5 * abs (tolerancia - 1))
        ][
          set satisfaccion satisfaccion + floor (15 * tolerancia)
        ]
      ][
        ifelse estado != "Esperando baño"[
          setxy (item 0 ubicacion-bannos - 4) item 1 ubicacion-bannos
          while [any? other turtles-here] [
            fd 1
          ]
          set satisfaccion satisfaccion - floor (5 * abs (tolerancia - 1))
          set estado "Esperando baño"
        ][
          set satisfaccion satisfaccion - 1
        ]
      ]
    ]
  ]
end

to actualizar-satisfaccion
  let consumidores-buscando-mesa consumidores with [estado = "Buscando mesa"]  ;;Determina cuales consumidores se encuentran buscando mesa
  if any? consumidores-buscando-mesa[
    if ticks mod 10 = 0    ;;Por cada 10 ticks que el usuario pase buscando mesa se decrementa la satisfacción en 4 unidades
    [ask consumidores-buscando-mesa [set satisfaccion satisfaccion - 4]]
  ]
end

to eliminar-insatisfechos
  let consumidores-insatisfechos consumidores with [satisfaccion <= 0]   ;;Determina cuales consumidores estan muy insatisfechos

  if any? consumidores-insatisfechos [
    set insatisfechos insatisfechos + count consumidores-insatisfechos
    ask consumidores-insatisfechos [die]
  ]
  show "eliminar"
  ;;elimina los consumidores insatisfechos para simular el abandono del bar por parte de los consumidores

end

;; In this model it doesn't really matter exactly which patch
;; a turtle is on, only whether the turtle is in the home area
;; or the bar area.  Nonetheless, to make a nice visualization
;; this procedure is used to ensure that we only have one
;; turtle per patch.
to mover-a-un-espacio-vacio-de [espacios]  ;; turtle procedure
  if any? espacios[
    ;move-to one-of espacios
    while [any? other turtles-here] [
      let espacio-escogido one-of espacios with [libre = 1]
      ask espacio-escogido [set libre 0]
      move-to espacio-escogido
    ]
  ]
end

to caminar
  ;; Basado del ejemplo de codigo "Look Ahead Example" de la Boblioteca de Modelos de NetLogo
  ask consumidores
  [
    ;; Buscar mesa
    ;;Si el consumidor esta buscando una mesa
    if estado = "Buscando mesa"
    [
      ;;  This important conditional determines if they are about to walk into a blue
      ;;  patch.  It lets us make a decision about what to do BEFORE the turtle walks
      ;;  into a blue patch.  This is a good way to simulate a wall or barrier that turtles
      ;;  cannot move onto.  Notice that we don't use any information on the turtle's
      ;;  heading or position.  Remember, patch-ahead 1 is the patch the turtle would be on
      ;;  if it moved forward 1 in its current heading.
      ifelse patch-ahead 1 != nobody and [pcolor] of patch-ahead 1 = blue
      [ lt random-float 360 ]   ;; We see a blue patch in front of us. Turn a random amount.
      [ fd 1 ]                  ;; Otherwise, it is safe to move forward.

      ;;Cada vez que se desplaza el consumidor revisa su alrededor en busca de una mesa
      buscar-mesa
    ]
  ]
  ;if ticks mod 10 = 0 and ticks > 0
  ;[set satisfaccion satisfaccion - 1]
end

to buscar-mesa ;[espacio]

  ask consumidores [
    if estado = "Buscando mesa"[
        let mesas-vacias nobody
        ask mesas [set mesas-vacias mesas with [capacidad > 0]]
      ifelse any? mesas-vacias[
        set mi-mesa min-one-of mesas-vacias [distance self]
        let espacios-mesa nobody
        ask mi-mesa [
          set espacios-mesa neighbors
          set capacidad capacidad - 1
        ]
        move-to one-of espacios-mesa
        while [any? other turtles-here] [
            fd 1
        ]
        set estado "Pedir"
        set satisfaccion satisfaccion + floor (5 * tolerancia)
      ][
        set estado "Sin mesa"
        set satisfaccion satisfaccion - floor (5 * abs (tolerancia - 1))
        mover-a-un-espacio-vacio-de patches with [ pcolor = brown + 3 ]
      ]
    ]

    if estado = "Volver a mesa"[
      ifelse mi-mesa != nobody [
        let espacios-mesa nobody
        ask mi-mesa [
          set espacios-mesa neighbors
        ]
        move-to one-of espacios-mesa
        while [any? other turtles-here] [
          fd 1
        ]
        set estado "Pedir"
      ][
        mover-a-un-espacio-vacio-de patches with [ pcolor = brown + 3 ]
        set estado "Pedir"
      ]
    ]
  ]
end

to pedir
  ask consumidores [
    if estado = "Pedir"[
      set satisfaccion satisfaccion - 1
    ]
    if sed >= 10[;; tiene sed?
      set estado "Pedir"
      set color orange
    ]
  ]

end

to servir
  ask empleados [
    if puesto = 0 and estado = "Servir"[
      let ordenes nobody
      ask consumidores [set ordenes consumidores with [color = orange]]

      if any? ordenes [
        let cliente-escogido one-of ordenes
        let mesa-cliente nobody
        ask cliente-escogido [
          set sed 0
          set color black
          set satisfaccion satisfaccion + floor (15 * tolerancia)
          set mesa-cliente mi-mesa
          set cuota-cervezas cuota-cervezas - 1
        ]

        if mesa-cliente != nobody[
          let espacios-mesa nobody
          ask mesa-cliente [set espacios-mesa neighbors]
          move-to one-of espacios-mesa
          while [any? other turtles-here] [
            fd 1
          ]
        ]
      ]
    ]
  ]

end

to limpiar-baño
  ask empleados [
    if puesto = 0 and espera-limpiar-baño <= 0 [
      let bannos-sucios bannos with [limpieza >= 18]
      if any? bannos-sucios [
        let espacio-mi-banno nobody
        ask bannos-sucios [ set espacio-mi-banno neighbors set limpieza 0 ]
        move-to one-of espacio-mi-banno
        while [any? other turtles-here] [
          fd 1
        ]
        set espera-limpiar-baño one-of [5 6 7 8]
        set estado "Limpiando baño"
      ]
    ]
  ]
end

to-report plot-satisfaccion
  let cont_satis sum [satisfaccion] of consumidores
    report cont_satis / cantidad-de-consumidores
end





@#$#@#$#@
GRAPHICS-WINDOW
298
10
806
519
-1
-1
13.52
1
10
1
1
1
0
0
0
1
-18
18
-18
18
1
1
1
ticks
30.0

BUTTON
9
29
82
62
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
179
30
242
63
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
9
81
258
114
cantidad-de-empleados
cantidad-de-empleados
1
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
9
119
258
152
cantidad-de-consumidores
cantidad-de-consumidores
1
100
46.0
1
1
NIL
HORIZONTAL

TEXTBOX
842
29
992
119
Consumidor: negro\nEmpleado: amarillo\n\nMesas: azul\nCaja: rojo\nBaño: verde
12
0.0
1

BUTTON
98
30
162
63
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
9
160
260
193
exigencia
exigencia
0.1
1
0.5
0.1
1
NIL
HORIZONTAL

PLOT
816
142
1271
494
Satisfaccion
Tiempo
Satisfaccion
0.0
1.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -13791810 true "" "plot plot-satisfaccion"

SLIDER
8
200
259
233
capacidad-baño
capacidad-baño
0
20
17.0
1
1
NIL
HORIZONTAL

SLIDER
7
240
259
273
capacidad-mesas
capacidad-mesas
1
10
6.0
2
1
NIL
HORIZONTAL

MONITOR
13
286
114
331
insatisfechos
insatisfechos
17
1
11

@#$#@#$#@
## ¿Que es el modelo?

El modelo "Bar" busca mostrar las implicaciones de la cantidad de mesas dentro de un bar, así como la cantidad de baños y empleados, en la satisfacción de sus clientes, considerando la limpieza de las mesas y los baños como factor importante para influenciar la satisfacción de los clientes del bar, además se consideran los tiempos de atención, el tiempo de espera de los consumidores del bar para recibir su pedido; por otro lado, también considera el impacto de la socialización en la satisfacción de los clientes.

## Como funciona

Los consumidores comienzan buscando una mesa, para lo cual se desplazan por el entorno respetando las "paredes" del bar y las mesas, cada consumidor debe ir al baño cada vez que ha tomado 4 o más cervezas, y cada vez que va al baño esa cuenta se reinicia, luego de ir al baño los consumidores vuelven a buscar su mesa, cada vez que los consumidores se desplazan por el entorno tienen la oportunidad de socializar con los otros consumidores cerca suyo, aumentando su satisfacción. En cuanto al tiempo que le toma a un consumidor encontrar una mesa, esto disminuye su satisfacción, así como la limpieza de la misma y de los baños, como también la espera para ser atendido por un empleado.
Los empleados atienden los pedidos de los consumidores, y cuando no tienen pedidos pendientes limpian los baños y las mesas, periodicamente, 

## Como se usa

En la interfaz gráfica se puede determinar la cantidad de empleados y consumidores deseados en la simulación, lo que permite ver que impacto tiene el incrementar los empleados.

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
