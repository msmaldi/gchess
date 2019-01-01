using FileUtils;

namespace GChess 
{ 
    public class PGNGame
    {
        public static string RESULT_IN_PROGRESS = "*";
        public static string RESULT_DRAW        = "1/2-1/2";
        public static string RESULT_WHITE       = "1-0";
        public static string RESULT_BLACK       = "0-1";

        public HashTable<string, string> tags;
        public List<string> moves;

        // Seven Tag Roster
        public string event
        {
            get { return tags.lookup ("Event"); }
            set { tags.insert ("Event", value); }
        }
        public string site
        {
            get { return tags.lookup ("Site"); }
            set { tags.insert ("Site", value); }
        }
        public string date
        {
            get { return tags.lookup ("Date"); }
            set { tags.insert ("Date", value); }
        }
        public string round
        {
            get { return tags.lookup ("Round"); }
            set { tags.insert ("Round", value); }
        }
        public string white
        {
            get { return tags.lookup ("White"); }
            set { tags.insert ("White", value); }
        }
        public string black
        {
            get { return tags.lookup ("Black"); }
            set { tags.insert ("Black", value); }
        }
        public string result
        {
            get { return tags.lookup ("Result"); }
            set { tags.insert ("Result", value); }
        }

        // Another Tags
        public string? fen
        {
            get { return tags.lookup ("FEN"); }
            set { tags.insert ("FEN", value); }
        }

        public PGNGame ()
        {
            tags = new HashTable<string, string> (str_hash, str_equal);
            tags.insert ("Event", "?");
            tags.insert ("Site", "?");
            tags.insert ("Date", "????.??.??");
            tags.insert ("Round", "?");
            tags.insert ("White", "?");
            tags.insert ("Black", "?");
            tags.insert ("Result", PGNGame.RESULT_IN_PROGRESS);
        }

        public string escape (string value)
        {
            var a = value.replace ("\\", "\\\\");
            return a.replace ("\"", "\\\"");
        }
    }

    public errordomain PGNError
    {
        LOAD_ERROR
    }

    enum State
    {
        TAGS,
        MOVE_TEXT,
        LINE_COMMENT,
        BRACE_COMMENT,
        TAG_START,
        TAG_NAME,
        PRE_TAG_VALUE,
        TAG_VALUE,
        POST_TAG_VALUE,
        SYMBOL,
        PERIOD,
        NAG,
        ERROR
    }

    public class PGN
    {
        public List<PGNGame> games;

        private void insert_tag (PGNGame game, string tag_name, string tag_value)
        {
            game.tags.insert (tag_name, tag_value);
        }

