{ FLAG --nested-comments -Werror }

(* COMPILE-CMD: nest22.cmp *)

Program Nest22;

{$ { This is a { nested } comment in a Pascal directive } M "Foo" { This is a { nested } comment in a Pascal directive }"Bar" }

begin
end.
