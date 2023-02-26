### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ d12ddb52-a973-11ed-2a52-b3b0d9449b3b
begin
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.add([
		Pkg.PackageSpec(name="StatsPlots"),
		Pkg.PackageSpec(name="Random"),
		Pkg.PackageSpec(name="BenchmarkTools"),
        Pkg.PackageSpec(url="https://github.com/LSchwerdt/SortingAlgorithms.jl",
			rev = "pdqsort"),
    ])
    using SortingAlgorithms
	using BenchmarkTools
	using StatsPlots
	using Random
	using Test
end

# ╔═╡ 1616f9ca-3110-43df-95a9-8ae0b6a17c80
md"## Setup Packages"

# ╔═╡ 45eb14c0-3204-45ff-8fa2-4fad013ee938
md"## Settings"

# ╔═╡ 1cb789a7-dd47-4977-bfa1-a4a43bfdc924
begin
	#calculate from 2^nPowMin to 2^nPowMax
	nPowMin = 7
	nPowMax = 28
	nSamples = 150
	biasExp = 64 # shifts more samples towards smaller values
sizes = convert.(Int,round.(2 .^ (range(nPowMin^(1/biasExp),nPowMax^(1/biasExp),nSamples)).^biasExp)) |> shuffle
end;

# ╔═╡ aefc7502-657c-44be-88bf-7e8ff0702b36
savePlots = false;

# ╔═╡ 3fc3e1f8-1a08-4601-b9a7-fcd627dfab58
md"## Sort Int64"

# ╔═╡ 37eb5997-12ff-47ac-91e8-9874a180c38b
begin
function sort64bench(sizes)
	nSamples = length(sizes)
	t = zeros(nSamples,3)
	for (idx,n) in enumerate(sizes)
		v = rand(Int64,n)
		v1 = copy(v)
		v2 = copy(v)
		GC.gc()        
		t[idx,1] = @elapsed sort!(v1, alg=BranchlessPdqSort)
		t[idx,2] = @elapsed sort!(v)
		@assert v == v1
		t[idx,3] = @elapsed sort!(v2, alg=Base.Sort.ScratchQuickSort())
	end
	t
end
t64 = sort64bench(sizes)
end;

# ╔═╡ eb917d4f-facf-497f-a3aa-d3d86058b642
let
plt = Plots.scatter(sizes,sizes./t64,xaxis=:log,yaxis=:log,xlabel="Input Size / Elements",ylabel= "Elements / Second",label=["sort!, alg=BranchlessPdqSort" "sort!" "sort!, alg=ScratchQuickSort"],legend=:bottomleft,xticks=10.0 .^ (2:9),minorticks=10,title="sort! rand(Int64,n)")
Plots.ylims!(1e7, 1e8)
Plots.xlims!(1e2, 1e9)
savePlots && Plots.savefig("pdqSort_bench_Int64.png")
savePlots && Plots.savefig("pdqSort_bench_Int64.svg")
plt
end

# ╔═╡ e1abc3e7-93d7-4be6-865a-06b99bf93158
let
plt = Plots.scatter(sizes,t64[:,2]./t64[:,1],xaxis=:log,xlabel="Input Size / Elements",ylabel= "Speedup vs sort!",label="BranchlessPdqSort",xticks=10.0 .^ (2:9),minorticks=10,alpha = 1.0)
Plots.hline!([1],lw=2,label="sort!")
Plots.scatter!(sizes,t64[:,2]./t64[:,3],xaxis=:log,xlabel="Input Size / Elements",ylabel= "Speedup vs sort!",label="ScratchQuickSort",legend=:topright,xticks=10.0 .^ (2:9),minorticks=10,alpha = 1.0, title="sort! rand(Int64,n)")
Plots.ylims!(0.5, 2.5)
Plots.xlims!(1e2, 1e9)
savePlots && Plots.savefig("pdqSort_bench_Int64_speedup.png")
savePlots && Plots.savefig("pdqSort_bench_Int64_speedup.svg")
plt
end

# ╔═╡ 459963f7-3998-4507-a061-0768f2f7157a
md"## Sort Int128"

# ╔═╡ 623496a4-1d96-4a7b-8e50-2ba54845fcbd
begin
function sort128bench(sizes)
	nSamples = length(sizes)
	t = zeros(nSamples,2)
	for (idx,n) in enumerate(sizes)
		v = rand(Int128,n)
		v1 = copy(v)
		GC.gc()
		t[idx,1] = @elapsed sort!(v1, alg=BranchlessPdqSort)
        t[idx,2] = @elapsed sort!(v)		
		@assert v == v1
	end
	t
