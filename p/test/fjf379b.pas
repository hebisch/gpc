program fjf379b;

type
  t = record
    o, k : Char
  end;

function f = r : t;
var a : Boolean = False; attribute (static);
begin
  if a then
    begin
      WriteLn ('failed');
      Halt
    end;
  a := True;
  r.o := 'O';
  r.k := 'K'
end;

{$W-,borland-pascal}

begin
  with f do WriteLn (o, k)
end.
