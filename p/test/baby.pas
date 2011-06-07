program baby;

type BigString = String(200000);

type trec      = record
                   s, t, u : BigString
                 end;
     prec      = ^trec;

var r : prec;

begin
   GetMem(r, sizeof(BigString));
   (@r^.s.capacity)^ := 42;  { GPC doesn't normally allow the modification
                               of a discriminant. With `@' and `^' one can
                               override this restriction. (Generally, when
                               you use `@', you're basically on your own ...) }
   r^.s := 'OK';
   writeln (r^.s)
end.
