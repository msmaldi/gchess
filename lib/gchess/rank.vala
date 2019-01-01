namespace GChess 
{
    [SimpleType]
    [CCode (cname = "Rank", has_type_id = false)]
    public struct Rank : int8 
    {
        public char to_char () { return '1' + (this); }
        public static Rank from_char (char c)
        {
            return (Rank)(c - '1');
        }
    }

    public const Rank RANK_1 = 0;
    public const Rank RANK_2 = 1;
    public const Rank RANK_3 = 2;
    public const Rank RANK_4 = 3;
    public const Rank RANK_5 = 4;
    public const Rank RANK_6 = 5;
    public const Rank RANK_7 = 6;
    public const Rank RANK_8 = 7;
    public const File RANK_INVALID = 8;

    public const Rank RANK_WHITE_PAWN = RANK_2;
    public const Rank RANK_BLACK_PAWN = RANK_7;

    public const Rank RANK_WHITE_PROMOTION = RANK_8;
    public const Rank RANK_BLACK_PROMOTION = RANK_1;

    public const Rank RANK_WHITE_CASTLE = RANK_1;
    public const Rank RANK_BLACK_CASTLE = RANK_8;
}