program fjf218a;

uses fjf218u, fjf218v;

var
  msg : pm;
  p, q : pil;

begin
  New (q);
  New (q^.Next);
  q^.v := Ord('O');
  q^.Next^.v := Ord('K');
  q^.Next^.Next := nil;
  msg := New (py, Init (q));

  { This was:
    p := y(msg^).jc;
    but this now gives a warning (`cast to type of different size')
    rightfully IMHO, Frank
    fjf218b.pas tests this with warnings disabled }
  p := py(msg)^.jc;

  while p <> nil do
    begin
      write (chr (p^.v));
      p := p^.Next
    end;
  writeln
end.
