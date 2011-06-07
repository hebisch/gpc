unit Unit1;

interface

{$if 0 }

type
  TForm1 = class(TForm)
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

{$endif }

Procedure OK;

implementation

{$if 0 }

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
   Label1.Caption := 'Hello World!';
end;

{$endif }

Procedure OK;

begin { OK }
  writeln ( 'OK' );
end { OK };

end.
