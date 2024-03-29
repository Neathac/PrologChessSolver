% This file takes care of inputs and validates formats
/*
:- [inputs].
:- [rules].
:- [utils].
:- [evaluator].
*/
% Print instructions for the user
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
    write('The input has to contain both a balck and a white king. Only one of each. \n'),
    write('Please input the position as a string of letters uninterrupted by spaces or other characters undefined above: \n').

askForTurn(_) :-
    writeln('Enter \'W\' if white plays next, enter \'B\' otherwise:').
/*
Test input:
-------- // 8 Spaces
RNBQKBNRPPPPPPPP // Default white
pppppppprnbqkbnr // Default black
RNBQKBNRPPPPPPPP--------------------------------pppppppprnbqkbnr // Default position
RNBQKBNRPPPPPPPPR-------------------------------pppppppprnbqkbnr // White rook in front of white pawns
RNBQKBNRPPPPPPPPn-------------------------------pppppppprnbqkbnr // Black knight in front of white pawns
RNBQKBNRPPPPPPPPB-------------------------------pppppppprnbqkbnr // White bishop in front of white pawns
RNBQKBNRPPPPPPPPp-------------------------------pppppppprnbqkbnr // Black pawn in front of white pawns
RNBQKBNRPPPPPPPPk-------------------------------pppppppprnbq-bnr // Black king in front of white pawns
RNBQKBNRP-PPPPPPkP------------------------------pppppppprnbq-bnr // Black king exposed to white knight and bishop
RNBQKBNRP-PPPPPPQ-------------------------------pppppppprnbqkbnr // White queen in front of white pawns
-NBQ-BNRPPPPPPPPK-------R-------r---------------pppppppprnbqkbnr // White rook blocking check to white king by black rook
-NBQ-BNRPPPPPPPPK--------------R-------r-------kpppppppprnbq-bn- // Black rook blocking check to black king by white rook
k---------R-----------R----------------K------------------------ // Mate in one for white by Rook
K---------r-----k-----r----------------------------------------- // Mate in one for black by Rook
R---K--------rr----------------------------------R-----------k-- // Mate in one for white by Rook
R--QK-NR-BPP--B--PN-PP-PP-----P---------bpnbpn--p-p--pppr--q-rk- // Mate in one for black by Bishop
-K-R----PPP------B---P---p----------p--p-------Q-q-P--b----r-k-- // Mate in one for white by Queen
k-------p-K-----------------------N----------------------------- // Mate in one for white by knight
----------------------P---n-------------k--------r------K------- // Mate in one for black by Knight
*/

% Validates the input length and number of found kings
% (+List of character codes, -Length of list, -Amount of white kings, -Amount of black kings, -Number of invalid character codes in input)
validate_position_counts([], 0, 0, 0, 0).
validate_position_counts([Head|Tail], N, WK, BK, Invalid) :- validate_position_counts(Tail, N1, WK1, BK1, Invalid1),
    N is N1+1,
    atom_codes(Character ,[Head]),
    whitePieces(WP),
    blackPieces(BP),
    emptySpace(S),
    (
        % Found a black king
        Character = 'k' ->
        BK is BK1 + 1,
        WK is WK1,
        Invalid is Invalid1
        ;
        % Found a white king
        Character = 'K' ->
        BK is BK1,
        WK is WK1 + 1,
        Invalid is Invalid1
        ;
        % No kings, but the character is valid
        (member(Character, WP); member(Character, BP); member(Character, S)
        ) ->
        BK is BK1,
        WK is WK1,
        Invalid is Invalid1
        ;
        % Found an invalid character
        BK is BK1,
        WK is WK1,
        Invalid is Invalid1 + 1
    ).

% (+Char codes of input)
% Ensures the input format and amount of kings is correct
validate_input(Codes) :-
    validate_position_counts(Codes, Length, WK, BK, Invalid),
    (
        Length = 64, WK = 1, BK = 1, Invalid = 0 ->
        write('Semantically correct input. \n')
        ;
        (
            Length \= 64 ->
            write('ERROR: The desired input needs to be 64 characters long. Detected input had '),
            write(Length),
            write(' characters. \n')
            ;
            true
        ),
        (
            BK \= 1 ->
            write('ERROR: There needs to be exactly 1 black king. Detected input had '),
            write(BK),
            write(' black kings. \n')
            ;
            true
        ),
        (
            WK \= 1 ->
            write('ERROR: There needs to be exactly 1 white king. Detected input had '),
            write(WK),
            write(' white kings. \n')
            ;
            true
        ),
        (
            Invalid \= 0 ->
            write('ERROR: Input can only contain characters specified by instructions. Detected input had '),
            write(Invalid),
            write(' invalid characters. \n')
            ;
            true
        ),
        fail
    ).