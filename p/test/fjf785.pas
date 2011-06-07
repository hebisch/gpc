{ Could be allowed in principle, but EP forbids it, and there
  doesn't seem to be a compelling reason for allowing it. }

program fjf785;

type
  r = 1 .. 1;
  t (n: Integer) = record
                   case r of
                     1: ()
                   end;

var
  v: ^t;

begin
  New (v, 42 { discriminant }, 1 { variant tag })  { WRONG }
end.