        public PGN.from_string (string data) throws PGNError
        {
            State state = State.TAGS, home_state = State.TAGS;
            PGNGame game = new PGNGame ();
            bool in_escape = false;
            size_t token_start = 0, line_offset = 0;
            string tag_name = "";
            StringBuilder tag_value = new StringBuilder ();
            int line = 1;
            int rav_level = 0;
            for (long offset = 0; offset <= data.length; offset++)
            {
                unichar c = data.get_char(offset);

                if (c == '\n')
                {
                    line++;
                    line_offset = offset + 1;
                }

                switch (state)
                {
                case State.TAGS:
                    home_state = State.TAGS;
                    if (c == ';')
                        state = State.LINE_COMMENT;
                    else if (c == '{')
                        state = State.BRACE_COMMENT;
                    else if (c == '[')
                        state = State.TAG_START;
                    else if (!c.isspace ())
                    {
                        offset--;
                        state = State.MOVE_TEXT;
                        continue;
                    }
                    break;

                case State.MOVE_TEXT:
                    home_state = State.MOVE_TEXT;
                    if (c.isspace ())
                        continue;
                    else if (c == ';')
                        state = State.LINE_COMMENT;
                    else if (c == '{')
                        state = State.BRACE_COMMENT;
                    else if (c == '*')
                    {
                        if (rav_level == 0)
                        {
                            game.result = PGNGame.RESULT_IN_PROGRESS;
                            games.append (game);
                            game = new PGNGame ();
                            state = State.TAGS;
                        }
                    }
                    else if (c == '.')
                    {
                        offset--;
                        state = State.PERIOD;
                    }
                    else if (c.isalnum ())
                    {
                        token_start = offset;
                        state = State.SYMBOL;
                    }
                    else if (c == '$')
                    {
                        token_start = offset + 1;
                        state = State.NAG;
                    }
                    else if (c == '(')
                    {
                        rav_level++;
                        continue;
                    }
                    else if (c == ')')
                    {
                        if (rav_level == 0)
                            state = State.ERROR;
                        else
                            rav_level--;
                    }
                    else
                        state = State.ERROR;
                    break;

                case State.LINE_COMMENT:
                    if (c == '\n')
                        state = home_state;
                    break;

                case State.BRACE_COMMENT:
                    if (c == '}')
                        state = home_state;
                    break;

                case State.TAG_START:
                    if (c.isspace ())
                        continue;
                    else if (c.isalnum ())
                    {
                        token_start = offset;
                        state = State.TAG_NAME;
                    }
                    else
                        state = State.ERROR;
                    break;

                case State.TAG_NAME:
                    if (c.isspace ())
                    {
                        tag_name = data[(long) token_start:(long) offset];
                        state = State.PRE_TAG_VALUE;
                    }
                    else if (c.isalnum () || c == '_' || c == '+' || c == '#' || c == '=' || c == ':' || c == '-')
                        continue;
                    else
                        state = State.ERROR;
                    break;

                case State.PRE_TAG_VALUE:
                    if (c.isspace ())
                        continue;
                    else if (c == '"')
                    {
                        state = State.TAG_VALUE;
                        tag_value.erase ();
                        in_escape = false;
                    }
                    else
                        state = State.ERROR;
                    break;

                case State.TAG_VALUE:
                    if (c == '\\' && !in_escape)
                        in_escape = true;
                    else if (c == '"' && !in_escape)
                        state = State.POST_TAG_VALUE;
                    else 
                    {
                        tag_value.append_unichar (c);
                        in_escape = false;  
                    }
                    //  else if (c.isprint ())
                    //  {
                    //      tag_value.append_unichar (c);
                    //      in_escape = false;
                    //  }
                    //  else
                    //      state = State.ERROR;
                    break;

                case State.POST_TAG_VALUE:
                    if (c.isspace ())
                        continue;
                    else if (c == ']')
                    {
                        insert_tag (game, tag_name, tag_value.str);
                        state = State.TAGS;
                    }
                    else
                        state = State.ERROR;
                    break;

                case State.SYMBOL:
                    /* NOTE: '/' not in spec but required for 1/2-1/2 symbol */
                    if (c.isalnum () || c == '_' || c == '+' || c == '#' || c == '=' || c == ':' || c == '-' || c == '/' || c == '!' || c == '?')
                        continue;
                    else
                    {
                        string symbol = data[(long) token_start:(long) offset];

                        bool is_number = true;
                        for (int i = 0; i < symbol.length; i++)
                        if (!symbol[i].isdigit ())
                            is_number = false;

                        state = State.MOVE_TEXT;
                        offset--;

                        /* Game termination markers */
                        if (symbol == PGNGame.RESULT_DRAW || symbol == PGNGame.RESULT_WHITE || symbol == PGNGame.RESULT_BLACK)
                        {
                            if (rav_level == 0)
                            {
                                game.result = symbol;
                                games.append (game);
                                game = new PGNGame ();
                                state = State.TAGS;
                            }
                        }
                        else if (!is_number)
                        {
                            if (rav_level == 0)
                                game.moves.append (symbol);
                        }
                    }
                    break;

                case State.PERIOD:
                    /* FIXME: Should check these move carefully, e.g. "1. e2" */
                    state = State.MOVE_TEXT;
                    break;

                case State.NAG:
                    if (c.isdigit ())
                        continue;
                    else
                    {
                        state = State.MOVE_TEXT;
                        offset--;
                    }
                    break;

                case State.ERROR:
                    size_t char_offset = offset - line_offset - 1;
                    //stderr.printf ("%d.%d: error: Unexpected character\n", line, (int) (char_offset + 1));
                    //stderr.printf ("%s\n", data[(long) line_offset:(long) offset]);
                    //for (int i = 0; i < char_offset; i++)
                    //    stderr.printf (" ");
                    //stderr.printf ("^\n");
                    //return;
                    throw new PGNError.LOAD_ERROR ("%d.%d: error: Unexpected character\n", line, (int) (char_offset + 1));
                }
            }

            if (game.moves.length () > 0)
            {
                games.append (game);
            }

            /* Must have at least one game */
            if (games == null)
                throw new PGNError.LOAD_ERROR ("No games in PGN file");
        }

