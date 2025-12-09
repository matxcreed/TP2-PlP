

% Ejercicio 1
% matriz(+F, +C, -M)
matriz(F, C, M) :-length(M, F),maplist(longDeFilas(C), M).

longDeFilas(C, Fila) :-length(Fila, C).

% Ejercicio 2
%replicar(+Elem, +N, -Lista)
replicar(X, N, XS):-length(XS,N), maplist(=(X), XS).

% Ejercicio 3
%transponer(+M, -MT)
transponer([], []).
transponer([[]|_], []).
transponer(M, [Columna|Resto]) :- extraerColumna(M, Columna, MSinColumna),
	transponer(MSinColumna, Resto).

%extraerColumna(+M, -Heads, -Tails)
extraerColumna(M, Heads, Tails) :- maplist(split, M, Heads, Tails).

%split(+L, -Cabeza, -Cola)
split([Cabeza|Cola], Cabeza, Cola).

%%transponer([PrimeraFila|Resto], T) :-     //version1
%%    length(PrimeraFila, N),
%%    numlist(1, N, Indices),
%%    maplist(columna([PrimeraFila|Resto]), Indices, T).

%%columna(M, I, Columna) :-
%%    J is I - 1,
%%    maplist(nth0(J), M, Columna).

%%transponer(M, T) :- length(M, CT), append([E], _, M), length(E, FT),   //version2 no funciona. da filas x columnas cantidad de respuestas con un solo valor unificado
%%	matriz(FT, CT, T),
%%	nth0(I, M, Fila),
%%	nth0(J, Fila, X),
%%	nth0(J, T, Columna),
%%	nth0(I, Columna, X).	

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
% pintadasValidas(+R)
pintadasValidas(r([], L)):- length(L, N), replicar(o, N, L).
pintadasValidas(r(XS, L)):- length(L, N), masRestricciones(XS, N, L).


armoFila(_, 0, []).
armoFila(R, N, F) :- replicar(x, R, B1), M is N-R, M>= 0, between(0, M, T), replicar(o, T, L1), M2 is M -T, replicar(o,M2, L2),
	append(L1,B1, F1), append(F1, L2, F).


masRestricciones([R], N, F):- armoFila(R, N, F).
masRestricciones([R|RS], N, F):- RS \= [], M is N-1, M>=0, 
	between(R, M, N1), %el bloque tiene minimo R casilleros
	Pref is N1-R , % pref son todos los casilleros que no son X's porque exceden la long de R
	replicar(o, Pref, O1), replicar(x, R, X1), %lleno de os al pincipio, y de xs al final
	append(O1, X1, F1 ), % junto todo
	Resto is N-N1-1, % evaluo ahora los casilleros que me quedan por pintar
	masRestricciones(RS, Resto, F2), F2 \= [],  append(F1, [o|F2], F). % separo con el o minimo necesario



% Ejercicio 5
% resolverNaive(+NN)
resolverNaive(nono(_Filas, Restricciones)) :- maplist(pintadasValidas, Restricciones).

% Ejercicio 6
% pintarObligatorias(+R)
pintarObligatorias(r(RS, L)) :-
	bagof(L, pintadasValidas(r(RS, L)), Soluciones), % obtenemos una lista de pintadas validas
	combinarFilas(Soluciones, L).

combinarFilas([Sol], L) :- Sol = L. % Esto unifica la solucion con L. ¿Es lo mismo hacer combinarFilas([L], L).?
combinarFilas([Sol1|[Sol2|SS]], L) :-   % combina todas las celdas de S1 y S2 a S3 y...
	maplist(combinarCelda, Sol1, Sol2, Sol3),	
	combinarFilas([Sol3|SS], L).


% Predicado dado combinarCelda/3
combinarCelda(A, B, _) :- var(A), var(B).
combinarCelda(A, B, _) :- nonvar(A), var(B).
combinarCelda(A, B, _) :- var(A), nonvar(B).
combinarCelda(A, B, A) :- nonvar(A), nonvar(B), A = B.
combinarCelda(A, B, _) :- nonvar(A), nonvar(B), A \== B.

% Ejercicio 7
% deducir1Pasada(+NN)
deducir1Pasada(nono(_Filas, Restricciones)) :- maplist(pintarObligatorias, Restricciones).

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
% restriccionConMenosLibres(+NN, -R)
restriccionConMenosLibres(nono(_Filas, Restricciones), R) :- 
	member(R, Restricciones), 
    cantidadVariablesLibres(R, NLibresR),
    NLibresR > 0,
    not((member(Otra, Restricciones), % mira que no exista otra restriccion con menos variables libres que R
         cantidadVariablesLibres(Otra, NLibresOtra),
         NLibresOtra > 0,
         NLibresOtra < NLibresR)).


% Ejercicio 9
% resolverDeduciendo(+NN)
resolverDeduciendo(NN) :- deducirVariasPasadas(NN), ground(NN).
resolverDeduciendo(NN) :- 
	deducirVariasPasadas(NN), not(ground(NN)), 
	restriccionConMenosLibres(NN, R), !, pintadasValidas(R),
	resolverDeduciendo(NN).

% Ejercicio 10
% solucionUnica(+NN)
solucionUnica(NN) :- findall(NN, resolverDeduciendo(NN), Bag), length(Bag, 1).

% Ejercicio 11
tam(N, (F, C)) :- nn(N, nono(M, _)), matriz(F, C, M).
checkBack(NN) :- deducirVariasPasadas(NN), ground(NN).
% Para la primera columna usamos 'tam', para la segunda 'resolverDeduciendo' y para la tercera 'checkBack'
% N  | Tamaño  | ¿Tiene solucion unica? | ¿Es deducible sin backtracking?
% 0  | 2 x 3   |		   Si  		    | 			   Si
% 1  | 5 x 5   |		   Si  		    | 			   Si
% 2  | 5 x 5   |		   Si  		    | 			   Si
% 3  | 10 x 10 |		   Si  		    | 			   Si
% 4  | 5 x 5   |		   Si  		    | 			   Si
% 5  | 5 x 5   |		   Si  		    | 			   No
% 6  | 5 x 5   |		   Si  		    | 			   Si
% 7  | 10 x 10 |		   Si  		    | 			   Si
% 8  | 10 x 10 |		   Si  		    | 			   Si
% 9  | 5 x 5   |		   Si  		    | 			   Si
% 10 | 5 x 5   |		   No  		    | 			   No
% 11 | 10 x 10 |		   Si  		    | 			   Si
% 12 | 15 x 15 |		   Si  		    | 			   Si
% 13 | 11 x 5  |		   Si  		    | 			   No
% 14 | 4 x 4   |		   Si  		    | 			   No

% Ejercicio 12
% El predicado replicar está definido como un length y un maplist.
% El predicado length es reversible. Por otro lado, el goal del maplist, (=) también es reversible.
% Por lo tanto replicar es reversible en todos sus argumentos, particularmente el segundo. 
% El motivo de esto se encuentra en el length(XS, N), que en caso de no ser dato, va a ir probando con todos los N posibles, que siempre serán una respuesta válida, e infinitos.


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
