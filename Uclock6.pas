// Rclock Chargement d'une image
unit Uclock6;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, FileCtrl, ComCtrls, Spin;

type
  TForm6 = class(TForm)
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    BitBtn1: TBitBtn;
    SpinButton1: TSpinButton;
    Edit1: TEdit;
    Label1: TLabel;
    BitBtn2: TBitBtn;
    Label2: TLabel;
    procedure FileListBox1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form6: TForm6;

implementation

Uses Uclock1;

{$R *.DFM}

Var
  wx, wy , ww, wh: integer;
  pct : integer;  { pourcentage de taille du cercle par rapport au + petit }
                  { côté min0 de Bmp0}
  min0 : integer;
  deplace : boolean;
  debutx, debuty : integer;
  cx6, cy6 : integer;
  basex6, basey6 : integer;
  rayon : integer;
  min6  : integer;  { rayon = min6*pct / 500 }

Procedure limites;
begin
  IF cx6 < rayon then cx6 := rayon;
  IF cy6 < rayon then cy6 := rayon;
  With Form6.Paintbox1 do
  begin
    IF cx6 > width-rayon-1  then cx6 := width  - rayon-1;
    IF cy6 > height-rayon-1 then cy6 := height - rayon-1;
  end;
end;

procedure chargebitmap;
var
  maxi0, k : integer;
begin
  With form6.Paintbox1.canvas do  { efface paintbox1 }
  begin
    brush.color := clbtnface;
    fillrect(rect(0,0,form6.Paintbox1.width, form6.paintbox1.height));
  end;
  IF Bmp0.Width > Bmp0.height then
  begin
    maxi0 := Bmp0.width;
    min0  := Bmp0.height;
  end
  else
  begin
    maxi0 := Bmp0.height;
    min0 := Bmp0.width;
  end;
  K := form6.panel1.width - 16;  { 8 bits de marge mini entre panel1 et paintbox1 }
  { le coefficient pour la taille est  k/maxi }
  IF (bmp0.width <= K) AND (bmp0.height <= K) then
  begin
    ww := bmp0.width;
    wh := bmp0.height;
  end
  else
  begin
    ww := (Bmp0.width*k)  div maxi0;
    wh := (Bmp0.height*k) div maxi0;
  end;  
  { centrage }
  with form6 do
  begin
    wx := (panel1.width-ww) div 2;
    wy := (panel1.height-wh) div 2;
    Paintbox1.left   := wx;
    Paintbox1.top    := wy;
    Paintbox1.width  := ww;
    Paintbox1.height := wh;
    pct := 80;
    Edit1.text := ' '+inttostr(pct)+'%';
    IF ww > wh then min6 := wh else min6 := ww;
    rayon := (min6*pct) div 200;
    cx6 := rayon;
    cy6 := rayon;
    Paintbox1paint(form6);
  end;
end;

procedure TForm6.FileListBox1Click(Sender: TObject);
begin
  IF form1.lectureimage(Filelistbox1.filename) then
  begin
    caption := 'Rclock - '+Thefile;
    chargebitmap;
  end
  else thefile := '';
end;

procedure TForm6.PaintBox1Paint(Sender: TObject);
begin
  IF (Bmp0.empty = false) and (ww > 0) then
  begin
    selectpalette(Paintbox1.canvas.handle, Bmp0.palette, false);
    Realizepalette(Paintbox1.canvas.handle);
    With Paintbox1.Canvas do
    begin
      setstretchbltmode(Paintbox1.canvas.handle, coloroncolor);
      stretchdraw(rect(0, 0, ww, wh), Bmp0);
      brush.style := bsclear;
      pen.color := clred;
      ellipse(cx6-rayon, cy6-rayon, cx6+rayon, cy6+rayon); { cercle }
      moveto(cx6-4, cy6);lineto(cx6+4, cy6);  { viseur aun centre }
      moveto(cx6, cy6-4); lineto(cx6, cy6+4);
    end;
    { calcul du cercle sur Bitmap0 pour utilisation dans Uclock1 }
    r0  := (min0*pct) div 200 - 2;
    cx0 := (cx6 * Bmp0.width)  div ww;
    cy0 := (cy6 * Bmp0.height) div wh;
  end;
end;

procedure TForm6.SpinButton1DownClick(Sender: TObject);
begin
  Dec(pct,5);
  IF pct < 20 then pct := 20;
  Edit1.text := ' '+inttostr(pct)+'%';
  rayon := (min6*pct) div 200;
  limites;
  paintbox1paint(sender);
  filelistbox1.setfocus;
end;

procedure TForm6.SpinButton1UpClick(Sender: TObject);
begin
  inc(pct,5);
  IF pct > 100 then pct := 100;
  Form6.Edit1.text := ' '+inttostr(pct)+'%';
  rayon := (min6*pct) div 200;
  limites;
  paintbox1paint(sender);
  filelistbox1.setfocus;
end;

procedure TForm6.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  deplace := true;
  debutx := x;
  debuty := y;
  basex6 := cx6;
  basey6 := cy6;
end;

procedure TForm6.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  IF deplace then
  begin
    cx6 := basex6+ X -debutx;
    cy6 := basey6+ Y -debuty;
    limites;
    paintbox1paint(sender);
  end;
end;

procedure TForm6.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  deplace := false;
  filelistbox1.setfocus;
end;

procedure TForm6.FormCreate(Sender: TObject);
begin
  ww := 0;
end;

end.
