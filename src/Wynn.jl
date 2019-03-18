module Wynn
    using SymPy

    # data structure to store the epsilon table
    # ϵ_ij indexed by ints i & j, stored within dict.
    struct EpsilonTable{T}
        series::T
        terms::Vector{T}
        etable::Dict{Tuple{Int,Int},T}
    end

    function EpsilonTable(terms::Vector{T}; simplified::Bool = true) where T<:Union{Real,Sym}
        # maximum occuring i & j index, minus 1 for nonzero julia indexing
        max_ind = length(terms) - 1

        # setting base case j = -1
        etable = Dict((i, -1) => eltype(terms)(0) for i in 0:max_ind)

        # setting base case j = 0, i = 0:max_ind
        merge!(etable, Dict((i, 0) => sum(terms[1:i+1]) for i in 0:max_ind))

        # setting base case i = -j-1, j even
        merge!(etable, Dict((-j-1, 2j) => eltype(terms)(0) for j in 0:max_ind/2))

        # recursive calculations, j>=1, i = -floor(Int,(j+1)/2):max_ind-j
        for j in 1:max_ind, i in -floor(Int,(j+1)/2):max_ind-j
            ϵ_ij = etable[i+1, j-2] + 1 / (etable[i+1, j-1] - etable[i, j-1])
            eltype(terms) <: Sym && simplified ? push!(etable, (i, j) =>
                simplify(ϵ_ij)) : push!(etable, (i, j) => ϵ_ij)
        end
        series = sum(terms)
        EpsilonTable(series, terms, etable)
    end

    export EpsilonTable
end
