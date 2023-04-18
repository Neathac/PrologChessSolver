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

---
---
# Tecnical documentation

## chess.pl

The core file of the program. It contains the entrypoint,:

---

**start:-**

It first instructs the user using _instructions(\_)_ and processes the user input using _read\_line\_to\_codes(user\_input,Cs)_, storing it to the variable Cs.

Input is then validated using _validate\_input(Cs)_, which ensures the correct format and that the position is legal.

The input is then processed using _constructBoard(Cs, \_, \_, Board, WhitePieces, BlackPieces)_, which extracts piece kinds and positions.

_askForTurn(\_)_ determines if black or white plays next, followed by _read\_line\_to\_codes(user\_input,Code)_ to extract the user answer. It is then decoded and processed by _atom\_codes(Character, Code)_ and _generateMoves(Board, White|BlackPieces, LegalMoves)_, which outputs a set of possible moves.

_evalAllMoves(LegalMoves, Board, WhitePieces, BlackPieces, Move, Score)_ then determines which of the possible moves is best.

---

**constructBoard([], 1, 9, [], [], []).**

**constructBoard([Head|Tail], X, Y, ExpandedList, WhitePieces, BlackPieces) :-**

A recursive function outputing a list of pieces or empty fields associated with coordinates, as well as creating two separate lists of only pieces for each color based on the user-provided input.

---

**generateMoves(_, [], []).**

**generateMoves(Board, [Piece|Pieces], LegalMoves) :-**

Generates a list of legal moves for each piece in the provided list.

---

**validateMoves(_, _, [], []).**

**validateMoves(Board, piece(Color, Kind, X, Y), [(MoveX, MoveY)| Moves], ValidMoves) :-**

Once all legal moves for each piece are generated, removes any move that might result in an overall illegal position, even though the move itself is possible by the piece. Example might be a discovered check on own king if the move were performed.

---

**countMoves([], 0).**

**countMoves([Head | Tail], MoveCount) :-**

Calculates how many moves are in an array.

---

**countPieceMoves((piece(_, _, _, _), []), 0).**

**countPieceMoves((piece(_, _, _, _), [Head|Tail]), MoveCount) :-**

Calculates how many moves are associated with the piece.

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

**getPieceMoves(piece(Color, somePiece, X, Y), Board, FoundLegalMoves) :-**

Finds all legal moves for a piece

---

**exploreContinuousDirs([], _, _, _, _, []).**

**exploreContinuousDirs([HeadDir|TailDirs], Board, X, Y, Color, MoveList) :-**

Recursively explores each direction up to an obstacle - A piece / edge of the board.

---

**exploreContinuousDirection((XDir, YDir), Board, PrevX, PrevY, Color, FoundMoves) :-**

Implements the exploration of a single continuous direction provided to it. Utilized by _exploreContinuousDirs_

---

**explorePawnTakes([], _, _, _, _, []).**

**explorePawnTakes([(X,Y)|Tail],Color, CurrX, CurrY, Board, FoundMoves) :-**

Finds all legal pawn moves.

---

**explorePawnMoves([], _, _, _, _, []).**

**explorePawnMoves([(X,Y)|Tail], Color, CurrX, CurrY, Board, FoundMoves) :-**

Tests if the pawn is able to take an enemy piece and should thus be included in legal moves.

---

**exploreKnightMoves([], _, _, _, _, []).**

**exploreKnightMoves([(X, Y)|Tail], Color, CurrX, CurrY, Board, FoundMoves) :-**

Tests all moves possible for a knight.

---

**exploreKingThreats(X, Y, Board, Color, Threats, IsKingThreatened) :-**

Checks if the position exposes a king of the corresponding color to a Check.

---

**knightThreats([], _, _, _, _, [], 0).**

**knightThreats([(X, Y)| Tail], CurrX, CurrY, Board, Color, FoundThreats, IsKingThreatened) :-**

A special case of exploring King threats for a knight, who can attack from a unique angle.

---

**continuousThreats([], _, _, _, _, [], 0, _).**

**continuousThreats([HeadDir|Tail], X, Y, Board, Color, FoundThreats, IsKingThreatened, Piece) :-**

Finds king threats in a straight line.

---

**pawnThreats(Board, X, Y, white|black, FoundThreats, IsKingThreatened) :-**

Finds if king can be threatened by pawns.

---

**kingThreats([], _, _, _, _, [], 0).**

**kingThreats([(XDir, YDir)| Tail], Board, Color, X, Y, FoundThreats, FoundNumberOfThreats) :-**

Counts the amount of threats to the king.

---

**continuousDirectionThreat((XDir, YDir), X, Y, Board, Color, FoundThreat, DidFindThreat, Piece) :-**

Finds threats in one specific continuous direction.

---
---

## utils.pl

A collection of utility functions mostly used in conditions or to ease work with lists

---

**append([], X, X).**

**append([X|Y], Z, [X|W]) :-**

---

**isSquareFriendly(Board, X, Y, Color) :-**

**isSquareHostile(Board, X, Y, black) :-**

**isSquareHostile(Board, X, Y, white) :-**

---

**findPiece(_, [], -1, -1).**

**findPiece(piece(Color, Piece, _, _), [piece(SomeColor, SomePiece, TestedX, TestedY) | Tail], OutputX, OutputY) :-**

---

**withinBounds(X,Y) :-**

---

**replaceP(_, _, [], []).**

**replaceP(O, R, [O|T], [R|T2]) :-**

**replaceP(O, R, [H|T], [H|T2]) :-**