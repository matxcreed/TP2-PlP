

% Ejercicio 1
matriz(F, C, M) :-length(M,F),maplist([Fila]>>length(Fila, C), M).

% Ejercicio 2

replicar(X, N, XS):-length(XS,N),maplist(=(X),XS).


% Ejercicio 3
transponer([[]|_], []).
transponer(M, T) :-
	M = [PrimeraFila|_],
	length(PrimeraFila, N).
	numlist(1, N, Indices),
	maplist(columna(M), Indices, T).

columna(M, I, Columna) :-
	J is I - 1,
	maplist(nth0(J), M, Columna).

% Predicado dado armarNono/3
armarNono(RF, RC, nono(M, RS)) :-
	length(RF, F),
	length(RC, C),
	matriz(F, C, M),
	transponer(M, Mt),
	zipR(RF, M, RSFilas),
	zipR(RC, Mt, RSColumnas),
	append(RSFilas, RSColumnas, RS).

zipR([], [], []).
zipR([R|RT], [L|LT], [r(R,L)|T]) :- zipR(RT, LT, T).

% Ejercicio 4
% version 1
%pintadasValidas([R|RS],L) :- sumlist([R|RS], SumaRestricciones),length(L,N),
			%				CantCeldasSinPintar is N-SumaRestricciones

% version 2


% look first restriction: grab between (0 and length(L)) so that it's white, the remainder is
% the amount of black that I need. then recursion for the second restriction.
pintadasValidas(r([X|T], L)):-
	% Defino primero las tres cantidades importantes
	length(L, CeldasTotalesC),
	sum_list([X|T], CeldasPintadasC),
	CeldasSinPintarC is CeldasTotalesC-CeldasPintadasC,

	% Algunas condiciones iniciales para poda (tal vez sean redudantes después)
	%CeldasPintadasC =< CeldasTotalesC,

	% Estas dos tal vez me sean útiles
	length(ParteSinPintar, CeldasSinPintarC),
	length(PartePintada, CeldasPintadasC),

	% Proceso
	member(TrozoPintadoC, [X|T]), % Tomo una restricción (que interpreto como cantidad)
	% TrozoPintadoC =/= CeldasSinPintarC, ya que el primero
	% varía y depende de qué trozo estamos hablando, mientras que el segundo es un total siempre igual.
	replicar('x', TrozoPintadoC, TrozoPintado), % Armo ese trozo de celdas pintadas

	% Idea 1:
	% LLeno a L con los trozos pintados
	%member(TrozoPintado, L), % Esto está mal, porque jode con la longitud: tendría que ser un append

	% Ahora el mismo proceso, pero sin pintar. Tengo que determinar cuántos trozos hay y su length
	% y la última condición es lo de >=0 para bordes, y >=1 para los demás.

	%length(TrozoSinPintar, TrozoSinPintarC),
	%TrozoSinPintarC => 0,
	%TrozoSinPintarC =< CeldasSinPintarC,
	%replicar('o', TrozoSinPintarC, TrozoSinPintar),
	%member(TrozoSinPintar, L).
	% Completar, faltan los bordes.

	% Idea 2, append(TrozoPintado, TrozoSinPintar, Trozo); member(Trozo, L).
	% Idea 3: dar más información de los tres totales, y saber que los
	% trozos impares son sin pintar, mientras que los pares son pintados. por último, los bordes pueden ser 0
	% e.g. es head/last, entonces length >=0.
	sum_list([H|T], TrozosPintadosTotal), % Esta nueva cantidad es el total de trozos individuales pintados
	TrozosSinPintarTotal =< TrozosPintadosTotal+1, % Definiendo el posible rango
	TrozosSinPintarTotal => TrozosPintadosTotal,

%	o, ignorar lo de arriba, definir dos listas posibles para sinpintar, luego crear una lista
%	temporaria, hacer elementos en posición par e impar, y luego flatten.

	%TrozoSinPintarC => 1,
	%TrozoSinPintarC =< CeldasSinPintarC,	
	%length(TrozoSinPintar, TrozoSinPintarC),
	%replicar('o', TrozoSinPintarC, )

%	sublista(TrozoPintado, L),

	TrozosTotales is TrozosPintadosTotal+TrozosSinPintarTotal,
	length(L1, TrozosPintadosTotal), % Creo L1 temporario, lista de trozos, para después aplanarlo
	member(TrozoPintado, L1),

	length(L2, TrozosSinPintarTotal).


	% Idea 4: crear lista de trozos pintados, lista de trozos sin pintar, zipwith, aplanar.


