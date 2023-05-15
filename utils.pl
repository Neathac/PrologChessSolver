
% Checks if a piece of the same color as input can be found on the given field
% Serves for backtracking, doesn't output anything
% (+Field - what field to check, +Color - What color the piece should be, +Position - Board situation)
checkFriendly(Field, Color, piecesPosition(WhitePieces, BlackPieces)) :- 
	(
		Color = white, isSquareFriendly(Field, WhitePieces, _) ->
		true
		;
		Color = black, isSquareFriendly(Field, BlackPieces, _) ->
		true
		;
		fail
	).

% Checks if a piece of the opposite color as input can be found on the given field
% Serves for backtracking, doesn't output anything
% (+Field - what field to check, +Color - What color the piece should not be, +Position - Board situation)
checkHostile(Field, Color, piecesPosition(WhitePieces, BlackPieces)) :- 
	(
		Color = white, isSquareFriendly(Field, BlackPieces, _) ->
		true
		;
		Color = black, isSquareFriendly(Field, WhitePieces, _) ->
		true
		;
		fail
	).

% Replaces a specific part of a set of pieces
% (+Type - kind of piece, +Replacement - What to insert in its palce, +Pieces - Set to update, -Pieces - updated pieces)
changePieces(pawn, Replacement, pieces(_,Rooks,Knights,Bishops,Queens,King), pieces(Replacement,Rooks,Knights,Bishops,Queens,King)).
changePieces(rook, Replacement, pieces(Pawns,_,Knights,Bishops,Queens,King), pieces(Pawns,Replacement,Knights,Bishops,Queens,King)).
changePieces(knight, Replacement, pieces(Pawns,Rooks,_,Bishops,Queens,King), pieces(Pawns,Rooks,Replacement,Bishops,Queens,King)).
changePieces(bishop, Replacement, pieces(Pawns,Rooks,Knights,_,Queens,King), pieces(Pawns,Rooks,Knights,Replacement,Queens,King)).
changePieces(queen, Replacement, pieces(Pawns,Rooks,Knights,Bishops,_,King), pieces(Pawns,Rooks,Knights,Bishops,Replacement,King)).
changePieces(king, Replacement, pieces(Pawns,Rooks,Knights,Bishops,Queens,_), pieces(Pawns,Rooks,Knights,Bishops,Queens,Replacement)).

% Replaces a specific piece in a set of pieces
% (+Field - where to replace, NewField - What to replace with, +Replacement - What to insert in its palce, +Pieces - Set to update, -Result - updated set of pieces)
replacePiece(Field, NewField, pieces(Pawns,_,_,_,_,_),pawn, Result) :- member(Field, Pawns), replace(Field, NewField, Pawns, Result).
replacePiece(Field, NewField, pieces(_,Rooks,_,_,_,_),rook, Result) :- member(Field, Rooks), replace(Field, NewField, Rooks, Result).
replacePiece(Field, NewField, pieces(_,_,Knights,_,_,_),knight, Result) :- member(Field, Knights), replace(Field, NewField, Knights, Result).
replacePiece(Field, NewField, pieces(_,_,_,Bishops,_,_),bishop, Result) :- member(Field, Bishops), replace(Field, NewField, Bishops, Result).
replacePiece(Field, NewField, pieces(_,_,_,_,Queens,_),queen, Result) :- member(Field, Queens), replace(Field, NewField, Queens, Result).
replacePiece(Field, NewField, pieces(_,_,_,_,_,King),king, Result) :- member(Field, King), replace(Field, NewField, King, Result).

% Removes a specific piece in a set of pieces
% (+Field - where to remove, +Replacement - What to insert in its palce, +Pieces - Set to update, -Result - updated set of pieces)
removePiece(Field, pieces(Pawns,_,_,_,_,_),pawn, Result) :- remove(Field, Pawns, Result).
removePiece(Field, pieces(_,Rooks,_,_,_,_),rook, Result) :- remove(Field, Rooks, Result).
removePiece(Field, pieces(_,_,Knights,_,_,_),knight, Result) :- remove(Field, Knights, Result).
removePiece(Field, pieces(_,_,_,Bishops,_,_),bishop, Result) :- remove(Field, Bishops, Result).
removePiece(Field, pieces(_,_,_,_,Queens,_),queen, Result) :- remove(Field, Queens, Result).
removePiece(Field, pieces(_,_,_,_,_,King),king, Result) :- remove(Field, King, Result).

% Checks if a square is occupied by a friendly color
% (+Field - What square to check, +Pieces - Set in which to look, -Type - What kind of piece was found)
isSquareFriendly(Field, pieces(Pawns,_,_,_,_,_),pawn) :- member(Field, Pawns).
isSquareFriendly(Field, pieces(_,Rooks,_,_,_,_),rook) :- member(Field, Rooks).
isSquareFriendly(Field, pieces(_,_,Knights,_,_,_),knight) :- member(Field, Knights).
isSquareFriendly(Field, pieces(_,_,_,Bishops,_,_),bishop) :- member(Field, Bishops).
isSquareFriendly(Field, pieces(_,_,_,_,Queens,_),queen) :- member(Field, Queens).
isSquareFriendly(Field, pieces(_,_,_,_,_,King),king) :- member(Field, King).

% Checks if a piece of any color occupies a square
% Doesn't output anything, serves for backtracking
% (+Field - What square to check, +Color - Who is asking, +Position - Board situation)
isSquareTaken(Field, Color, Position) :-
	(
		(checkFriendly(Field, Color, Position) ; checkHostile(Field, Color, Position)) ->
		true
		;
		fail
	).

% Coordinates are not out of bounds
withinBounds(X,Y) :- X > 0, X < 9, Y > 0, Y < 9, !.
withinBounds((X,Y)) :- X > 0, X < 9, Y > 0, Y < 9, !.

% remove(Elem, List, ListNew)
remove(X,[X|New],New):- !.
remove(X,[A|Old],[A|New]):-
	remove(X,Old,New).

replace(X, Y,[X|New],[Y|New]):- !.
replace(X, Y,[A|Old],[A|New]):-
	replace(X,Y,Old,New).

% List appending
append([], X, X).
append([X|Y], Z, [X|W]) :- append(Y,Z,W).
