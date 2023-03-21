### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ d12ddb52-a973-11ed-2a52-b3b0d9449b3b
begin
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.add([
		Pkg.PackageSpec(name="BenchmarkTools"),
		Pkg.PackageSpec(name="CategoricalArrays"),
		Pkg.PackageSpec(name="Plots"),	
		Pkg.PackageSpec(name="StatsBase"),		
        Pkg.PackageSpec(url="https://github.com/LSchwerdt/SimultaneousSortperm.jl",rev = "main"),
    ])
    using BenchmarkTools
	using CategoricalArrays
	using Plots
	using Random
	using SimultaneousSortperm
	using StatsBase
	using Test
end

# ╔═╡ 1616f9ca-3110-43df-95a9-8ae0b6a17c80
md"## Setup Packages"

# ╔═╡ 45eb14c0-3204-45ff-8fa2-4fad013ee938
md"## Settings"

# ╔═╡ aefc7502-657c-44be-88bf-7e8ff0702b36
savePlots = true;

# ╔═╡ 127e7858-19d5-4d05-b57e-93e31ec280a5
begin
	algorithms = [sort, sortperm, ssortperm]
	labels = ["sort" "sortperm" "ssortperm"]
end;

# ╔═╡ 3fc3e1f8-1a08-4601-b9a7-fcd627dfab58
md"## Int64"

# ╔═╡ 2736c02b-62a9-4639-8cfa-67941d7e0941
#=╠═╡
scatterplot_speed(sizes,times_Int64,labels,"Int64", "Int64")
  ╠═╡ =#

# ╔═╡ 2506322e-0440-4389-8794-a8d7e0456cb6
#=╠═╡
scatterplot_speedup(sizes,times_Int64,labels,"Int64", "Int64")
  ╠═╡ =#

# ╔═╡ 459963f7-3998-4507-a061-0768f2f7157a
md"## Int128"

# ╔═╡ 229884cb-59a1-423a-9538-608c7adbb081
#=╠═╡
scatterplot_speed(sizes,times_Int128,labels,"Int128", "Int128")
  ╠═╡ =#

# ╔═╡ cbb857d6-718a-4263-ad2b-bb2a91ab9aec
#=╠═╡
scatterplot_speedup(sizes,times_Int128,labels,"Int128", "Int128")
  ╠═╡ =#

# ╔═╡ 1b164d4c-793f-45e7-bfe7-d2b9ad5b4628
md"## Int64 by=abs2"

# ╔═╡ 799a3043-4020-484f-bbb5-673fde5eb0aa
#=╠═╡
begin
	algorithms_sq = [x->sort(x,by=abs2), x->sortperm(x,by=abs2), x->ssortperm(x,by=abs2)]
	times_Int64sq = bench(sizes, vfun_Int64, algorithms_sq)
end;
  ╠═╡ =#

# ╔═╡ ea597909-274d-4cad-b950-325fcaaaa61e
#=╠═╡
scatterplot_speed(sizes,times_Int64sq,labels,"Int64_by_abs2", "Int64 by=abs2")
  ╠═╡ =#

# ╔═╡ ebb3d4d8-0fee-4b5f-aca0-9aa8ec5db3ed
#=╠═╡
scatterplot_speedup(sizes,times_Int64sq,labels,"Int64_by_abs2", "Int64 by=abs2")
  ╠═╡ =#

# ╔═╡ 2c5c3d86-bf61-42ff-8b56-59e6e06159c5
md"## Int64, almost presorted"

# ╔═╡ 8713321b-4159-4197-9a0c-a51c813d520a
#=╠═╡
scatterplot_speed(sizes,times_Int64almostpresorted,labels,"Int64_almost_presorted", "Int64, almost presorted")
  ╠═╡ =#

# ╔═╡ 4aa443fe-4c2e-45fd-acfa-3ff3aa5ddbff
#=╠═╡
scatterplot_speedup(sizes,times_Int64almostpresorted,labels,"Int64_almost_presorted", "Int64, almost presorted")
  ╠═╡ =#

# ╔═╡ ae489bbb-3527-4b58-b4e0-4a27b814aef2
md"## Float64"

# ╔═╡ 98aa72a9-abb4-4207-8185-a4b256ad297b
md"## Float64 by=abs2"

# ╔═╡ 34b5eb41-cdf6-4d6c-91d1-50391e345c53
#=╠═╡
begin
	times_Float64sq = bench(sizes, vfun_Float64, algorithms_sq)
end;
  ╠═╡ =#

# ╔═╡ 2250d2ec-a5a6-491a-b957-901db94c57d4
#=╠═╡
scatterplot_speed(sizes,times_Float64sq,labels,"Float64_by_abs2", "Float64 by=abs2")
  ╠═╡ =#

