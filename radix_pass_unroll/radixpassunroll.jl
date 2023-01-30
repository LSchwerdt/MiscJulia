using Test, Printf

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

macro repeat4x(a)
    quote
        $a; $a; $a; $a
    end |> esc
end

# radix sort pass with unrolled loop
function radix_sort_pass_unrolled!(t, lo, hi, offset, counts, v, shift, chunk_size)
    mask = UInt(1) << chunk_size - 1  # mask is defined in pass so that the compiler
    @inbounds begin                   #  ↳ knows it's shape
        # counts[2:mask+2] will store the number of elements that fall into each bucket.
        # if chunk_size = 8, counts[2] is bucket 0x00 and counts[257] is bucket 0xff.
        counts .= 0
        k = lo
        while k <= hi
            x = v[k]                  # lookup the element
            i = (x >> shift)&mask + 2 # compute its bucket's index for this pass
            counts[i] += 1            # increment that bucket's count
            k += 1
        end
        
        counts[1] = lo                # set target index for the first bucket
        cumsum!(counts, counts)       # set target indices for subsequent buckets
        # counts[1:mask+1] now stores indices where the first member of each bucket
        # belongs, not the number of elements in each bucket. We will put the first element
        # of bucket 0x00 in t[counts[1]], the next element of bucket 0x00 in t[counts[1]+1],
        # and the last element of bucket 0x00 in t[counts[2]-1].
        
        #original loop unrolled 4x
        k = lo
        while k <= hi - 4
            @repeat4x begin
                x = v[k]                  # lookup the element
                i = (x >> shift)&mask + 1 # compute its bucket's index for this pass
                j = counts[i]             # lookup the target index
                t[j + offset] = x         # put the element where it belongs
                counts[i] = j + 1         # increment the target index for the next
                k += 1                    #  ↳ element in this bucket
            end
        end                           
        while k <= hi
            x = v[k]                  # lookup the element
            i = (x >> shift)&mask + 1 # compute its bucket's index for this pass
            j = counts[i]             # lookup the target index
            t[j + offset] = x         # put the element where it belongs
            counts[i] = j + 1         # increment the target index for the next
            k += 1                    #  ↳ element in this bucket
        end
    end
end

let
    #for precompilation
    n = 100
    v = rand(UInt,n)
    chunk_size = 10
    shift = 0
    offset = 0
    counts = Vector{Int}(undef, 1 << chunk_size + 1)
    
    t = 0 * v
    radix_sort_pass!(t, 1, n, offset, counts, v, shift, chunk_size)
    radix_sort_pass_unrolled!(t, 1, n, offset, counts, v, shift, chunk_size)
    
    # actual test
    n = 10^5
    v = rand(UInt,n)
    t1 = t2 = 0v
    time_base = 0.0
    time_unrolled = 0.0
    nRepeats = 20000
    for ii = 1:nRepeats
        if rand(Bool)
            time_base += @elapsed radix_sort_pass!(t1, 1, n, offset, counts, v, shift, chunk_size)
            time_unrolled += @elapsed radix_sort_pass_unrolled!(t2, 1, n, offset, counts, v, shift, chunk_size)
        else
            time_unrolled += @elapsed radix_sort_pass_unrolled!(t2, 1, n, offset, counts, v, shift, chunk_size)
            time_base += @elapsed radix_sort_pass!(t1, 1, n, offset, counts, v, shift, chunk_size)
        end
        mod(ii,2000) == 0 && println("$ii/$nRepeats")
    end
    
    @printf "\nbase:     %.3f seconds\n" time_base
    @printf "unrolled: %.3f seconds\n" time_unrolled
    @printf "speedup factor: %.2f\n" time_base/time_unrolled
    @test t1 == t2    
end