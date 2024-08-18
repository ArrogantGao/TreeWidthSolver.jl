# Contraction Order

This package can be used as backend for finding the optimal tensor network contraction order.

## OMEinsumContractionOrders.jl

A new optimizer has been added in [OMEinsumContractionOrders.jl](https://github.com/TensorBFS/OMEinsumContractionOrders.jl).

Here is an example of usage:
```julia
julia> using OMEinsum, OMEinsumContractionOrders

# define the contraction using Einstein summation
julia> code = ein"ijl, ikm, jkn, l, m, n -> "
ijl, ikm, jkn, l, m, n -> 

ulia> optimizer = ExactTreewidth()
ExactTreewidth{GreedyMethod{Float64, Float64}}(GreedyMethod{Float64, Float64}(0.0, 0.0, 1))

# set the size of the indices
julia> size_dict = uniformsize(code, 2)
Dict{Char, Int64} with 6 entries:
  'n' => 2
  'j' => 2
  'i' => 2
  'l' => 2
  'k' => 2
  'm' => 2

julia> optcode = optimize_code(code, size_dict, optimizer)
n, n -> 
├─ jk, jkn -> n
│  ├─ ij, ik -> jk
│  │  ├─ ijl, l -> ij
│  │  │  ├─ ijl
│  │  │  └─ l
│  │  └─ ikm, m -> ik
│  │     ├─ ikm
│  │     └─ m
│  └─ jkn
└─ n

# check the complexity
julia> contraction_complexity(optcode, size_dict)
Time complexity: 2^5.087462841250339
Space complexity: 2^2.0
Read-write complexity: 2^5.882643049361841

# check the results
julia> A = rand(2, 2, 2); B = rand(2, 2, 2); C = rand(2, 2, 2); D = rand(2); E = rand(2); F = rand(2);

julia> code(A, B, C, D, E, F) ≈ optcode(A, B, C, D, E, F)
true
```

## TensorOperations.jl

This optimizer will be used as an extension of [TensorOperations.jl](https://github.com/Jutho/TensorOperations.jl) in the future, see this [PR](https://github.com/Jutho/TensorOperations.jl/pull/185).
We compared the performance of this method against the default optimizer of TensorOperations.jl based on exhaustive searching, the results is shown below.

![](https://github.com/ArrogantGao/TreeWidthSolver_benchmark/blob/main/figs/compare_TO.png?raw=true)

The results shown that the tree width based solver is faster for some graph similar to trees.
For more details, please see the benchmark repo: [https://github.com/ArrogantGao/TreeWidthSolver_benchmark](https://github.com/ArrogantGao/TreeWidthSolver_benchmark).