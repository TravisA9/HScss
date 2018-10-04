mutable struct Tokenizer
    str::String
    i::Int
    offset::Int
    tokens::Array{Any,1}
    Tokenizer(str) = new(str, 1, 0, [])
end

# ==============================================================================
isDigit(l) =   '0' ≤ l ≤ '9'
isHex(l) = ('a' ≤ l ≤ 'f') || ('A' ≤ l ≤ 'F') || isDigit(l)
isUpper(l) = 'A' ≤ l ≤ 'Z'
isLower(l) = 'a' ≤ l ≤ 'z'
isAlpha(l) = isLower(l) || isUpper(l) || l == '-'
# ==============================================================================
# some convenience functions
# ==============================================================================
is(p, symbol) = (p.i < length(p.str)) &&  (p.str[p.i] == symbol)
at(p) = p.str[p.i + p.offset]
range(p) = p.str[p.i:p.i + (p.offset-1)] # Why -1 ???
getIt(p, symbol)= ( push!(p.tokens, symbol); p.i+=1)
# ==============================================================================
function parseHex(v) # Parse hex as RGB[A] values
    if length(v) == 3
        color = [parse(Int, "0x" * v[1:1]), parse(Int, "0x" * v[2:2]), parse(Int, "0x" * v[3:3])]
    elseif length(value) == 6
        color = [parse(Int, "0x" * v[1:2]), parse(Int, "0x" * v[3:4]), parse(Int, "0x" * v[5:6])]
    elseif length(value) == 8
        color = [parse(Int, "0x" * v[1:2]), parse(Int, "0x" * v[3:4]), parse(Int, "0x" * v[5:6]), parse(Int, "0x" * v[7:8])]
    else
        println("Error parsing Hex to color values")
    end
    color
end
# ==============================================================================
function getHex(p)
  p.i+=1
  p.offset = 1 # Assume 0 is true
  while isHex(at(p))
      p.i + p.offset < length(p.str) ?  p.offset+=1 : break
  end
   push!(p.tokens, Hex(parseHex(range(p))));
   p.i += p.offset
end
# ==============================================================================
function getAlpha(p)
  p.offset = 1 # Assume 0 is true
  while isAlpha(at(p)) || isDigit(at(p))
      p.i + p.offset < length(p.str) ?  p.offset+=1 : break
  end
   push!(p.tokens, Alpha(range(p)));
   p.i += p.offset
end
# ==============================================================================
function getDigit(p)
  p.offset = 1 # Assume 0 is true
  while isDigit(at(p))
    p.i + p.offset < length(p.str) ?  p.offset+=1 : break
  end
  push!(p.tokens, Digit(range(p)));
  p.i += p.offset
end
# ==============================================================================
#  Dot Digit Open Close Value End Unit Dotdot Hex At
#  Hash Dollar Reference Alpha Var Attr Tag Class
function getString(p, symbol)
    p.i+=1 # Trim off the quotes.
    p.offset = 1
    while at(p) != symbol
        p.i + p.offset < length(p.str) ? p.offset+=1 : break
    end #
    push!(p.tokens, Str(range(p)));
    p.offset+=1
    p.i += p.offset
end
# ==============================================================================
# Main function to tokenize
# ==============================================================================
function tokenize(s)
  t = Tokenizer(s)

while t.i < length(t.str) # lastindex

    (is(t, ' ') || is(t, '\t')) && getIt(t, Space(t.str[t.i:t.i]))
    (is(t, ',') || is(t, ';') || is(t, '\r') || is(t, '\n')) && getIt(t, End(t.str[t.i:t.i]))

    isDigit(t.str[t.i]) && getDigit(t)
    isAlpha(t.str[t.i]) && getAlpha(t)
    is(t, '#')          && getHex(t)
    is(t, '\'')         && getString(t, '\'')
    is(t, '\"')         && getString(t, '\"')
    is(t, '{')          && getIt(t, Open("{"))
    is(t, '}')          && getIt(t, Close("}"))
    is(t, ':')          && getIt(t, Dotdot(":"))
    is(t, '%')          && getIt(t, Unit("%"))
    is(t, '$')          && getIt(t, Dollar("\$"))
    is(t, '@')          && getIt(t, At("@"))
    is(t, '.')          && getIt(t, Dot("."))
end
  return t
end
