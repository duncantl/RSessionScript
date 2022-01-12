library(RSessionScript)
input = commandArgs(TRUE)

if(length(input) == 1)
  input[2] = sprintf("%s.Rdb", input[1])

k = getCode(input[1], output = TRUE)
db = asRdbTranscript(k)
toFile(db, input[2])

