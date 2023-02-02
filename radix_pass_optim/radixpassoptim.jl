using Test, Printf
import Humanize: digitsep

# radix sort pass from base
function radix_sort_pass!(t, lo, hi, offset, counts, v, shift, chunk_size)
    mask = UInt(1) << chunk_size - 1  # mask is defined in pass so that the compiler
    @inbounds begin                   #  ↳ knows it's shape
        # counts[2:mask+2] will store the number of elements that fall into each bucket.
        # if chunk_size = 8, counts[2] is bucket 0x00 and counts[257] is bucket 0xff.
        counts .= 0
        for k in lo:hi
            x = v[k]                  # lookup the element
            i = (x >> shift)&mask + 2 # compute its bucket's index for this pass
            counts[i] += 1            # increment that bucket's count
        end

        counts[1] = lo                # set target index for the first bucket
        cumsum!(counts, counts)       # set target indices for subsequent buckets
        # counts[1:mask+1] now stores indices where the first member of each bucket
        # belongs, not the number of elements in each bucket. We will put the first element
        # of bucket 0x00 in t[counts[1]], the next element of bucket 0x00 in t[counts[1]+1],
        # and the last element of bucket 0x00 in t[counts[2]-1].

        for k in lo:hi
            x = v[k]                  # lookup the element
            i = (x >> shift)&mask + 1 # compute its bucket's index for this pass
            j = counts[i]             # lookup the target index
            t[j + offset] = x         # put the element where it belongs
            counts[i] = j + 1         # increment the target index for the next
        end                           #  ↳ element in this bucket
    end
end

# radix sort pass with offset calculation removed from loop
function radix_sort_pass2!(t, lo, hi, offset, counts, v, shift, chunk_size)
    mask = UInt(1) << chunk_size - 1 # mask is defined in pass so that the compiler
    @inbounds begin                   #  ↳ knows it's shape
        # counts[2:mask+2] will store the number of elements that fall into each bucket.
        # if chunk_size = 8, counts[2] is bucket 0x00 and counts[257] is bucket 0xff.
        counts .= 0
        for k in lo:hi
            x = v[k]                  # lookup the element
            i = (x >> shift)&mask + 2 # compute its bucket's index for this pass
            counts[i] += 1            # increment that bucket's count
        end

        counts[1] = lo + offset       # set target index for the first bucket
        cumsum!(counts, counts)       # set target indices for subsequent buckets
        # counts[1:mask+1] now stores indices where the first member of each bucket
        # belongs, not the number of elements in each bucket. We will put the first element
        # of bucket 0x00 in t[counts[1]], the next element of bucket 0x00 in t[counts[1]+1],
        # and the last element of bucket 0x00 in t[counts[2]-1].

        for k in lo:hi
            x = v[k]                  # lookup the element
            i = (x >> shift)&mask + 1 # compute its bucket's index for this pass
            j = counts[i]             # lookup the target index
            t[j] = x                  # put the element where it belongs
            counts[i] = j + 1         # increment the target index for the next
        end                           #  ↳ element in this bucket
    end
end

dispnumber(n) = digitsep(n, seperator= "_", per_separator=3)

let
    #for precompilation
    n = 100
    v = rand(UInt,n)
    chunk_size = 10
    shift = 10
    offset = 0
    counts = Vector{Int}(undef, 1 << chunk_size + 1)

    t = 0 * v
    radix_sort_pass!(t, 1, n, offset, counts, v, shift, chunk_size)
    radix_sort_pass2!(t, 1, n, offset, counts, v, shift, chunk_size)

    # actual test
    n = 10^3
    v = rand(UInt,n)
    t1 = t2 = 0v
    time_base = 0.0
    time_modified = 0.0
    nRepeats = 10^6
    for ii = 1:nRepeats
        if rand(Bool)
            time_base += @elapsed radix_sort_pass!(t1, 1, n, offset, counts, v, shift, chunk_size)
            time_modified += @elapsed radix_sort_pass2!(t2, 1, n, offset, counts, v, shift, chunk_size)
        else
            time_modified += @elapsed radix_sort_pass2!(t2, 1, n, offset, counts, v, shift, chunk_size)
            time_base += @elapsed radix_sort_pass!(t1, 1, n, offset, counts, v, shift, chunk_size)
        end
    end
    println("$(dispnumber(nRepeats)) radix sort passes with $(dispnumber(n)) elements:")
    @printf "base: %.3f seconds\n" time_base
    @printf "PR:   %.3f seconds\n" time_modified
    @printf "speedup factor: %.3f\n\n" time_base/time_modified
    @test t1 == t2

    # actual test
    n = 10^7
    v = rand(UInt,n)
    t1 = t2 = 0v
    offset = 0
    time_base = 0.0
    time_modified = 0.0
    nRepeats = 10^2
    for ii = 1:nRepeats
        if rand(Bool)
            time_base += @elapsed radix_sort_pass!(t1, 1, n, offset, counts, v, shift, chunk_size)
            time_modified += @elapsed radix_sort_pass2!(t2, 1, n, offset, counts, v, shift, chunk_size)
        else
            time_modified += @elapsed radix_sort_pass2!(t2, 1, n, offset, counts, v, shift, chunk_size)
            time_base += @elapsed radix_sort_pass!(t1, 1, n, offset, counts, v, shift, chunk_size)
        end
    end
    println("$(dispnumber(nRepeats)) radix sort passes with $(dispnumber(n)) elements:")
    @printf "base: %.3f seconds\n" time_base
    @printf "PR:   %.3f seconds\n" time_modified
    @printf "speedup factor: %.3f\n\n" time_base/time_modified
    versioninfo()
    @test t1 == t2
end