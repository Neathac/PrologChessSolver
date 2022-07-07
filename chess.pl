% This file serves as the driver file. The user will consult this file and perform inputs here

:- [inputs].
:- [rules].
:- [utils].

% Program entry point
start :- 
    instructions(_),
    read_line_to_codes(user_input,Cs),
    validate_input(Cs),
    constructBoard(Cs, _, _, Board),
    knightDirs(KnightDirs),
    knightThreats(KnightDirs, 1, 3, Board, black, FoundMoves, IsKingThreatened),
    writeln(FoundMoves),
    writeln(IsKingThreatened).

% (+List of character codes, ?X coordinate, ?Y coordinate, -Board array of piece data structures)
constructBoard([], 1, 9, []).
constructBoard([Head|Tail], X, Y, ExpandedList) :- 
    constructBoard(Tail, X1, Y1, List),
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
    append([piece(Color, Piece, X, Y)], List, ExpandedList).
