Program ISO ( Output );

{ FLAG --extended-pascal }

{ Redefinition of Borland keywords }

Const
  Absolute = 'O';
  Shl = 'K';

Type
  Uses = Char;

Var
  Operator: Uses value Shl;
  Object: Uses value Absolute;

  { Object may be redefined everywhere but in a type definition. }
  { Absolute may be redefined everywhere and even used in such a }
  { dangerous context as above.                                  }

begin
  writeln ( Object, Operator );
end.