# ╔═╡ b8eb8049-5f64-4c78-8eaf-db3742fa6d94
#=╠═╡
scatterplot_speedup(sizes,times_Float64sq,labels,"Float64_by_abs2", "Float64 by=abs2")
  ╠═╡ =#

# ╔═╡ 9cd57e1b-f896-49b5-896d-b8d3c1e7bcc3
md"## Categorical, 4 Groups"

# ╔═╡ 444abc3a-2656-43cc-b249-ce82cbe5a987
#=╠═╡
scatterplot_speed(sizes,times_cat4,labels,"Categorical", "Categorical, 4 Groups")
  ╠═╡ =#

# ╔═╡ f0c6334a-bc37-4bc3-b30f-02cec07ae9f6
#=╠═╡
scatterplot_speedup(sizes,times_cat4,labels,"Categorical", "Categorical, 4 Groups")
  ╠═╡ =#

# ╔═╡ 36f9a816-be26-404b-9d40-099ea3b11a62
md"## Int64, 5% missing"

# ╔═╡ b7f59e89-2e1e-4043-9118-464e0d24f23d
#=╠═╡
scatterplot_speed(sizes,times_IntMissing5,labels,"Int64_missing5", "Int64, 5% missing")
  ╠═╡ =#

# ╔═╡ 885c22ed-0c60-44d2-8de7-76477cc9f5df
#=╠═╡
scatterplot_speedup(sizes,times_IntMissing5,labels,"Int64_missing5", "Int64, 5% missing")
  ╠═╡ =#

# ╔═╡ b520c52c-14a1-4d2d-b6b6-181ffd099a9a
md"## Int64, 50% missing"

# ╔═╡ f2056f13-1edd-48f7-a53a-8691291989c0
#=╠═╡
scatterplot_speed(sizes,times_IntMissing50,labels,"Int64_missing50", "Int64, 50% missing")
  ╠═╡ =#

# ╔═╡ 78dbbd8f-5e4c-49ae-8be6-f2745d0c901f
#=╠═╡
scatterplot_speedup(sizes,times_IntMissing50,labels,"Int64_missing50", "Int64, 50% missing")
  ╠═╡ =#

# ╔═╡ fec73ac3-2a1a-4ded-9c67-f039d5d04c4f
md"## Int64, 95% missing"

# ╔═╡ b196c000-62e5-4339-95e3-1208e2aa27f4
#=╠═╡
scatterplot_speed(sizes,times_IntMissing95,labels,"Int64_missing95", "Int64, 95% missing")
  ╠═╡ =#

# ╔═╡ 7eeb4f13-063f-4e85-9725-67d4dd213f93
#=╠═╡
scatterplot_speedup(sizes,times_IntMissing95,labels,"Int64_missing95", "Int64, 95% missing")
  ╠═╡ =#

# ╔═╡ 54ee9c29-ae20-4762-a6ae-4b69ceaacfb7
md"## Strings"

# ╔═╡ 1e361013-f4f0-4ac9-ae25-1a237dcb9b40
# disabled to avoid long execution times

# ╔═╡ 31e8de1e-0cce-4a49-8804-2a236ff93a59
# ╠═╡ disabled = true
#=╠═╡
begin
	vfun_string(n) = [randstring(rand(1:30)) for _ in 1:n]
	times_string = bench(sizes, vfun_string, algorithms)
end;
  ╠═╡ =#

# ╔═╡ e79776e7-d3c8-409a-822a-9c5ef43e874c
#=╠═╡
scatterplot_speed(sizes,times_string,labels,"shortstrings30", "randstring, random length 1:30")
  ╠═╡ =#

# ╔═╡ cc338bf5-42fe-482e-8413-d4451fde9732
#=╠═╡
scatterplot_speedup(sizes,times_string,labels,"shortstrings30", "randstring, random length 1:30")
  ╠═╡ =#

# ╔═╡ a44d080a-fbb5-424e-a9cb-177f5af36609
md"## Version"

# ╔═╡ aaa96bad-f4cc-45b4-b6c7-600ff1ff5af8
versioninfo()

# ╔═╡ d54ae970-5fbe-4ad7-abbc-c10f035291bc
md"## Functions"

# ╔═╡ fed575c4-04fd-4f0d-8993-8c96b2683550
begin
function problemsizes(nPowMin=7,nPowMax=20, nSamples=100, biasExp=1.3)
    convert.(Int,round.(2 .^ (1 ./(range((1/nPowMin)^(biasExp),(1/nPowMax)^(biasExp),nSamples).^(1/biasExp))))) |> shuffle
end
	
