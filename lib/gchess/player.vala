namespace GChess 
{ 
    public enum Players
    {
        WHITE, BLACK
    }

    [SimpleType]
    [CCode (cname = "Player", has_type_id = false)]
    public struct Player : uint8
    {
        public Player other() { return this == Players.WHITE ? Players.BLACK : Players.WHITE; }
    }
    
    public const Player WHITE = Players.WHITE;
    public const Player BLACK = Players.BLACK;  
}

