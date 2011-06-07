program fjf690;

type
  a = record
    i: String (8);
    p: procedure (var b: a)  (* WRONG; allowed for objects, cf. fjf696c.pas *)
  end;

procedure Foo (var d: a);
begin
  WriteLn (d.i)
end;

var
  b: a = ('failed 1', nil);
  c: a = ('failed 2', Foo);

begin
  c.p (b)
end.
