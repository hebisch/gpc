program fjf218b;

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
  {$local X+,W-} p := y(msg^).jc; {$endlocal}
  while p <> nil do
    begin
      write (chr (p^.v));
      p := p^.Next
    end;
  writeln
end.
