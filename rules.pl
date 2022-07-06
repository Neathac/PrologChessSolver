% Checks legality of moves

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
getPieceMoves(piece(white, pawn, X, Y), Board, FoundLegalMoves) :-
    explorePawnTakes([(1, 1), (1, -1)], white, X, Y, Board, FoundTakes),
    (
        % Pawn can make a double move
        X = 2 ->
        explorePawnMoves([(1, 0), (2, 0)], white, X, Y, Board, FoundMoves)
        ;
        explorePawnMoves([(1, 0)], white, X, Y, Board, FoundMoves)
    ),
    append(FoundTakes, FoundMoves, FoundLegalMoves).

getPieceMoves(piece(black, pawn, X, Y), Board, FoundLegalMoves) :-
    explorePawnTakes([(-1, 1), (-1, -1)], black, X, Y, Board, FoundTakes),
    (
        % Pawn can make a double move
        X = 7 ->
        explorePawnMoves([(-1, 0), (-2, 0)], black, X, Y, Board, FoundMoves)
        ;
        explorePawnMoves([(-1, 0)], black, X, Y, Board, FoundMoves)
    ),
    append(FoundTakes, FoundMoves, FoundLegalMoves).
    
getPieceMoves(piece(Color, rook, X, Y), Board, FoundLegalMoves) :-
    rookDirs(Dirs),
    exploreContinuousDirs(Dirs, Board, X, Y, Color, LegalMoves),
    append(LegalMoves, [], FoundLegalMoves).
getPieceMoves(piece(Color, queen, X, Y), Board, FoundLegalMoves) :- 
    queenDirs(Dirs),
    exploreContinuousDirs(Dirs, Board, X, Y, Color, LegalMoves),
    append(LegalMoves, [], FoundLegalMoves).
getPieceMoves(piece(Color, bishop, X, Y), Board, FoundLegalMoves) :- 
    bishopDirs(Dirs),
    exploreContinuousDirs(Dirs, Board, X, Y, Color, LegalMoves),
    append(LegalMoves, [], FoundLegalMoves).
getPieceMoves(piece(Color, knight, X, Y), Board, FoundLegalMoves).
getPieceMoves(piece(Color, king, X, Y), Board, FoundLegalMoves).
% (+Directions in which the piece moves, +State of the board, +Piece row, +Piece column, +PieceColor, -List of possible moves)
% Used for the queen, the bishop, and the rook, as there is no set distance the piece has or can travel as long as unobstructed
exploreContinuousDirs([], Board, X, Y, Color, []).
exploreContinuousDirs([HeadDir|TailDirs], Board, X, Y, Color, MoveList) :-
    exploreContinuousDirection(HeadDir, Board, X, Y, Color, ListOfMoves),
    exploreContinuousDirs(TailDirs, Board, X, Y, Color, NewMoveList),
    append(ListOfMoves, NewMoveList, MoveList).

% (+Directional coordinates, +Board state, +Previous X coordinate, +Previous Y coordinate, +Color of piece being moved, -Legal moves )
exploreContinuousDirection((XDir, YDir), Board, PrevX, PrevY, Color, FoundMoves) :-
    writeln(FoundMoves),
    Xmove is XDir + PrevX,
    Ymove is YDir + PrevY,
    writeln(Xmove),
    writeln(Ymove),
    ( 
        isSquareFriendly(Board, Xmove, Ymove, Color) ->
        append([], [], FoundMoves)
        ;
        isSquareHostile(Board, Xmove, Ymove, Color) ->
        append([], [(Xmove, Ymove)], FoundMoves) 
        ;
        withinBounds(Xmove, Ymove) ->

        exploreContinuousDirection((XDir, YDir), Board, Xmove, Ymove, Color, NewFoundMoves),
        append([(Xmove, Ymove)], NewFoundMoves, FoundMoves)
        ;
        append([], [], FoundMoves)
    ).

