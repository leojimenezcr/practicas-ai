% TAREA PROGRAMADA I
%
% Escuela​ ​ de​ ​ Ciencias​ ​ de​ ​ la​ ​ Computación​ ​ e Informática
% CI-1441​ ​ - ​ ​ Paradigmas​ ​ Computacionales
% Prof.​ ​ Alvaro​ ​ de​ ​ la​ ​ Ossa​ ​ O.
%
% Estudiantes:
% Leonardo​ ​ Jiménez​ ​ Quijano,​ ​ 961611
% Daniel​ ​ Orozco​ ​ Venegas,​ ​ B24882
% Fanny​ ​ Porras​ ​ Zúñiga,​ ​ A34045



% Predicados para el procesamiento de arboles y conjuntos %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% listap(+Objeto): verdadero si Objeto es una lista, falso si no
%   Objeto: cualquier objeto Prolog
%   ?- listap(a). -> false
%   ?- listap([]). -> true
%   ?- listap([a,b,c]). -> true
listap([]) :- !.
listap([_|Y]) :- listap(Y).

% primero(+L,-E): E es el primer elemento de la lista L
%   L: lista; E: cualquier objeto Prolog
%   ?- primero([a,b,c],a). -> true
%   ?- primero([a,b,c],X). -> X = a
%   ?- primero([],X). -> false
primero(X,X) :- atom(X).
primero([X|_],X) :- !.

primeros([],[]).
primeros([X|Xr],[Y|Yr]) :- primero(X,Y), primeros(Xr,Yr).

% ultimo(+L,-E): E es el último elemento de la lista L
%   L: lista; E: cualquier objeto Prolog
%   ?- ultimo([a,b,c],X). -> X = c
ultimo([X],X):-!.
ultimo([_|T],X) :- ultimo(T,X).

% primerindice(+E,+L,-I): I es la posición de la primera ocurrencia de E en L
%   E: cualquier objeto Prolog; L: Lista; I: entero
%   En caso de que E no este en la lista se retorna "falso"
%   ?- primerindice(d,[a,b,c,d,e],I). -> I = 3
primerindice(E,[E|_],0) :- !.
primerindice(E,[_|T],I) :-
  primerindice(E,T,Y),
  !,
  I is Y + 1.

% concatena(+L1,+L2,-L3): L3 es la lista que resulta de concatenar L1 y L2
%   L1, L2, L3: listas
%   ?- concatena(X,Y,[a,b,c,d,e]). -> X = [], Y = [a, b] ;
%                                     X = [a], Y = [b] ;
%                                     X = [a, b], Y = [] ;
%   ?- concatena([w,e],[x,c,v,b,n],L). -> L = [w, e, x, c, v, b, n].
concatena([],Y,Y).
concatena([X|Xr],Y,[X|Zr]) :- concatena(Xr,Y,Zr).


% Busqueda por profundidad primero %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bpp/3(+N,+A,-S) S es el subarbol de A cuya raız es N, nil si el subarbol no existe
% El predicado implementa el metodo de busqueda en profundidad primero, y muestra la
% secuencia de nodos visitados.
%   Validacion: N debe ser un atomo y A un arbol.
%   ?- bpp(d,[a,b,[c,d,e],[f,[g,h],i]],X). → X = d; Nodos visitados en el orden correspondiente: a b c d
%   ?- bpp(f,[a,b,[c,d,e],[f,[g,h],i]],X). → X =[f,[g,h],i]; Nodos visitados en el orden correspondiente: a b c d e f
%   ?- bpp(x,[a,b,[c,d,e],[f,[g,h],i]],X). → X = nil; Nodos visitados en el orden correspondiente: a b c d e f g h i

% si es la raíz
bpp(N,[N|R],[N|R]) :-
  write("Nodos visitados en el orden correspondiente: "),
  write(N),!,write("\s").

% si no es la raíz
bpp(N,[X|R],S):-
  write("Nodos visitados en el orden correspondiente: "),write(X),write("\s"),
  rama(N,R,S),!.

% rama/3(+N,+A,-S)
% Recorre las ramas de los arboles en busca de una coincidencia, regresa en S un
% subarbol del cual N es padre.
%   Validacion: N debe ser un atomo y A un arbol.

% si es lo que busco
rama(N,[N|_],N) :-
  write(N),!,write("\s").

% sin respuesta
rama(_,[],nil) :- !.

% si es un padre
rama(N,[X|_],X) :-
  listap(X),
  primero(X,F),
  F==N,
  write(F),!,write("\s").

