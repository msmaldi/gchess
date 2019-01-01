using GLib;
using GChess;

int error = 0;
int success = 0;
uint ply = 0;

int main()
{
    string path = "/home/msmaldi/Documents/new_pgn/pgn/";//"../data/pgn/";
    string? name = null;
    try
    {
        Dir dir = Dir.open (path, 0);

        while ((name = dir.read_name()) != null)
        {
            string content = null;
            GLib.FileUtils.get_contents("%s%s".printf(path, name), out content);
            try
            {
                PGN pgn = new PGN.from_string(content);
                try
                {
                    Game game = new Game.from_pgn_game(pgn.games.data);

                    if (game.ply() != pgn.games.data.moves.length())
                    {
                        error++;
                        print("Ply count error %u != %u\n", game.ply(), pgn.games.data.moves.length());
                    }

                    ply += game.ply();
                    success++;
                }
                catch (GameError e)
                {
                    error++;
                    print("Error %d -> %s -> %s\n", error, name, e.message);
                }
            }
            catch (PGNError e)
            {
                error++;
                print("Error %d -> %s ---> %s\n", error, name, e.message);
            }
            
        }
    }
    catch (Error e)
    {
        error++;
        print("%s %s", name, e.message);
    }

    print ("Game Success read: %d\n", success);
    print ("Total moves parsed: %u\n", ply);

    return error == 0 ? 0 : 1;
}