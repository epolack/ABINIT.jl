using ABINIT
using Test

const PROJECT_ROOT = pkgdir(ABINIT)

@testset "version" begin
    import TOML
    pkg_version = TOML.parsefile("$(PROJECT_ROOT)/Project.toml")["compat"]["ABINIT_jll"]
    version = strip(abinit_cli("--version"), '\n')
    @test version == pkg_version
end
