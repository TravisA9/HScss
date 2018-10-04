module HScss

export hscss, printScss, compile, hscss_get, hscss_getall
#tokenize, structure, modifiers, clumps

include("Units.jl")
include("Tokenize.jl")
include("write.jl")




function findUnit(token)
  for i in 1:length(units)
    if units[i] == token.val
      return true
    end
  end
  return false
end
# ==============================================================================
# clump related tokens for easier structuring...
# ==============================================================================
function clumps(token)
  fin = length(token)
  stack = []
  t = 1
  while t <= fin
    offset = 1
    if  isa(token[t], Alpha)
        if findUnit(token[t]) # test for units.
            token[t] = Unit(token[t].val)
            offset = 1
        elseif isa(token[t+1], Dotdot)
            token[t] = Attr(token[t].val)
            offset = 2
        elseif isa(token[t+1], Open)
            token[t] = Tag(token[t].val)
            offset = 2
        elseif  isa(token[t+1], End)
            token[t] = Value(token[t].val)
            offset = 2
        end

    elseif isa(token[t], Dot)
        if isa(token[t+1], Digit)
            token[t] = Float(parse(Float64, "." * token[t+1].val))
            offset = 2
        elseif isa(token[t+1], Alpha) && isa(token[t+2], Open)
            token[t] = Class(token[t+1].val)
            offset = 3
        end

    elseif isa(token[t], Dollar)
        if isa(token[t+1], Alpha) && isa(token[t+2], Dotdot)
            token[t] = Ident(token[t+1].val)
            offset = 3
        elseif isa(token[t+1], Alpha)
            token[t] = Reference(token[t+1].val)
            offset = 2
        end


    elseif isa(token[t], Digit)
        if t<fin-1 && isa(token[t+1], Dot) && isa(token[t+2], Digit)
            token[t] = Float(parse(Float64, token[t].val * "." * token[t+2].val))
            offset = 3
        elseif isa(token[t+1], Dot)
            token[t] = Float(parse(Float64, token[t].val * ".")) # Float(token[t].val * ".")
            offset = 2
        else # this must be an integer!
            token[t] = Int_(parse(Int, token[t].val))
            offset = 1
        end

    elseif isa(token[t], Hash) && (isa(token[t+1], Digit) || isa(token[t+1], Alpha))
            token[t] = Hex(token[t+1].val)
            offset = 2
    end

    if !isa(token[t], End) && !isa(token[t], Space)
      push!(stack, token[t])
    end
    t+=offset
    end
    stack
end
# ==============================================================================
# Push attributes to
# ==============================================================================
function pushAttributes(token)
  fin = length(token)
  stack = []
  t = 1
while t < fin

    offset = 1
    if isa(token[t], Attr) || isa(token[t], Ident) # AbstractLeft
        values = []
        while t+offset <= fin && isa(token[t+offset], AbstractRight)
            # Unpackage the standard typed vars
            if isa(token[t+offset], Int_) || isa(token[t+offset], Float) || isa(token[t+offset], Hex) || isa(token[t+offset], Value) || isa(token[t+offset], Alpha)
                push!(values, token[t+offset].val)
            else
                push!(values, token[t+offset])
            end

            offset +=1
        end


        if length(values) == 1
            values = values[1]
        end
        if isa(token[t], Ident)
            token[t] = token[t] => values
        else
            token[t] = token[t].val => values
        end
    end
    push!(stack, token[t])
    t+=offset

end
    t <= fin &&  push!(stack, token[t])
    return stack
end
# ==============================================================================
function modifiers(token)
  fin = length(token)
  stack = []
  t = 1
