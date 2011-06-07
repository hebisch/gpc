program fjf458c;

procedure p (c: Char);

  procedure q;
  var a: String (10); attribute (static);
  begin
    if c = 'I' then
      a := ''
    else if c = 'P' then
      WriteLn (a)
    else
      a := a + c
  end;

begin
  q
end;

begin
  p ('I');
  p ('O');
  p ('K');
  p ('P')
end.
