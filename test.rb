def something(a:, b:, c: 1)
  print a, b, c
end

def something(a, b, c = 1)
  print a, b, c
end

->(a:, b:) { print a, b }
