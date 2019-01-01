project('msmaldi-chess', [ 'vala', 'c' ],
    version: '1.0.0'
)

min_glib_version = '2.44.0'

glib = dependency('glib-2.0', version: '>=' + min_glib_version)
gio = dependency('gio-unix-2.0', version: '>=' + min_glib_version)
soup = dependency('libsoup-2.4', version: '>=' + min_glib_version)
posix = meson.get_compiler('vala').find_library('posix')

subdir('lib')
subdir('src')
subdir('src/chessgame_downloader')
subdir('test')