// Rclock Gestion des alarmes
unit Uclock3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TForm3 = class(TForm)
    ListBox1: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    BitBtn1: TBitBtn;
    Image1: TImage;
    Button1: TButton;
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form3: TForm3;

implementation

{$R *.DFM}

procedure TForm3.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
Var
  code : string[1];
  aa : string[2];  { tronquée à 2 c }
  mm : string[2];
  jj : string[2];
  hh : string[2];
  mn : string[2];
  cc : string[1];
  al : string[2];
  tt : string[50];
  s : string[80];
  icolor : integer;
begin
  s := listbox1.items[index];
  code := copy(s,1,1);
  aa := copy(s,4,2);   { année sans le siècle }
  mm := copy(s,6,2);
  jj := copy(s,8,2);
  hh := copy(s,10,2);
  mn := copy(s,12,2);
  cc := copy(s,14,1);
  al := copy(s,15,2);
  IF al[1] = '0' Then al[1] := ' ';
  tt := copy(s,17,50);
  s :=  jj+'-'+mm+'-'+aa;
  With listbox1.canvas do
  begin
    textout(panel3.Left+4, Rect.top+1, s);
    s := hh+'h'+mn;
    textout(panel4.left+panel4.width-8-textwidth(s), rect.top+1, s);
    Icolor  := strtoint(cc);
    case icolor of
    0 : pen.color := clwhite;
    1 : pen.color := clfuchsia;
    2 : pen.color := clred;
    3 : pen.color := clsilver;
    4 : pen.color := clyellow;
    5 : pen.color := cllime;
    6 : pen.color := claqua;
    7 : pen.color := clblue;
    end;
    pen.width := 2;
    rectangle(panel5.left,rect.top, panel5.left+panel5.width-3, rect.bottom-1);
    pen.width := 1;
    s := '-'+al+'mn';
    textout(panel5.left+panel5.width-22-textwidth(s), rect.top+1, s);
    IF code = '0' then draw(panel6.left-18, rect.top, Image1.picture.bitmap);
    Textout(panel6.left+5, rect.top+1, tt);
    pen.color := clbtnface;
    moveto(panel6.left-2, rect.top);
    lineto(panel6.left-2, rect.bottom);
    moveto(rect.left, rect.bottom-1);
    lineto(rect.right, rect.bottom-1);
  end;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  IF listbox1.itemindex > -1 then Listbox1.items.delete(listbox1.itemindex);
end;

end.
