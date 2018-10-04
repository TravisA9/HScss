using HScss

#cd(Base.Filesystem.homedir() * "/.julia/packages/HScss/3YW9k")
s = open(Base.Filesystem.homedir() * "/.julia/packages/HScss/3YW9k/src/test/testPage.Scss") do file
    String(read(file))
end
println("\nParse file contents")
vars, classes, body = hscss(s)

println("\ntranslate data structure to HScss and print")
printScss(vars, classes, body)

println("\nget head element")
print( hscss_get(body, "head"))

println("\nget all divs")
print( hscss_getall(body, "div") )


# This will be a future work... maybe
#compile(s)
