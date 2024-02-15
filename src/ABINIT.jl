module ABINIT

using ABINIT_jll

export abinit

function abinit(args...)
    read(pipeline(`$(ABINIT_jll.abinit()) $(args...)`; stderr=devnull), String)
end

end
