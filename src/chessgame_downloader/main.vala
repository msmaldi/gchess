using GChess;

void download_game (int gid)
{
    string url = "http://www.chessgames.com/perl/chessgame?gid=%d".printf(gid);
    // create an HTTP session to twitter
    Soup.Session session = null;
    Soup.Message message = null;

    string result = null;
    do {
        session = new Soup.Session ();
        message = new Soup.Message ("GET", url);

        session.send_message (message);

        result = (string)message.response_body.data;      
        print("Problem to download Page %d\n", gid);  
    } while (result == null);

    Regex regex = new Regex("<a href=\"/pgn/(.*?)\">download</a>");
    var splited = regex.split(result);

    if (splited.length < 2)
    {
        print ("Not found game %d\n", gid);
        return;
    }
    var url_game = "http://www.chessgames.com/pgn/%s".printf(splited[1]);
    print (url_game);
    print ("\n");


    string pgn_name = splited[1].replace(".pgn?", "_").replace("=", "_").concat(".pgn");
    string pgn_content = null;
    do
    {
        message = new Soup.Message("GET", url_game);
        // send the HTTP request and wait for response
        session.send_message (message);

        pgn_content = (string)message.response_body.data;
        print("Problem to download PGN %d\n", gid);
    } while (pgn_content == null);

    try
    {
        var file = GLib.File.new_for_path ("/home/msmaldi/Documents/pgn/%s".printf(pgn_name));
        {
            // Test for the existence of file
            if (file.query_exists ()) {
                print("PGN exists %d\n", gid);
            }
            else
            {
                // Create a new file with this name
                var file_stream = file.create (FileCreateFlags.REPLACE_DESTINATION);

                // Write text data to file
                var data_stream = new DataOutputStream (file_stream);
                data_stream.put_string (pgn_content);
            }
        }
    }
    catch
    {
        print ("Error\n");
    }
}

void main(string[] args) 
{
    if (args.length != 3)
    {
        print ("U need pass 2 paremeters.\n");

        return; 
    }

    int gid = int.parse(args[1]);
    int count = int.parse(args[2]);

    Timer timer = new Timer ();
    double seconds = 0.0;
    for (int i = 0; i < count; i++) 
    {
        download_game (gid + i);
        double downloaded = (double)(i + 1);
        seconds = timer.elapsed();
        double games_per_seconds = downloaded / seconds;
        double games_per_minutes = games_per_seconds * 60;

        double restante_minutes = (((double)count) - downloaded) / games_per_minutes;

        print("%.2lf Per Minutes, %.2lf Restantes\n", games_per_minutes, restante_minutes);
    }    
}