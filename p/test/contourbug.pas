{ BUG with goto ... }

program CountourBug;

(*
  Running this program with the command line:

    gpc --gnu-pascal --stack-checking -S contourbug.pas

  produces:

    contourbug.pas: In procedure `Q':
    contourbug.pas:57: label `1' used before containing binding contour

  An examination of the assembly code produced reveals this very odd
  set of instructions (compiler configured for i486-pc-mingw32msvc):

    _Q:
          pushl %ebp
          movl %esp,%ebp
          subl $28,%esp
          pushl %edi
          pushl %esi
          pushl %ebx
          movl %esp,-8(%ebp)
  ===>    leal -4392(%esp),%eax
  ===>    movl $0,(%eax)
          movl -4(%ebp),%eax
          movl %eax,-12(%ebp)
          movl $L7,-4(%ebp)
          movl %esp,%esi
          jmp L4
  ===>    leal -4440(%esp),%eax
  ===>    movl $0,(%eax)

  Something appears to be seriously wrong here; perhaps some sort of
  uninitialized variable problem within the compiler?

  Frank: No, that's the stack checking code. The problem is related
  to the `goto' and to what GPC does internally with strings. It can
  be reproduced in C, using local variables of variable size and a
  certain way of using `{ ... }' groups.
*)

procedure p (str: string);

begin
end;


var
  Dummy: Integer value 0;


procedure q;

label 1;

begin
  goto 1;
  p ('123456789.123456789.123456789.12');

{ Note that shortening the above constant string by one character
  eliminates the error message and produces dramatically different
  generated assembly code. }

1:Dummy := 42  { just to avoid a `statement with no effect' warning for the call of `q' }
end;


begin
  q;
  WriteLn ('OK')
end.
