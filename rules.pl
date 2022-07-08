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
    explorePawnTakes([(1, 1), (-1, 1)], white, X, Y, Board, FoundTakes),
    (
        % Pawn can make a double move
        X = 2 ->
        explorePawnMoves([(0, 1), (0, 2)], white, X, Y, Board, FoundMoves)
        ;
        explorePawnMoves([(0, 1)], white, X, Y, Board, FoundMoves)
    ),
    append(FoundTakes, FoundMoves, FoundLegalMoves).

getPieceMoves(piece(black, pawn, X, Y), Board, FoundLegalMoves) :-
    explorePawnTakes([(1, -1), (-1, -1)], black, X, Y, Board, FoundTakes),
    (
        % Pawn can make a double move
        X = 7 ->
        explorePawnMoves([(0, -1), (0, -2)], black, X, Y, Board, FoundMoves)
        ;
        explorePawnMoves([(0, -1)], black, X, Y, Board, FoundMoves)
    ),
    append(FoundTakes, FoundMoves, FoundLegalMoves).
    
getPieceMoves(piece(Color, rook, X, Y), Board, FoundLegalMoves) :-
    rookDirs(Dirs),
    exploreContinuousDirs(Dirs, Board, X, Y, Color, LegalMoves),
    append(LegalMoves, [], FoundLegalMoves).
getPieceMoves(piece(Color, queen, X, Y), Board, FoundLegalMoves) :- 
    queenDirs(Dirs),
    exploreContinuousDirs(Dirs, Board, X, Y, Color, LegalMoves),
    writeln(LegalMoves),
    append(LegalMoves, [], FoundLegalMoves).
getPieceMoves(piece(Color, bishop, X, Y), Board, FoundLegalMoves) :- 
    bishopDirs(Dirs),
    exploreContinuousDirs(Dirs, Board, X, Y, Color, LegalMoves),
    append(LegalMoves, [], FoundLegalMoves).
getPieceMoves(piece(Color, knight, X, Y), Board, FoundLegalMoves) :-
    knightDirs(KnightDirs),
    exploreKnightMoves(KnightDirs, Color, X, Y, Board, LegalMoves),
    append(LegalMoves, [], FoundLegalMoves).
% getPieceMoves(piece(Color, king, X, Y), Board, FoundLegalMoves).
% (+Directions in which the piece moves, +State of the board, +Piece row, +Piece column, +PieceColor, -List of possible moves)
% Used for the queen, the bishop, and the rook, as there is no set distance the piece has or can travel as long as unobstructed
exploreContinuousDirs([], _, _, _, _, []).
exploreContinuousDirs([HeadDir|TailDirs], Board, X, Y, Color, MoveList) :-
    exploreContinuousDirection(HeadDir, Board, X, Y, Color, ListOfMoves),
    exploreContinuousDirs(TailDirs, Board, X, Y, Color, NewMoveList),
    writeln([HeadDir|TailDirs]),
    writeln(ListOfMoves),
    append(ListOfMoves, NewMoveList, MoveList).

% (+Directional coordinates, +Board state, +Previous X coordinate, +Previous Y coordinate, +Color of piece being moved, -Legal moves )
exploreContinuousDirection((XDir, YDir), Board, PrevX, PrevY, Color, FoundMoves) :-
    Xmove is XDir + PrevX,
    Ymove is YDir + PrevY,
    ( 
        isSquareFriendly(Board, Ymove, Xmove, Color) ->
        append([], [], FoundMoves)
        ;
        isSquareHostile(Board, Ymove, Xmove, Color) ->
        append([], [(Xmove, Ymove)], FoundMoves) 
        ;
        withinBounds(Xmove, Ymove) ->
        exploreContinuousDirection((XDir, YDir), Board, Xmove, Ymove, Color, NewFoundMoves),
        append([(Xmove, Ymove)], NewFoundMoves, FoundMoves)
        ;
        append([], [], FoundMoves)
    ).

explorePawnTakes([], _, _, _, _, []).
explorePawnTakes([(X,Y)|Tail],Color, CurrX, CurrY, Board, FoundMoves) :-
    explorePawnTakes(Tail, Color,  CurrX, CurrY, Board, FoundLegalMoves),
    TakeX is X + CurrX,
    TakeY is Y + CurrY,
    (
        % No need to check for bounds. Hostility fails if there is no enemy piece on specified coordinates
        isSquareHostile(Board, TakeX, TakeY, Color) ->
        append([(TakeX, TakeY)], FoundLegalMoves, FoundMoves)
        ;
        append([], FoundLegalMoves, FoundMoves)
    ).

explorePawnMoves([], _, _, _, _, []).
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

exploreKnightMoves([], _, _, _, _, []).
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
exploreKingThreats(X, Y, Board, Color, Threats, IsKingThreatened) :-
    knightDirs(KnightDirs),
    bishopDirs(BishopDirs),
    rookDirs(RookDirs),
    kingDirs(KingDirs),
    knightThreats(KnightDirs ,X, Y, Board, Color, KnightThreats, IsKingThreatenedByKnight),
    continuousThreats(BishopDirs ,X, Y, Board, Color, DiagonalThreats, IsKingThreatenedDiagonally, bishop),
    continuousThreats(RookDirs ,X, Y, Board, Color, LineThreats, IsKingThreatenedInLine, rook),
    kingThreats(KingDirs, Board, Color, X, Y, KingThreats, IsKingThreatenedByKing),
    pawnThreats(Board, X, Y, Color, PawnThreats, IsKingThreatenedByPawns),
    IsKingThreatened is IsKingThreatenedByPawns + IsKingThreatenedByKing + IsKingThreatenedInLine + IsKingThreatenedDiagonally + IsKingThreatenedByKnight,
    append(KnightThreats, DiagonalThreats, MergerList),
    append(LineThreats, KingThreats, MergerList2),
    append(MergerList, MergerList2, MergerList3),
    append(PawnThreats, MergerList3, Threats).

