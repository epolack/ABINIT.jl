module ABINIT

using ABINIT_jll

export abinit_cli

function abinit_cli(args...)
    read(pipeline(`$(ABINIT_jll.abinit()) $(args...)`; stderr=devnull), String)
end

end
