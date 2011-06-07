program fjf806a;

var
  s: String (2);

procedure p1 (a: String);
begin
  if @a = @s then begin WriteLn ('failed 1'); Halt end
end;

procedure p2 (protected a: String);
begin
  if @a = @s then begin WriteLn ('failed 2'); Halt end
end;

procedure p3 (var a: String);
begin
  if @a <> @s then begin WriteLn ('failed 3'); Halt end
end;

procedure p4 (protected var a: String);
begin
  if @a <> @s then begin WriteLn ('failed 4'); Halt end
end;

procedure p5 (const a: String);
begin
  if @a <> @s then begin WriteLn ('failed 5'); Halt end
end;

procedure q1 (a: String);
begin
end;

procedure q2 (protected a: String);
begin
end;

procedure q3 (const a: String);
begin
end;

begin
  p1 (s);
  p2 (s);
  p3 (s);
  p4 (s);
  p5 (s);
  q1 ('');
  q2 ('');
  q3 ('');
  WriteLn ('OK')
end.
