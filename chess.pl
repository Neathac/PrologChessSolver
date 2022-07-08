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
    generateMoves(Board, white, WhitePieces, LegalMoves),
%    getPieceMoves(piece(white, queen, 3, 1), Board, LegalMoves),
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
    append([piece(Color, Piece, X, Y)], List, ExpandedList),
    (
        Color = white ->
        append(NewWhitePieces, [piece(Color, Piece, X, Y)], WhitePieces),
        append(NewBlackPieces, [], BlackPieces)
        ;
        Color = black ->
        append(NewBlackPieces, [piece(Color, Piece, X, Y)], BlackPieces),
        append(NewWhitePieces, [], WhitePieces)
        ;
        append(NewWhitePieces, [], WhitePieces),
        append(NewBlackPieces, [], BlackPieces)
    ).

generateMoves(_, _, [], []).
generateMoves(Board, Color, [Piece|Pieces], LegalMoves) :-
    writeln('Generating'),
    writeln(Pieces),
    generateMoves(Board, Color, Pieces, NewLegalMoves),
    getPieceMoves(Piece, Board, PossibleMoves),
    writeln(Piece),
    validateMoves(Board, Color, Piece, PossibleMoves, ValidMoves),
    writeln(ValidMoves),
    append(NewLegalMoves, [(Piece,ValidMoves)], LegalMoves).

validateMoves(_, _, _, [], []).
validateMoves(Board, Color, piece(Color, Kind, X, Y), [(MoveX, MoveY)| Moves], ValidMoves) :-
    validateMoves(Board, Color, Piece, Moves, NewValidMoves),
    replaceP(piece(_, _, X, Y), piece(neutral, empty, X, Y), Board, NewBoard),
    replaceP(piece(_, _, MoveX, MoveY), piece(Color, Kind, MoveX, MoveY), NewBoard, FinalPosition),
    findPiece(piece(Color, king, _, _), FinalPosition, KingX, KingY),
    exploreKingThreats(KingX, KingY, FinalPosition, Color, FoundThreats, FoundThreatNumber),
    (
        FoundThreatNumber > 0 ->
        append([], NewValidMoves, ValidMoves)
        ;
        append([(MoveX, MoveY)], NewValidMoves, ValidMoves)    
    ).