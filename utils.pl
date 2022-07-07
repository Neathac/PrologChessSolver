%Various data structure manipulations

% List appending
append([], X, X).
append([X|Y], Z, [X|W]) :- append(Y,Z,W).

% Replacement of specific elements in a list
replaceP(_, _, [], []).
replaceP(O, R, [O|T], [R|T2]) :- replaceP(O, R, T, T2).
replaceP(O, R, [H|T], [H|T2]) :- dif(H,O), replaceP(O, R, T, T2).