{ COMPILE-CMD: fjf519i.cmp }
program foo;
const
  OK='OK';
  Failed='failed';

{$define OK Failed}

begin
  WriteLn (OK)
end.
