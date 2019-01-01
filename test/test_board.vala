// valac src/gchess/*.vala test/board_test.vala -o board_test && ./board_test

using GChess;

const string[] list_of_valid_fen = 
{
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
    "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
    "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2",
    "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
    "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
    "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
    "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/2P2N2/PP1P1PPP/RNBQK2R b KQkq - 0 4",
    "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2P2N2/PP1P1PPP/RNBQK2R w KQkq - 1 5",
    "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2PP1N2/PP3PPP/RNBQK2R b KQkq - 0 5",
    "r1bqk2r/ppp2ppp/2np1n2/2b1p3/2B1P3/2PP1N2/PP3PPP/RNBQK2R w KQkq - 0 6",
    "r1bqk2r/ppp2ppp/2np1n2/2b1p3/2B1P3/2PP1N2/PP3PPP/RNBQ1RK1 b kq - 1 6",
    "r1bqk2r/1pp2ppp/p1np1n2/2b1p3/2B1P3/2PP1N2/PP3PPP/RNBQ1RK1 w kq - 0 7",
    "r1bqk2r/1pp2ppp/p1np1n2/2b1p3/4P3/1BPP1N2/PP3PPP/RNBQ1RK1 b kq - 1 7",
    "r1bqk2r/1pp2pp1/p1np1n1p/2b1p3/4P3/1BPP1N2/PP3PPP/RNBQ1RK1 w kq - 0 8",
    "r1bqk2r/1pp2pp1/p1np1n1p/2b1p3/4P3/1BPP1N2/PP1N1PPP/R1BQ1RK1 b kq - 1 8",
    "r1bq1rk1/1pp2pp1/p1np1n1p/2b1p3/4P3/1BPP1N2/PP1N1PPP/R1BQ1RK1 w - - 2 9",
    "r1bq1rk1/1pp2pp1/p1np1n1p/2b1p3/4P3/1BPP1N2/PP1N1PPP/R1BQR1K1 b - - 3 9",
    "r1bq1rk1/bpp2pp1/p1np1n1p/4p3/4P3/1BPP1N2/PP1N1PPP/R1BQR1K1 w - - 4 10",
    "r1bq1rk1/bpp2pp1/p1np1n1p/4p3/4P3/1BPP1N2/PP3PPP/R1BQRNK1 b - - 5 10",
    "r2q1rk1/bpp2pp1/p1npbn1p/4p3/4P3/1BPP1N2/PP3PPP/R1BQRNK1 w - - 6 11",
    "r2q1rk1/bpp2pp1/p1npbn1p/4p3/4P3/1BPP1NN1/PP3PPP/R1BQR1K1 b - - 7 11",
    "r2qr1k1/bpp2pp1/p1npbn1p/4p3/4P3/1BPP1NN1/PP3PPP/R1BQR1K1 w - - 8 12",
    "r2qr1k1/bpp2pp1/p1npBn1p/4p3/4P3/2PP1NN1/PP3PPP/R1BQR1K1 b - - 0 12",
    "r2q2k1/bpp2pp1/p1nprn1p/4p3/4P3/2PP1NN1/PP3PPP/R1BQR1K1 w - - 0 13",
    "r2q2k1/bpp2pp1/p1nprn1p/4p3/4P3/2PPBNN1/PP3PPP/R2QR1K1 b - - 1 13",
    "r2q2k1/1pp2pp1/p1nprn1p/4p3/4P3/2PPbNN1/PP3PPP/R2QR1K1 w - - 0 14",
    "r2q2k1/1pp2pp1/p1nprn1p/4p3/4P3/2PPRNN1/PP3PPP/R2Q2K1 b - - 0 14",
    "r2q2k1/1pp2pp1/p1n1rn1p/3pp3/4P3/2PPRNN1/PP3PPP/R2Q2K1 w - - 0 15",
    "r2q2k1/1pp2pp1/p1n1rn1p/3pp3/4P3/1QPPRNN1/PP3PPP/R5K1 b - - 1 15",
    "1r1q2k1/1pp2pp1/p1n1rn1p/3pp3/4P3/1QPPRNN1/PP3PPP/R5K1 w - - 2 16",
    "1r1q2k1/1pp2pp1/p1n1rn1p/3pp3/4P3/1QPPRNNP/PP3PP1/R5K1 b - - 0 16",
    "1r4k1/1ppq1pp1/p1n1rn1p/3pp3/4P3/1QPPRNNP/PP3PP1/R5K1 w - - 1 17",
    "1r4k1/1ppq1pp1/p1n1rn1p/3pp3/4P3/1QPPRNNP/PP3PP1/4R1K1 b - - 2 17",
    "1r4k1/1ppq1pp1/p1n1rn1p/4p3/4p3/1QPPRNNP/PP3PP1/4R1K1 w - - 0 18",
    "1r4k1/1ppq1pp1/p1n1rn1p/4p3/4P3/1QP1RNNP/PP3PP1/4R1K1 b - - 0 18",
    "1r4k1/1ppq1pp1/p3rn1p/n3p3/4P3/1QP1RNNP/PP3PP1/4R1K1 w - - 1 19",
    "1r4k1/1ppq1pp1/p3rn1p/n3p3/4P3/2P1RNNP/PPQ2PP1/4R1K1 b - - 2 19",
    "3r2k1/1ppq1pp1/p3rn1p/n3p3/4P3/2P1RNNP/PPQ2PP1/4R1K1 w - - 3 20",
    "3r2k1/1ppq1pp1/p3rn1p/n3p3/4P3/1PP1RNNP/P1Q2PP1/4R1K1 b - - 0 20",
    "3r2k1/1ppq1p2/p3rnpp/n3p3/4P3/1PP1RNNP/P1Q2PP1/4R1K1 w - - 0 21",
    "3r2k1/1ppq1p2/p3rnpp/n3p3/4P3/1PP2NNP/P1Q1RPP1/4R1K1 b - - 1 21",
    "3r2k1/1ppq1p2/p1n1rnpp/4p3/4P3/1PP2NNP/P1Q1RPP1/4R1K1 w - - 2 22",
    "3r2k1/1ppq1p2/p1n1rnpp/4p3/4P3/1PP2N1P/P1Q1RPP1/4RNK1 b - - 3 22",
    "3r2k1/1ppq1p2/p1n1r1pp/4p2n/4P3/1PP2N1P/P1Q1RPP1/4RNK1 w - - 4 23",
    "3r2k1/1ppq1p2/p1n1r1pp/4p2n/4P3/1PP1NN1P/P1Q1RPP1/4R1K1 b - - 5 23",
    "3r2k1/1ppq1p2/p1n1r1pp/4p3/4Pn2/1PP1NN1P/P1Q1RPP1/4R1K1 w - - 6 24",
    "3r2k1/1ppq1p2/p1n1r1pp/4p3/4Pn2/1PP1NN1P/P1QR1PP1/4R1K1 b - - 7 24",
    "3r2k1/1ppq1p2/p1nr2pp/4p3/4Pn2/1PP1NN1P/P1QR1PP1/4R1K1 w - - 8 25",
    "3r2k1/1ppq1p2/p1nr2pp/4p3/4Pn2/1PP1NN1P/P1QR1PP1/3R2K1 b - - 9 25",
    "3r2k1/1pp2p2/p1nrq1pp/4p3/4Pn2/1PP1NN1P/P1QR1PP1/3R2K1 w - - 10 26",
    "3r2k1/1pp2p2/p1nrq1pp/4p3/1P2Pn2/2P1NN1P/P1QR1PP1/3R2K1 b - - 0 26",
    "3r4/1pp2pk1/p1nrq1pp/4p3/1P2Pn2/2P1NN1P/P1QR1PP1/3R2K1 w - - 1 27",
    "3r4/1pp2pk1/p1nrq1pp/4p3/PP2Pn2/2P1NN1P/2QR1PP1/3R2K1 b - a3 0 27",
    "3r4/1pp2pk1/p1n1q1pp/4p3/PP2Pn2/2P1NN1P/2Qr1PP1/3R2K1 w - - 0 28",
    "3r4/1pp2pk1/p1n1q1pp/4p3/PP2Pn2/2P1N2P/2QN1PP1/3R2K1 b - - 0 28",
    "3r4/1pp2pk1/p1n1q1p1/4p2p/PP2Pn2/2P1N2P/2QN1PP1/3R2K1 w - - 0 29",
    "3r4/1pp2pk1/p1n1q1p1/4p2p/PP2Pn2/2P1NN1P/2Q2PP1/3R2K1 b - - 1 29",
    "8/1pp2pk1/p1nrq1p1/4p2p/PP2Pn2/2P1NN1P/2Q2PP1/3R2K1 w - - 2 30",
    "8/1pp2pk1/p1nrq1p1/4p2p/PP2Pn1P/2P1NN2/2Q2PP1/3R2K1 b - - 0 30",
    "8/1ppq1pk1/p1nr2p1/4p2p/PP2Pn1P/2P1NN2/2Q2PP1/3R2K1 w - - 1 31",
    "8/1ppq1pk1/p1nR2p1/4p2p/PP2Pn1P/2P1NN2/2Q2PP1/6K1 b - - 0 31",
    "8/1pp2pk1/p1nq2p1/4p2p/PP2Pn1P/2P1NN2/2Q2PP1/6K1 w - - 0 32",
    "8/1pp2pk1/p1nq2p1/4p2p/PP2Pn1P/2P1NNP1/2Q2P2/6K1 b - - 0 32",
    "8/1pp2pk1/p1nqn1p1/4p2p/PP2P2P/2P1NNP1/2Q2P2/6K1 w - - 1 33",
    "8/1pp2pk1/p1nqn1p1/4p2p/PPN1P2P/2P2NP1/2Q2P2/6K1 b - - 2 33",
    "3q4/1pp2pk1/p1n1n1p1/4p2p/PPN1P2P/2P2NP1/2Q2P2/6K1 w - - 3 34",
    "3q4/1pp2pk1/p1n1n1p1/4N2p/PP2P2P/2P2NP1/2Q2P2/6K1 b - - 0 34",
    "3q4/1pp2pk1/p3n1p1/4n2p/PP2P2P/2P2NP1/2Q2P2/6K1 w - - 0 35",
    "3q4/1pp2pk1/p3n1p1/4N2p/PP2P2P/2P3P1/2Q2P2/6K1 b - - 0 35",
    "3q4/1p3pk1/p3n1p1/2p1N2p/PP2P2P/2P3P1/2Q2P2/6K1 w - c6 0 36",
    "3q4/1p3pk1/p3n1p1/1Pp1N2p/P3P2P/2P3P1/2Q2P2/6K1 b - - 0 36",
    "3q4/1p3pk1/4n1p1/1pp1N2p/P3P2P/2P3P1/2Q2P2/6K1 w - - 0 37",
    "3q4/1p3pk1/4n1p1/1Pp1N2p/4P2P/2P3P1/2Q2P2/6K1 b - - 0 37",
    "3q4/1pn2pk1/6p1/1Pp1N2p/4P2P/2P3P1/2Q2P2/6K1 w - - 1 38",
    "3q4/1pn2pk1/1P4p1/2p1N2p/4P2P/2P3P1/2Q2P2/6K1 b - - 0 38",
    "3q4/1p3pk1/1P2n1p1/2p1N2p/4P2P/2P3P1/2Q2P2/6K1 w - - 1 39",
    "3q4/1p3pk1/1P2n1p1/2p4p/2N1P2P/2P3P1/2Q2P2/6K1 b - - 2 39",
    "8/1p1q1pk1/1P2n1p1/2p4p/2N1P2P/2P3P1/2Q2P2/6K1 w - - 3 40",
    "8/1p1q1pk1/1P2n1p1/2p4p/2N1P2P/2P3P1/4QP2/6K1 b - - 4 40",
    "8/1p3pk1/1P2n1p1/1qp4p/2N1P2P/2P3P1/4QP2/6K1 w - - 5 41",
    "8/1p3pk1/1P2n1p1/1qp4p/2N1P2P/2P3P1/4QPK1/8 b - - 6 41",
    "8/1p3pk1/1Pq1n1p1/2p4p/2N1P2P/2P3P1/4QPK1/8 w - - 7 42",
    "8/1p3pk1/1Pq1n1p1/2p4p/2N1P2P/2PQ2P1/5PK1/8 b - - 8 42",
    "8/1p3pk1/1P2n1p1/1qp4p/2N1P2P/2PQ2P1/5PK1/8 w - - 9 43",
    "8/1p3pk1/1P2n1p1/1qpQ3p/2N1P2P/2P3P1/5PK1/8 b - - 10 43",
    "8/1p3pk1/1P2n1p1/2pQ3p/2N1P2P/1qP3P1/5PK1/8 w - - 11 44",
    "8/1p3pk1/1P1Nn1p1/2pQ3p/4P2P/1qP3P1/5PK1/8 b - - 12 44",
    "8/1p3pk1/1q1Nn1p1/2pQ3p/4P2P/2P3P1/5PK1/8 w - - 0 45",
    "8/1N3pk1/1q2n1p1/2pQ3p/4P2P/2P3P1/5PK1/8 b - - 0 45",
    "8/1N3pk1/4n1p1/2pQ3p/4P2P/2P3P1/1q3PK1/8 w - - 1 46",
    "8/5pk1/4n1p1/2NQ3p/4P2P/2P3P1/1q3PK1/8 b - - 0 46",

    "rnbqkbnr/pppppppp/pppppppp/pppppppp/PPPPPPPP/PPPPPPPP/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
    null
};

