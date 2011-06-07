program fjf336;

type
  foo = (a, b, c);

const
  m = low (foo);

type
  t = m .. b;
  u = low (t) .. succ (high (t));

begin
  if (low (t) = a) and (high (t) = b) and
     (low (u) = a) and (high (u) = c)
    then writeln ('OK') else writeln ('failed ',
                                      ord (low (t)), ' ', ord (a), ' ',
                                      ord (high (t)), ' ', ord (b), ' ',
                                      ord (low (u)), ' ', ord (a), ' ',
                                      ord (high (u)), ' ', ord (c), ' ')
end.
