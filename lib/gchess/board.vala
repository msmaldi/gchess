namespace GChess 
{
    public errordomain BoardError
    {
        INVALID_FORMAT
    }

    [Compact]
    public struct Castling
    {
        bool kingside;
        bool queenside;
    }

    [Compact]
    public struct Board
    {
        public Player turn;
        public Castling castling[2];
        public Square en_passant;
        public uint8 half_move_clock;
        public uint16 move_number;
        public Square king[2];
        public Piece pieces[64];

        public static Board* new()
        {
            Board* result = new Board[1];
            return result;
        }

        public void copy(Board *dst)
        {
            Memory.copy (dst, &this, sizeof (Board));
        }

        public string to_fen ()
        {
            var builder = new StringBuilder ();

            for (Rank rank = RANK_8; rank >= RANK_1; rank--)
            {
                int8 skip_count = 0;
                for (File file = FILE_A; file <= FILE_H; file++)
                {
                    var p = pieces[SQUARE(file, rank)];
                    if (p == EMPTY)
                        skip_count++;
                    else
                    {
                        if (skip_count > 0)
                        {
                            builder.append_printf ("%d", skip_count);
                            skip_count = 0;
                        }
                        builder.append_printf ("%c", p.to_char());
                    }

                }
                if (skip_count > 0)
                    builder.append_printf ("%d", skip_count);
                if (rank != RANK_1)
                    builder.append_c ('/');
            }
            builder.append_c (' ');

            if (turn == WHITE)
                builder.append_c ('w');
            else
                builder.append_c ('b');
            builder.append_c (' ');

            if (castling[WHITE].kingside)
                builder.append_c ('K');
            if (castling[WHITE].queenside)
                builder.append_c ('Q');
            if (castling[BLACK].kingside)
                builder.append_c ('k');
            if (castling[BLACK].queenside)
                builder.append_c ('q');
            if (castling[WHITE].kingside == false && castling[WHITE].queenside == false &&
                castling[BLACK].kingside == false && castling[BLACK].queenside == false)
                builder.append_c ('-');            
            builder.append_c (' ');
            
            if (en_passant == NULL_SQUARE)
                builder.append_c ('-');
            else
                builder.append_printf("%c%c", en_passant.file.to_char(), 
                                              en_passant.rank.to_char());                                                   
            builder.append_c (' ');
             
            builder.append_printf ("%d", half_move_clock);                                                   
            builder.append_c (' ');

            builder.append_printf ("%d", move_number);

            return builder.str;
        }

        public void print_board ()
        {
            print ("\n    a   b   c   d   e   f   g   h\n");
            print ("  +---+---+---+---+---+---+---+---+\n");
            for (Rank y = 8 - 1; y >= 0; y--) {
                print(" %d|", y + 1);
                for (File x = 0; x < 8; x++) 
                {
                    Piece p = this.pieces[SQUARE (x, y)]; //PIECE_AT(board, x, y);
                    char c = p.to_char();
                    print(" %c |", p.player == BLACK ? c.tolower() : c);

                }
                print("%d\n", y + 1);
                print ("  +---+---+---+---+---+---+---+---+\n");
            }
            print ("    a   b   c   d   e   f   g   h\n\n");
            print ("%s\n", to_fen());
        }

        private static void decode_board (ref Board board, string board_sz) throws BoardError
        {
            int index = 0;
            int w_king_count = 0, b_king_count = 0;
            for (Rank rank = RANK_8; rank >= RANK_1; rank--)
	        {
                File file = FILE_A;
                while (board_sz[index] != '/' && board_sz[index] != '\0')
                {
                    if (is_number_fen_rank ((char)board_sz[index]))
                    {
                        File empty_squares = (File)(board_sz[index] - '0');
                        if (file + empty_squares > 8)
                        {
                            throw new BoardError.INVALID_FORMAT ("Rank %d length > 8", rank + 1);
                        }				
                        for(File i = FILE_A; i < empty_squares; i++)
                        {	
                            var square = SQUARE(file + i, rank);
                            board.pieces[square] = EMPTY;
                        }
                        file += empty_squares;
                    }
                    else if (is_piece ((char)board_sz[index]))
                    {
                        if (file > FILE_H)
                            throw new BoardError.INVALID_FORMAT ("Rank %d length > 8", rank - 1);

                        Piece piece = Piece.from_char (board_sz[index]);
                        if (piece == BLACK_KING)
                        {
                            b_king_count++;
                            board.king[BLACK] = SQUARE (file, rank);
                        }
                        else if (piece == WHITE_KING)
                        {
                            w_king_count++;
                            board.king[WHITE] = SQUARE (file, rank);
                        }

                        board.pieces[SQUARE(file, rank)] = piece;
                        file++;
                    }
                    else
                    {
                        throw new BoardError.INVALID_FORMAT ("Found '%c', character must be [rnbqkpRNBQKP] or [1-8].", board_sz[index]);
                    }
                    index++;
                }
		        index++;
            }
            if (b_king_count != 1)
                throw new BoardError.INVALID_FORMAT ("Found %d Black King, must be 1.", b_king_count);
            if (w_king_count != 1)
                throw new BoardError.INVALID_FORMAT ("Found %d White King, must be 1.", w_king_count);
        }

        private static void decode_current_player (ref Board board, string player) throws BoardError
        {
            if (player == "w")
                board.turn = WHITE;
            else if (player == "b")
                board.turn = BLACK;
            else
                throw new BoardError.INVALID_FORMAT ("Unknown active player: %s", player);
        }

        private static void decode_castling (ref Board board, string castling_sz) throws BoardError
        {
            Castling b_castling = { false, false };
	        Castling w_castling = { false, false };	
            
            if (castling_sz == "KQkq")
            {
                w_castling.kingside = true;
                w_castling.queenside = true;
                b_castling.kingside = true;
                b_castling.queenside = true;
            }
            else if (castling_sz == "KQk")
            {
                w_castling.kingside = true;
                w_castling.queenside = true;
                b_castling.kingside = true;
                b_castling.queenside = false;
            }
            else if (castling_sz == "KQq")
            {
                w_castling.kingside = true;
                w_castling.queenside = true;
                b_castling.kingside = false;
                b_castling.queenside = true;
            }
            else if (castling_sz == "Kkq")
            {
                w_castling.kingside = true;
                w_castling.queenside = false;
                b_castling.kingside = true;
                b_castling.queenside = true;
            }
            else if (castling_sz == "Qkq")
            {
                w_castling.kingside = false;
                w_castling.queenside = true;
                b_castling.kingside = true;
                b_castling.queenside = true;
            }
            else if (castling_sz == "KQ")
            {
                w_castling.kingside = true;
                w_castling.queenside = true;
                b_castling.kingside = false;
                b_castling.queenside = false;
            }
            else if (castling_sz == "Kk")
            {
                w_castling.kingside = true;
                w_castling.queenside = false;
                b_castling.kingside = true;
                b_castling.queenside = false;
            }
            else if (castling_sz == "Kq")
            {
                w_castling.kingside = true;
                w_castling.queenside = false;
                b_castling.kingside = false;
                b_castling.queenside = true;
            }
            else if (castling_sz == "Qk")
            {
                w_castling.kingside = false;
                w_castling.queenside = true;
                b_castling.kingside = true;
                b_castling.queenside = false;
            }
            else if (castling_sz == "Qq")
            {
                w_castling.kingside = false;
                w_castling.queenside = true;
                b_castling.kingside = false;
                b_castling.queenside = true;
            }
            else if (castling_sz == "kq")
            {
                w_castling.kingside = false;
                w_castling.queenside = false;
                b_castling.kingside = true;
                b_castling.queenside = true;
            }
            else if (castling_sz == "K")
            {
                w_castling.kingside = true;
                w_castling.queenside = false;
                b_castling.kingside = false;
                b_castling.queenside = false;
            }
            else if (castling_sz == "Q")
            {
                w_castling.kingside = false;
                w_castling.queenside = true;
                b_castling.kingside = false;
                b_castling.queenside = false;
            }
            else if (castling_sz == "k")
            {
                w_castling.kingside = false;
                w_castling.queenside = false;
                b_castling.kingside = true;
                b_castling.queenside = false;
            }
            else if (castling_sz == "q")
            {
                w_castling.kingside = false;
                w_castling.queenside = false;
                b_castling.kingside = false;
                b_castling.queenside = true;
            }
            else if (castling_sz == "-")
            {
                w_castling.kingside = false;
                w_castling.queenside = false;
                b_castling.kingside = false;
                b_castling.queenside = false;
            }
            else
            {
                throw new BoardError.INVALID_FORMAT ("Found expected - or \"KQkq\" end must be ordered.");
            }            
            board.castling[WHITE] = w_castling;
            board.castling[BLACK] = b_castling;
        }

        private static void decode_en_passant (ref Board board, string en_passant) throws BoardError
        {
            if (en_passant == "-")
            {
                board.en_passant = NULL_SQUARE;
            }
            else
            {
                if (en_passant.length != 2)
                    throw new BoardError.INVALID_FORMAT ("Invalid EnPassant: %s", en_passant);
                
                char file_char = en_passant[0];
                char rank_char = en_passant[1];

                if (!('a' <= file_char <= 'h'))
                    throw new BoardError.INVALID_FORMAT ("Invalid EnPassant File: %c", file_char);
                if (!('1' <= rank_char <= '8'))
                    throw new BoardError.INVALID_FORMAT ("Invalid EnPassant Rank: %c", rank_char);
                
                File file = File.from_char(file_char);
                Rank rank = Rank.from_char(rank_char);
                
                if (board.turn == WHITE)
                {
                    if (rank != RANK_6)
                        throw new BoardError.INVALID_FORMAT (
                            "Found '%c%c' en passant, is invalid.",
                            file_char, rank_char);
                    Piece pawn = board.pieces[SQUARE (file, RANK_5)];
                    Piece target = board.pieces[SQUARE (file, rank)];
                    Piece empty = board.pieces[SQUARE (file, RANK_7)];
                    if (pawn != BLACK_PAWN || target.piece_type != EMPTY || empty.piece_type != EMPTY)
                    {
                        throw new BoardError.INVALID_FORMAT (
                            "Found '%c%c' en passant, is invalid.",
                            file_char, rank_char);
                    }
                }
                else
                {
                    if (rank != RANK_3)
                        throw new BoardError.INVALID_FORMAT (
                            "Found '%c%c' en passant, is invalid.",
                            file_char, rank_char);
                    Piece pawn = board.pieces[SQUARE (file, RANK_4)];
                    Piece target = board.pieces[SQUARE (file, rank)];
                    Piece empty = board.pieces[SQUARE (file, RANK_2)];

                    if (pawn != WHITE_PAWN || target.piece_type != EMPTY || empty.piece_type != EMPTY)
                    {
                        throw new BoardError.INVALID_FORMAT (
                            "Found '%c%c' en passant, is invalid.",
                            file_char, rank_char);
                    }
                }
                board.en_passant = SQUARE (file, rank);
            }
        }

        public static void from_fen (out Board board, string fen) throws BoardError
        {
            board = { };

            string[] fields = fen.split (" ");
            int fields_count = fields.length;
            
            // Fen string is
            // "board_pieces player castling en_passant half_moveclock move_number
            if (fields_count != 6) // (4 >= fields_count >= 6)
                throw new BoardError.INVALID_FORMAT ("Invalid FEN string");
            
            string[] ranks = fields[0].split ("/");
            if (ranks.length != 8)
                throw new BoardError.INVALID_FORMAT ("Invalid piece placement");

            //  Part 1 - Board Pieces
            decode_board (ref board, fields[0]);
            
            //  PART 2 - Player Parse
            decode_current_player (ref board, fields[1]);
            
            //  PART 3 - Castling Parse
            decode_castling (ref board, fields[2]);

            //  PART 4 - En Passant Parse
            decode_en_passant (ref board, fields[3]);

            //  PART 5 - Half Move Clock Parse
            board.half_move_clock = (uint8) int.parse (fields[4]);

            //  PART 6 - Move Number Parse
            board.move_number = (uint16) int.parse (fields[5]);
        }
        
        // Assumes the move is legal. This is necessary as the easiest way to test
        // whether a move doesn't put the moving player in check (illegal) is to
        // perform the move and then test if they are in check.
        public void performe_move(Move move)
        {
            Square start = move.start;
            Square end = move.end;
            Piece p = pieces[start];
            PieceType type = p.piece_type;
            Player player = p.player;

            half_move_clock++;
	        if (player == BLACK)
		        move_number++;

            // Check if we're capturing en passant
            if (type == PAWN && end == en_passant)
            {
                Rank en_passanter_rank = player == WHITE ? RANK_5 : RANK_4;
                Square captured_en_passanter = SQUARE (end.x, en_passanter_rank);
                pieces[captured_en_passanter] = EMPTY;
            }

            // Check if this move enables our opponent to perform en passant
            int dy = end.y - start.y;
            if (type == PAWN && dy.abs() == 2)
            {
                Rank en_passant_rank = player == WHITE ? RANK_3 : RANK_6;
                en_passant = SQUARE(start.x, en_passant_rank);
            } 
            else 
            {
                // Otherwise reset en passant
                en_passant = NULL_SQUARE;
            }

            // Check if we're castling so we can move the rook too
            int dx = end.x - start.x;
            if (type == KING) 
            {
                king[turn] = end;

                if (dx.abs() > 1)
                {
                    Rank y = player == WHITE ? RANK_1 : RANK_8;
                    bool kingside = end.x == 6;
                    if (kingside) 
                    {
                        pieces[SQUARE(7, y)] = EMPTY;
                        pieces[SQUARE(5, y)] = PIECE(player, PieceType.ROOK);
                    } 
                    else 
                    {
                        pieces[SQUARE(0, y)] = EMPTY;
                        pieces[SQUARE(3, y)] = PIECE(player, PieceType.ROOK);
                    }
                }
            }

            // Check if we're depriving ourself of castling rights
            Castling *c = &castling[player];
            if (type == KING) 
            {
                c.kingside = false;
                c.queenside = false;
            }
            else
            {
                if (start == Squares.SQ_A1 || end == Squares.SQ_A1)
                    castling[WHITE].queenside = false;
                if (start == Squares.SQ_A8 || end == Squares.SQ_A8)
                    castling[BLACK].queenside = false;
                if (start == Squares.SQ_H1 || end == Squares.SQ_H1)
                    castling[WHITE].kingside = false;
                if (start == Squares.SQ_H8 || end == Squares.SQ_H8)
                    castling[BLACK].kingside = false;
            }

            // Check if we should reset the half-move clock
            if (type == PAWN || pieces[end] != EMPTY)
                half_move_clock = 0;

            // Update the turn tracker
            turn = turn.other();
            
            pieces[end] = pieces[start];
            pieces[start] = EMPTY;

            // Pawn get promotion
            if (type == PAWN)
            {
                PieceType promotion = move.promotion;
                if (end.rank == RANK_BLACK_PROMOTION)
                {
                    pieces[end] = PIECE (BLACK, promotion);
                }
                else if (end.rank == RANK_WHITE_PROMOTION)
                {
                    pieces[end] = PIECE (WHITE, promotion);
                }
            }
        }

        private Square find_piece_looking_at (Square square, Player piece_owner)
        {
            // We need to make sure we don't have infinite recursion in legal_move.
            // This can happen with looking for checks - we need to see if there are
            // any moves that put us in check to decide if the move is legal, but to
            // see if we are in check we need to look at all the moves our opponent
            // can make. And checking those moves will follow the same process.
            // We need use pseudo_legal_move
            for(Square s = Squares.SQ_A1; s <= Squares.SQ_H8; s++)
            {
                Piece p = pieces[s];
                if (p == EMPTY || p.player != piece_owner)
                    continue;
                Move m = PROMOTE(MOVE(s, square), PieceType.QUEEN); 

                if (pseudo_legal_move(m))
                    return s;
            }

            return NULL_SQUARE;
        }

        private bool under_attack (Square target, Player p)
        {
            return find_piece_looking_at(target, p) != NULL_SQUARE;
        }

        private bool can_castle_kingside(Player p)
        {
            Rank rank = p == WHITE ? RANK_1 : RANK_8;
            Player other = p.other();

            return castling[p].kingside && 
                pieces[SQUARE (FILE_F, rank)] == EMPTY &&
                pieces[SQUARE (FILE_G, rank)] == EMPTY &&
                !in_check (p) &&
                !under_attack (SQUARE(FILE_F, rank), other) &&
                !under_attack (SQUARE(FILE_G, rank), other);
        }

        private bool can_castle_queenside (Player p)
        {
            Rank rank = p == WHITE ? RANK_1 : RANK_8;
            Player other = p.other();

            return castling[p].queenside &&                 
                pieces[SQUARE (FILE_D, rank)] == EMPTY &&
                pieces[SQUARE (FILE_C, rank)] == EMPTY &&
                pieces[SQUARE (FILE_B, rank)] == EMPTY &&
                !in_check (p) &&
                !under_attack (SQUARE(FILE_D, rank), other) &&
                !under_attack (SQUARE(FILE_C, rank), other) &&
                !under_attack (SQUARE(FILE_B, rank), other);
        }

        // Pseudo Legal Move check only move piece is valid, and not blocked,
        // this doesn't check if is current player on board and is pinned piece.
        private bool pseudo_legal_move (Move move)
        {
            Square start = move.start;
            Square end = move.end;
            Piece p = pieces[start];
            PieceType type = p.piece_type;
            Piece at_end_square = pieces[end];

            Player player = p.player;

            // Can't "move" a piece by putting it back into the same square
            if (start == end)
                return false;

            int dx = end.x - start.x;
            int dy = end.y - start.y;

            int ax = dx.abs();
            int ay = dy.abs();

            int8 x_direction = ax == 0 ? 0 : dx / ax;
            int8 y_direction = ay == 0 ? 0 : dy / ay;

            // Pieces other than knights are blocked by intervening pieces
            if (type != KNIGHT) 
            {
                File x = start.x + x_direction;
                Rank y = start.y + y_direction;

                while ((!(x == end.x && y == end.y)) &&
                        x < 8 && y < 8) 
                {
                    if (pieces[SQUARE(x, y)] != EMPTY)
                        return false;

                    x += x_direction;
                    y += y_direction;
                }
            }

            // Now handle each type of movement
            bool legal_movement = false;
            switch (type) {
            case PieceType.PAWN:
                if ((player == WHITE && start.y == RANK_WHITE_PAWN) ||
                    (player == BLACK && start.y == RANK_BLACK_PAWN)) 
                {
                    if (ay != 1 && ay != 2) 
                    {
                        legal_movement = false;
                        break;
                    }
                } 
                else if (ay != 1) 
                {
                    legal_movement = false;
                    break;
                }

                if (y_direction != (player == WHITE ? 1 : -1))
                {
                    legal_movement = false;
                    break;
                }

                Rank end_y = end.rank;
                if (end_y == RANK_WHITE_PROMOTION || end_y == RANK_BLACK_PROMOTION)
                {
                    PieceType promotion = move.promotion;
                    if (!is_promotable (promotion))
                    {
                        legal_movement = false;
                        break;			
                    }
                }

                if (dx == 0)
                {
                    legal_movement = at_end_square == EMPTY;
                    break;
                }

                if (dx == 1 || dx == -1)
                {
                    legal_movement = (ay == 1 && at_end_square != EMPTY &&
                            at_end_square.player != player) ||
                            end == en_passant;
                    break;
                }

                legal_movement = false;
                break;
            case PieceType.KNIGHT:
                legal_movement = (ax == 1 && ay == 2) || (ax == 2 && ay == 1);
                break;
            case PieceType.BISHOP: legal_movement = ax == ay; break;
            case PieceType.ROOK:   legal_movement = dx == 0 || dy == 0; break;
            case PieceType.QUEEN:  legal_movement = ax == ay || dx == 0 || dy == 0; break;
            case PieceType.KING:
                if (ax <= 1 && ay <= 1)
                {
                    legal_movement = true;
                    break;
                }
                if (end.rank != (player == WHITE ? RANK_WHITE_CASTLE : RANK_BLACK_CASTLE))
                {
                    legal_movement = false;
                    break;
                }

                if (end.file == FILE_CASTLE_KINGSIDE)
                {			
                    legal_movement = can_castle_kingside(player);
                    break;
                } 
                else if (end.file == FILE_CASTLE_QUEENSIDE)
                {
                    legal_movement = can_castle_queenside(player);
                    break;
                }
                else
                {
                    legal_movement = false;
                    break;
                }
            case PieceType.EMPTY:  legal_movement = false; break;
            }

            return legal_movement;
        }

        public bool in_check (Player p)
        {
            Square king_location = king[p];
            return under_attack (king_location, p.other());
        }

        public bool gives_check (Move move, Player player)
        {
            Board coppied = { };
            copy(&coppied);
            coppied.performe_move (move);

            return coppied.in_check (player);
        }

        public bool is_legal_move (Move move)
        {
            Square start = move.start;
	        Square end = move.end;
	        Piece p = pieces[start];
	        PieceType type = p.piece_type;
            Piece at_end_square = pieces[end];
            Player player = p.player;

            // Can't move a piece that isn't there
            if (type == EMPTY)
                return false;

            // Can only move if it's your turn
            if (player != turn)
                return false;

            // Can't capture your own pieces
            if (at_end_square != EMPTY && at_end_square.player == player)
                return false;
    
            if (pseudo_legal_move(move))
                return !gives_check(move, player);
            else 
                return false;
        }

        private bool under_legal_move_attack (Square target, Player piece_owner)
        {
            for(Square s = Squares.SQ_A1; s <= Squares.SQ_H8; s++)
            {
                Piece p = pieces[s];
                if (p == EMPTY || p.player != piece_owner)
                    continue;
                Move m = PROMOTE(MOVE(s, target), PieceType.QUEEN);

                if (is_legal_move(m))
                    return true;
            }

            return false;
        }

        public bool gives_mate (Move move, Player player)
        {
            Board coppied = {};
            copy(&coppied);
            coppied.performe_move(move);

            return coppied.checkmate(player);
        }

        public string algebraic_notation_for (Move move)
        {
            int i = 0;
            Square start = move.start;
            Square end = move.end;
            Piece p = pieces[start];
            PieceType type = p.piece_type;
            Player other_player = p.player.other();
            
            // Castling
            if (type == PieceType.KING && ((int)(start.x - end.x)).abs() > 1) 
            {
                if (end.x == 6)
                {	
                    if (gives_mate (move, other_player))
                        return "O-O#";
                    else if (gives_check (move, other_player))
                        return "O-O+";
                    else
                        return "O-O";
                }
                else
                {
                    if (gives_mate (move, other_player))
                        return "O-O-O#";
                    else if (gives_check (move, other_player))
                        return "O-O-O+";
                    else
                        return "O-O-O";
                }
            }
            bool capture = pieces[end] != EMPTY;
            char result_sz[8] = { '\0', '\0', '\0', '\0', '\0', '\0', '\0', '\0' };
            
            if (type == PieceType.PAWN)
            {
                // en_passant capture
                capture = (capture || (end == en_passant));
            }
            else
            {
                // Add the letter denoting the type of piece moving
                result_sz[i++] = "\0\0NBRQK"[type];
            }

            bool multiples_ambiguous = has_multiples_ambiguous_piece (move);
            if (multiples_ambiguous)
            {
                result_sz[i++] = start.file.to_char();
                result_sz[i++] = start.rank.to_char();
            }
            else
            {
                // Add the number/letter of the rank/file
                // of the moving piece if necessary
                Square ambig = ambiguous_piece(move);
                // We always add the file if it's a pawn capture
                if (ambig != NULL_SQUARE || (type == PieceType.PAWN && capture)) {
                    char disambiguate;
                    if (ambig.x == start.x)
                        disambiguate = start.y.to_char();
                    else
                        disambiguate = start.x.to_char();

                    result_sz[i++] = disambiguate;
                }
            }

            // Add an 'x' if its a capture
            if (capture)
                result_sz[i++] = 'x';

            // Add the target square
            result_sz[i++] = end.x.to_char();
            result_sz[i++] = end.y.to_char();

            // If move need promotion, type must be PAWN
            if (type == PieceType.PAWN)
            {
                if (end.rank == RANK_8 || end.rank == RANK_1)
                {
                    result_sz[i++] = '=';
                    result_sz[i++] = "\0\0NBRQK"[(move.promotion)];
                }
            }

            // Add a '#' if its mate
            if (gives_mate(move, other_player))
                result_sz[i++] = '#';
            // Add a '+' if its check
            else if (gives_check(move, other_player))
                result_sz[i++] = '+';

            result_sz[i++] = '\0';
            return "%s".printf((string)result_sz);
        }

        private bool has_multiples_ambiguous_piece (Move move)
        {
            Square start_move = move.start;
            PieceType type = pieces[start_move].piece_type;
            
            bool rank_is_ambibuous = false;
            bool file_is_ambibuous = false;
            for (File file = FILE_A; file <= FILE_H; file++)
            {
                Square curr_square = SQUARE (file, start_move.rank);
                if (curr_square == move.start)
                    continue;
                if (pieces[curr_square].piece_type == type &&
                    is_legal_move(MOVE(curr_square, move.end)))
                {
                    file_is_ambibuous = true;
                }
            }
            for(Rank rank = RANK_1; rank <= RANK_8; rank++)
            {
                Square curr_square = SQUARE (start_move.file, rank);
                if (curr_square == move.start)
                    continue;
                if (pieces[curr_square].piece_type == type &&
                    is_legal_move(MOVE(curr_square, move.end)))
                {
                    rank_is_ambibuous = true;
                }
            }
            return rank_is_ambibuous && file_is_ambibuous;
        }
  
        private Square ambiguous_piece (Move move)
        {
            Square start_square = move.start;
            PieceType type = pieces[start_square].piece_type;

            for(Square square = Squares.SQ_A1; square <= Squares.SQ_H8; square++)
            {
                if (square == start_square)
                    continue;
                if (pieces[square].piece_type == type &&
                    is_legal_move(MOVE(square, move.end)))
                    return square;
            }	

            return NULL_SQUARE;
        }

        public bool in_double_check (Player p)
        {
            Square king_location = king[p];
            
            return exist_two_piece_looking_at (king_location, p.other());
        }

        public bool checkmate (Player p)
        {
            // We must be in check
            if (!in_check(p))
                return false;

            Square king_location = king[p];
            Player other = p.other();
            int x = king_location.x;
            int y = king_location.y;

            // Can the king move out of check?
            for (int dx = -1; dx < 2; dx++) 
            {
                for (int dy = -1; dy < 2; dy++) 
                {
                    File file = (File)(x + dx);
                    Rank rank = (Rank)(y + dy);
                    if (file < 0 || file >= 8 ||
                        rank < 0 || rank >= 8 || (dx == 0 && dy == 0))
                        continue;
                    Move m = MOVE(king_location, SQUARE(file, rank));
                    if (is_legal_move (m))
                    {
                        return false;
                    }
                }
            }

            // King cannot move, if is in double check, it is checkmake,
            // is impossible block or capture 2 pieces in 1 move
            if (in_double_check (p))
                return true;


            // Can the attacking piece be captured?
            // Created a function to check a legal move attack.
            Square attacker = find_piece_looking_at (king_location, other);
            if (under_legal_move_attack (attacker, p))
            {
                return false;
            }

            // Can we block?
            PieceType type = pieces[attacker].piece_type;
            if (type != KNIGHT) {
                int dx = attacker.x - x;
                int dy = attacker.y - y;

                int ax = dx.abs();
                int ay = dy.abs();

                int x_direction = ax == 0 ? 0 : dx / ax;
                int y_direction = ay == 0 ? 0 : dy / ay;

                int xp = (king_location.x + x_direction);
                int yp = (king_location.y + y_direction);
                while (!(xp == attacker.x &&
                            yp == attacker.y)) 
                {
                    Square blocker = find_piece_looking_at(SQUARE((File)xp, (Rank)yp), p);
                    if (blocker != NULL_SQUARE &&
                        pieces[blocker].piece_type != PieceType.KING)
                        return false;

                    xp += x_direction;
                    yp += y_direction;
                }
            }

            // All outta luck
            return true;
        }
        
        private bool exist_two_piece_looking_at (Square square, Player piece_owner)
        {
            int8 check_count = 0;
            for(Square s = Squares.SQ_A1; s <= Squares.SQ_H8; s++)
            {
                Piece p = pieces[s];
                if (p == EMPTY || p.player != piece_owner)
                    continue;
                Move m = MOVE(s, square);

                if (pseudo_legal_move(m))
                    check_count++;
            }
            return check_count >= 2;
        }

        private PieceType decode_piece_type (char c)
        {
            switch (c)
            {
            case 'R':
                return PieceType.ROOK;
            case 'N':
                return PieceType.KNIGHT;
            case 'B':
                return PieceType.BISHOP;
            case 'Q':
                return PieceType.QUEEN;
            case 'K':
                return PieceType.KING;
            default:
                return PieceType.PAWN;
            }
        }

        public Move decode_notation (string notation)
        {
            int i = 0;
            if (notation.has_prefix ("O-O-O"))
            {
                Rank rank = turn == WHITE ? RANK_WHITE_CASTLE : RANK_BLACK_CASTLE;
                return MOVE(SQUARE(FILE_E, rank), SQUARE(FILE_C, rank));
            }
            else if (notation.has_prefix ("O-O"))
            {
                Rank rank = turn == WHITE ? RANK_WHITE_CASTLE : RANK_BLACK_CASTLE;
                return MOVE(SQUARE(FILE_E, rank), SQUARE(FILE_G, rank));
            }

            PieceType type = decode_piece_type(notation[i]);
            if (type != PieceType.PAWN)
                i++;

            Piece piece_moved = PIECE(turn, type);

            File start_file = FILE_INVALID;
            Rank start_rank = RANK_INVALID;
            File end_file = FILE_INVALID;
            Rank end_rank = RANK_INVALID;
            PieceType promotion_type = PieceType.QUEEN;

            if ('a' <= notation[i] <= 'h')
            {
                end_file = File.from_char(notation[i]);
                i++;
            }
            if ('1' <= notation[i] <= '8')
            {
                end_rank = Rank.from_char(notation[i]);
                i++;
            }
            if (notation[i] == 'x' || notation[i] == '-')
                i++;
            if ('a' <= notation[i] <= 'h')
            {
                start_file = end_file;
                end_file = File.from_char(notation[i]);
                i++;
            }
            if ('1' <= notation[i] <= '8')
            {
                start_rank = end_rank;
                end_rank = Rank.from_char(notation[i]);
                i++;
            }
            if (notation[i] == '=')
            {
                i++;
                promotion_type = decode_piece_type(notation[i]);
                if (!is_promotable(promotion_type))
                    return NULL_MOVE;
                i++;         
            }
            while (notation[i] == '+' || notation[i] == '#' || notation[i] == '!' || notation[i] == '?')
            {
                i++;
            }
            if (notation[i] != '\0')
            {
                return NULL_MOVE;
            }

            if (end_file == FILE_INVALID || end_rank == RANK_INVALID)
            {
                return NULL_MOVE;
            }

            Square end = SQUARE(end_file, end_rank);    
            if (start_file == FILE_INVALID && start_rank == RANK_INVALID)
            {
                for (Square start = Squares.SQ_A1; start <= Squares.SQ_H8; start++) 
                {
                    if (pieces[start] != piece_moved)
                        continue;
                    Move move = PROMOTE(MOVE(start, end), promotion_type);
                    if (is_legal_move(move))
                        return move;
                }
                return NULL_MOVE;
            }
            else if (start_rank == RANK_INVALID)
            {
                for (start_rank = RANK_1; start_rank <= RANK_8; start_rank++) 
                {
                    Square start = SQUARE(start_file, start_rank);
                    if (pieces[start] != piece_moved)
                        continue;
                    Move move = PROMOTE(MOVE(start, end), promotion_type);
                    if (is_legal_move(move))
                        return move;
                }
                return NULL_MOVE;
            }
            else if (start_file == FILE_INVALID)
            {
                for (start_file = FILE_A; start_file <= FILE_H; start_file++) 
                {
                    Square start = SQUARE(start_file, start_rank);
                    if (pieces[start] != piece_moved)
                        continue;
                    Move move = PROMOTE(MOVE(start, end), promotion_type);
                    if (is_legal_move(move))
                        return move;
                }
                return NULL_MOVE;
            }
            
            return PROMOTE(MOVE(SQUARE(start_file, start_rank), SQUARE(end_file, end_rank)), promotion_type);
        }
    }

    public const string START_BOARD_FEN =
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

    private static bool is_piece (char c)
    {
        return c == 'r' || c == 'n' || c == 'b' || c == 'q' || c == 'k' || c == 'p'
            || c == 'R' || c == 'N' || c == 'B' || c == 'Q' || c == 'K' || c == 'P';
    }

    private static bool is_number_fen_rank (char c)
    {
        return ('1' <= c && c <= '8');
    }

    private static bool is_promotable(PieceType type)
    {
        return (KNIGHT <= type <= QUEEN);
    }

    public enum Squares 
    {
        SQ_A1, SQ_B1, SQ_C1, SQ_D1, SQ_E1, SQ_F1, SQ_G1, SQ_H1,
        SQ_A2, SQ_B2, SQ_C2, SQ_D2, SQ_E2, SQ_F2, SQ_G2, SQ_H2,
        SQ_A3, SQ_B3, SQ_C3, SQ_D3, SQ_E3, SQ_F3, SQ_G3, SQ_H3,
        SQ_A4, SQ_B4, SQ_C4, SQ_D4, SQ_E4, SQ_F4, SQ_G4, SQ_H4,
        SQ_A5, SQ_B5, SQ_C5, SQ_D5, SQ_E5, SQ_F5, SQ_G5, SQ_H5,
        SQ_A6, SQ_B6, SQ_C6, SQ_D6, SQ_E6, SQ_F6, SQ_G6, SQ_H6,
        SQ_A7, SQ_B7, SQ_C7, SQ_D7, SQ_E7, SQ_F7, SQ_G7, SQ_H7,
        SQ_A8, SQ_B8, SQ_C8, SQ_D8, SQ_E8, SQ_F8, SQ_G8, SQ_H8,
        SQ_NONE,

        SQUARE_NB = 64
    }
}