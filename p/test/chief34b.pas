program Chief34b;

type foo = record
  static : byte; { <--- compiler rejects this }
end;

begin
  WriteLn ('OK');
end.
