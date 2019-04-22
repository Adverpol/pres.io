# -*-python-*-

project('pres.io', 'cpp',
        default_options : ['cpp_std=c++17'])

qt5_mod = import('qt5')
qt5_deps = dependency('qt5', modules: ['Core', 'Quick', 'Xml', 'XmlPatterns', 'Gui', 'Qml'])

processed = qt5_mod.preprocess(
    moc_headers : ['src/Util.h', 'src/Launcher.h', 'src/TextModel.h'],
    moc_sources : ['src/Util.cpp', 'src/Launcher.cpp', 'src/TextModel.cpp'], # must have #include"moc_helperFile.cpp"
    #ui_files    : 'mainWindow.ui',
    qresources : 'qml.qrc'
)

# Use boost_dep below when C++17 is available
# compiler = meson.get_compiler('cpp')
# boost_inc = include_directories('../../../thirdparty/boost')
# boost_dep = dependency('boost')

if build_machine.system() == 'windows'
    extra_args = ['-DWINDOWS']
else
    extra_args = []
endif

cal = executable('pres.io',
           sources     : ['src/main.cpp',
                          'src/Util.cpp',
                          'src/Launcher.cpp',
                          'src/TextModel.cpp',
                          processed],
           dependencies: [qt5_deps],
           include_directories: [],
	   cpp_args: extra_args
)
