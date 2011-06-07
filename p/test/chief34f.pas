program Chief34f;

var
  static : byte; { <--- compiler rejects this }

begin
  static := static;
  WriteLn ('OK');
end.
