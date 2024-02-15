using BinaryBuilder, Pkg
# https://github.com/JuliaPackaging/BinaryBuilder.jl/pull/1315
using GitHub

github_token = get(ENV, "GITHUB_TOKEN", "")
if length(github_token) > 0
    BinaryBuilder.Wizard._github_auth[] = GitHub.authenticate(github_token)
end

name = "ABINIT"
version = v"9.10.3"

sources = [
    ArchiveSource("https://www.abinit.org/sites/default/files/packages/abinit-$(version).tar.gz",
                  "3f2a9aebbf1fee9855a09dd687f88d2317b8b8e04f97b2628ab96fb898dce49b"),
    DirectorySource(joinpath(@__DIR__, "patches")),
]

script = raw"""
cd abinit-*
# Disable Kxc check because of cross-compilation. Libxc_jll does not support it anyway.
atomic_patch -p1 ../disable_kxc_check.patch
autoreconf -i
mkdir ${prefix}/share/licenses/ABINIT
cp ./doc/COPYING ${prefix}/share/licenses/ABINIT/COPYING
export PYTHONPATH="/usr/lib/python3.9"
atomic_patch -p1 ../remove_native.patch

export BLAS_LIBS="-L${libdir} -lopenblas"
export LAPACK_LIBS="-L${libdir} -lopenblas"
export FFTW3_LIBS="-L${libdir} -lfftw3 -lfftw3f"

flags=(--with-mpi=no)
flags+=(--with-libxc)
flags+=(--with-fftw3)
flags+=(--with-netcdf)
flags+=(--with-netcdf-fortran="/workspace/destdir/")

./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target} ${flags[@]}
make -j $nproc
make install
"""

platforms = [
             Platform("x86_64", "linux"; libgfortran_version=v"4.0.0"),
             Platform("x86_64", "linux"; libgfortran_version=v"5.0.0"),
            ]

products = [
    ExecutableProduct("abinit", :abinit),
    ExecutableProduct("abitk", :abitk),
    ExecutableProduct("aim", :aim),
    ExecutableProduct("anaddb", :anaddb),
    ExecutableProduct("atdep", :atdep),
    ExecutableProduct("band2eps", :band2eps),
    ExecutableProduct("conducti", :conducti),
    ExecutableProduct("cut3d", :cut3d),
    ExecutableProduct("dummy_tests", :dummy_tests),
    ExecutableProduct("fftprof", :fftprof),
    ExecutableProduct("fold2Bloch", :fold2Bloch),
    ExecutableProduct("ioprof", :ioprof),
    ExecutableProduct("lapackprof", :lapackprof),
    ExecutableProduct("macroave", :macroave),
    ExecutableProduct("mrgddb", :mrgddb),
    ExecutableProduct("mrgdv", :mrgdv),
    ExecutableProduct("mrggkk", :mrggkk),
    ExecutableProduct("mrgscr", :mrgscr),
    ExecutableProduct("multibinit", :multibinit),
    ExecutableProduct("optic", :optic),
    ExecutableProduct("testtransposer", :testtransposer),
    ExecutableProduct("vdw_kernelgen", :vdw_kernelgen),
]

dependencies = [
    Dependency("FFTW_jll"),
    Dependency("HDF5_jll"),
    Dependency("LAPACK_jll"),
    Dependency("Libxc_jll"),
    Dependency("NetCDFF_jll"),
    Dependency(PackageSpec(; name="CompilerSupportLibraries_jll",
                           uuid="e66e0078-7015-5450-92f7-15fbd957f2ae")),
    Dependency(PackageSpec(; name="OpenBLAS32_jll",
                           uuid="656ef2d0-ae68-5445-9ca0-591084a874a2")),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               preferred_gcc_version=v"12")
