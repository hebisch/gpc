program Chief34d;

var
  view : byte; { <--- compiler rejects this }

begin
  view := view;
  WriteLn ('OK');
end.
