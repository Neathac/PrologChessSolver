# PrologChessSolver
A university semestral project

At the moment, the chess simulation doesn't support:
 - castling moves
 - pawns switching out at the end of the board
 - En passant

The current move search only finds mate in 1 moves

To start the chess simulation, consult the chess.pl file and call start. predicate. The code will instruct you afterwards.
Here are some example inputs:

__RNBQKBNRPPPPPPPP--------------------------------pppppppprnbqkbnr__ _// Default position_

__RNBQKBNRPPPPPPPPR-------------------------------pppppppprnbqkbnr__ _// White rook in front of white pawns_

__RNBQKBNRPPPPPPPPn-------------------------------pppppppprnbqkbnr__ _// Black knight in front of white pawns_

__RNBQKBNRPPPPPPPPB-------------------------------pppppppprnbqkbnr__ _// White bishop in front of white pawns_

__RNBQKBNRPPPPPPPPp-------------------------------pppppppprnbqkbnr__ _// Black pawn in front of white pawns_

__RNBQKBNRPPPPPPPPk-------------------------------pppppppprnbq-bnr__ _// Black king in front of white pawns_

__RNBQKBNRP-PPPPPPkP------------------------------pppppppprnbq-bnr__ _// Black king exposed to white knight and bishop_

__RNBQKBNRP-PPPPPPQ-------------------------------pppppppprnbqkbnr__ _// White queen in front of white pawns_

__-NBQ-BNRPPPPPPPPK-------R-------r---------------pppppppprnbqkbnr__ _// White rook blocking check to white king by black rook_

__k---------R-----K-----R-----------------------------------------__ _// Mate in one for white_

__K---------r-----k-----r-----------------------------------------__ _// Mate in one for black_

__R---K--------rr----------------------------------R-----------k--__ _// Mate in one for white by Rook_

__R--QK-NR-BPP--B--PN-PP-PP-----P---------bpnbpn--p-p--pppr--q-rk-__ _// Mate in one for black by Bishop_

__-K-R----PPP------B---P---p----------p--p-------Q-q-P--b----r-k--__ _// Mate in one for white by Queen_

__k-------p-K-----------------------N-----------------------------__ _// Mate in one for white by knight_

__----------------------P---n-------------k--------r------K-------__ _// Mate in one for black by Knight_

---
---
# Tecnical documentation

## chess.pl

The core file of the program. It contains the entrypoint,:

---

**start:-**

It first instructs the user using _instructions(\_)_ and processes the user input using _read\_line\_to\_codes(user\_input,Cs)_, storing it to the variable Cs.

Input is then validated using _validate\_input(Cs)_, which ensures the correct format and that the position is legal.

The input is then processed using _constructPieces(Cs, _, _, Position)_, which extracts piece kinds and positions. Its output takes the format piecesPosition(pieces(WhitePawns,WhiteRooks,WhiteKnights,WhiteBishops,WhiteQueens,WhiteKing), pieces(BlackPawns,BlackRooks,BlackKnights,BlackBishops,BlackQueens,BlackKing))

_askForTurn(\_)_ determines if black or white plays next, followed by _read\_line\_to\_codes(user\_input,Code)_ to extract the user answer. It is then decoded and processed by _atom\_codes(Character, Code)_ and _generateMoves(Board, White|BlackPieces, LegalMoves)_, which outputs a set of possible moves.

_play(Position,Color)_ then determines which of the possible moves is best.

---

**constructPieces([], 1, 9, piecesPosition(pieces([],[],[],[],[],[]), pieces([],[],[],[],[],[]))).**

**constructPieces([Head|Tail], X, Y, piecesPosition(WhitePieces, BlackPieces)) :-**

A recursive function outputing a list of pieces associated with coordinates, as well as creating two separate lists of only pieces for each color based on the user-provided input.

---

**play(Position,Color) :-**

Simply calls the legal moves generation and formats the output depending on the outcome.

---

**generate(move(From, To),Color,piecesPosition(WhitePieces,BlackPieces),NewPosition):-**

Exploiting backtracking, generates all legal moves. It then tries the move and looks two turns ahead to check for checkmate.

---

**changePiece(piecesPosition(WhitePieces, BlackPieces), Color, From, To, New) :-**