explorePawnTakes([], Color, X, Y, Board, []).
explorePawnTakes([(X,Y)|Tail],Color, CurrX, CurrY, Board, FoundMoves) :-
    explorePawnTakes(Tail, Color, Board, CurrX, CurrY, FoundLegalMoves),
    TakeX is X + CurrX,
    TakeY is Y + CurrY,
    (
        % No need to check for bounds. Hostility fails if there is no enemy piece on specified coordinates
        isSquareHostile(Board, TakeX, TakeY, Color) ->
        append([(TakeX, TakeY)], FoundLegalMoves, FoundMoves)
        ;
        append([], FoundLegalMoves, FoundMoves)
    ).

explorePawnMoves([], Color, X, Y, Board, []).
explorePawnMoves([(X,Y)|Tail], Color, CurrX, CurrY, Board, FoundMoves) :-
    explorePawnMoves(Tail, Color, CurrX, CurrY, Board, FoundLegalMoves),
    MoveX is CurrX + X,
    MoveY is CurrY + Y,
    (
        (isSquareHostile(Board, MoveX, MoveY, Color) ; isSquareFriendly(Board, MoveX, MoveY, Color) ; \+withinBounds(MoveX, MoveY))  ->
        % The next square not being taken is nice, but the pawn is blocked - Ignore found moves from potential second iteration
        append([], [], FoundMoves)
        ;
        append([(MoveX, MoveY)], FoundLegalMoves, FoundMoves)   
    ).

exploreKnightMoves([], Color, X, Y, Board, []).
exploreKnightMoves([(X, Y)|Tail], Color, CurrX, CurrY, Board, FoundMoves) :-
    exploreKnightMoves(Tail, Color, CurrX, CurrY, Board, FoundLegalMoves),
    XMove is X + CurrX,
    YMove is Y + CurrY,
    (
        \+isSquareFriendly(Board, XMove, YMove, Color), withinBounds(XMove, YMove) ->
        append(FoundLegalMoves, [(XMove, YMove)], FoundMoves)
        ;
        append(FoundLegalMoves, [], FoundMoves)
    ).

% (+Coordinates of square with king, +State of the board, + Color of the king, - Pieces directly threatening the king
    % - Pieces that would threaten the king if something moved paired with blockers, - Is the square checked)
exploreKingThreats(X, Y, Board, Color, Threats, BlockedThreats, ThreatBlockers, IsKingThreatened) :-
    knightDirs(KnightDirs),
    bishopDirs(BishopDirs),
    rookDirs(RookDirs),
    knightThreats(KnightDirs ,X, Y, Board, Color, KnightThreats, IsKingThreatenedByKnight),
    diagonalThreats(BishopDirs ,X, Y, Board, Color, DiagonalThreats, IsKingThreatenedDiagonally),
    lineThreats(RookDirs ,X, Y, Board, Color, LineThreats, IsKingThreatenedInLine),
    pawnThreats().

knightThreats([], X, Y, Board, Color, [], 0).
knightThreats([(X, Y)| Tail], CurrX, CurrY, Board, Color, FoundThreats, IsKingThreatened) :-
    knightThreats(Tail, CurrX, CurrY, Board, Color, NewFoundThreats, NewIsKingThreatened),
    XMove is X + CurrX,
    YMove is Y + CurrY,
    (
        isSquareHostile(Board, XMove, YMove, Color), member(piece(Color, knight, XMove, YMove)) ->
        IsKingThreatened is NewIsKingThreatened + 1,
        append([(XMove, YMove)], NewFoundThreats, FoundThreats)
        ;
        IsKingThreatened is NewIsKingThreatened,
        append([], NewFoundThreats, FoundThreats)  
    ).

withinBounds(X,Y) :- X > 0, X < 9, Y > 0, Y < 9.

isSquareFriendly(Board, X, Y, Color) :- member(piece(Color, _, X, Y), Board).
isSquareHostile(Board, X, Y, black) :- member(piece(white, _, X, Y), Board).
isSquareHostile(Board, X, Y, white) :- member(piece(black, _, X, Y), Board).
