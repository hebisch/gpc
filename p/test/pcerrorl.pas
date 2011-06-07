program PCErrorL;

type
etype = (ECHR, EHALT);

var
variant :record
        case boolean of
        true:(val :1..100);
        false:(name :etype)
        end;

begin
writeln(variant.name);  { WRONG }
end.
