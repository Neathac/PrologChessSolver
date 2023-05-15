% *******************************************
% predecates for generating new moves
% *******************************************
%

% List of viable pieces used for move validity
blackPieces(X) :- X = ['p','r','n','b','q','k'].
whitePieces(X) :- X = ['P','R','N','B','Q','K'].
emptySpace(X) :- X = ['-'].

% Mapping of letters to terms
boardLetter('-', empty, neutral).
boardLetter('k', king, black).
boardLetter('K', king, white).
boardLetter('p', pawn, black).
boardLetter('P', pawn, white).
boardLetter('r', rook, black).
boardLetter('R', rook, white).
boardLetter('n', knight, black).
boardLetter('N', knight, white).
boardLetter('b', bishop, black).
boardLetter('B', bishop, white).
boardLetter('q', queen, black).
boardLetter('Q', queen, white).

% Tries to step onto a square
% (+From - Where to find the pawn, +Direction - Direction in which to move, -Next - The explored output square, +Color - Who is to move, +Position - The board situation)
exploreSingleSquare((FieldX, FieldY), (DirX, DirY), NextTuple, Color, PiecesPosition) :-
	NextX is FieldX + DirX,
	NextY is FieldY + DirY,
	NextTuple = (NextX, NextY),
	withinBounds(NextTuple),
	not(checkFriendly(NextTuple, Color, PiecesPosition)).

% Tries to step onto one or more squares. Bouth outputs straight away and backtracks if movement is longer
% (+From - Where to find the pawn, +Direction - Direction in which to move, -Next - The explored output square, +Color - Who is to move, +Position - The board situation)
exploreContinuousDirection(Field,Direction,Next,Color,Position):-
	exploreSingleSquare(Field,Direction,Next,Color,Position).
	
exploreContinuousDirection(Field, Direction, Next, Color, PiecesPosition) :-
	exploreSingleSquare(Field, Direction, FieldNew, Color, PiecesPosition),
	not(checkHostile(FieldNew, Color, PiecesPosition)),
	exploreContinuousDirection(FieldNew, Direction, Next, Color, PiecesPosition).

% Possible directions in which a piece can move
% (+Type - kind of piece, -Direction - X and Y axis in which to move)
pieceMoves(rook, (1, 0)).
pieceMoves(rook, (-1, 0)).
pieceMoves(rook, (0, 1)).
pieceMoves(rook, (0, -1)).

pieceMoves(bishop, (1, -1)).
pieceMoves(bishop, (-1, 1)).
pieceMoves(bishop, (1, 1)).
pieceMoves(bishop, (-1, -1)).

pieceMoves(knight, (-2, -1)).
pieceMoves(knight, (2, -1)).
pieceMoves(knight, (2, 1)).
pieceMoves(knight, (-2, 1)).
pieceMoves(knight, (1, -2)).
pieceMoves(knight, (-1, -2)).
pieceMoves(knight, (1, 2)).
pieceMoves(knight, (-1, 2)).

pieceMoves(queen, (1, 0)).
pieceMoves(queen, (-1, 0)).
pieceMoves(queen, (0, 1)).
pieceMoves(queen, (0, -1)).
pieceMoves(queen, (1, -1)).
pieceMoves(queen, (-1, 1)).
pieceMoves(queen, (1, 1)).
pieceMoves(queen, (-1, -1)).

pieceMoves(king, (1, 0)).
pieceMoves(king, (-1, 0)).
pieceMoves(king, (0, 1)).
pieceMoves(king, (0, -1)).
pieceMoves(king, (1, -1)).
pieceMoves(king, (-1, 1)).
pieceMoves(king, (1, 1)).
pieceMoves(king, (-1, -1)).

% Pawns need to be distinguished by color
% (+From - Where to find the pawn, +Color - Who is to move, +Position - The board situation, -To - Found legal move)
pawnMove((FromX, FromY),white,Position,To):-
	ToX is FromX + 1,
	ToY is FromY - 1,
	To = (ToX, ToY),
	checkHostile(To,black,Position).
