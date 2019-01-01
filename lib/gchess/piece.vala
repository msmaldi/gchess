namespace GChess 
{
    [CCode (has_type_id = false)]
    public enum PieceType
    {
        EMPTY,
	    PAWN,
	    KNIGHT,
	    BISHOP,
	    ROOK,
	    QUEEN,
	    KING
    }

    [SimpleType]
    [CCode (cname = "Piece", has_type_id = false)]
    public struct Piece : uint8
    {
        public Player player { get { return ((Player)(this >> 7)); }}
        public PieceType piece_type { get { return ((PieceType)((this) & ~(1 << 7))); }}
        public bool is_promotable
        {
            get
            {
                PieceType type = this.piece_type;
                return (KNIGHT <= type <= QUEEN);
            }
        }

        public static Piece from_char (char c)
        {
            switch (c)
            {
                case 'P': return WHITE_PAWN;
                case 'N': return WHITE_KNIGHT;
                case 'B': return WHITE_BISHOP;
                case 'R': return WHITE_ROOK;
                case 'Q': return WHITE_QUEEN;
                case 'K': return WHITE_KING;
                case 'p': return BLACK_PAWN;
                case 'n': return BLACK_KNIGHT;
                case 'b': return BLACK_BISHOP;
                case 'r': return BLACK_ROOK;
                case 'q': return BLACK_QUEEN;
                case 'k': return BLACK_KING;
                default: return EMPTY;
            }
        }

        public char to_char()
        {
            switch ((uint8)this)
            {
                case WHITE_PAWN:   return 'P';
                case WHITE_KNIGHT: return 'N';
                case WHITE_BISHOP: return 'B';
                case WHITE_ROOK:   return 'R';
                case WHITE_QUEEN:  return 'Q';
                case WHITE_KING:   return 'K';
                case BLACK_PAWN:   return 'p';
                case BLACK_KNIGHT: return 'n';
                case BLACK_BISHOP: return 'b';
                case BLACK_ROOK:   return 'r';
                case BLACK_QUEEN:  return 'q';
                case BLACK_KING:   return 'k';
                default:           return ' ';
            }
        }
    }

    public Piece PIECE (Player player, PieceType pieceType)
    {
        return ((Piece)(((player << 7) | (pieceType))));
    }

    public const Piece EMPTY = PieceType.EMPTY;
    public const Piece PAWN = PieceType.PAWN;
    public const Piece KNIGHT = PieceType.KNIGHT;
    public const Piece BISHOP = PieceType.BISHOP;
    public const Piece ROOK = PieceType.ROOK;
    public const Piece QUEEN = PieceType.QUEEN;
    public const Piece KING = PieceType.KING;

    public const Piece WHITE_PAWN = ((Piece)(((WHITE << 7) | (PAWN))));
    public const Piece WHITE_KNIGHT = ((Piece)(((WHITE << 7) | (KNIGHT))));
    public const Piece WHITE_BISHOP = ((Piece)(((WHITE << 7) | (BISHOP))));
    public const Piece WHITE_ROOK = ((Piece)(((WHITE << 7) | (ROOK))));
    public const Piece WHITE_QUEEN = ((Piece)(((WHITE << 7) | (QUEEN))));
    public const Piece WHITE_KING = ((Piece)(((WHITE << 7) | (KING))));

    public const Piece BLACK_PAWN = ((Piece)(((BLACK << 7) | (PAWN))));
    public const Piece BLACK_KNIGHT = ((Piece)(((BLACK << 7) | (KNIGHT))));
    public const Piece BLACK_BISHOP = ((Piece)(((BLACK << 7) | (BISHOP))));
    public const Piece BLACK_ROOK = ((Piece)(((BLACK << 7) | (ROOK))));
    public const Piece BLACK_QUEEN = ((Piece)(((BLACK << 7) | (QUEEN))));
    public const Piece BLACK_KING = ((Piece)(((BLACK << 7) | (KING))));
    
    public const Piece NULL_PIECE = (Piece)255;
}