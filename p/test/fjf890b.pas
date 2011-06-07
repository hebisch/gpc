program fjf890b;

type
  a = object
    b: array [1 .. BitSizeOf (a)] of Char  { WRONG }
  end;

begin
end.