const string[] list_of_invalid_fen = 
{
    "---------1---------2---------3---------4---------5---------6---------7---------8---------9---------0",
    //"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR/ w KQkq - 0 1",     // 8 slashs
    "5k5/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",           // 11 piecies on rank 8
    "rnbqkbnr/pppppppp/8/8/8/8/5P5/RNBQKBNR w KQkq - 0 1",           // 11 piecies on rank 2
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/4K5 w KQkq - 0 1",           // 10 piecies on rank 1
    "rnbqkbnrp/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",     // 9 piecies on rank 8
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNRP w KQkq - 0 1",     // 9 piecies on rank 1
    "knbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",      // Found 2 Black King
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNK w KQkq - 0 1",      // Found 2 White King
    "rnbqrbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",      // No Found Black King
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQRBNR w KQkq - 0 1",      // No Found White King
    "rnaqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",      // Invalid character a on board
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNAQKBNR w KQkq - 0 1",      // Invalid character A on board
    "rnbqkbnr/pppppppp/0/8/8/8/PPPPPPPP/RNAQKBNR w KQkq - 0 1",      // Invalid character 0 on board
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR a KQkq - 0 1",      // invalid player a on active
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR wKQkq - 0 1",       // Needed whitespace after active
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq- - 0 1",     // Needed whitespace after castling
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQaq - 0 1",      // Castling KQkq

    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -- 0 1",     // Needed whitespace after en passant
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3- 0 1",  // Needed whitespace after en passant
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq 03 0 1",   // Expected [a-h]
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq i3 0 1",   // Expected [a-h]
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e4 0 1",   // Expected 3 or 6
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e7 0 1",   // Expected 3 or 6

    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e6 0 1",   // En Passant Black on rank 6
    "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e3 0 2", // En Passant White on rank 3

    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPPPPPP/RNBQKBNR b KQkq e3 0 1",   // Pawn moves 2, but exist piece
    "rnbqkbnr/pppppppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2", // Pawn moves 2, but exist piece

    //"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 123 1",    // Half move clock > 99
    //"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - - 1",      // Half move clock != [0-99]

    //"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 10000",  // Moves > 9999
    //"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 ab",     // Moves != [0-9999]
    "8/5pk1/4n1p1/2NQ3p/4P2P/2P3P1/1q3PK1/8 b - - 0 46 ",            // Last character != '\0'
    
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w kqKQ - 0 1",
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w QK - 0 1",

    null
};

