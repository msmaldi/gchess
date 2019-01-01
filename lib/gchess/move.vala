namespace GChess 
{
    // A move is represented as 4 bytes, represented by:
    //
    //  |    1 bytes    |    1 bytes    |    1 bytes    |    1 bytes    |
    //  32--------------24--------------16--------------8---------------0
    //  |     empty     |   Piece Type  |  Square Start |  Square end   |
    //
    // Default PieceType to promote is QUEEN, if you want change, use
    // PROMOTE to change piece.

    // TODO: can be otimized for use only 16 bits (2 bytes)
    // TODO: castling in chess960

    [SimpleType]
    [CCode (cname = "Move", has_type_id = false)]
    public struct Move : int32
    {
        public Square start { get { return ((Square)(((this) & 0xFFF) >> 6)); } }
        public Square end { get { return ((Square)((this) & 0x3F)); } }
        public PieceType promotion { get { return ((PieceType) (((this & 0x3FFF) >> 12) + 2)); } }

        public new string to_string()
        {
            return "Start: %c%c End %c%c".printf(start.x.to_char(), start.y.to_char(), end.x.to_char(), end.y.to_char());
        }
    }

    public Move MOVE (Square start, Square end)
    {
        return ((start << 6) | end);
    }

    public Move PROMOTE (Move move, PieceType type)
    {
        return ((Move)(((type - 2) << 12) | (move & 0xFFF)));
    }

    public Move CASTLING (Move move)
    {
        return ((Move)((3 << 14) | (move & 0x3FFF)));
    }

    public const Move NULL_MOVE = ((Move)(~((Move)0)));    
}