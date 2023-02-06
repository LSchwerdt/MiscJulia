### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 10412630-a582-11ed-0e68-c1bacd01cb35
# ╠═╡ show_logs = false
begin
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.add([
        Pkg.PackageSpec(name="PlutoUI"),
		Pkg.PackageSpec(name="Humanize"),
        Pkg.PackageSpec(url="https://github.com/LSchwerdt/SortingAlgorithms.jl",
			rev = "pagedmergesort"),
    ])
    using SortingAlgorithms
	using PlutoUI
	import Humanize: digitsep, datasize
	using Test
end

# ╔═╡ 8fd5b1b3-f703-4b40-b36d-a8ea43f3746d
PlutoUI.with_terminal() do
	versioninfo()
    println()
end

# ╔═╡ 076f9e9e-94b3-4659-8c08-81681ff66d4c
dispnumber(n) = digitsep(n, seperator= "_", per_separator=3)

# ╔═╡ fdafeda8-0215-4ea6-95b8-4e862489759a
function benchPagedMergeSort(T,n)
PlutoUI.with_terminal() do      
        # precompilation
        v = rand(T,10^5)
        v2 = copy(v)
        sort!(v2)
        v2 = copy(v)
        sort!(v2,alg=MergeSort)
        v2 = copy(v)
        sort!(v2,alg=PagedMergeSort)
        sort!(v,alg=ThreadedPagedMergeSort)
        @test issorted(v)
        # precompilation
        v = rand(T,10^5)
        p = Vector{Int}(undef,length(v))
        p2 = Vector{Int}(undef,length(v))
        sortperm!(p,v,alg=MergeSort)
        sortperm!(p2,v)
        @test p == p2
        sortperm!(p2,v,alg=PagedMergeSort)
        @test p == p2
        sortperm!(p2,v,alg=ThreadedPagedMergeSort)
        @test p == p2

        # benchmark sort
        v = rand(T,n)
        println("sort! T=$(T) n=$(dispnumber(n)) ($(datasize(sizeof(v), style=:bin)))")
        v2 = copy(v)
        print("default:\t\t\t\t\t")
        @time sort!(v2)
        v2 = copy(v)
        print("MergeSort:\t\t\t\t\t")
        @time sort!(v2,alg=MergeSort)
        v2 = copy(v)
        print("PagedMergeSort:\t\t\t\t")
        @time sort!(v2,alg=PagedMergeSort)
        print("PagedMergeSort, $(Threads.nthreads()) threads:\t")
        @time sort!(v,alg=ThreadedPagedMergeSort)
        @test issorted(v)
        println()

        # benchmark sortperm
        v = rand(T,n)
        println("sortperm! T=$(T) n=$(dispnumber(n)) ($(datasize(sizeof(v), style=:bin)))")
        p = Vector{Int}(undef,length(v))
        p2 = Vector{Int}(undef,length(v))
        print("default:\t\t\t\t\t")
        @time sortperm!(p,v)
        print("MergeSort:\t\t\t\t\t")
        @time sortperm!(p2,v,alg=MergeSort)
        print("PagedMergeSort:\t\t\t\t")
        @time sortperm!(p2,v,alg=PagedMergeSort)
        @test p == p2
        print("PagedMergeSort, $(Threads.nthreads()) threads:\t")
        @time sortperm!(p2,v,alg=ThreadedPagedMergeSort)
        @test p == p2
	end
end

# ╔═╡ f9d7e784-3a46-43d4-bde5-86115a9ee044
benchPagedMergeSort(UInt,2^17)

# ╔═╡ 11472959-894b-46da-af78-e01214737324
benchPagedMergeSort(UInt,2^23)

# ╔═╡ fc875468-190c-4ee9-8c91-828d59929cc8
benchPagedMergeSort(UInt,2^27)

# ╔═╡ Cell order:
# ╠═10412630-a582-11ed-0e68-c1bacd01cb35
# ╟─8fd5b1b3-f703-4b40-b36d-a8ea43f3746d
# ╠═f9d7e784-3a46-43d4-bde5-86115a9ee044
# ╠═11472959-894b-46da-af78-e01214737324
# ╠═fc875468-190c-4ee9-8c91-828d59929cc8
# ╟─076f9e9e-94b3-4659-8c08-81681ff66d4c
# ╟─fdafeda8-0215-4ea6-95b8-4e862489759a