const string[] list_of_checkmated_valid_fen =
{
    "r1bqkb1r/pppp1Qpp/2n2n2/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4",
    "1nbqkb1r/pppr1Qpp/5n2/1B2p3/2B5/8/PPPPPPPP/RN2K1NR b KQkq - 0 1",
    "1nbqkb2/pppr1Qpp/5n2/KBr1p3/2B5/8/PPPPPPPP/RN4NR b KQk - 0 1",
    "4k3/8/8/K7/8/8/8/rr6 w - - 0 1",
    "3qk3/3ppQ2/8/8/2B5/8/8/4K3 b - - 0 1",
    "6rk/5Npp/7P/8/8/8/8/4K3 b - - 0 1",
    "7R/8/7k/2r5/5n2/8/6Q1/4K3 b - - 0 1",
    "2rbN3/2k5/8/1Q6/8/8/8/4K3 b - - 0 1",
    "1r2kb2/pPB1p3/5p2/2p1N3/B7/8/8/3RK3 b - - 0 1",
    "8/pk1N4/n7/b7/8/1r3B2/8/1RR1K3 b - - 0 1",
    "r1b5/ppp1Q3/2N2kpN/5q2/8/8/8/2K1B3 b - - 0 1",
    null
};

static int error_count = 0;

void performe_move (ref Board board, Move move, string notation)
{
    string move_algebraic = null;
    if ((move_algebraic = board.algebraic_notation_for(move)) == notation)
    {
        if (board.turn == WHITE)
            print ("%d. %s", board.move_number, move_algebraic);
        else
            print (" %s\n", move_algebraic);
         
        board.performe_move(move);        
    }
    else
    {
        print ("%s", move_algebraic);
    }
}

