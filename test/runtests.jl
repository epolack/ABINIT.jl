using ABINIT
using Test

@testset begin "version"
    version = strip(abinit("--version"), '\n')
    @test version == "9.10.3"
end