end
t128 = sort128bench(sizes)
end;

# ╔═╡ e3217c5f-40d5-47ff-8782-067bcfa22700
let
plt = Plots.scatter(sizes,sizes./t128,xaxis=:log,yaxis=:log,xlabel="Input Size / Elements",ylabel= "Elements / Second",label=["sort!, alg=BranchlessPdqSort" "sort!"],legend=:topright,xticks=10.0 .^ (2:9),minorticks=10,title="sort! rand(Int128,n)")
Plots.ylims!(1e7, 1e8)
Plots.xlims!(1e2, 1e9)
savePlots && Plots.savefig("pdqSort_bench_Int128.png")
savePlots && Plots.savefig("pdqSort_bench_Int128.svg")
plt
end

# ╔═╡ 62ab722f-5f8b-4dc8-8f64-d99580aad729
let
plt = Plots.scatter(sizes,t128[:,2]./t128[:,1],xaxis=:log,xlabel="Input Size / Elements",ylabel= "Speedup vs sort!",label="BranchlessPdqSort",legend=true,xticks=10.0 .^ (2:9),minorticks=10,alpha = 1.0, title="sort! rand(Int128,n)")
Plots.hline!([1],lw=2,label="sort!")
Plots.xlims!(1e2, 1e9)
Plots.ylims!(0, 2.1)
savePlots && Plots.savefig("pdqSort_bench_Int128_speedup.png")
savePlots && Plots.savefig("pdqSort_bench_Int128_speedup.svg")
plt
end

# ╔═╡ d4b8d977-14b3-4549-993b-8bac6ce457e0
md"## Sort special inputs
* random
* few unique 0:63
* few unique, one hot bit
* sorted + 10 random
* reverse sorted + 10 random"

# ╔═╡ 3f618c37-5083-40a7-a442-c67406194399
begin
n = 10^7
algs = [sort,v->sort(v, alg=BranchlessPdqSort),v->sort(v, alg=Base.Sort.ScratchQuickSort())]
#precompile:
for alg in algs
	alg(rand(Int,n))
end
inputs = [
	rand(Int,n),
	rand(0:63,n),
	rand(2 .^(0:63),n),
	[1:n;rand(Int,10)],
	[n:-1:1;rand(Int,10)]
]

ts = [@belapsed $alg($input) for alg in algs,input in inputs]
end;

# ╔═╡ 2510e38d-2144-42a5-be01-683ad4f66fa8
let
inputlabels = repeat([
	"rand(Int,n)"
	"rand(0:63,n)"
	"rand(2 .^(0:63),n)"
	"[1:n;rand(Int,10)]"
	"[n:-1:1;rand(Int,10)]"
	],inner=length(algs))
plt = groupedbar(
	inputlabels,
	ts,
	bar_position = :dodge,
	ylabel="time / s",
	group=repeat(["Default", "BranchlessPdqSort", "ScratchQuickSort"],length(inputs)),
	title="sort n=10^7 elements (Int64)",
	legend=:right,
	size=(800,480)
	)
	savePlots && Plots.savefig("pdqSort_bench_specialinputs.png")
	savePlots && Plots.savefig("pdqSort_bench_specialinputs.svg")
	plt
end

# ╔═╡ 4118dc85-edc6-4c24-839e-b34bdcf9d00f
md"## Prototype packed sortperm"

# ╔═╡ 063f6e43-9b6f-4b91-b347-900a4e87ab2d
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
pack64(a::UInt64, b) = UInt128(a)<<64 + b
pack64(a::Int64, b) = Int128(a)<<64 + b
	
function pack_vector(v::Union{AbstractArray{UInt64},AbstractArray{Int64}})
    offset = firstindex(v) - 1
    v2 = [pack64(v[b + offset],b) for b in 1:length(v)]
    v2, offset
end
	
function unpack_vector!(vp::Union{AbstractArray{UInt128},AbstractArray{Int128}}, offset)    
    lenv = length(vp)
    mask = 0xffffffffffffffff
    for i in 1:lenv÷2
        vp[i] = vp[2i-1] & mask + (vp[2i] & mask)<<64
    end
    if iseven(lenv)
        resize!(vp,lenv÷2)
        sizehint!(vp,lenv÷2)
        return reinterpret(Int64,vp) .+ offset
    else
        vp[lenv÷2+1] = vp[end]
        resize!(vp,lenv÷2+1)
        sizehint!(vp,lenv÷2+1)
        return reinterpret(Int64,vp)[1:end-1] .+ offset
    end
end
	
