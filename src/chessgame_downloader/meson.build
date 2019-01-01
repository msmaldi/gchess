gchess_sources = [
    'main.vala'
]

gchess_deps = [
    gio,
    glib,
    libchess_dep,
    soup
]

executable ('chessgame_downloader', gchess_sources,
  dependencies: gchess_deps,
  c_args: [ '-O0' ],
  install: false,
)