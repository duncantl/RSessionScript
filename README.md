This package contains a script and some functions that I have used to
 take the transcript of an R session  (e.g., during a class I teach interactively/with live coding)
 and extract the top-level expressions/commands and/or the
 output from the commands.
 I used this after lectures to create an Rdb and then HTML file of the
 R session.
 

## Get the Code/Commands from a Session
 
 ```r
script = "RSession"
k = getCode(script)
```

We can then parse the expressions, evaluate them, analyze them (e.g., with 
[CodeDepends](https://github.com/duncantl/CodeDepends), [CodeAnalysis](https://github.com/duncantl/CodeAnalysis), ...)
```r
e = lapply(k, function(x) parse(text = x))
 ```

## Format the session as an R-Docbook document
 ```r
k = getCode(script, output = TRUE)
db = asRdbTranscript(k)
toFile(db, "/tmp/foo.Rdb")
 ```
 
 Then we can convert it to HTML:
 ```
 make -f ~/MakeRSession/inst/Make/GNUmakefile foo.html
 ```
 

 