elemPosPar([H|T], X) :- nth1(N,[H|T,X), N mod 2 =:= 0.
elemPosImpar([H|T], X) :- nth1(N,[H|T,X), N mod 2 \= 0.

sublista(X,[H|T]) :- append(_,B,[H|T]),append(X,_,B) , X \= [].

	


% Ejercicio 5
resolverNaive(nono(_Filas, Restricciones)) :- maplist(pintadasValidas, Restricciones).


	% Razonamiento 2: usando 'pintadasObligatorias'
	% es hacer pintadasValidas para todas las filas y quedarse con 'una' solución
	% en donde puede ser que una de las celdas ya sepamos que es definitivamente un X o O.
	% (algunas celdas van a seguir quedando como 'cualquier cosa', ver dibujo 1.3)
	% ahora, al hacer pintadasValidas para columnas, es tener en cuenta si hay una restricción
	% (i.e. que una celda tenga que ser X o O) existente.
	% alternativo: ir resolviendo row1 col1, then row2 col2, etc.
	% Esta forma puede no ser 'naive' en sí.



% Ejercicio 6
pintarObligatorias(r([X|T], L)) :-
	pintadaValida(r([X|T], L)),
	member(C, L),
	% declarar que es C es no iniciada
	combinarCelda(A, B,  C), % completar
	pintarObligatorias(r(T, L)).
	% idea?: combinar cada par de restricciones



% Predicado dado combinarCelda/3
combinarCelda(A, B, _) :- var(A), var(B).
combinarCelda(A, B, _) :- nonvar(A), var(B).
combinarCelda(A, B, _) :- var(A), nonvar(B).
combinarCelda(A, B, A) :- nonvar(A), nonvar(B), A = B.
combinarCelda(A, B, _) :- nonvar(A), nonvar(B), A \== B.

% Ejercicio 7
deducir1Pasada(NN) :-
	NN = nono(M, [R|Rs]),
	pintarObligatorias(R),
	deducir1Pasada(nono(M, Rs)).

% Predicado dado
cantidadVariablesLibres(T, N) :- term_variables(T, LV), length(LV, N).

% Predicado dado
deducirVariasPasadas(NN) :-
	NN = nono(M,_),
	cantidadVariablesLibres(M, VI), % VI = cantidad de celdas sin instanciar en M en este punto
	deducir1Pasada(NN),
	cantidadVariablesLibres(M, VF), % VF = cantidad de celdas sin instanciar en M en este punto
	deducirVariasPasadasCont(NN, VI, VF).

% Predicado dado
deducirVariasPasadasCont(_, A, A). % Si VI = VF entonces no hubo más cambios y frenamos.
deducirVariasPasadasCont(NN, A, B) :- A =\= B, deducirVariasPasadas(NN).

% Ejercicio 8
restriccionConMenosLibres(NN, R) :-
	NN = nono(M, [r([X|Xs], L)|T]),
	% R tiene que ser una de las restricciones.
	member(R, [r([X|Xs], L)|T]),
	cantidadVariablesLibres(L, N),
	% Tiene que tener al menos una variable no instanciada.
	N>=1,
	% Y tiene que ser la mínima.
	member(R2, [r([X|Xs], L)|T]),
	cantidadVariablesLibres(L, N1),
	R2 \= R,
	N<=N1.



% Ejercicio 9
resolverDeduciendo(NN) :-
	NN = nono(M, [r([X|Xs], L)|T]),
	deducirVariasPasadas(NN),
	% chequear si no está resuelto acá? con !/1
	restriccionConMenosLibres(NN, R),
	pintadasValidas(R),
	% chequear si está resuelto acá? con !/1
	resolverDeduciendo(NN).

% Ejercicio 10
solucionUnica(NN) :- completar("Ejercicio 10").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              %
%    Ejemplos de nonogramas    %
%        NO MODIFICAR          %
%    pero se pueden agregar    %
%                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fáciles
nn(0, NN) :- armarNono([[1],[2]],[[],[2],[1]], NN).
nn(1, NN) :- armarNono([[4],[2,1],[2,1],[1,1],[1]],[[4],[3],[1],[2],[3]], NN).
nn(2, NN) :- armarNono([[4],[3,1],[1,1],[1],[1,1]],[[4],[2],[2],[1],[3,1]], NN).
nn(3, NN) :- armarNono([[2,1],[4],[3,1],[3],[3,3],[2,1],[2,1],[4],[4,4],[4,2]], [[1,2,1],[1,1,2,2],[2,3],[1,3,3],[1,1,1,1],[2,1,1],[1,1,2],[2,1,1,2],[1,1,1],[1]], NN).
nn(4, NN) :- armarNono([[1, 1], [5], [5], [3], [1]], [[2], [4], [4], [4], [2]], NN).
nn(5, NN) :- armarNono([[], [1, 1], [], [1, 1], [3]], [[1], [1, 1], [1], [1, 1], [1]], NN).
nn(6, NN) :- armarNono([[5], [1], [1], [1], [5]], [[1, 1], [2, 2], [1, 1, 1], [1, 1], [1, 1]], NN).
nn(7, NN) :- armarNono([[1, 1], [4], [1, 3, 1], [5, 1], [3, 2], [4, 2], [5, 1], [6, 1], [2, 3, 2], [2, 6]], [[2, 1], [1, 2, 3], [9], [7, 1], [4, 5], [5], [4], [2, 1], [1, 2, 2], [4]], NN).
nn(8, NN) :- armarNono([[5], [1, 1], [1, 1, 1], [5], [7], [8, 1], [1, 8], [1, 7], [2, 5], [7]], [[4], [2, 2, 2], [1, 4, 1], [1, 5, 1], [1, 8], [1, 7], [1, 7], [2, 6], [3], [3]], NN).
nn(9, NN) :- armarNono([[4], [1, 3], [2, 2], [1, 1, 1], [3]], [[3], [1, 1, 1], [2, 2], [3, 1], [4]], NN).
nn(10, NN) :- armarNono([[1], [1], [1], [1, 1], [1, 1]], [[1, 1], [1, 1], [1], [1], [ 1]], NN).
nn(11, NN) :- armarNono([[1, 1, 1, 1], [3, 3], [1, 1], [1, 1, 1, 1], [8], [6], [10], [6], [2, 4, 2], [1, 1]], [[2, 1, 2], [4, 1, 1], [2, 4], [6], [5], [5], [6], [2, 4], [4, 1, 1], [2, 1, 2]], NN).
nn(12, NN) :- armarNono([[9], [1, 1, 1, 1], [10], [2, 1, 1], [1, 1, 1, 1], [1, 10], [1, 1, 1], [1, 1, 1], [1, 1, 1, 1, 1], [1, 9], [1, 2, 1, 1, 2], [2, 1, 1, 1, 1], [2, 1, 3, 1], [3, 1], [10]], [[], [9], [2, 2], [3, 1, 2], [1, 2, 1, 2], [3, 11], [1, 1, 1, 2, 1], [1, 1, 1, 1, 1, 1], [3, 1, 3, 1, 1], [1, 1, 1, 1, 1, 1], [1, 1, 1, 3, 1, 1], [3, 1, 1, 1, 1], [1, 1, 2, 1], [11], []], NN).
nn(13, NN) :- armarNono([[2], [1,1], [1,1], [1,1], [1], [], [2], [1,1], [1,1], [1,1], [1]], [[1], [1,3], [3,1,1], [1,1,3], [3]], NN).
nn(14, NN) :- armarNono([[1,1], [1,1], [1,1], [2]], [[2], [1,1], [1,1], [1,1]], NN).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              %
%    Predicados auxiliares     %
%        NO MODIFICAR          %
%                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%! completar(+S)
%
% Indica que se debe completar el predicado. Siempre falla.
completar(S) :- write("COMPLETAR: "), write(S), nl, fail.

%! mostrarNono(+NN)
%
% Muestra una estructura nono(...) en pantalla
% Las celdas x (pintadas) se muestran como ██.
% Las o (no pintasdas) se muestran como ░░.
% Las no instanciadas se muestran como ¿?.
mostrarNono(nono(M,_)) :- mostrarMatriz(M).

%! mostrarMatriz(+M)
%
% Muestra una matriz. Solo funciona si las celdas
% son valores x, o, o no instanciados.
mostrarMatriz(M) :-
	M = [F|_], length(F, Cols),
	mostrarBorde('╔',Cols,'╗'),
	maplist(mostrarFila, M),
	mostrarBorde('╚',Cols,'╝').

mostrarBorde(I,N,F) :-
	write(I),
	stringRepeat('══', N, S),
	write(S),
	write(F),
	nl.

stringRepeat(_, 0, '').
stringRepeat(Str, N, R) :- N > 0, Nm1 is N - 1, stringRepeat(Str, Nm1, Rm1), string_concat(Str, Rm1, R).

%! mostrarFila(+M)
%
% Muestra una lista (fila o columna). Solo funciona si las celdas
% son valores x, o, o no instanciados.
mostrarFila(Fila) :-
	write('║'),
	maplist(mostrarCelda, Fila),
	write('║'),
	nl.

mostrarCelda(C) :- nonvar(C), C = x, write('██').
mostrarCelda(C) :- nonvar(C), C = o, write('░░').
mostrarCelda(C) :- var(C), write('¿?').
