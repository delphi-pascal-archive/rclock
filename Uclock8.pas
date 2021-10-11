// gestion des plages horaires
unit Uclock8;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Grids, ExtCtrls;

type
  TForm8 = class(TForm)
    BitBtn1: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Button1: TButton;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Panel3: TPanel;
    Button2: TButton;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    Panel4: TPanel;
    Button3: TButton;
    Label7: TLabel;
    Edit7: TEdit;
    Label8: TLabel;
    Edit8: TEdit;
    Panel5: TPanel;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form8: TForm8;

implementation

uses Uclock1;
{$R *.DFM}
procedure initform8;
begin
  with form8 do
  begin
  Edit1.text := '';
  Edit2.text := '';
  Edit3.text := '';
  Edit4.text := '';
  Edit5.text := '';
  Edit6.text := '';
  Edit7.text := '';
  Edit8.text := '';
  Panel2.color := clbtnface;
  Panel3.color := clbtnface;
  Panel4.color := clbtnface;
  Panel5.color := clbtnface;
  end;
end;

procedure afficheligne(n : integer);
var
  s1, s2 : string[2];
  s3 : string;
begin
  s1 := inttostr(plagehdeb[n]);
  s2 := inttostr(plagemdeb[n]);
  while length(s1) < 2 do s1 := ' '+s1;
  while length(s2) < 2 do s2 := '0'+s2;
  s3 := ' '+s1+' h '+s2;
  case n of
  1 : Form8.Edit1.text := s3;
  2 : Form8.Edit3.text := s3;
  3 : Form8.Edit5.text := s3;
  4 : Form8.Edit7.text := s3;
  end;
  s1 := inttostr(plagehfin[n]);
  s2 := inttostr(plagemfin[n]);
  while length(s1) < 2 do s1 := ' '+s1;
  while length(s2) < 2 do s2 := '0'+s2;
  s3 := ' '+s1+' h '+s2;
  case n of
    1 : Form8.Edit2.text := s3;
    2 : Form8.Edit4.text := s3;
    3 : Form8.Edit6.text := s3;
    4 : Form8.Edit8.text := s3;
  end;
  case n of
    1 : Form8.Panel2.color := plagecolo[n];
    2 : Form8.Panel3.color := plagecolo[n];
    3 : Form8.Panel4.color := plagecolo[n];
    4 : Form8.Panel5.color := plagecolo[n];
  end;
end;

procedure TForm8.Button1Click(Sender: TObject);
var
  i,j : integer;
begin
  i := 1;
  If sender = button1 then i := 1;
  If sender = button2 then i := 2;
  If sender = button3 then i := 3;
  If sender = button4 then i := 4;
  IF maxplage > 0 then
  begin
    For j := maxplage-1 downto i do
    begin
      plagehdeb[j] := plagehdeb[j+1];
      plagemdeb[j] := plagemdeb[j+1];
      plagehfin[j] := plagehfin[j+1];
      plagemfin[j] := plagemfin[j+1];
      plagecolo[j] := plagecolo[j+1];
    end;
    dec(maxplage);
  end;
  initform8;
  for i := 1 to maxplage do afficheligne(i);
end;


procedure TForm8.FormActivate(Sender: TObject);
var
  i : integer;
begin
  initform8;
  for i := 1 to maxplage do afficheligne(i);
end;

end.