while t <= fin
    if (isa(token[t], AbstractRight)) && isa(token[t+1], Unit) # This seems fragile!
      unit = token[t+1].val
      value = token[t].val
      if     unit == "px"
        value = Px(value)
      elseif unit == "em"
        value = Em(value)
      elseif unit == "cm"
        value = Cm(value)
      elseif unit == "in"
        value = In(value)
      elseif unit == "deg"
        value = Deg(value)
      elseif unit == "mm"
        value = Mm(value)
      elseif unit == "pt"
        value = Pt(value)
      elseif unit == "pc"
        value = Pc(value)
      elseif unit == "ex"
        value = Ex(value)
      elseif unit == "ch"
        value = CH(value)
      elseif unit == "rem"
        value = Rem(value)
      elseif unit == "vw"
        value = Vw(value)
      elseif unit == "vh"
        value = Vh(value)
      elseif unit == "vmin"
        value = Vmin(value)
      elseif unit == "vmax"
        value = Vmax(value)
      elseif unit == '%'
        value = Pcnt(value)
      end
      push!(stack, value)
          t+=2
    elseif (isa(token[t], Attr)) && ( isa(token[t+1], Value) || isa(token[t+1], String) )
        push!(stack, token[t].val => String(token[t+1].val))
        t+=2
    else
        push!(stack, token[t])
        t+=1
    end
end

    return pushAttributes(stack)
end
# ==============================================================================
function structure(token)
  fin = length(token)
  t = 1
  vars, classes, body = [], [], []

function getnode() # get everything and
        stack = []
        tags = []
        while t <= fin
            node = token[t]
            t+=1
            if isa(node, Class) #|| isa(node, Tag) # Go deeper
                push!(stack, node.val => Dict( getnode()...))
            elseif isa(node, Tag) # Go deeper
                push!(tags, node.val => Dict( getnode()...))
                #push!(stack, Dict(node.val => getnode()))
            elseif isa(node, Close) # Go back
                push!(stack, "nodes" => tags)
                return Dict(stack...)
            else # Add to current
                push!(stack, node)
            end
        end
        push!(stack, "nodes" => tags)
        return stack
end


# In theory we chould only find the three principal node types at the base level
while t <= fin
        node = token[t]
        t+=1
        if isa(node, Pair) && isa(node[1], Ident)
            push!(vars, node[1].val => node[2])
        elseif isa(node, Ident)
            push!(vars, (node.val => node))

        elseif isa(node, Class)
            push!(classes, (node.val => getnode()))
        elseif isa(node, Tag)
            push!(body, (node.val => getnode()))
        elseif isa(node, Close)
        else
            println("---ERROR: ", node," should not be here! ---")
        end
end

    return (vars, classes, body)
end

function hscss(s)
    tokens = tokenize(s)
    return structure(modifiers(clumps(tokens.tokens)))
end


# ==============================================================================
# Find ONE named element
# ==============================================================================
function hscss_get(array, name)
    for e in array
        if e[1] == name
            return e
        end
    end
    return nothing
end
# ==============================================================================
# return all elements of name
# ==============================================================================
function hscss_getall(array, name)
    elements = []
    for e in array
        if e[1] == name
            push!(elements, e)
        end
    end
    return elements
end










# maybe a future addition...
function compile(s)
    vars, classes, body = hscss(s)
    values = []
    for b in vars
        push!(values, (b[1],"var"))
    end

    for b in classes
        push!(values, (b[1],"class"))
    end

    for b in classes
        push!(values, (b[1],"class"))
    end



    # function p_pair(a, b, i)
    #     print(" "^(i*2), "$a:")
    #     if isa(b, Array)
    #         for i in b
    #             print(" ", printvalue(i))
    #         end
    #     else
    #         print(printvalue(b))
    #     end
    #     print(";\n")
    # end

    function p_dict(d)
        for (k,v) in d
            if k == "nodes"
                p_dict(v)
            elseif isa(v, Dict) #
                #println(" "^(i*2), "$k{")
                p_dict(v)
                #println(" "^(i*2), "}")
            else # All attributes...
                if k == "style"
                    println(k)
                elseif isa(v, Ident)
                    println(v)
                end
            end
        end
    end


    for b in body
        p_dict(b[2])
    end

    return values
end

end # module