function bench(sizes, vFun, algorithms)
    nSamples = length(sizes)
    nAlgos = length(algorithms)
	t = zeros(nSamples,nAlgos)
	for (sample_idx,n) in enumerate(sizes)
		v = vFun(n)
        for (algo_idx,alg) in enumerate(algorithms)
		    t[sample_idx,algo_idx] = @elapsed alg(v)  
        end
	end
	t
end
end;

# ╔═╡ 1cb789a7-dd47-4977-bfa1-a4a43bfdc924
begin
	#calculate from 2^nPowMin to 2^nPowMax
	nPowMin = 7
	nPowMax = 27
	nSamples = 150
	sizes = problemsizes(nPowMin, nPowMax, nSamples)
end;

# ╔═╡ 01e05d8c-5d61-470d-b794-ff15ddfa23be
begin
vfun_Int64(n) = rand(Int64,n)
times_Int64 = bench(sizes, vfun_Int64, algorithms)
end;

# ╔═╡ 9f3070e2-5fa8-4c89-a087-5ab9b8adc32b
begin
vfun_Int128(n) = rand(Int128,n)
times_Int128 = bench(sizes, vfun_Int128, algorithms)
end;

# ╔═╡ 200d9fbe-3bf0-4e49-9faa-c0cb8e26d9bb
begin
	vfun_Int64almostpresorted(n) = [sort(rand(Int64,n-1));0]
	times_Int64almostpresorted = bench(sizes, vfun_Int64almostpresorted, algorithms)
end;

# ╔═╡ b16118bd-28a8-41aa-aa1b-003c29f7731d
begin
	vfun_Float64(n) = rand(Float64,n)
	times_Float64 = bench(sizes, vfun_Float64, algorithms)
end;

# ╔═╡ b9db5627-e84a-4bb0-a6e7-a35e97e16994
begin
	vfun_cat4(n) = categorical(shuffle(vcat(map(x->repeat(x,n÷4),[["A"],["B"],["C"],["D"]])...)), compress=true, ordered=true)
	times_cat4 = bench(sizes, vfun_cat4, algorithms)
end;

# ╔═╡ 0f5c1954-81d2-4574-9a2e-59150accc0ef
begin
	vfun_IntMissing5(n) = [rand(1:100)<=5 ? missing : rand(Int64) for _ in 1:n]
	times_IntMissing5 = bench(sizes, vfun_IntMissing5, algorithms)
end;

# ╔═╡ a57e3eaf-ba4a-40b3-b7e7-690872795c03
begin
	vfun_IntMissing50(n) = [rand(1:100)<=50 ? missing : rand(Int64) for _ in 1:n]
	times_IntMissing50 = bench(sizes, vfun_IntMissing50, algorithms)
end;

# ╔═╡ 734668b4-2a26-4f51-969c-84f346337ee4
begin
	vfun_IntMissing95(n) = [rand(1:100)<=95 ? missing : rand(Int64) for _ in 1:n]
	times_IntMissing95 = bench(sizes, vfun_IntMissing95, algorithms)
end;

# ╔═╡ 946ff0d4-03c3-489f-82de-c137776759ba
begin
function scatterplot_speed(sizes,times,labels,filename,title;xlabel="Input Size (Elements)")
    y = sizes./times
    plt = Plots.scatter(sizes,y,xaxis=:log,yaxis=:log,xlabel=xlabel,ylabel= "Elements / Second",label=labels,minorticks=10,legend=:bottomleft,title=title,yticks=:auto)
    y2 = StatsBase.percentile(y[:],2)
    y98 = StatsBase.percentile(y[:],98)
    ylims!(0.5y2, 1.4y98)
    savePlots && Plots.savefig("$filename.png")
    savePlots && Plots.savefig("$filename.svg")
    plt
end

function scatterplot_speedup(sizes,times,labels,filename,title;xlabel="Input Size (Elements)")
    plt = Plots.scatter(sizes,times[:,2]./times[:,1],label=labels[1,1])
    Plots.hline!([1],lw=2,label=labels[2])
    Plots.scatter!(sizes,times[:,2]./times[:,3],xaxis=:log,xlabel=xlabel,ylabel= "Speedup vs sortperm",label=labels[1,3],minorticks=10,minorgrid=true,legend=:topleft,title=title)
    y = times[:,2]./times[:,[1,3]]
    y2 = StatsBase.percentile(y[:],2)
    y99 = StatsBase.percentile(y[:],99)
    ylims!(0, 1.1y99)
    savePlots && Plots.savefig("$(filename)_speedup.png")
    savePlots && Plots.savefig("$(filename)_speedup.svg")
    plt
end
end;

# ╔═╡ 60a4b4c4-821c-40c6-961b-956c03d93d55
scatterplot_speed(sizes,times_Float64,labels,"Float64", "Float64")

