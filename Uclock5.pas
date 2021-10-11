// Rclock affichage d'alarme
unit Uclock5;

interface

uses
  MMsystem, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtCtrls, Buttons;

type
  TForm5 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    Edit1: TEdit;
    SpinButton1: TSpinButton;
    BitBtn1: TBitBtn;
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form5  : TForm5;
  F5mn   : integer;

implementation

uses Uclock1, Uclock4;

{$R *.DFM}

procedure TForm5.SpinButton1DownClick(Sender: TObject);
begin
  dec(F5mn);
  IF f5mn < 0 then F5mn := 0;
  edit1.text := ' '+inttostr(F5mn)+' mn';
  IF f5mn < 10 then edit1.text := ' '+edit1.text;
end;

procedure TForm5.SpinButton1UpClick(Sender: TObject);
begin
  inc(F5mn);
  IF f5mn > 60 then F5mn := 60;
  edit1.text := ' '+inttostr(F5mn)+' mn';
  IF f5mn < 10 then edit1.text := ' '+edit1.text;
end;

procedure TForm5.CheckBox1Click(Sender: TObject);
begin
  IF Checkbox1.checked then
  begin
    label2.visible := true;
    edit1.visible := true;
    spinbutton1.visible := true;
  end
  else
  begin
    label2.visible := false;
    edit1.visible := false;
    spinbutton1.visible := false;
  end;
end;

procedure TForm5.FormActivate(Sender: TObject);
var
  son : array[0..128] of char;
begin
  Case form4.radiogroup2.Itemindex of
  1 : messagebeep(0);
  2 : begin
        IF fichierwav <> '' then
        begin
          strpcopy(@son, fichierwav);
          sndplaysound(@son, SND_ASYNC OR SND_NOSTOP);
        end
        else { si pas de fichier beep quand même }
         messagebeep(0);
      end;
  end;
  F5mn := 5;
  Edit1.text := ' '+inttostr(F5mn)+' mn';
  Checkbox1.checked := false;
  label2.visible := false;
  edit1.visible := false;
  spinbutton1.visible := false;
end;



end.
