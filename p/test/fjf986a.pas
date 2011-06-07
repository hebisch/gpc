program fjf986a;

type
  a = packed array [1 .. 1] of Char;

const
  c = a[1: 'B'];

begin
  case c of {WRONG}
    'B':
  end;
end.