        //public PGN.from_file (GLib.File file) throws Error
        //{
        //    uint8[] contents = null;
        //    file.load_contents (null, out contents, null);
        //    this.from_string ((string) contents);
        //}

        public PGN.from_path (string path) throws PGNError, Error
        {
            string contents = null;
            get_contents(path, out contents);
            this.from_string (contents);
        }

        private void write_tag_if_exist (DataOutputStream data_stream, PGNGame game, string tag_name)
            throws GLib.IOError
        {
            if (game.tags.contains(tag_name))
            {
                string tag_value = game.tags.lookup (tag_name);
                string encoded_tag = "[%s \"%s\"]\n".printf(tag_name, tag_value.replace("\"", "\\\""));
                data_stream.put_string (encoded_tag);
            }
        }

        private void write_tags (DataOutputStream data_stream, PGNGame game)
            throws GLib.IOError
        {
            string tag_name = null;
            for (int i = 0; (tag_name = tag_order[i]) != null; i++)
            {
                write_tag_if_exist (data_stream, game, tag_name);
            }
        }

        public void write_moves (DataOutputStream data_stream, PGNGame game, int max_line_length = 62)
            throws GLib.IOError
        {
            int i = 1;
            bool is_white = true;
            int line_length = 0;
            bool first_move = true;
            foreach (var move in game.moves) 
            {
                string encoded_move = null;
                if (is_white)
                {
                    is_white = false;
                    encoded_move = "%d.%s".printf(i, move);
                }
                else
                {
                    is_white = true;
                    encoded_move = "%s".printf(move);
                    i++;                
                }
                line_length += encoded_move.length;
                if (line_length > max_line_length)
                {
                    line_length = encoded_move.length;
                    data_stream.put_string ("\n");
                    data_stream.put_string (encoded_move);
                    //data_stream.put_string (" ");
                    line_length++;
                }
                else
                {
                    if (first_move)
                    {
                        first_move = false;
                    }
                    else
                    {
                        data_stream.put_string (" ");
                    }
                    data_stream.put_string (encoded_move);
                    line_length++;
                }
            }
            string result = game.result;
            line_length += result.length;
            if (line_length > max_line_length)
            {
                data_stream.put_string ("\n");
                data_stream.put_string (game.result);
            }
            else
            {
                data_stream.put_string (" ");
                data_stream.put_string (game.result);
            }
        }

        public void export_file (GLib.File file) throws GLib.IOError
        {
            var file_stream = file.create (FileCreateFlags.NONE);

            var data_stream = new DataOutputStream (file_stream);

            bool first_game = true;
            foreach (var game in games) 
            {
                if (first_game)
                {
                    first_game = false;
                }
                else
                {
                    data_stream.put_string ("\n\n\n");
                }
                write_tags (data_stream, game);
                data_stream.put_string ("\n");
                write_moves (data_stream, game);

            }
        }
    }

    const string[] tag_order = 
    {
        "Event",
        "Site",
        "Date",
        "EventDate",
        "Round",
        "Result",
        "White",
        "Black",
        "ECO",
        "WhiteElo",
        "BlackElo",
        "PlyCount",
        null
    };
}
