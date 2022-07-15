%Various data structure manipulations

% List appending
append([], X, X).
append([X|Y], Z, [X|W]) :- append(Y,Z,W).

% Replacement of specific elements in a list
replaceP(_, _, [], []).
replaceP(O, R, [O|T], [R|T2]) :- replaceP(O, R, T, T2).
replaceP(O, R, [H|T], [H|T2]) :- dif(H,O), replaceP(O, R, T, T2).

% Coordinates are not out of bounds
withinBounds(X,Y) :- X > 0, X < 9, Y > 0, Y < 9.

% A piece of the same color is standing on the square
isSquareFriendly(Board, X, Y, Color) :- member(piece(Color, _, X, Y), Board).
isSquareHostile(Board, X, Y, black) :- member(piece(white, _, X, Y), Board).
isSquareHostile(Board, X, Y, white) :- member(piece(black, _, X, Y), Board).

% Find a specific piece in a list of pieces if it exists
findPiece(_, [], -1, -1).
findPiece(piece(Color, Piece, _, _), [piece(SomeColor, SomePiece, TestedX, TestedY) | Tail], OutputX, OutputY) :- 
    (
        SomeColor = Color, SomePiece = Piece ->
        OutputX is TestedX,
        OutputY is TestedY
        ;
        findPiece(piece(Color, Piece, _, _), Tail, NewX, NewY),
        OutputX is NewX,
        OutputY is NewY
    ).