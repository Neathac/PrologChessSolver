% This file serves as the driver file. The user will consult this file and perform inputs here

:- [inputs].
:- [rules].
:- [utils].

% Program entry point
start :- 
    instructions(_),
    read_line_to_codes(user_input,Cs),
    validate_input(Cs),
    constructBoard(Cs, _, _, Board, WhitePieces, BlackPieces),
    generateMoves(Board, WhitePieces, LegalMoves),
%    getPieceMoves(piece(white, pawn, 2, 2), Board, LegalMoves),
    writeln(LegalMoves). 

% (+List of character codes, ?X coordinate, ?Y coordinate, -Board array of piece data structures)
constructBoard([], 1, 9, [], [], []).
constructBoard([Head|Tail], X, Y, ExpandedList, WhitePieces, BlackPieces) :- 
    constructBoard(Tail, X1, Y1, List, NewWhitePieces, NewBlackPieces),
    (
        % We got to the start of a row (We travel from X = 8)
        % Reset column (X) and decrement row index (Y)
        X1 =:= 1 ->
        X is X1 + 7,
        Y is Y1 - 1
        ;
        % We can continue decrementing columns
        Y is Y1,
        X is X1 - 1
    ),
    atom_codes(Character, [Head]),
    boardLetter(Character, Piece, Color),
    append([piece(Color, Piece, Y, X)], List, ExpandedList),
    (
        Color = white ->
        append(NewWhitePieces, [piece(Color, Piece, Y, X)], WhitePieces),
        append(NewBlackPieces, [], BlackPieces)
        ;
        Color = black ->
        append(NewBlackPieces, [piece(Color, Piece, Y, X)], BlackPieces),
        append(NewWhitePieces, [], WhitePieces)
        ;
        append(NewWhitePieces, [], WhitePieces),
        append(NewBlackPieces, [], BlackPieces)
    ).

generateMoves(_, [], []).
generateMoves(Board, [Piece|Pieces], LegalMoves) :-
    generateMoves(Board, Pieces, NewLegalMoves),
    getPieceMoves(Piece, Board, PossibleMoves),
    validateMoves(Board, Piece, PossibleMoves, ValidMoves),
    append(NewLegalMoves, [(Piece,ValidMoves)], LegalMoves).

validateMoves(_, _, [], []).
validateMoves(Board, piece(Color, Kind, X, Y), [(MoveX, MoveY)| Moves], ValidMoves) :-
    validateMoves(Board, piece(Color, Kind, X, Y), Moves, NewValidMoves),
    replaceP(piece(_, _, X, Y), piece(neutral, empty, X, Y), Board, NewBoard),
    replaceP(piece(_, _, MoveX, MoveY), piece(Color, Kind, MoveX, MoveY), NewBoard, FinalPosition),
    findPiece(piece(Color, king, _, _), FinalPosition, KingX, KingY),
    exploreKingThreats(KingX, KingY, FinalPosition, Color, _, FoundThreatNumber),
    (
        FoundThreatNumber > 0 ->
        append([], NewValidMoves, ValidMoves)
        ;
        append([(MoveX, MoveY)], NewValidMoves, ValidMoves)    
    ).