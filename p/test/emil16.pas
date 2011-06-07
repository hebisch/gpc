{ The RTS doesn't track the length and current position of
  file variables, and tries to compute them from the byte-size of the file
  when needed. This is wrong for "file of record end" and similar beasts,
  because

  (i) it makes EOF always return False (in Inspection mode, at least)

  (ii) most direct access functions raise a "division by zero" signal

  Fixed now by making sure that the size on the file level is always
  at least one byte. (This may be changed to one bit later when
  packed files are supported.) }

program FileTest (Output);
{$macros}

const
  MaxLen  = 100;
  Len     = 42;
  TestPos = 13;

type
  EmptyType = record end;

var
  F: file of EmptyType;
  G: file [1 .. MaxLen] of EmptyType;
  I: Integer;
  OK: Boolean value True;

{$define Fail(Pass, Pos, Func, Result)
    begin
      WriteLn ('failed ', Pass, ': ', Pos : 5, ' ... ', Func, ' = ', Result);
      OK := False
    end
}

begin
  Rewrite (F);
  for I := 1 to Len do begin
    if not EOF (F) then           Fail (0, I, 'EOF', False);
    Put (F)
  end;

  Reset (F);
  for I := 1 to Len do begin
    if EOF (F) then               Fail (1, I, 'EOF', True);
    Get (F)
  end;
  if not EOF (F) then             Fail (1, '(end)', 'EOF', False);

  Rewrite (G);
  for I := 1 to Len do begin
    if not EOF (G) then           Fail (2, I, 'EOF', False);
    if Position (G) <> I then     Fail (2, I, 'Position', Position (G));
    Put (G);
    if LastPosition (G) <> I then Fail (2, I, 'LastPosition', LastPosition (G))
  end;

  Reset (G);
  for I := 1 to Len do begin
    if EOF (G) then               Fail (3, I, 'EOF', True);
    if Position (G) <> I then     Fail (3, I, 'Position', Position (G));
    Get (G)
  end;
  if not EOF (G) then             Fail (3, '(end)', 'EOF', False);

  if Empty (G) then               Fail (3, '(end)', 'Empty', True);

  SeekUpdate (G, TestPos);
  Update (G);
  if EOF (G) then                 Fail (4, TestPos, 'EOF', True);
  if Position (G) <> TestPos then Fail (4, TestPos, 'Position', Position (G));
  if LastPosition (G) <> Len then Fail (4, TestPos, 'LastPosition', LastPosition (G));

  if OK then WriteLn ('OK')
end.
