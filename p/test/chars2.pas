Program Chars2;

Var
  foo: 'A'..'Z';

begin
  for foo:= 'Z' downto 'A' do
    case foo of
      'O', 'K': write ( foo );
    end { case };
  writeln;
end.
