// Rclock - Options
unit Uclock4;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Spin, Buttons, MMSystem;

type
  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    GroupBox1: TGroupBox;
    SpinEdit1: TSpinEdit;
    Label8: TLabel;
    RadioGroup1: TRadioGroup;
    GroupBox4: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label15: TLabel;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    Label16: TLabel;
    GroupBox5: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label11: TLabel;
    GroupBox6: TGroupBox;
    Label5: TLabel;
    Label4: TLabel;
    Label10: TLabel;
    GroupBox7: TGroupBox;
    Label14: TLabel;
    Label13: TLabel;
    Panel01: TPanel;
    Panel02: TPanel;
    Panel03: TPanel;
    Panel04: TPanel;
    Panel05: TPanel;
    Panel06: TPanel;
    Panel07: TPanel;
    Panel08: TPanel;
    Panel09: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    ColorDialog1: TColorDialog;
    Button1: TButton;
    OpenDialog2: TOpenDialog;
    GroupBox8: TGroupBox;
    RadioGroup2: TRadioGroup;
    Button2: TButton;
    Button3: TButton;
    RadioGroup3: TRadioGroup;
    Panel13: TPanel;
    Label3: TLabel;
    Panel14: TPanel;
    Label9: TLabel;
    Bttester: TBitBtn;
    procedure Couleurclick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup3Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure BttesterClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form4: TForm4;

implementation

uses Uclock1, Uclock6;

{$R *.DFM}
Var
  Modifcolors : array[1..16] OF Tcolor;

procedure TForm4.Couleurclick(Sender: TObject);
var
  i : integer;
begin
  inc(modif);
  With sender as Tpanel do
  begin
    colordialog1.color := color;
    colordialog1.execute;
    color := colordialog1.color;
    i := strtoint(copy(name, length(name)-1,2)); { n° de panel panel }
    couleurs[i] := color;
  end;
end;

Procedure TForm4.Formactivate(sender: Tobject);
var
  i : integer;
Begin
  For i := 1 TO 16 do Modifcolors[i] := couleurs[i]; { sauve couleurs }
  Panel01.color := couleurs[01];
  Panel02.color := couleurs[02];
  Panel03.color := couleurs[03];
  Panel04.color := couleurs[04];
  Panel05.color := couleurs[05];
  Panel06.color := couleurs[06];
  Panel07.color := couleurs[07];
  Panel08.color := couleurs[08];
  Panel09.color := couleurs[09];
  Panel10.color := couleurs[10];
  Panel11.color := couleurs[11];
  Panel12.color := couleurs[12];
  Panel13.color := couleurs[13];
  Panel14.color := couleurs[14];
  Radiogroup1.itemindex := fond;
end;

procedure TForm4.Button1Click(Sender: TObject);
begin
  Radiogroup1.itemindex := 1;
  Form6.showmodal;
  IF form6.modalresult <> mroK then radiogroup1.itemindex := 0;
  inc(modif);
end;

procedure TForm4.RadioGroup2Click(Sender: TObject);
begin
  case radiogroup2.itemindex of
  0 : fichierwav := '';
  1 : fichierwav := '';
  end; { du case }
  inc(modif);
end;

procedure TForm4.Button2Click(Sender: TObject);
var
  son : array[0..128] of char;
begin
  IF radiogroup2.itemIndex = 2 then
  begin
    IF fileexists(fichierwav) then
    begin
      strpcopy(@son, fichierwav);
      sndplaysound(@son, SND_ASYNC OR SND_NOSTOP);
    end;
  end;
  IF radiogroup2.itemindex = 1 then
  begin
    beep;
  end;
end;

procedure TForm4.Button3Click(Sender: TObject);
begin
  fichierwav := '';
  IF opendialog2.execute then
  begin
    radiogroup2.itemindex := 2;
    fichierwav := opendialog2.filename
  end;
  IF fichierwav = '' then radiogroup2.itemindex := 1;
  inc(modif);
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  { la récupération paramètres de ini ne peut être effectué dans form1.create }
  radiogroup1.itemindex := fond;
  radiogroup2.itemindex := sonor;
  radiogroup3.itemindex := posdate;
  modif := 0;
end;

procedure TForm4.RadioGroup3Click(Sender: TObject);
begin
  inc(modif);
end;

procedure TForm4.SpinEdit1Change(Sender: TObject);
begin
  inc(modif);
end;

procedure TForm4.BttesterClick(Sender: TObject);
begin
  form1.nouveauxparams;
end;

end.
