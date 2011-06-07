program fjf630b;

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

begin
  WriteLn (CString2String (foo), CString2String (bar))
end.