% Checks by knights
knightThreats([], _, _, _, _, [], 0).
knightThreats([(X, Y)| Tail], CurrX, CurrY, Board, Color, FoundThreats, IsKingThreatened) :-
    knightThreats(Tail, CurrX, CurrY, Board, Color, NewFoundThreats, NewIsKingThreatened),
    XMove is X + CurrX,
    YMove is Y + CurrY,
    (
        isSquareHostile(Board, XMove, YMove, Color), member(piece(_, knight, XMove, YMove), Board) ->
        IsKingThreatened is NewIsKingThreatened + 1,
        append([(XMove, YMove)], NewFoundThreats, FoundThreats)
        ;
        IsKingThreatened is NewIsKingThreatened,
        append([], NewFoundThreats, FoundThreats)  
    ).

% Checks by queens, rooks, and bishops
continuousThreats([], _, _, _, _, [], 0, _).
continuousThreats([HeadDir|Tail], X, Y, Board, Color, FoundThreats, IsKingThreatened, Piece) :-
    continuousDirectionThreat(HeadDir, X, Y, Board, Color, FoundThreat, DidFindThreat, Piece),
    continuousThreats(Tail, X, Y, Board, Color, NewFoundThreats, NewIsKingThreatened, Piece),
    IsKingThreatened is DidFindThreat + NewIsKingThreatened,
    append(NewFoundThreats, FoundThreat, FoundThreats).

% White king checked by black pawns
pawnThreats(Board, X, Y, white, FoundThreats, IsKingThreatened) :-
    ThreatRow is X + 1,
    RightColumn is Y + 1,
    LeftColumn is Y - 1,
    (
        member(piece(black, pawn, ThreatRow, RightColumn), Board) ->
        IsRightThreat is 1,
        append([], [(ThreatRow, RightColumn)], RightThreat)
        ;
        IsRightThreat is 0,
        append([], [], RightThreat)    
    ),
    (
        member(piece(black, pawn, ThreatRow, LeftColumn), Board) ->
        IsLeftThreat is 1,
        append([], [(ThreatRow, LeftColumn)], LeftThreat)
        ;
        IsLeftThreat is 0,
        append([], [], LeftThreat)    
    ),
    IsKingThreatened is IsLeftThreat + IsRightThreat,
    append(LeftThreat, RightThreat, FoundThreats).

% Black king checked by white pawns
pawnThreats(Board, X, Y, black, FoundThreats) :-
    ThreatRow is Y - 1,
    RightColumn is X + 1,
    LeftColumn is X - 1,
    (
        member(piece(white, pawn, ThreatRow, RightColumn), Board) ->
        append([], [(ThreatRow, RightColumn)], RightThreat)
        ;
        append([], [], RightThreat)    
    ),
    (
        member(piece(white, pawn, ThreatRow, LeftColumn), Board) ->
        append([], [(ThreatRow, LeftColumn)], LeftThreat)
        ;
        append([], [], LeftThreat)    
    ),
    append(LeftThreat, RightThreat, FoundThreats).

% Checks by the enemy king
kingThreats([], _, _, _, _, [], 0).
kingThreats([(XDir, YDir)| Tail], Board, Color, X, Y, FoundThreats, FoundNumberOfThreats) :-
    kingThreats(Tail, Board, Color, X, Y, NewFoundThreats, NewFoundNumberOfThreats),
    XMove is XDir + X,
    YMove is YDir + Y,
    (
        isSquareHostile(Board, XMove, YMove, Color), member(piece(_, king, XMove, YMove), Board) ->
        append(NewFoundThreats, [(XMove, YMove)], FoundThreats),
        FoundNumberOfThreats is NewFoundNumberOfThreats + 1
        ;
        append([], NewFoundThreats, FoundThreats),
        FoundNumberOfThreats is NewFoundNumberOfThreats
    ).

continuousDirectionThreat((XDir, YDir), X, Y, Board, Color, FoundThreat, DidFindThreat, Piece) :-
    XStep is XDir + X,
    YStep is YDir + Y,
    (
        isSquareHostile(Board, XStep, YStep, Color), (member(piece(_, Piece, XStep, YStep), Board); member(piece(_, queen, XStep, YStep), Board)) ->
        DidFindThreat is 1, % Potential expected evaluable error here
        append([], [(XStep, YStep)], FoundThreat)
        ;
        withinBounds(XStep, YStep), \+isSquareFriendly(Board, XStep, YStep, Color), \+isSquareHostile(Board, XStep, YStep, Color) ->
        continuousDirectionThreat((XDir, YDir), XStep, YStep, Board, Color, NewFoundThreat, NewThreatIndicator, Piece),
        append([], NewFoundThreat, FoundThreat),
        DidFindThreat is NewThreatIndicator
        ;
        DidFindThreat is 0, % Another expected value threat
        append([], [], FoundThreat)
    ).
