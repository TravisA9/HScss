


function printvalue(unit)
    if  isa(unit, Px)
        return string(unit.val)*"px"
    elseif isa(unit, Em)
        return string(unit.val)*"em"
    elseif isa(unit, Cm)
        return string(unit.val)*"cm"
    elseif isa(unit, In)
        return string(unit.val)*"in"
    elseif isa(unit, Deg)
        return string(unit.val)*"deg"
    elseif isa(unit, Mm)
        return string(unit.val)*"mm"
    elseif isa(unit, Pt)
        return string(unit.val)*"pt"
    elseif isa(unit, Pc)
        return string(unit.val)*"pc"
    elseif isa(unit, Ex)
        return string(unit.val)*"ex"
    elseif isa(unit, Ch)
        return string(unit.val)*"ch"
    elseif isa(unit, Rem)
        return string(unit.val)*"rem"
    elseif isa(unit, Vw)
        return string(unit.val)*"vw"
    elseif isa(unit, Vh)
        return string(unit.val)*"vh"
    elseif isa(unit, Vmin)
        return string(unit.val)*"vmin"
    elseif isa(unit, Vmax)
        return string(unit.val)*"vmax"
    elseif isa(unit, Pcnt)
        return string(unit.val)*"%"
    elseif isa(unit, Str)
        return "\""*unit.val*"\""
    end
    return unit
end


function printScss(vars, classes, body)

    function p_pair(a, b, i)
        print(" "^(i*2), "$a:")
        if isa(b, Array)
            for i in b
                print(" ", printvalue(i))
            end
        else
            print(printvalue(b))
        end
        print(";\n")
    end

    function p_dict(d, i)
        for (k,v) in d
            if k == "nodes"
                p_dict(v, i+1)
            elseif isa(v, Dict) #
                println(" "^(i*2), "$k{")
                p_dict(v, i+1)
                println(" "^(i*2), "}")
            else # All attributes..
                p_pair(k, v, i+1)
            end
        end
    end
    for b in vars
        print("\$")
        p_pair(b[1], b[2], 0)
    end
    print("\n\n")
    for b in classes
        println(".", b[1], "{")
        p_dict(b[2], 1)
        println("}")
        print("\n\n")
    end
    print("\n\n")
    for b in body
        println(b[1], "{")
        p_dict(b[2], 1)
        println("}")
        print("\n\n")
    end
end
