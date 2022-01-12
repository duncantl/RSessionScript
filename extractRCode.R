#
# get the R code from an R session transcript
#
#
# Identify graphics code, including looking within the with() statements.
#
# How to use
#  k=getCode("Lec15.Rsession", output = TRUE)
#  db = asRdbTranscript(k)   # now an XMLSession
#  toFile(db, "Lec15.Rdb")
# Then  make Lec15.html

getCode = 
function(filename, txt = readLines(filename), prompt = c("(\\[[0-9]+:[0-9]+\\] [0-9]+>|1>)", "\\+ "),
          fun = getExpression, omit = TRUE, dropErrors = TRUE, output = FALSE)
{
    i = grep(sprintf("^%s", prompt[1]), txt)
    browser()
    if(max(i) != length(txt)) {
     txt = c(txt, prompt[1])
     i = c(i, length(txt))
   }
   # kill of txt before the first prompt.
   group = rep(1:length(i), c(diff(i), 1))

   if(min(i) > 1)
     txt = txt[-(1:(min(i) - 1))]

   if(is.null(fun))
     return(data.frame(text = txt, group = group))
   
   ans = tapply(txt, group, fun, prompt, dropErrors, output)

   if(is.na(ans[length(ans)]) || ans[length(ans)] == "")
     ans = ans[-length(ans)]

   if(omit)
       ans = ans[!is.na(ans) & ans!= ""]
   
   structure(ans, class = if(output) "SessionCodeWithOutput" else "SessionCode",
                  infile = filename)
}

# Want another function that gets the output too.
# And we want to detect errors and ignore those.

getExpression =
function(lines, prompt = c("> ", "\\+ "), dropErrors = TRUE,
          output = FALSE)
{
  if(dropErrors && length(lines) > 1 && grepl("^Error", lines[2]))
    return("")
    
  lines[1] = gsub(sprintf("^%s", prompt[1]), "", lines[1])
  i = grep(sprintf("^%s", prompt[2]), lines[-1])
  rest = lines[ - c(1, i) ]
  if(any(rest == "*** output flushed ***"))
     rest = NA
  
  e = if(length(i))
         c(lines[1], gsub(sprintf("^%s", prompt[2]), "", lines[-1][i]))
      else
         lines[1]

  ans = tryCatch(parse(text = e), error = function(e) NULL)
  if(is.null(ans)) {
    if(output)
     list(cmd = NA, output = NA)
    else
      NA
  } else {
    ans = paste(e, collapse = "\n  ")
    if(output) {
       list(cmd = ans, output = if(length(rest)) rest else NA)     
    } else
       ans
  }
}

colophon =
function(x, ...)
{
  sprintf('<colophon infile="%s" time="%s">',
            attr(x, "infile"), Sys.time())
}

asRdbTranscript =
function(x, ...)
  UseMethod("asRdbTranscript")

asRdbTranscript.SessionCode =
function(x, ..., parse = FALSE)
{
  x = x[!sapply(x, is.na)]
  txt =
    c('<?xml version="1.0"?>',
      '<article xmlns:r="http://www.r-project.org"',
      '         xmlns:xi="http://www.w3.org/2003/XInclude">',
      "", "",
      sprintf("\n\n\n<r:code><![CDATA[\n%s\n]]></r:code>\n\n", x),
      "",
      colophon(x),
      "</article>")

  if(parse)
     xmlParse(txt, asText = TRUE)
  else
     structure(txt, class = "XMLSession")
}


asRdbTranscript.SessionCodeWithOutput =
function(x, ..., parse = FALSE)
{
  x = x[!sapply(x, function(x) is.na(x$cmd))]  
  txt =
    c('<?xml version="1.0"?>',
      '<article xmlns:r="http://www.r-project.org"',
      '         xmlns:xi="http://www.w3.org/2003/XInclude">',
      "", "",
      sprintf("\n\n\n<r:code><![CDATA[\n%s\n]]>\n%s</r:code>\n\n",
               sapply(x, `[[`, "cmd"),
               sapply(x, function(i) {

                       if(length(i$output) && is.na(i$output))
                         return("")
                       tag = if(grepl("^Error", i$output[1])) "error" else "output"
                       sprintf('<r:%s><![CDATA[\n%s\n]]></r:%s>',
                                  tag,
                                  paste(escapeCDATA(i$"output"), collapse = "\n"),
                                  tag)
                     })),
      "",
      colophon(x),
      "</article>")

  if(parse)
     xmlParse(txt, asText = TRUE)
  else
     structure(txt, class = "XMLSession")
}

escapeCDATA =
function(x)
{
  gsub("]]>", "]]]]><![CDATA[>]]><![CDATA[", x, fixed = TRUE)
}


toFile =
       # Write the object to a file
function(x, file, ...)
 UseMethod("toFile")

toFile.XMLSession =
function(x, file, ...)
{
  cat(x, file = file, sep = "\n\n")
}

