namespace GChess 
{
    [SimpleType]
    [CCode (cname = "File", has_type_id = false)]
    public struct File : int8 
    {
        public char to_char () { return 'a' + (this); }
        public static File from_char (char c) 
        { 
            return (File)(c - 'a'); 
        }
    }

    public const File FILE_A = 0;
    public const File FILE_B = 1;
    public const File FILE_C = 2;
    public const File FILE_D = 3;
    public const File FILE_E = 4;
    public const File FILE_F = 5;
    public const File FILE_G = 6;
    public const File FILE_H = 7;
    public const File FILE_INVALID = 8;

    public const File FILE_CASTLE_KINGSIDE = FILE_G;
    public const File FILE_CASTLE_QUEENSIDE = FILE_C;
}