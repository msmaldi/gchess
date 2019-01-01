namespace GChess
{
    public errordomain GameError
    {
        PARSE_ERROR;
    }

    public class GameNode
    {
        public Move move;
        public Board board;

        public GameNode(Move m = NULL_MOVE)
        {
            move = m;
            board = {};
        }

        public GameNode.with_start_fen()
        {
            this();
            try
            {
                Board.from_fen(out board, START_BOARD_FEN);
            }
            catch
            {                
            }
        }

        public GameNode.with_fen(string fen) throws Error
        {
            this();
            Board.from_fen(out board, fen);
        }

        ~GameNode()
        {
        }
    }

    public class Game
    {
        public GameNode current { get { return nodes.data; } }
        public List<GameNode> nodes;

        public GameNode last() 
        {
            return nodes.last().data;
        }

        public uint ply()
        {
            return nodes.length() - 1;
        }

        public Game()
        {
            nodes = new List<GameNode>();
        }

        public Game.with_start_fen()
        {
            this();
            nodes.append(new GameNode.with_start_fen());
        }

        public Game.with_fen(string fen) throws Error
        {
            this();
            nodes.append(new GameNode.with_fen(fen));
        }

        public Game.from_pgn_game(PGNGame pgn_game) throws GameError, Error
        {
            this();            
            if (pgn_game.fen == null)
                nodes.append(new GameNode.with_start_fen());
            else
                nodes.append(new GameNode.with_fen(pgn_game.fen));

            foreach (var move in pgn_game.moves) 
            {
                Move m = last() .board.decode_notation(move);

                if (m != NULL_MOVE)
                {
                    add_child(m);
                }
                else
                {
                    throw new GameError.PARSE_ERROR ("Error to parse: %s", move);
                }
            }
        }

        public void add_child(Move move)
        {
            GameNode children = new GameNode(move);

            last().board.copy(&children.board);
            children.board.performe_move(move);

            nodes.append(children);            
        }

        ~Game()
        {
        }
    }
}