{ COMPILE-CMD: fjf519h.cmp }
program foo;
const
  OK='failed';
  Failed='OK';

{$define OK Failed}

begin
  WriteLn (OK)
end.
