{ Bug: Result variables were not prediscriminated }

{$implicit-result}

program fjf614;

type
  p = ^t;
  t (d: Integer) = array [1 .. d] of Integer;

  o = object
    function ox = Res: p;
    function oy: p;
  end;

var
  a: t (42);
  Dummy: p;
  b: o;

function x = Res: p;
begin
  Res := p (@a);
  if (Res^.d <> 42) and (High (Res^) <> 42) then
    begin
      WriteLn ('failed 1 ', Res^.d, ' ', High (Res^));
      Halt
    end
end;

function y: p;
begin
  Result := p (@a);
  if (Result^.d <> 42) and (High (Result^) <> 42) then
    begin
      WriteLn ('failed 1 ', Result^.d, ' ', High (Result^));
      Halt
    end
end;

function o.ox = Res: p;
begin
  Res := p (@a);
  if (Res^.d <> 42) and (High (Res^) <> 42) then
    begin
      WriteLn ('failed 1 ', Res^.d, ' ', High (Res^));
      Halt
    end
end;

function o.oy: p;
begin
  Result := p (@a);
  if (Result^.d <> 42) and (High (Result^) <> 42) then
    begin
      WriteLn ('failed 1 ', Result^.d, ' ', High (Result^));
      Halt
    end
end;

operator * (x, y: p) Res: p;
begin
  Res := p (@a);
  if (Res^.d <> 42) and (High (Res^) <> 42) then
    begin
      WriteLn ('failed 1 ', Res^.d, ' ', High (Res^));
      Halt
    end
end;

operator / (x, y: p) = Res: p;
begin
  Res := p (@a);
  if (Res^.d <> 42) and (High (Res^) <> 42) then
    begin
      WriteLn ('failed 1 ', Res^.d, ' ', High (Res^));
      Halt
    end
end;

begin
  Dummy := x;
  Dummy := y;
  Dummy := b.ox;
  Dummy := b.oy;
  Dummy := Dummy * Dummy;
  Dummy := Dummy / Dummy;
  WriteLn ('OK')
end.
