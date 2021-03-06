% (+A single piece, +Move to evaluate, +State of board, +List of white pieces, +List of BlackPieces, -Score of tried move)
% Move evaluation for white pieces
evalMove(piece(white, Piece, X, Y), [MoveX, MoveY], Board, WhitePieces, BlackPieces, Score) :-
    replaceP(piece(white, Piece, X, Y), piece(neutral, empty, X, Y), Board, MidBoard),
    replaceP(piece(_, _, MoveX, MoveY), piece(white, Piece, MoveX, MoveY), MidBoard, NewBoard),
    replaceP(piece(white, Piece, X, Y), piece(white, Piece, MoveX, MoveY), WhitePieces, NewWhitePieces),
    (
        member(piece(black, _, MoveX, MoveY), BlackPieces) ->
        delete(piece(black, _, MoveX, MoveY), BlackPieces, NewBlackPieces)
        ;
        append(BlackPieces, [], NewBlackPieces)
    ),
    generateMoves(NewBoard, NewBlackPieces, NewMoves),
    countMoves(NewMoves, MoveCount),
    findPiece(piece(black, king, _, _), NewBoard, KingX, KingY),
    exploreKingThreats(KingX, KingY, NewBoard, black, _, FoundThreatNumber),
    (
        MoveCount = 0, FoundThreatNumber > 0 ->
        Score is 999999
        ;
        Score is 1
    ).

% (+A single piece, +Move to evaluate, +State of board, +List of white pieces, +List of BlackPieces, -Score of tried move)
% Move evaluation of black pieces
evalMove(piece(black, Piece, X, Y), [MoveX, MoveY], Board, WhitePieces, BlackPieces, Score) :-
    replaceP(piece(black, Piece, X, Y), piece(neutral, empty, X, Y), Board, MidBoard),
    replaceP(piece(_, _, MoveX, MoveY), piece(black, Piece, MoveX, MoveY), MidBoard, NewBoard),
    replaceP(piece(black, Piece, X, Y), piece(black, Piece, MoveX, MoveY), BlackPieces, NewBlackPieces),
    (
        member(piece(white, _, MoveX, MoveY), WhitePieces) ->
        delete(piece(white, _, MoveX, MoveY), WhitePieces, NewWhitePieces)
        ;
        append(WhitePieces, [], NewWhitePieces)
    ),
    generateMoves(NewBoard, NewWhitePieces, NewMoves),
    countMoves(NewMoves, MoveCount),
    findPiece(piece(white, king, _, _), NewBoard, KingX, KingY),
    exploreKingThreats(KingX, KingY, NewBoard, white, _, FoundThreatNumber),
    (
        MoveCount = 0, FoundThreatNumber > 0 ->
        Score is 999999
        ;
        Score is 1
    ).

% (+A single piece with associated list of moves, +State of Board, +List of white pieces, +List of black pieces, -Best found score of move, -Best found move)
% Finds the best rated move for a piece
evalPieceMoves((_, []), _, _, _, 0, _).
evalPieceMoves((piece(Color, Piece, X, Y), [(MoveX, MoveY) | Tail]), Board, WhitePieces, BlackPieces, Score, BestFoundMove) :-
    evalPieceMoves((piece(Color, Piece, X, Y), Tail), Board, WhitePieces, BlackPieces, NewScore, NewBestFoundMove),
    evalMove(piece(Color, Piece, X, Y), [MoveX, MoveY], Board, WhitePieces, BlackPieces, MoveScore),
    (
        NewScore > MoveScore ->
        Score is NewScore,
        append(NewBestFoundMove, [], BestFoundMove)
        ;
        Score is MoveScore,
        append([(piece(Color, Piece, X, Y), [MoveX, MoveY])], [], BestFoundMove)
    ).

% (+A list of moves compounded with associated pieces, +Board state, +List of white pieces, +List of black pieces, -Best found move, -Best rating of move found)
% Evaluates all legal moves according to the evaluation function, then returns the best one found
evalAllMoves([], _, _, _, _, 0).
evalAllMoves([Head | Tail], Board, WhitePieces, BlackPieces, ResultingMove, ResultingScore) :-
    evalAllMoves(Tail, Board, WhitePieces, BlackPieces, NewResultingMove, NewResultingScore),
    evalPieceMoves(Head, Board, WhitePieces, BlackPieces, PieceScore, PieceMove),
    (
        PieceScore > NewResultingScore ->
        append(PieceMove, [], ResultingMove),
        ResultingScore is PieceScore
        ;
        append(NewResultingMove, [], ResultingMove),
        ResultingScore is NewResultingScore 
    ).
