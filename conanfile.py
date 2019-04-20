# https://docs.conan.io/en/latest/reference/conanfile.html?highlight=conanfile

from conans import ConanFile, tools, Meson

class CalendarApp(ConanFile):
    name       = "pres.io"
    version    = "0.1.0"
    requires   = ()
    generators = 'pkg_config'
    settings   = "os", "compiler", "build_type", 'arch'

    def build(self):
        # https://docs.conan.io/en/latest/reference/build_helpers/meson.html#meson-build-reference
        meson = Meson(self)
        meson.configure(build_folder='.')
        meson.build()