% si no es el padre, revisa la rama y deja el camino para el hermano
rama(N,[X|R],S) :-
  listap(X),
  concatena(X,R,F),
  rama(N,F,S).

%si no es el buscado
rama(N,[X|R],S) :-
  write(X),write("\s"),
  rama(N,R,S).


% Busqueda anchura primero %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% eliminacabeza/2(+X,-Y) Elimina la cabeza de la lista X y la devuelve en Y
%   Validacion: X y Y son una listas
%   ?- eliminacabeza([a,b,c],Y). -> Y = [b, c].
eliminacabeza([_|Y],Y):-!.

% bap/3(+N,+X,-S) busca el elemento N en el arbol X y devuelve el subarbol S
% del cual es padre N, utilizando la busqueda por anchura primero
%   Validacion: N es un atomo y X y S son arboles
%   bap(c,[a,b,[c,d,e],[f,[g,h],i]],F). -> F=[c,d,e], recorrido abc

% si es la raiz no busque mas
bap(N,[N|R],[N|R]):-
write(N),!.

% no es la raíz
bap(N,[X|R],S):-
  write(X),
  busqueda(N,R,S),!.

% busqueda/3 (+N,+X,-S) busca internamente por el arbol en anchura primero
%   Validacion: N es un atomo y X y S son arboles

% es primer elemento es un padre
busqueda(N,[X|_],X):-
  listap(X),
  primero(X,Y),
  Y==N,
  write(N),!.

% el primer elemento es un padre pero no es el buscado
busqueda(N,[X|R],S):-
  listap(X),
  primero(X,T),
  eliminacabeza(X,Y),
  concatena(R,Y,F),
  write(T),
  busqueda(N,F,S).

% el primer elemento es un hijo y es el buscado
busqueda(N,[N|_],N):-
  write(N),!.

% el primer elemento es un hijo y no es el buscado
busqueda(N,[X|R],S):-
  write(X),
  busqueda(N,R,S).

% no esta en la lista
busqueda(_,[],nil):-!.


% Potencia %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% elimina/2(+X,-S) elimina el ultimo elemento de la lista que recibe
%   Validacion: X y S son Listas
%   ?- elimina([a,b,c],S). -> S = [a, b].
elimina([_],[]):-!.

elimina([X|Y],[X|Z]):-
  elimina(Y,Z).

% potencia/2(+C,-P) implementa el cálculo del conjunto potencia de un conjunto
%   Validacion: C y P son Listas
%   ?- potencia([a,b,c],X). -> X = [[a, b, c], [a, b], [a], [b, c], [b], [c], nil].
%   ?- potencia(x,X). -> El argumento no es un conjunto; X = nil.
potencia(C,nil):-
  not(listap(C)),
  write("El argumento no es un conjunto"),!.

potencia([X],[[X],nil]):-!.

potencia([H|R],Z):-
  sub([H|R],P),
  potencia(R,L),
  concatena(P,L,Z).

% sub/2(+X,-Z): Z devuelve los subconjuntos de X
%   Vallidacion: X y Z son listas
%   ?- sub([a,b,c],Z). -> Z = [[a, b, c], [a, b], [a]].
sub([X],[[X]]):-!.

sub(X,Z):-
  elimina(X,Y),
  sub(Y,L),
  concatena([X],L,Z).


% Producto cartesiano %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cartesiano(+X,+Y,-C) C es el conjunto de pares ordenados que se obtiene de la
% combinacion de X y Y
%   Validacion:X,Y y C son listas
%   ?- cartesiano([a,b,c],[d,e],X). -> X = [[a, d], [a, e], [b, d], [b, e], [c, d], [c, e]].
%   ?- cartesiano(x,y,X). -> X = [].; Uno de los argumentos no es un conjunto
cartesiano(X,_,[]):-
  not(listap(X)),
  write("Uno de los argumentos no es un conjunto"),!.

cartesiano(_,Y,_):-
  not(listap(Y)),
  write("Uno de los argumentos no es un conjunto"),!.

cartesiano([X],Y,C):-
  subcart(X,Y,C).

cartesiano([X|XR],Y,C):-
  subcart(X,Y,Z),
  cartesiano(XR,Y,L),
  concatena(Z,L,C),!.

% sub/2(+X,Y,-Z) Z devuelve los subconjuntos de X
%   Vallidacion: X y Z son listas
%   ?- subcart([a,b,c],[d,e],X). -> X = [[[a, b, c], d], [[a, b, c], e]].
subcart(X,[Y],[[X|[Y]]]):-!.

