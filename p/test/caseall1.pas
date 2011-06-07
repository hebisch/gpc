{ FLAG -Wall -Werror }

Program CaseAll1;

Var
  Meta: (Foo, Bar, Baz) value Foo;

begin
  case Meta of
    Foo: begin
           writeln ('OK');
           Halt (0);
         end { Foo };
    Baz: writeln ('baz');
  end { case };
  writeln ('failed')
end.
