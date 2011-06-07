{ BUG: Constant initialized by a function call.
  Should this be a compile-time failure? EP doesn't allow it.
  Otherwise, of course, bar must be called only once. }

program drf10a;

function bar : Integer;
begin
  bar := 42
end;

const
  foo = bar;  { WRONG }

begin
end.
