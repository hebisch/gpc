program fjf798;

type
  t (n: Integer) = array [1 .. n] of Integer;

var
  v: ^t;
  a: Pointer;

procedure p1 (protected var x);
begin
  if @x <> a then
    begin
      WriteLn ('failed 1 ', PtrInt (@x), ' ', PtrInt (a));
      Halt
    end
end;

procedure p2 (const x);
begin
  if @x <> a then
    begin
      WriteLn ('failed 2 ', PtrInt (@x), ' ', PtrInt (a));
      Halt
    end;
  p1 (x)
end;

procedure p3 (var x);
begin
  if @x <> a then
    begin
      WriteLn ('failed 3 ', PtrInt (@x), ' ', PtrInt (a));
      Halt
    end;
  p2 (x)
end;

begin
  New (v, 10);
  a := v;
  p1 (v^);
  p2 (v^);
  p3 (v^);
  WriteLn ('OK')
end.
