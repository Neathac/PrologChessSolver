
:- [utils].	
:- [rules].
:- [evaluator].
:- [inputs].

% The main move generation and solution detection
% (+Position - format of piecesPosition(WhitePieces, BlackPieces), +Color - Who is to move)
play(Position,Color) :-
    (
        generate(Move,Color,Position,New_Position) ->
        (
            (Color = white) ->
            write('White wins. Move: '),
            write(Move),
            write(' is checkmate')
            ;
            (Color = black) ->
            write('Black wins. Move: '),
            write(Move),
            write(' is checkmate')
            ;
            write('There is no checkmate in 1 move possible for '),
            write(Color)
	    )
        ;
        write('There is no checkmate in 1 move possible for '),
        write(Color)
    ),
    halt.

% For a given move made by a given color, update the list of friendly positions and check if an enemy piece needs to be taken
% (+Position - position to change, +Color - who made the move, +From - Square from which the move was made, 
% +To - Square to which make the move, -New - Updated position)
changePiece(piecesPosition(WhitePieces, BlackPieces), Color, From, To, New) :-
	(
		Color = white, replacePiece(From, To, WhitePieces, Type, Result) ->
		changePieces(Type, Result, WhitePieces, ResultingPieces),
        killPiece(To, BlackPieces, NewBlackPieces),
		New = piecesPosition(ResultingPieces, NewBlackPieces)
		;
		Color = black, replacePiece(From, To, BlackPieces, Type, Result) ->
		changePieces(Type, Result, BlackPieces, ResultingPieces),
        killPiece(To, WhitePieces, NewWhitePieces),
		New = piecesPosition(NewWhitePieces, ResultingPieces)
		;
		fail
	).

% Removes a piece from a list of given pieces or does nothing if the piece is missing
% (+Field - Where to find the desired piece, +Pieces - List of pieces from which to remove, -Result - Updated list of pieces)
killPiece(Field, Pieces, Result):-
    (
        isSquareFriendly(Field, Pieces, Type) ->
        removePiece(Field, Pieces, Type, ResultPieces),
        changePieces(Type, ResultPieces, Pieces, Result)
        ;
        Result = Pieces,
        true
    ).

% Iterates over all legal moves for a given player, then checks if any of them lead to checkmate
% (-Move - Outputs the found move, +Color - Who is to move first, -NewPosition - Always undefined, mostly for debugging or future extension)
generate(move(From, To),Color,piecesPosition(WhitePieces,BlackPieces),NewPosition):-
	(
		Color = white ->
		legalMoves(Color,piecesPosition(WhitePieces,BlackPieces), WhitePieces, move(From, To)) % If move doesn't lead to checkmate, backtrack here until one is found or none are left
		;
		Color = black ->
		legalMoves(Color,piecesPosition(WhitePieces,BlackPieces), BlackPieces, move(From, To))
		;
		fail
	),
    withinBounds(From),
    withinBounds(To),
    changePiece(piecesPosition(WhitePieces,BlackPieces), Color, From, To, NewPosition), % Update the board by the found move
    canThreaten(NewPosition, Color),
    not(checkEnemyKing(Color, NewPosition)),
    writeln(NewPosition). % Write the checkmate position for more information

% Program entrypoint, it will instruct the user
start:-
	instructions(_),
    read_line_to_codes(user_input,Cs),
    validate_input(Cs),
    constructPieces(Cs, _, _, Position),
	askForTurn(_),
    read_line_to_codes(user_input,Code),
    atom_codes(Character, Code),
	(
        Character = 'W' ->
		Color = white
        ;
		Color = black
    ),
	play(Position,Color).

% Recursively read input and place a new piece into the appropriate position
% (+List of characters, _ControlX - coordinate for iteration, _ControlY - coordinate for iteration, -Position - resulting predicate with pieces)
constructPieces([], 1, 9, piecesPosition(pieces([],[],[],[],[],[]), pieces([],[],[],[],[],[]))).
constructPieces([Head|Tail], X, Y, piecesPosition(WhitePieces, BlackPieces)) :- 
    constructPieces(Tail, X1, Y1, piecesPosition(pieces(WPawns, WRooks, WKnights, WBishops, WQueens, WKing), pieces(BPawns, BRooks, BKnights, BBishops, BQueens, BKing))),
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
    append(WPawns, [], NewWPawns),
    append(WRooks, [], NewWRooks),
    append(WKnights, [], NewWKnights),
    append(WBishops, [], NewWBishops),
    append(WQueens, [], NewWQueens),
    append(WKing, [], NewWKing),
    append(BPawns, [], NewBPawns),
    append(BRooks, [], NewBRooks),
    append(BKnights, [], NewBKnights),
    append(BBishops, [], NewBBishops),
    append(BQueens, [], NewBQueens),
    append(BKing, [], NewBKing),
    boardLetter(Character, Piece, Color), !,
    (
        Piece = pawn, Color = white ->
        append(NewWPawns, [(Y, X)], ExpandedWPawns),
        WhitePieces = pieces(ExpandedWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing)
        ;
        Piece = rook, Color = white ->
        append(NewWRooks, [(Y, X)], ExpandedWRooks),
        WhitePieces = pieces(NewWPawns, ExpandedWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing)
        ;
        Piece = knight, Color = white ->
        append(NewWKnights, [(Y, X)], ExpandedWKnights),
        WhitePieces = pieces(NewWPawns, NewWRooks, ExpandedWKnights, NewWBishops, NewWQueens, NewWKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing)
        ;
        Piece = bishop, Color = white ->
        append(NewWBishops, [(Y, X)], ExpandedWBishops),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, ExpandedWBishops, NewWQueens, NewWKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing)
        ;
        Piece = king, Color = white ->
        append(NewWKing, [(Y, X)], ExpandedWKing),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, ExpandedWKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing)
        ;
        Piece = queen, Color = white ->
        append(NewWQueens, [(Y, X)], ExpandedWQueens),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, ExpandedWQueens, NewWKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing)
        ;
        Piece = pawn, Color = black ->
        append(NewBPawns, [(Y, X)], ExpandedBPawns),
        BlackPieces = pieces(ExpandedBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing)
        ;
        Piece = rook, Color = black ->
        append(NewBRooks, [(Y, X)], ExpandedBRooks),
        BlackPieces = pieces(NewBPawns, ExpandedBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing)
        ;
        Piece = knight, Color = black ->
        append(NewBKnights, [(Y, X)], ExpandedBKnights),
        BlackPieces = pieces(NewBPawns, NewBRooks, ExpandedBKnights, NewBBishops, NewBQueens, NewBKing),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing)
        ;
        Piece = bishop, Color = black ->
        append(NewBBishops, [(Y, X)], ExpandedBBishops),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, ExpandedBBishops, NewBQueens, NewBKing),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing)
        ;
        Piece = queen, Color = black ->
        append(NewBQueens, [(Y, X)], ExpandedBQueens),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, ExpandedBQueens, NewBKing),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing)
        ;
        Piece = king, Color = black ->
        append(NewBKing, [(Y, X)], ExpandedBKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, ExpandedBKing),
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing)
        ;
        WhitePieces = pieces(NewWPawns, NewWRooks, NewWKnights, NewWBishops, NewWQueens, NewWKing),
        BlackPieces = pieces(NewBPawns, NewBRooks, NewBKnights, NewBBishops, NewBQueens, NewBKing)
    ).