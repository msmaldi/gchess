using GChess;

int error = 0;
int main ()
{
    Square e2 = Squares.SQ_E2;
    Square e4 = Squares.SQ_E4;
    PieceType type = PieceType.QUEEN;

    Move e2e4 = PROMOTE(MOVE(e2, e4), type);

    Square e2_e = e2e4.start;
    Square e4_e = e2e4.end;
    PieceType type_e = e2e4.promotion;

    if (e2 != e2_e)
    {
        error++;
    }
    else if (e4 != e4_e)
    {
        error++;
    }
    else if (type != type_e)
    {
        error++;
    }

    return error == 0 ? 0 : 1;
}