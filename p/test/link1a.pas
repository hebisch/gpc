Program Link1a;

{ The same as link1.pas -- the error does not occur the first time }

{$L link2.pas }

Procedure OK; external name 'OK';

begin
  OK;
end.
