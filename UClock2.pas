// Rclock Création d'une alarme
unit UClock2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Grids, StdCtrls, Calendar, ColorGrd, Buttons, Spin, ComCtrls;

type
  TForm2 = class(TForm)
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Panel1: TPanel;
    Label4: TLabel;
    SpinH: TSpinButton;
    Edit1: TEdit;
    SpinMN: TSpinButton;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Label1: TLabel;
    Edit2: TEdit;
    Bevel1: TBevel;
    Edit3: TEdit;
    SpinButton3: TSpinButton;
    procedure SpinHDownClick(Sender: TObject);
    procedure SpinHUpClick(Sender: TObject);
    procedure SpinMNDownClick(Sender: TObject);
    procedure SpinMNUpClick(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpinButton3DownClick(Sender: TObject);
    procedure SpinButton3UpClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

uses Uclock1;

procedure afficheheure;
Var
  s : string;
begin
  with form2 do
  begin
    s := inttostr(curalarm.almin);
    while length(s) < 2 do s := '0'+s;
    s := inttostr(curalarm.alheure)+' h '+s;
    IF curalarm.alheure < 10 then  s := ' '+s;
    edit1.text := s;
  end;
end;

procedure affichedelai;
Var
  s : string;
begin
  with form2 do
  begin
    s := inttostr(curalarm.aldelai);
    if length(s) < 2 then s := ' '+s;
    s := s+' mn';
    edit3.text := s;
  end;
end;

procedure TForm2.SpinHDownClick(Sender: TObject);
begin
  IF curalarm.alheure > 0 then
  dec(curalarm.alheure)
    else
  curalarm.alheure := 23;
  afficheheure;
end;

procedure TForm2.SpinHUpClick(Sender: TObject);
begin
  inc(curalarm.alheure);
  if curalarm.alheure > 23 then curalarm.alheure := 0;
  afficheheure;
end;

procedure TForm2.SpinMNDownClick(Sender: TObject);
begin
  if curalarm.almin > 0 then dec(curalarm.almin)
  else
  begin
    curalarm.almin := 59;
    spinHdownclick(sender);
  end;
  afficheheure;
end;

procedure TForm2.SpinMNUpClick(Sender: TObject);
begin
  IF curalarm.almin < 59 then inc(curalarm.almin)
  else
  begin
    curalarm.almin := 0;
    spinHupclick(sender);
  end;
  afficheheure;
end;

procedure TForm2.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
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
  with sender as Tshape do
  begin
    IF (brush.color = clblue) or (brush.color = clsilver)
    then edit1.font.color := clwhite else edit1.font.color := clblack;
    edit1.color := brush.color;
    pen.width := 3;
  end;
  IF sender = shape1 then curalarm.alcolo := 0 else
  IF sender = shape2 then curalarm.alcolo := 1 else
  IF sender = shape3 then curalarm.alcolo := 2 else
  IF sender = shape4 then curalarm.alcolo := 3 else
  IF sender = shape5 then curalarm.alcolo := 4 else
  IF sender = shape6 then curalarm.alcolo := 5 else
  IF sender = shape7 then curalarm.alcolo := 6 else
  IF sender = shape8 then curalarm.alcolo := 7 ;
end;


procedure TForm2.SpinButton3DownClick(Sender: TObject);
begin
  IF curalarm.aldelai > 0 then dec(curalarm.aldelai);
  affichedelai;
end;

procedure TForm2.SpinButton3UpClick(Sender: TObject);
begin
  inc(curalarm.aldelai);
  IF curalarm.aldelai > 60 then curalarm.aldelai := 60;
  affichedelai;
end;

end.