pawnMove((FromX, FromY),white,Position,To):-
	ToX is FromX + 1,
	ToY is FromY,
	To = (ToX, ToY),
	not(isSquareTaken(To, _, Position)).
pawnMove((FromX, FromY),white,Position,To):-
	ToX is FromX + 1,
	ToY is FromY + 1,
	To = (ToX, ToY),
	checkHostile(To,white,Position).
pawnMove((FromX, FromY),white,Position,To):- 
	FromX = 2,
	ToX  is  FromX + 2,
	ToY is FromY,
	OverX  is  FromX + 1,
	OverY is FromY,
	To = (ToX, ToY),
	not(isSquareTaken((ToX, ToY), white, Position)),
	not(isSquareTaken((OverX, OverY), white, Position)).
pawnMove((FromX, FromY),black,Position,To):-
	ToX is FromX - 1,
	ToY is FromY + 1,
	To = (ToX, ToY),
	checkHostile(To,black,Position).
pawnMove((FromX, FromY),black,Position,To):-
	ToX is FromX - 1,
	ToY is FromY,
	To = (ToX, ToY),
	not(isSquareTaken(To, _, Position)).
pawnMove((FromX, FromY),black,Position,To):-
	ToX is FromX - 1,
	ToY is FromY - 1,
	To = (ToX, ToY),
	checkHostile(To,black,Position).
pawnMove((FromX, FromY),black,Position,To):-
	FromX = 7,
	ToX  is  FromX - 2,
	ToY is FromY,
	OverX  is  FromX - 1,
	OverY is FromY,
	To = (ToX, ToY),
	not(isSquareTaken((ToX, ToY), black, Position)),
	not(isSquareTaken((OverX, OverY), black, Position)).


% For Rooks, Bishops, and Queens, who can have interrupted sightlines
% (+From - Where the piece is, +Color - Which player is moving, +Type - type of piece, +Position - Board situation, -To - Move to make)
continuousMove(From,Color,Type,Position,To):-
	pieceMoves(Type,Direction),
	exploreContinuousDirection(From,Direction,To,Color,Position).

% For Knights and kings, who only move once and not in line
% (+From - Where the piece is, +Color - Which player is moving, +Type - type of piece, +Position - Board situation, -To - Move to make)
singleMove(From,Color,Type,Position,To):-
	pieceMoves(Type,Direction),
	exploreSingleSquare(From,Direction,To,Color,Position).

% Any list of pieces can be passed, failure of the calling predicate will backtrack to the next possible move
% (+Color - Who is to move (only relevant for pawns and potential castling), +Position - environment in which to move, +Pieces - which list of pieces to move
% -Move - Found move)
legalMoves(Color, Position, pieces(Pawns,_,_,_,_,_), move(From,To)):-
	member(From,Pawns), 
	pawnMove(From,Color,Position,To).
legalMoves(Color, Position, pieces(_,Rooks,_,_,_,_), move(From,To)):-
	member(From,Rooks), 	
	continuousMove(From,Color,rook,Position,To).
legalMoves(Color, Position, pieces(_,_,Knights,_,_,_), move(From,To)):-
	member(From,Knights),	
	singleMove(From, Color, knight, Position, To).
legalMoves(Color, Position, pieces(_,_,_,Bishops,_,_), move(From,To)):-
	member(From,Bishops),
	continuousMove(From, Color, bishop, Position, To).
legalMoves(Color, Position, pieces(_,_,_,_,Queens,_), move(From,To)):-
	member(From, Queens),	
	continuousMove(From,Color,queen,Position,To).
legalMoves(Color, Position, pieces(_,_,_,_,_,King), move(From,To)):-
	member(From, King),
	singleMove(From, Color, king, Position,To).
