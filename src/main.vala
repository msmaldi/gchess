using GChess;

List<PGN> pgns;

void read_all_pgn_file(string path)
{
    pgns = new List<PGN>();
    try
    {
        string? name = null;
        try
        {
            Dir dir = Dir.open (path, 0);

            while ((name = dir.read_name()) != null)
            {
                string content = null;
                GLib.FileUtils.get_contents("%s%s".printf(path, name), out content);
                PGN pgn = new PGN.from_string(content);

                pgns.append(pgn);
            }
        }
        catch (GameError e)
        {
            print("Error %s\n", name);
        }
    }
    catch (Error e)
    {
        print (e.message);
    }
}

void another_main()
{
    string path = "/home/msmaldi/Documents/pgn/";

    print ("Reading all files in %s...", path);
    read_all_pgn_file (path);
    print ("OK\n");
    print ("Total files: %u\n", pgns.length());

    HashTable<string, List<PGN>> group_by_event = new HashTable<string, List<PGN>>(str_hash, str_equal);

    foreach (var pgn in pgns) 
    {
        foreach (var game in pgn.games) 
        {
            var event = game.event;
            unowned List<PGN> event_pgns = null; 
            if (group_by_event.contains(event))
            {
                event_pgns = group_by_event.get(event);
            }
            else
            {
                group_by_event.insert(event, new List<PGN>());
                event_pgns = group_by_event.get(event);
            }
        }        
    }

    print ("Total groups: %u\n", group_by_event.size());

    foreach (var events in group_by_event.get_keys()) 
    {
    }
}

void main ()
{   
    try 
    {
        PGN pgn = new PGN.from_path("/home/msmaldi/Downloads/WCC 2018/wcc_2018.pgn");
                
        GLib.File file = GLib.File.new_for_path ("/home/msmaldi/Downloads/WCC 2018/wcc_2018_clone.pgn");
        if (file.query_exists ()) {
            file.delete();
        }
        pgn.export_file(file);
    }
    catch (Error e)
    {
        print (e.message);
    }

}