function pdqsortperm(v)
    vp, offset = pack_vector(v)
    sort!(vp,alg=BranchlessPdqSort)
    unpack_vector!(vp, offset)
end
	
function sortpermbench(sizes)
	nSamples = length(sizes)
	t = zeros(nSamples,4)
	for (idx,n) in enumerate(sizes)
		v = rand(UInt64,n)
		GC.gc()
		t[idx,1] = @elapsed p2 = pdqsortperm(v)        
		t[idx,2] = @elapsed p1 = sortperm(v)
		t[idx,3] = @elapsed sortperm(v, alg=MergeSort)
		t[idx,4] = @elapsed sort(v)
		@assert p1 == p2
	end
	t
end
end
  ╠═╡ =#

# ╔═╡ a5764ba0-e52c-4e26-b2bd-d8d665562b78
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
tp = sortpermbench(sizes);
  ╠═╡ =#

# ╔═╡ 43057eed-1b3c-4813-96be-aa6da06182ee
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
let
plt = Plots.scatter(sizes,sizes./tp,xaxis=:log,yaxis=:log,xlabel="Input Size / Elements",ylabel= "Elements / Second",label=["packed pdq sortperm" "sortperm" "sortperm, alg=MergeSort" "sort"],legend=:bottomleft,xticks=10.0 .^ (2:9),minorticks=10,title="sort/sortperm rand(Int64,n)")
Plots.xlims!(1e2, 1e9)
#Plots.ylims!(1e5, 1e8)
savePlots && Plots.savefig("pdqSort_bench_sortperm.png")
savePlots && Plots.savefig("pdqSort_bench_sortperm.svg")
plt
end
  ╠═╡ =#

# ╔═╡ f0e95849-88ca-4fe5-bdea-ed67cd38ba44
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
let
plt = Plots.scatter(sizes,tp[:,2]./tp[:,1],xaxis=:log,xlabel="Input Size / Elements",ylabel= "Speedup vs sortperm",label="packed pdq sortperm",legend=:topleft,xticks=10.0 .^ (2:9),minorticks=10,alpha = 1.0)
Plots.hline!([1],lw=2,label="sortperm")
Plots.scatter!(sizes,tp[:,2]./tp[:,3:4],xaxis=:log,xlabel="Input Size / Elements",ylabel= "Speedup vs sortperm",label=["sortperm, alg=MergeSort" "sort"],title="sort/sortperm rand(Int64,n)")
#Plots.ylims!(0, 30)
Plots.xlims!(1e2, 1e9)
savePlots && Plots.savefig("pdqSort_bench_sortperm_speedup.png")
savePlots && Plots.savefig("pdqSort_bench_sortperm_speedup.svg")
plt
end
  ╠═╡ =#

# ╔═╡ aaa96bad-f4cc-45b4-b6c7-600ff1ff5af8
versioninfo()

# ╔═╡ Cell order:
# ╟─1616f9ca-3110-43df-95a9-8ae0b6a17c80
# ╠═d12ddb52-a973-11ed-2a52-b3b0d9449b3b
# ╟─45eb14c0-3204-45ff-8fa2-4fad013ee938
# ╠═1cb789a7-dd47-4977-bfa1-a4a43bfdc924
# ╠═aefc7502-657c-44be-88bf-7e8ff0702b36
# ╟─3fc3e1f8-1a08-4601-b9a7-fcd627dfab58
# ╟─37eb5997-12ff-47ac-91e8-9874a180c38b
# ╟─eb917d4f-facf-497f-a3aa-d3d86058b642
# ╟─e1abc3e7-93d7-4be6-865a-06b99bf93158
# ╟─459963f7-3998-4507-a061-0768f2f7157a
# ╟─623496a4-1d96-4a7b-8e50-2ba54845fcbd
# ╟─e3217c5f-40d5-47ff-8782-067bcfa22700
# ╟─62ab722f-5f8b-4dc8-8f64-d99580aad729
# ╟─d4b8d977-14b3-4549-993b-8bac6ce457e0
# ╟─3f618c37-5083-40a7-a442-c67406194399
# ╟─2510e38d-2144-42a5-be01-683ad4f66fa8
# ╟─4118dc85-edc6-4c24-839e-b34bdcf9d00f
# ╟─063f6e43-9b6f-4b91-b347-900a4e87ab2d
# ╟─a5764ba0-e52c-4e26-b2bd-d8d665562b78
# ╟─43057eed-1b3c-4813-96be-aa6da06182ee
# ╟─f0e95849-88ca-4fe5-bdea-ed67cd38ba44
# ╠═aaa96bad-f4cc-45b4-b6c7-600ff1ff5af8