# ╔═╡ 8c265189-f4a1-4335-b4d5-064de408d84d
scatterplot_speedup(sizes,times_Float64,labels,"Float64", "Float64")

# ╔═╡ Cell order:
# ╟─1616f9ca-3110-43df-95a9-8ae0b6a17c80
# ╠═d12ddb52-a973-11ed-2a52-b3b0d9449b3b
# ╟─45eb14c0-3204-45ff-8fa2-4fad013ee938
# ╠═1cb789a7-dd47-4977-bfa1-a4a43bfdc924
# ╠═aefc7502-657c-44be-88bf-7e8ff0702b36
# ╟─127e7858-19d5-4d05-b57e-93e31ec280a5
# ╟─3fc3e1f8-1a08-4601-b9a7-fcd627dfab58
# ╟─01e05d8c-5d61-470d-b794-ff15ddfa23be
# ╟─2736c02b-62a9-4639-8cfa-67941d7e0941
# ╟─2506322e-0440-4389-8794-a8d7e0456cb6
# ╟─459963f7-3998-4507-a061-0768f2f7157a
# ╟─9f3070e2-5fa8-4c89-a087-5ab9b8adc32b
# ╟─229884cb-59a1-423a-9538-608c7adbb081
# ╟─cbb857d6-718a-4263-ad2b-bb2a91ab9aec
# ╟─1b164d4c-793f-45e7-bfe7-d2b9ad5b4628
# ╟─799a3043-4020-484f-bbb5-673fde5eb0aa
# ╟─ea597909-274d-4cad-b950-325fcaaaa61e
# ╟─ebb3d4d8-0fee-4b5f-aca0-9aa8ec5db3ed
# ╟─2c5c3d86-bf61-42ff-8b56-59e6e06159c5
# ╟─200d9fbe-3bf0-4e49-9faa-c0cb8e26d9bb
# ╟─8713321b-4159-4197-9a0c-a51c813d520a
# ╟─4aa443fe-4c2e-45fd-acfa-3ff3aa5ddbff
# ╟─ae489bbb-3527-4b58-b4e0-4a27b814aef2
# ╟─b16118bd-28a8-41aa-aa1b-003c29f7731d
# ╟─60a4b4c4-821c-40c6-961b-956c03d93d55
# ╟─8c265189-f4a1-4335-b4d5-064de408d84d
# ╟─98aa72a9-abb4-4207-8185-a4b256ad297b
# ╟─34b5eb41-cdf6-4d6c-91d1-50391e345c53
# ╟─2250d2ec-a5a6-491a-b957-901db94c57d4
# ╟─b8eb8049-5f64-4c78-8eaf-db3742fa6d94
# ╟─9cd57e1b-f896-49b5-896d-b8d3c1e7bcc3
# ╟─b9db5627-e84a-4bb0-a6e7-a35e97e16994
# ╟─444abc3a-2656-43cc-b249-ce82cbe5a987
# ╟─f0c6334a-bc37-4bc3-b30f-02cec07ae9f6
# ╟─36f9a816-be26-404b-9d40-099ea3b11a62
# ╟─0f5c1954-81d2-4574-9a2e-59150accc0ef
# ╟─b7f59e89-2e1e-4043-9118-464e0d24f23d
# ╟─885c22ed-0c60-44d2-8de7-76477cc9f5df
# ╟─b520c52c-14a1-4d2d-b6b6-181ffd099a9a
# ╟─a57e3eaf-ba4a-40b3-b7e7-690872795c03
# ╟─f2056f13-1edd-48f7-a53a-8691291989c0
# ╟─78dbbd8f-5e4c-49ae-8be6-f2745d0c901f
# ╟─fec73ac3-2a1a-4ded-9c67-f039d5d04c4f
# ╟─734668b4-2a26-4f51-969c-84f346337ee4
# ╟─b196c000-62e5-4339-95e3-1208e2aa27f4
# ╟─7eeb4f13-063f-4e85-9725-67d4dd213f93
# ╟─54ee9c29-ae20-4762-a6ae-4b69ceaacfb7
# ╠═1e361013-f4f0-4ac9-ae25-1a237dcb9b40
# ╠═31e8de1e-0cce-4a49-8804-2a236ff93a59
# ╠═e79776e7-d3c8-409a-822a-9c5ef43e874c
# ╠═cc338bf5-42fe-482e-8413-d4451fde9732
# ╟─a44d080a-fbb5-424e-a9cb-177f5af36609
# ╟─aaa96bad-f4cc-45b4-b6c7-600ff1ff5af8
# ╟─d54ae970-5fbe-4ad7-abbc-c10f035291bc
# ╟─fed575c4-04fd-4f0d-8993-8c96b2683550
# ╟─946ff0d4-03c3-489f-82de-c137776759ba
