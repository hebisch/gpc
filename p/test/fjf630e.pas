program fjf630e;

type
  PString = ^String;

var
  c: PString = nil;

function foo: PString;
begin
  Dispose (c);
  New (c, 1);
  c^ := 'O';
  foo := c
end;

function bar: PString;
begin
  Dispose (c);
  New (c, 1);
  c^ := 'K';
  bar := c
end;

{$X+}

procedure p (a, b: CString);
begin
  WriteLn (a, b)
end;

begin
  p (String2CString (foo^), String2CString (bar^))
end.