Performs a given move. It first updates friendly pieces and then tries if the move was a take of an enemy piece. Outputs a valid position after the move was performed.

---

**killPiece(Field, Pieces, Result):-**

A helper predicate called by changePiece, taking care of takes.

---
---

## inputs.pl

---

**instructions(\_) :-**

Provides the user with instructions on how to use the programme.

---

**askForTurn(\_) :-**

Allows user to specify whether white or black plays next.

---

**validate_position_counts([], 0, 0, 0, 0).**

**validate_position_counts([Head|Tail], N, WK, BK, Invalid) :-**

Validates the input length and number of found kings after input is parsed.

---

**validate_input(Codes) :-**

Ensures the input format and amount of kings is correct pre-parsing.

---
---

## evaluator.pl

---

**evalMove(piece(white|black, Piece, X, Y), [MoveX, MoveY], Board, WhitePieces, BlackPieces, Score) :-**

Scores a specific move passed to the function.

---

**evalPieceMoves((_, []), _, _, _, 0, _).**

**evalPieceMoves((piece(Color, Piece, X, Y), [(MoveX, MoveY) | Tail]), Board, WhitePieces, BlackPieces, Score, BestFoundMove) :-**

Iteratively scores each move available to the piece and returns the best one.

---

**evalAllMoves([], _, _, _, _, 0).**

**evalAllMoves([Head | Tail], Board, WhitePieces, BlackPieces, ResultingMove, ResultingScore) :-**

Iterates over all pieces and finds which has the best move available.

---
---

## rules.pl

---

**whitePieces(X)**
**blackPieces(X)**
**emptySpace(X)**
**boardLetter(character, type, color)**
**pieceMoves(Type, Direction)**

There is nothing interesting about these predicates, they simply enumerate possibilities used for generation of board or possible piece directional moves

---

**legalMoves(Color, Position, Pieces, move(From,To)):-**

A version of this predicate exists for each piece. It finds current placement of a piece of a certain kind on the board, finds its possible directional moves, then attempts them and returns successful attempts. This serves to generate all possible legal moves.

---

**exploreContinuousDirection(Field,Direction,Next,Color,Position):-**

Implements the exploration of a single continuous direction provided to it. Tries to step onto one or more squares. Bouth outputs straight away and backtracks if movement is longer.

---

**pawnMove((FromX, FromY),Color,Position,To):-**

Finds all legal pawn moves. Essentially the same as pieceMoves, but pawns need to be distinguished by color.

---

**exploreSingleSquare((FieldX, FieldY), (DirX, DirY), NextTuple, Color, PiecesPosition) :-**

Does exactly as the name suggests. Attempts to step on a square if legal.

---

**continuousMove(From,Color,Type,Position,To):-**

Utilizes the direction in a move that possibly steps over multiple squares, meaning rooks, queens, and bishops.

---

**singleMove(From,Color,Type,Position,To):-**

Utilizes directional movement, but only once, meaning knights and kings.

---
---

## utils.pl

A collection of utility functions mostly used in conditions or to ease work with lists. They are all explained in closer detail via comments in implementation.

---

**append([], X, X).**

**append([X|Y], Z, [X|W]) :-**

---

**checkFriendly(Field, Color, piecesPosition(WhitePieces, BlackPieces)) :-**

**checkHostile(Field, Color, piecesPosition(WhitePieces, BlackPieces)) :-**

**isSquareFriendly(Board, X, Y, Color) :-**

**isSquareHostile(Board, X, Y, black) :-**

**isSquareHostile(Board, X, Y, white) :-**

---

**changePieces(king, Replacement, pieces(Pawns,Rooks,Knights,Bishops,Queens,Kings), pieces(Pawns,Rooks,Knights,Bishops,Queens,Replacement)).**

**replacePiece(Field, NewField, pieces(_,_,_,_,_,_),Type, Result) :- member(Field, _), replace(Field, NewField, _, Result).**

**removePiece(Field, pieces(_,_,_,_,_,_),Type, Result) :- remove(Field, _, Result).**

**isSquareTaken(Field, Color, Position) :-**

---

**withinBounds(X,Y) :-**

---

**remove(X,[X|New],New):-**

**replace(X, Y,[X|New],[Y|New]):-**
