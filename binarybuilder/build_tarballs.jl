using BinaryBuilder, Pkg

GITHUB_REF_NAME = haskey(ENV, "GITHUB_REF_NAME") ? ENV["GITHUB_REF_NAME"] : ""

name = "ABINIT"
version = v"6.1.0"

# Sources required for all builds
sources = [
    ArchiveSource("https://gitlab.com/libxc/libxc/-/archive/$(version)/libxc-$(version).tar.gz",
                  "f593745fa47ebfb9ddc467aaafdc2fa1275f0d7250c692ce9761389a90dd8eaf"),
]

script = raw"""
cd $WORKSPACE/srcdir/libxc-*/

mkdir libxc_build
cd libxc_build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN} \
    -DCMAKE_BUILD_TYPE=Release -DENABLE_XHOST=OFF -DBUILD_SHARED_LIBS=ON \
    -DENABLE_FORTRAN=OFF -DDISABLE_KXC=ON ..

make -j${nproc}
make install
"""

platforms = [Platform("x86_64", "linux"; libc="glibc")]

products = [
    LibraryProduct("libxc", :libxc)
]

dependencies = [
    Dependency(PackageSpec(name="CompilerSupportLibraries_jll", uuid="e66e0078-7015-5450-92f7-15fbd957f2ae")),
]

GITHUB_REF_NAME = haskey(ENV, "GITHUB_REF_NAME") ? ENV["GITHUB_REF_NAME"] : ""
deployingargs = deepcopy(ARGS)
#if !isempty(GITHUB_REF_NAME) && GITHUB_REF_NAME != "main"
#    push!(deployingargs, "--deploy=local")
#end
push!(deployingargs, "--deploy=local")

build_tarballs(deployingargs, name, version, sources, script, platforms, products,
               dependencies; preferred_gcc_version=v"5", julia_compat="1.6")
