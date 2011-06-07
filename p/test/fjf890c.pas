program fjf890c;

type
  a = object
    b: array [1 .. AlignOf (a)] of Char  { WRONG }
  end;

begin
end.
