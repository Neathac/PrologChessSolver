% Checks legality of moves

% Is the 
withinBounds(CurrX,CurrY) :-
    CurrX < 9,
    CurrX > -1,
    CurrY < 9,
    CurrY > -1.

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

% Valid directional moves for individual pieces
rookDirs(X) :- X = [(0,1),(0,-1),(1,0),(-1,0)].
knightDirs(X) :- X = [(2,1),(2,-1),(-2,1),(-2,-1),(-1,2),(-1,-2),(1,-2),(1,2)].
bishopDirs(X) :- X = [(-1,-1),(-1,1),(1,-1),(1,1)].
queenDirs(X) :- X = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)].
kingDirs(X) :- X = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)].

% Get legal moves for a given piece. Branch for specific pieces based on type of piece
getPieceMoves(piece(Color, pawn, X, Y), Board).
getPieceMoves(piece(Color, rook, X, Y), Board) :- 
    rookDirs(Dirs).
getPieceMoves(piece(Color, queen, X, Y), Board) :- 
    queenDirs(Dirs).
getPieceMoves(piece(Color, king, X, Y), Board) :- 
    kingDirs(Dirs).
getPieceMoves(piece(Color, knight, X, Y), Board) :- 
    knightDirs(Dirs).
getPieceMoves(piece(Color, bishop, X, Y), Board) :- 
    bishopDirs(Dirs).

% (+Directions in which the piece moves, +State of the board, +Piece row, +Piece column, +PieceColor, -List of possible moves)
% Used for the queen, the bishop, and the rook, as there is no set distance the piece has or can travel as long as unobstructed
exploreContinuousDirs([], Board, X, Y, Color, []).
exploreContinuousDirs([HeadDir|TailDirs], Board, X, Y, Color, MoveList) :-
    exploreContinuousDirection(HeadDir, Board, X, Y, Color, ListOfMoves),
    exploreContinuousDirs(TailDirs, Board, X, Y, Color, NewMoveList),
    append(ListOfMoves, NewMoveList, MoveList).

% (+Directional coordinates, +Board state, +Previous X coordinate, +Previous Y coordinate, +Color of piece being moved, -Legal moves )
exploreContinuousDirection((XDir, YDir), Board, PrevX, PrevY, Color, FoundMoves) :-
    (
        isSquareFriendly(Board, XDir + PrevX, YDir + PrevY, Color) ->
        FoundMoves is []
        ;
        isSquareHostile(Board, XDir + PrevX, YDir + PrevY, Color) ->
        FoundMoves is [(XDir + PrevX, YDir + PrevY)]
        ;
        withinBounds(XDir + PrevX, YDir + PrevY) ->
        exploreContinuousDirection((XDir, YDir), Board, PrevX + XDir, PrevY + YDir, Color, NewFoundMoves),
        append([(PrevX, PrevY)], NewFoundMoves, FoundMoves)
        ;
        FoundMoves is []
    ).

withinBounds(X,Y) :- X > 0, X < 9, Y > 0, Y < 9.

isSquareFriendly(Board, X, Y, Color) :- member(piece(Color, _, X, Y), Board).
isSquareHostile(Board, X, Y, black) :- member(piece(white, _, X, Y), Board).
isSquareHostile(Board, X, Y, white) :- member(piece(black, _, X, Y), Board).