subcart(X,[Y|YR],Z):-
  subcart(X,YR,V),
  concatena([[X|[Y]]],V,Z),!.


% La maquina encriptadora %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rota/2(+L1,-L2): Toma la lista L1 y la rota, moviendo la cabeza
%   al final de la misma.
%
%   L1, L2: Listas
%   ?- rota([a,b,c,d],N). -> N = [b, c, d, a].
rota([C|R],N):- append(R,[C],N).

% reversa/2(+Lista,-Reversa): Reversa es la lista Lista invertida
%
%   Lista, Reversa: listas
%   ?- reversa([a,b,c,d],N). -> N = [d, c, b, a].
reversa([X],[X]):-!.
reversa([X|M],Z) :- reversa(M,S), append(S,[X],Z),!.

% configura/5(+Ae,+As,+Ef,-AeC,-AsC): rota los alfabetos hasta coincidir con el
%   estado final de encripta.
%
%   Ae,As,Ef,AeC,AsC: Listas
%   ?- configura([b,c,a],[c,2],A). -> A = [c, a, b].

% cuando el alfabeto coincide con el estado
configura([C|A],[C|_],[C|A]):-!.

% si no hay coincidencia rota los alfabetos y busca de nuevo
configura(A,E,AC):-
  rota(A,AR),
  configura(AR,E,AC).

% Encripta %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% encripta/5(+He,+Ae,+As,-Hs,-Ef):
%   Hs es la hilera que resulta al encriptar la hilera He. Ae es el alfabeto de
%   entrada y As el alfabeto de salida. Ef es el estado en que queda la maquina.
%
%   He, Ae, As, Hs, Ef: Listas
%   -? encripta([h,i,e,c,a],[a,b,c,d,e,f,g,h,i,j],[0,1,2,3,4,5,6,7,8,9],Hs,Ef).
%         -> Hs = [7, 8, 4, 2, 0], Ef = [a, 0].

% cuando llega al fin de la busqueda
encripta([],Ae,As,[],[EfAe,EfAs]):-
  ultimo(Ae,EfAe), ultimo(As,EfAs),
  write([]),write(Ae), write(As), write("\n"),
  write("Nothing To Do Here  »»» >-[o\n\n"), sleep(0.1), !.

% cuando el simbolo coincide con la cabeza del alfabeto de entrada
encripta([C|RHe],[C|RAe],[CAs|RAs],Hs,Ef):-
  write([C|RHe]),write([C|RAe]), write([CAs|RAs]), write("\n"),
  write("Hay coincidencia\n\n"), sleep(0.5),
  rota([C|RAe],AeR), rota([CAs|RAs],AsR), % rota los engranajes
  encripta(RHe,AeR,AsR,Hsd,Ef),           % y sigue buscando
  append([CAs],Hsd,Hs), % como hubo coincidencia, lo guarda en la Hilera de salida
  !.

% cuando no hay coincidencia del simbolo con la cabeza del alfabeto
encripta(He,Ae,As,Hs,Ef):-
  write(He),write(Ae), write(As), write("\n"),
  write("No hay coincidencia\n\n"), sleep(0.1),
  rota(Ae,AeR), rota(As,AsR), % rota los engranajes
  encripta(He,AeR,AsR,Hs,Ef), % y sigue buscando
  !.


% Decripta %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% decripta/5(+Hs,+Ae,+As,+Ef,-He):
%   Toma la hilera de salida del predicado encripta y devuelve la hilera de
%   entrada original. Ae y As son los alfabetos de entrada y salida utilizados
%   para encriptar. Ef es el estado final de encripta.
%
%   He, Ae, As, Hs, Ef: Listas
%   -? decripta([7,8,4,2,0],[a,b,c,d,e,f,g,h,i,j],[0,1,2,3,4,5,6,7,8,9],[a,0],He).
%         -> He = [h, i, e, c, a].

% El proceso es el mismo que encripta pero en orden inverso, asi
% que llama con hileras invertidas y alfabetos intercambiados
decripta(Hs,Ae,As,Ef,He):-
  reversa(Hs,HsR), reversa(Ae,AeR), reversa(As,AsR),
  configura(AeR,Ef,AeC),                    % rota los alfabetos hasta coincidir
  reversa(Ef,EfR), configura(AsR,EfR,AsC),  % con el estado final de encripta.
  encripta(HsR,AsC,AeC,HeR,_),
  reversa(HeR,He). % pone al derecho la hilera
