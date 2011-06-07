program fjf630d;

var
  c: CString = nil;

function foo: CString;
begin
  Dispose (c);
  c := NewCString ('O');
  foo := c
end;

function bar: CString;
begin
  Dispose (c);
  c := NewCString ('K');
  bar := c
end;

procedure baz (s, t: String);
begin
  WriteLn (s, t)
end;

begin
  baz (CString2String (foo), CString2String (bar))
end.
