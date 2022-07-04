% This file takes care of inputs and validates formats

instructions(_) :- 
    write('Usage of the chess solver utility: \n'),
    write('The input will first ask for a position, followed up by whose turn it is and desired move search depth. \n'),
    write('The solver will then use alpha-beta algorithm to find the best move for the given player, as found by the desired search depth. \n'),
    write('--------- \n'),
    write('Input expects a total of 64 position values. First input character corresponds to the piece in position [1,1], while last corresponds to position [8,8] on the board. \n'),
    write('Small letters correspond to black pieces, while capital letters correspond to white pieces. \n'),
    write(' The character \' - \' represents an empty field. \n'),
    write(' The character \' p/P \' represents a pawn. \n'),
    write(' The character \' n/N \' represents a knight. \n'),
    write(' The character \' r/R \' represents a rook. \n'),
    write(' The character \' b/B \' represents a bishop. \n'),
    write(' The character \' q/Q \' represents a queen. \n'),
    write(' The character \' k/K \' represents a king. \n'),
    write('---------- \n'),
    write('The input has to contain both a balck and a white king. Only one of each.'),
    write('Please input the position as a string of letters uninterrupted by spaces or other characters undefined above: \n').

/*
Test input:
RNBQKBNRPPPPPPPP--------------------------------pppppppprnbqkbnr
*/

% Validates the input length and number of found kings
validate_position_counts([], 0, 0, 0).
validate_position_counts([Head|Tail], N, WK, BK) :- validate_position_counts(Tail, N1, WK1, BK1),
    N is N1+1,
    atom_codes(Character ,[Head]),
    (
        Character = 'k' ->
        BK is BK1 + 1,
        WK is WK1
        ;
        Character = 'K' ->
        BK is BK1,
        WK is WK1 + 1
        ;
        BK is BK1,
        WK is WK1
    ).

validate_input(Codes) :-
    validate_position_counts(Codes, X, WK, BK),
    write(X),
    (
        X = 65, WK = 1, BK = 1 ->
        write('')
        ;
        write('Incorrect length or incorrect number of kings.'),
        fail
    ).