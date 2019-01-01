gchess_deps = [
    gio,
    glib,
    libchess_dep
]

test_move = executable (
    'test_move', [ 'test_move.vala' ],
    dependencies: gchess_deps,
    c_args: [ '-O2' ],
    install: false
)

test_board = executable (
    'test_board', [ 'test_board.vala' ],
    dependencies: gchess_deps,
    c_args: [ '-O2' ],
    install: false
)

test_pgn = executable (
    'test_pgn', [ 'test_pgn.vala' ],
    dependencies: gchess_deps,
    c_args: [ '-O2' ],
    install: false
)

test('Move Test', test_move)
test('Board Test', test_board)
test('PGN Test', test_pgn)