libgchess_sources = [
  'gchess/board.vala',
  'gchess/file.vala',
  'gchess/game.vala',
  'gchess/move.vala',
  'gchess/pgn.vala',
  'gchess/piece.vala',
  'gchess/player.vala',
  'gchess/rank.vala',
  'gchess/square.vala',
]

libchess_deps = [
  glib,
  gio
]

libchess = static_library('gchess', libgchess_sources,
  dependencies: libchess_deps,
  c_args: [ '-O2' ]
)

libchess_dep = declare_dependency(
  link_with: libchess,
  include_directories: include_directories('.'),
)