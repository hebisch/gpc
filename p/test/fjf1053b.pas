program fjf1053b (Output);

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
    procedure q;
  end;

constructor o.Init;
begin
end;

procedure o.p;
begin
  WriteLn ('failed 2')
end;

procedure o.q;
begin
  p
end;

var
  a: ^o;

begin
  AtExit (ExpectError);
  New (a);
  SetType (a^, nil);
  a^.q
end.
