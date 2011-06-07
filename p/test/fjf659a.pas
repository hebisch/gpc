program fjf659a;

type
  Foo (n: Integer) = Integer;
  t = object end;

var
  a: record
       b: String (42);
       c: Integer;
       d: Foo (17);
       e: array [1 .. 10] of String (100);
       f: t
     end;

function Check1: Boolean;
var i: Integer;
begin
  Check1 := False;
  if (a.b.Capacity <> 42) or
     (a.d.n <> 17) or
     (TypeOf (a.f) <> TypeOf (t)) then Exit;
  for i := 1 to 10 do
    if a.e[i].Capacity <> 100 then Exit;
  Check1 := True
end;

function Check0: Boolean;
var i: Integer;
begin
  Check0 := False;
  if (a.b.Capacity <> 0) or
     (a.d.n <> 0) or
     (TypeOf (a.f) <> nil) then Exit;
  for i := 1 to 10 do
    if a.e[i].Capacity <> 0 then Exit;
  Check0 := True
end;

begin
  if not Check1 then begin WriteLn ('failed 1'); Halt end;
  FillChar (a, SizeOf (a), 0);
  if not Check0 then begin WriteLn ('failed 2'); Halt end;
  Initialize (a);
  if not Check1 then begin WriteLn ('failed 3'); Halt end;
  WriteLn ('OK')
end.
