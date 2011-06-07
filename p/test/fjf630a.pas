program fjf630a;

var
  c: CString = nil;
  s: String (10);

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
  s := CString2String (foo) + CString2String (bar);
  WriteLn (s)
end.
