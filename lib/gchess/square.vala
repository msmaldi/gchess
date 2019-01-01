namespace GChess 
{
    [SimpleType]
    [CCode (cname = "Square", has_type_id = false)]
    public struct Square : int8
    {
        public File x { get { return this & 0x7; } }
        public Rank y { get { return this >> 3; } }
        public File file { get { return x; } }
        public Rank rank { get { return y; } }

        public new string to_string()
        {
            string s = "%c%c".printf(x.to_char(), y.to_char());
            return s;
        }
    }

    public static Square SQUARE (File file, Rank rank)
    {
        return ((Square)(((rank) << 3) | (file)));
    }

    public const Square NULL_SQUARE = (Square)(-1);

}