int main (string[] args)
{
    string fen = null;
    print ("Checking Valid FEN\n");
    for (int i = 0; (fen = list_of_valid_fen[i]) != null; i++)
    {
        Board board = {};
        try
        {
            Board.from_fen(out board, fen);
            //print ("Valid -> %s\n", fen);
        }
        catch (Error error)
        {
            print ("Expected success for fen: %s\nError %s\n", fen, error.message);  
            error_count++;       
        }
    }

    print ("Checking Invalid FEN\n");
    for (int i = 0; (fen = list_of_invalid_fen[i]) != null; i++)
    {
        Board board = {};
        try
        {
            Board.from_fen(out board, fen);
            
            print ("Expected error for fen: %s\n", fen);
            error_count++;
        }
        catch (BoardError error)
        {
            //print ("OK -> %s \t %s\n", error.message, fen);    
        }
    }

    print ("Checking FEN parse Board and parse back FEN\n");
    for (int i = 0; (fen = list_of_valid_fen[i]) != null; i++)
    {
        Board board = {};
        try
        {
            Board.from_fen(out board, fen);
            string fen_clone = board.to_fen();
            if (fen == fen_clone)
            {
                //print (".");
            }
            else
            {
                print ("\n%s\n%s\n", fen, fen_clone);
                error_count++;
            }
        }
        catch
        {
        }
    }

    print ("Checking Valid Checkmated board from FEN\n");
    for (int i = 0; (fen = list_of_checkmated_valid_fen[i]) != null; i++)
    {
        Board board = {};
        try
        {
            Board.from_fen(out board, fen);
            if (board.checkmate(board.turn))
            {
                //print ("Ok Checkmated\n");                
            }
            else
            {      
                print ("Fail\n");
            }
            if (!board.checkmate(board.turn.other()))
            {
                //print ("Ok No Checkmated\n");
            }
            else
            {      
                print ("Fail\n");
            }
        }
        catch (Error error)
        {
            print ("Expected success for fen: %s\nError %s\n", fen, error.message);  
            error_count++;       
        }
    }

    print ("\n\n\nChecking Algebraic Notation for Move\n");
    try
    {
        Board board = {};
        Board.from_fen(out board, START_BOARD_FEN);
        
        Move e4 = MOVE(Squares.SQ_E2, Squares.SQ_E4);
        performe_move (ref board, e4, "e4");

        Move e5 = MOVE(Squares.SQ_E7, Squares.SQ_E5);
        performe_move (ref board, e5, "e5");

        Move f4 = MOVE(Squares.SQ_F2, Squares.SQ_F4);
        performe_move (ref board, f4, "f4");

        Move exf4 = MOVE(Squares.SQ_E5, Squares.SQ_F4);
        performe_move (ref board, exf4, "exf4");

        Move g4 = MOVE(Squares.SQ_G2, Squares.SQ_G4);
        performe_move (ref board, g4, "g4");

        Move fxg3 = MOVE(Squares.SQ_F4, Squares.SQ_G3);
        performe_move (ref board, fxg3, "fxg3");

        Move h3 = MOVE(Squares.SQ_H2, Squares.SQ_H3);
        performe_move (ref board, h3, "h3");

        Move g2 = MOVE(Squares.SQ_G3, Squares.SQ_G2);
        performe_move (ref board, g2, "g2");

        Move h4 = MOVE(Squares.SQ_H3, Squares.SQ_H4);
        performe_move (ref board, h4, "h4");

        Move gxh1Q = PROMOTE(MOVE(Squares.SQ_G2, Squares.SQ_H1), PieceType.QUEEN);
        performe_move (ref board, gxh1Q, "gxh1=Q");

        // Another Board Q1bq1bnr/2pkpppp/8/Q2p3Q/8/4P3/2PP1PPP/RNB1KBNR w KQ - 6 15
        print ("\nQ1bq1bnr/2pkpppp/8/Q2p3Q/8/4P3/2PP1PPP/RNB1KBNR w KQ - 6 15\n");
        Board.from_fen(out board, "Q1bq1bnr/2pkpppp/8/Q2p3Q/8/4P3/2PP1PPP/RNB1KBNR w KQ - 6 15");
        Move qa5xd5m = MOVE(Squares.SQ_A5, Squares.SQ_D5);
        performe_move (ref board, qa5xd5m, "Qa5xd5+");

        // Another Board rnbqkbnr/ppppp1p1/8/8/8/8/PPPPKp1p/RNBQ1BNR b kq - 1 9
        print ("\nrnbqkbnr/ppppp1p1/8/8/8/8/PPPPKp1p/RNBQ1BNR b kq - 1 9\n");
        Board.from_fen(out board, "rnbqkbnr/ppppp1p1/8/8/8/8/PPPPKp1p/RNBQ1BNR b kq - 1 9");
        Move hxg1N = PROMOTE(MOVE(Squares.SQ_H2, Squares.SQ_G1), PieceType.KNIGHT);
        performe_move (ref board, hxg1N, "hxg1=N+");
    }
    catch (Error error)
    {
        print ("Expected success for fen: %s\nError %s\n", fen, error.message);  
        error_count++;       
    }

    print ("\nError Count: %d\n", error_count);
    
    return error_count == 0 ? 0 : 1;
}