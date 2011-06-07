program Chief34a;

type foo = record
  value : byte; { <--- compiler rejects this }
end;

begin
  WriteLn ('OK');
end.
