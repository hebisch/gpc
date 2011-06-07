{ Parse this!

  Note: It's about the type declarations. The procedures are there
  just so we can use the same identifiers with different meanings,
  for maximum confusion.

  -- No problem with the GLR parser. :-) Frank, 20031001 }

program fjf622;

procedure p0;
type t = (a, b);
begin
  if (Ord (Low (t)) <> 0) or (Ord (High (t)) <> 1) then
    begin
      WriteLn ('failed 0');
      Halt
    end
end;

procedure p1;
type t = (a);
begin
  if (Ord (Low (t)) <> 0) or (High (t) <> Low (t)) then
    begin
      WriteLn ('failed 1');
      Halt
    end
end;

procedure p2;
const a = 4;
type t = (a) .. 10;
begin
  if (Low (t) <> 4) or (High (t) <> 10) then
    begin
      WriteLn ('failed 2');
      Halt
    end
end;

procedure p3;
type t = Sqr (2) .. 10;
begin
  if (Low (t) <> 4) or (High (t) <> 10) then
    begin
      WriteLn ('failed 3');
      Halt
    end
end;

procedure p4;
type Sqr = Integer;
type t = Sqr (2) .. 10;
begin
  if (Low (t) <> 2) or (High (t) <> 10) then
    begin
      WriteLn ('failed 4');
      Halt
    end
end;

procedure p5;
type Sqr (d: Integer) = array [1 .. d] of Integer;
type t = Sqr (2);
begin
  if (Low (t) <> 1) or (High (t) <> 2) then
    begin
      WriteLn ('failed 5');
      Halt
    end
end;

procedure p6;
type t = Integer (5) .. 10;
begin
  if (Low (t) <> 5) or (High (t) <> 10) then
    begin
      WriteLn ('failed 6');
      Halt
    end
end;

procedure p7;
type t = Integer attribute (Size = 5);  { formerly: `Integer (5)' which was a conflict, now harmless }
begin
  if (Low (t) <> -16) or (High (t) <> 15) then
    begin
      WriteLn ('failed 7');
      Halt
    end
end;

procedure p8;
type t = @Integer = nil;
var a: t;
begin
  if (Low (a^) <> Low (Integer)) or (High (a^) <> MaxInt) or (a <> nil) then
    begin
      WriteLn ('failed 8');
      Halt
    end
end;

procedure p9;
var Integer: Word; attribute (static);
type t = @Integer <> nil .. True;
begin
  if (Low (t) <> True) or (High (t) <> True) then
    begin
      WriteLn ('failed 9');
      Halt
    end
end;

begin
  p0;
  p1;
  p2;
  p3;
  p4;
  p5;
  p6;
  p7;
  p8;
  p9;
  WriteLn ('OK')
end.
