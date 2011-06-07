{ FLAG --nested-comments }

Program Nest7;

(*$define FOO WriteLn (* This is a (* nested *) comment in a Pascal directive *) ('OK') *)

begin
  FOO
end.
