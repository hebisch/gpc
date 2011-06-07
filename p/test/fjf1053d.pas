{$object-checking}

program fjf1053d (Output);

uses GPC;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

type
  o = object
    constructor Init;
    procedure p; virtual;
  end;

constructor o.Init;
begin
end;

procedure o.p;
begin
  WriteLn ('failed 2')
end;

var
  a: ^o;
  i: Integer;
  Garbage: array [1 .. 10] of Integer;

begin
  AtExit (ExpectError);
  New (a);
  for i := 1 to 10 do Garbage[i] := i;
  SetType (a^, Pointer (@Garbage));
  a^.p
end.
