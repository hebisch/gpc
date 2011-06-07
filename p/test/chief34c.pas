program Chief34c;

type foo = record
  view : byte; { <--- compiler rejects this }
end;

begin
  WriteLn ('OK');
end.
