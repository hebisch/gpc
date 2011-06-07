{ FLAG --nested-comments -Werror }

Program Nest21;

(*$X-*)

(*$ (* This is a (* nested *) comment in a Pascal directive *) W+ (* This is a (* nested *) comment in a Pascal directive *) , (* This is a (* nested *) comment in a Pascal directive *) X+ (* This is a (* nested *) comment in a Pascal directive *) *)

var s : String (10);

begin
  s := 'OKfailed';
  SetLength (s, 2);
  WriteLn (s)
end.
