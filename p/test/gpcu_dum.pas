{ Only for test suite internal purposes to compile a C file without
  having to get the name of the corresponding C compiler (possibly
  cross-compiler or newly built compiler), by letting GPC or GP find
  the C compiler. }

program { Line break so this is not tested by itself. }
  Dummy;

{$L gpcu_c_c.c}

begin
end.
