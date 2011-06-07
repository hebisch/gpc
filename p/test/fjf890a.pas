program fjf890a;

type
  a = object
    b: array [1 .. SizeOf (a)] of Char  { WRONG }
  end;

begin
end.
