{ FLAG --nested-comments }

Program Nest13;

(*$define FOO Write (* This is a (* nested \
  multiline *) comment in a Pascal directive *) ('O')
  *)
(*$undef BAR (* This is a (* nested \
  multiline *) comment in a Pascal directive *)     *)

begin
(*$ifdef FOO (* This is a (* nested \
  multiline *) comment in a Pascal ifdef *)  *)
  FOO;
(*$else (* This is a (* nested \
  multiline *) comment in a Pascal else *)*)
  WriteLn ('failed');
(*$endif (* This is a (* nested \
  multiline *) comment in a Pascal endif *) *)
(*$ifdef BAR (* This is a (* nested \
  multiline *) comment in a Pascal ifdef *) *)
  WriteLn ('failed');
(*$else (* This is a (* nested \
  multiline *) comment in a Pascal else *) *)
  WriteLn ('K')
(*$endif (* This is a (* nested \
  multiline *) comment in a Pascal endif *)*)
end.
