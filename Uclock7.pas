// Rclock  Création de plage horaire
unit Uclock7;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Spin;

type
  TForm7 = class(TForm)
    Spinh1: TSpinButton;
    Edit1: TEdit;
    SpinMN1: TSpinButton;
    Label5: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    BitBtn5: TBitBtn;
    BitBtn4: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    SpinH2: TSpinButton;
    Edit2: TEdit;
    SpinMn2: TSpinButton;
    Bevel1: TBevel;
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Spinh1DownClick(Sender: TObject);
    procedure Spinh1UpClick(Sender: TObject);
    procedure SpinMN1DownClick(Sender: TObject);
    procedure SpinMN1UpClick(Sender: TObject);
    procedure SpinH2DownClick(Sender: TObject);
    procedure SpinH2UpClick(Sender: TObject);
    procedure SpinMn2DownClick(Sender: TObject);
    procedure SpinMn2UpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form7: TForm7;

implementation

{$R *.DFM}
uses Uclock1;


procedure afficheheuredeb;
Var
  s : string;
begin
  with form7 do
  begin
    s := inttostr(plagemdeb[maxplage]);
    while length(s) < 2 do s := '0'+s;
    s := inttostr(plagehdeb[maxplage])+' h '+s;
    IF plagehdeb[maxplage] < 10 then  s := ' '+s;
    edit1.text := s;
  end;
end;

procedure afficheheurefin;
Var
  s : string;
begin
  with form7 do
  begin
    s := inttostr(plagemfin[maxplage]);
    while length(s) < 2 do s := '0'+s;
    s := inttostr(plagehfin[maxplage])+' h '+s;
    IF plagehfin[maxplage] < 10 then  s := ' '+s;
    edit2.text := s;
  end;
end;

procedure TForm7.SpinH1DownClick(Sender: TObject);
begin
  dec(plagehdeb[maxplage]);
  if plagehdeb[maxplage] < 0 then plagehdeb[maxplage] := 23;
  afficheheuredeb;
end;

procedure TForm7.SpinH1UpClick(Sender: TObject);
begin
  inc(plagehdeb[maxplage]);
  if plagehdeb[maxplage] > 23 then plagehdeb[maxplage] := 0;
  afficheheuredeb;
  if plagehdeb[maxplage] >= plagehfin[maxplage] then
  begin
    plagehfin[maxplage] := plagehdeb[maxplage] +1;
    afficheheurefin;
  end;
end;

procedure TForm7.SpinMN1DownClick(Sender: TObject);
begin
  dec(plagemdeb[maxplage], 5);
  if plagemdeb[maxplage] < 0 then
  begin
    plagemdeb[maxplage]:= 55;
    spinH1downclick(sender);
  end;
  afficheheuredeb;
end;

procedure TForm7.SpinMN1UpClick(Sender: TObject);
begin
  inc(plagemdeb[maxplage],5);
  if plagemdeb[maxplage] > 59 then
  begin
    plagemdeb[maxplage]:= 0;
    spinH1upclick(sender);
  end;
  afficheheuredeb;
  if plagehfin[maxplage] <= plagehdeb[maxplage] then
  begin
    plagehdeb[maxplage] := plagehfin[maxplage] -1;
    afficheheuredeb;
  end;
end;

procedure TForm7.SpinH2DownClick(Sender: TObject);
begin
  dec(plagehfin[maxplage]);
  if plagehfin[maxplage] < 0 then plagehfin[maxplage] := 23;
  afficheheurefin;
end;

procedure TForm7.SpinH2UpClick(Sender: TObject);
begin
  inc(plagehfin[maxplage]);
  if plagehfin[maxplage] > 23 then plagehfin[maxplage] := 0;
  afficheheurefin;
end;

procedure TForm7.SpinMN2DownClick(Sender: TObject);
begin
  dec(plagemfin[maxplage], 5);
  if plagemfin[maxplage] < 0 then
  begin
    plagemfin[maxplage]:= 55;
    spinH2downclick(sender);
  end;
  afficheheurefin;
end;

procedure TForm7.SpinMN2UpClick(Sender: TObject);
begin
  inc(plagemfin[maxplage], 5);
  if plagemfin[maxplage] > 59 then
  begin
    plagemfin[maxplage]:= 0;
    spinH2upclick(sender);
  end;
  afficheheurefin;
end;

procedure TForm7.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  shape1.pen.width := 1;
  shape2.pen.width := 1;
  shape3.pen.width := 1;
  shape4.pen.width := 1;
  shape5.pen.width := 1;
  shape6.pen.width := 1;
  shape7.pen.width := 1;
  shape8.pen.width := 1;
  with sender as Tshape do pen.width := 3;
  IF sender = shape1 then plagecolo[maxplage] := shape1.brush.color else
  IF sender = shape2 then plagecolo[maxplage] := shape2.brush.color else
  IF sender = shape3 then plagecolo[maxplage] := shape3.brush.color else
  IF sender = shape4 then plagecolo[maxplage] := shape4.brush.color else
  IF sender = shape5 then plagecolo[maxplage] := shape5.brush.color else
  IF sender = shape6 then plagecolo[maxplage] := shape6.brush.color else
  IF sender = shape7 then plagecolo[maxplage] := shape7.brush.color else
  IF sender = shape8 then plagecolo[maxplage] := shape8.brush.color ;
end;

procedure TForm7.FormActivate(Sender: TObject);
begin
  afficheheuredeb;
  afficheheurefin;
  shape1Mousedown(shape1, mbleft, [], shape1.left, shape1.top);
end;

end.
