% For a given position, check if the opponent has any way of responding that would put his king into safety
% This predicate outputs nothing, if it succeeds, enemy king is safe
% (+Color - Who made the king threat, +Pieces - list of pieces)
checkEnemyKing(white, piecesPosition(WhitePieces, BlackPieces)) :-
	legalMoves(black, piecesPosition(WhitePieces, BlackPieces), BlackPieces, move(From, To)),
    withinBounds(From),
    withinBounds(To),
    changePiece(piecesPosition(WhitePieces,BlackPieces), black, From, To, NewPosition),
	not(canThreaten(NewPosition, white)). % Success means we found a move that puts the king out of danger
    % Failure backtracks to another legal move until none are available, this fails the predicate and means we found a checkmate position 

checkEnemyKing(black, piecesPosition(WhitePieces, BlackPieces)) :-
	legalMoves(white, piecesPosition(WhitePieces, BlackPieces), WhitePieces, move(From, To)),
    withinBounds(From),
    withinBounds(To),
    changePiece(piecesPosition(WhitePieces,BlackPieces), white, From, To, NewPosition),
	not(canThreaten(NewPosition, black)).

% Once the enemy made his response to a given position, check if any move we can make results in taking the enemy king - equivallent to checkmate
% Serves for backtracking. Failure means we can't take the enemy king
% (+Position - list of pieces, +Color - Who is to move and try to take the king)
canThreaten(piecesPosition(WhitePieces, pieces(BlackPawns,BlackRooks,BlackKnights,BlackBishops,BlackQueens,[(KingX, KingY)])), white) :-
	legalMoves(white, piecesPosition(WhitePieces, pieces(BlackPawns,BlackRooks,BlackKnights,BlackBishops,BlackQueens,[(KingX, KingY)])), WhitePieces, move(_,(KingX, KingY))).

% No king means automatic success
canThreaten(piecesPosition(WhitePieces, pieces(BlackPawns,BlackRooks,BlackKnights,BlackBishops,BlackQueens,[])), white).

canThreaten(piecesPosition(pieces(Pawns,Rooks,Knights,Bishops,Queens,[(KingX, KingY)]), BlackPieces), black) :-
	legalMoves(black, piecesPosition(pieces(Pawns,Rooks,Knights,Bishops,Queens,[(KingX, KingY)]), BlackPieces), BlackPieces, move(_,(KingX, KingY))).

canThreaten(piecesPosition(pieces(Pawns,Rooks,Knights,Bishops,Queens,[]), BlackPieces), black).