% This file serves as the driver file. The user will consult this file and perform inputs here

:- [inputs].
:- [rules].
:- [utils].
:- [evaluator].

% Program entry point
start :- 
    instructions(_),
    read_line_to_codes(user_input,Cs),
    validate_input(Cs),
    constructBoard(Cs, _, _, Board, WhitePieces, BlackPieces),
    askForTurn(_),
    getPieceMoves(piece(black, king, 1, 1), Board, Moves),
    validateMoves(Board, piece(black, king, 1, 1), Moves, LegalMoves),
    writeln(LegalMoves),
    read_line_to_codes(user_input,Code),
    atom_codes(Character, Code),
    (
        Character = 'W' ->
        generateMoves(Board, WhitePieces, LegalMoves)
        ;
        generateMoves(Board, BlackPieces, LegalMoves)
    ),
    evalAllMoves(LegalMoves, Board, WhitePieces, BlackPieces, Move, Score),
    (
        Score > 0 ->
        writeln('Best found move:'),
        writeln(Move)
        ;
        writeln('No legal moves found!')    
    ). 

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
    writeln((MoveX, MoveY)),
    replaceP(piece(_, _, X, Y), piece(neutral, empty, X, Y), Board, NewBoard),
    replaceP(piece(_, _, MoveX, MoveY), piece(Color, Kind, MoveX, MoveY), NewBoard, FinalPosition),
    findPiece(piece(Color, king, _, _), FinalPosition, KingX, KingY),
    writeln(FinalPosition),
    exploreKingThreats(KingX, KingY, FinalPosition, Color, ThreatList, FoundThreatNumber),
    (
        FoundThreatNumber > 0 ->
        append([], NewValidMoves, ValidMoves)
        ;
        append([(MoveX, MoveY)], NewValidMoves, ValidMoves)    
    ).

countMoves([], 0).
countMoves([Head | Tail], MoveCount) :-
    countMoves(Tail, NewMoveCount),
    countPieceMoves(Head, PieceMoveCount),
    MoveCount is NewMoveCount + PieceMoveCount.

countPieceMoves((piece(_, _, _, _), []), 0).
countPieceMoves((piece(_, _, _, _), [Head|Tail]), MoveCount) :-
    countPieceMoves((piece(_, _, _, _), Tail), NewMoveCount),
    MoveCount is NewMoveCount + 1.