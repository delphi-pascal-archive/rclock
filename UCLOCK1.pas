
// Rclovk fiche principale
unit Uclock1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus, Inifiles, StdCtrls, Jpeg;

  { enregistrement Talarm stocké sous forme de chaine dans TListbox1 }
  { #yyyymmjjhhmn@alzzzzzzz libellé 50 c zzzzzzzzzzzz}
  { positions utilisées : code 1,aaaa 2, mm 6, jj 8, hh 10, mn 12 }
  {                       couleur 14, minutes alarme 15, libellé 17 }
  { # = code = 0 si alarme exécutée ou dépassée, 1 si alarme en cours }
type Talarm = class(Tobject)
   alactive : boolean;
   alannee  : word;
   almois   : word;
   aljour   : word;
   alheure  : word;
   almin    : word;
   alsec    : word;
   alms     : word;
   alcolo   : integer;
   aldelai  : integer;
   altexte  : string[50];
   Procedure raz;
   Procedure setdatetime(wdt : Tdatetime);
   Procedure alarmtostr(var s : shortstring);
   Procedure strtoalarm(var s : shortstring);
   Procedure addminutes(mn : word);
   Function  getalarme : Tdatetime;
   Function  getdatetime : Tdatetime;
   Function  getcolor : Tcolor;
end;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Timer2: TTimer;
    PaintBox1: TPaintBox;
    PopupMenu1: TPopupMenu;
    Quitter1: TMenuItem;
    Alarme1: TMenuItem;
    Reduire1: TMenuItem;
    Liste: TMenuItem;
    N1: TMenuItem;

    Options1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Plagehoraire1: TMenuItem;
    Listeplages1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Quitter1Click(Sender: TObject);
    procedure Alarme1Click(Sender: TObject);
    procedure ListeClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Reduire1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure Plagehoraire1Click(Sender: TObject);
    procedure Listeplages1Click(Sender: TObject);
    procedure AppliOnrestore(Sender: Tobject);

  private
    { Déclarations privées }
    Procedure Initsincos;    { précalcul des sinus et cosinus 0..360 degrés }
    { donne le rang dans la palette pour un dégradé }
    Function  Calculcolo( code,    { 0 dégradé  COLO1..COLO2 et 1 = COLO3..COLO4  }
                          plage1, plage2,        { plage du coefficient }
                          coef: integer): integer;
    { fonction de calcul positions wx et xy en fonction de temps et rayon }
    Procedure Timetoxy(style,              { 0 heure, 1 minutes, 2 secondes }
                       k1 ,k2,    { Heure+mn ou mn+sec ou sec+0 selon style }
                       r : integer;                       { rayon du cercle }
                       var wx, wy: longint );     { coordonnées du résultat }
    Procedure Horloge(cancan : Tcanvas);                  { dessine horloge }
    Procedure Affaiguille(cancan : Tcanvas;          { affiche une aiguille }
                          style, k1, k2 : integer;          { voir timetoxy }
                          c1,                  { couleur extérieur aiguille }
                          c2 : tcolor);        { couleur intérieur aiguille }
    Procedure Affplageh(cancan : Tcanvas; { arc de cercle pour plage horaire}
                        h1, mn1, h2, mn2 : integer; c : tcolor);
    Procedure AffAlarme(cancan : tcanvas;    { point clignotant pour alarme }
                        h, mn, tempo : integer; c1, c2 : tcolor);
    Procedure Setcolorpalette(n: integer; c: Tcolor);
    Procedure Calculrayons;
    Procedure creepalette;
  public
    { Déclarations publiques }
    Function lectureImage(nomfichier: string): boolean;
    procedure NouveauxParams;
end;

var
  Form1: TForm1;
  { saisie d'une l'alarme }
  curalarm : talarm;
  manoalarm : Talarm;
  { gestion de la palette }
  Newpalette : HPalette;                   { nouvelle palette pour dégradés }
  OldPal : HPalette;                             { ancien Handle de palette }
  pPal  : PLOGPALETTE;                      { pointeur vers palette logique }

  {--------- préférences sauvegardées sur Rclock.ini -----------------------}
  sz : integer;                            { taille de l'horloge (diamètre) }
  couleurs  : array[1..16] OF TCOLOR;           { couleurs personnalisables }
  Thefile : Tfilename;  { nom complet de Bmp0, espaces si non utilisé }
  cx0, cy0, r0 : Integer;     { position centre cercle et rayon sur Bmp0    }
  Fichierwav   : Tfilename;          { nom complet fichier son pour alarme }
  sonor        : integer;     { type d'alarme sonore cf. Form4 radiogroup2 }
  fond         : integer;     { type de fond cf form4 radiogroup1 }
  posdate      : integer;     { position de la date form4.radiogroup 3 }
  {------- bitmaps pour dessiner l'horloge }
  {Si un bitmap de fond est choisi, il est chargé dans Bmp0. La portion
   ronde utile de Bmp0 est centrée en cx0 cy0 avec un rayon r0.
   L'horloge est dessinée sur Bmp1 avec son fond et ses graduations. Le fond
   peut être Bmp0 ou un dégradé de couleurs créé dans newpalette.
   Dans Ontimer1, à chaque seconde, copie de Bmp1 sur Bmp2 et dessin des
   aiguilles sur Bmp2 (Bmp1 a effacé les aiguilles). Affichage de Bmp2 dans
   le canvas de la fiche. Cette technique évite le clignotement qui se
   produit quand on dessine directement les aiguilles sur la fiche. }
  Bmp0 : Tbitmap;       { cadran de l'horloge }
  Bmp1 : Tbitmap;       { dessin horloge sans aiguilles }
  Bmp2 : tbitmap;       { dessin caché horloge+aiguille }
  modif : integer;      { nombre de modifs options }

  { 4 plages horaires maxi utilisées par form7 }
  maxplage   : integer;  { rang plage maxi }
  plagehdeb  : array[1..4] of integer;
  plagemdeb  : array[1..4] of integer;
  plagehfin  : array[1..4] of integer;
  plagemfin  : array[1..4] of integer;
  plagecolo  : array[1..4] of Tcolor;

implementation

uses UClock2, Uclock3, Uclock4, Uclock5, Uclock6, Uclock7, Uclock8;

{$R *.DFM}
CONST       { constantes du fichier fichini }
  K0 = 'RCLOCK';
  F00 = 'SIZE';
  F01 = 'COULEUR01';
  F02 = 'COULEUR02';
  F03 = 'COULEUR03';
  F04 = 'COULEUR04';
  F05 = 'COULEUR05';
  F06 = 'COULEUR06';
  F07 = 'COULEUR07';
  F08 = 'COULEUR08';
  F09 = 'COULEUR09';
  F10 = 'COULEUR10';
  F11 = 'COULEUR11';
  F12 = 'COULEUR12';
  F13 = 'COULEUR13';
  F14 = 'COULEUR14';
  F15 = 'COULEUR15';
  F16 = 'COULEUR16';
  F19 = 'FOND';
  F20 = 'BITMAP';
  F21 = 'POSX';
  F22 = 'POSY';
  F23 = 'RAYON';
  F24 = 'WAV';
  F25 = 'SON';
  F26 = 'DATE';
Var
  {---------------- Dessin horloge  ----------------------------------------}
  { les rayons des zones de l'horloge sont calculés à partir se SZ }
  r1 : integer;            { Rayon bord extérieur }
  r2 : integer;            { rayon des alarmes et plages horaires }
  r3 : integer;            { rayon intérieur graduations }
  r4 : integer;            { rayon fond cadran }
  r5 : integer;            { rayon centre des chiffres }
  cx, cy : integer;        { centre de l'horloge }
  Aig : integer;           { largeur des aiguilles }
  deplace : boolean;       { true si déplacement avec clic bouton gauche }
  fx, fy : integer;        { pour déplacement de la fenêtre }
  { pré-calcul des sinus et cosinus }
  zsin : array[0..360] OF single;
  zcos : array[0..360] OF single;
  { 8 alarmes en cours maxi }
  maxalcur  : integer;  { rang alarme maxi }
  alcurhh   : array[1..8] of integer;
  alcurmn   : array[1..8] of integer;
  alcurcolo : array[1..8] of Tcolor;
  angle : integer;
  rgn : THandle;    { région elliptique pour fenêtre ronde }
  curdir : string;  { directory de l'application }

{--------------- objet Talarm ----------------------------}
Procedure Talarm.raz;
Begin
  alactive := False;
  alannee  := 0;
  almois   := 0;
  aljour   := 0;
  alheure  := 0;
  almin    := 0;
  alsec    := 0;
  alms     := 0;
  alcolo   := 0;
  aldelai  := 0;
  altexte  := ' ';
end;

Procedure Talarm.setdatetime(wdt : Tdatetime);
begin
  DecodeDate(wdt, alannee, almois, aljour);
  DecodeTime(wdt, alHeure, alMin, alsec, alms);
end;

Function Talarm.getcolor : Tcolor;
begin
 case alcolo of
   0 : result := clwhite;
   1 : result := clfuchsia;
   2 : result := clred;
   3 : result := clsilver;
   4 : result := clyellow;
   5 : result := cllime;
   6 : result := claqua;
   7 : result := clblue;
   else
      result := clwhite;
  end; { du case }
end;

Procedure Talarm.alarmtostr(var s : shortstring);
Var
  s1 : string[80];
BEGIN
  IF alactive Then s := '1' else s := '0';
  s := s+inttostr(alannee);
  s1 := inttostr(almois);
  while length(s1) < 2 do s1 := '0'+s1;
  s := s+s1;
  s1 := inttostr(aljour);
  while length(s1) < 2 do s1 := '0'+s1;
  s := s+s1;
  s1 := inttostr(alheure);
  while length(s1) < 2 do s1 := '0'+s1;
  s := s+s1;
  s1 := inttostr(almin);
  while length(s1) < 2 do s1 := '0'+s1;
  s := s+s1;
  s := s+inttostr(alcolo);
  s1:= inttostr(aldelai);
  while length(s1) < 2 do s1 := '0'+s1;
  s := s+s1;
  s := s+altexte;
END;

Procedure Talarm.strtoalarm(var s : shortstring);
BEGIN
  { positions utilisées : code 1,aaaa 2, mm 6, jj 8, hh 10, mn 12 }
  {                       couleur 14, minutes alarme 15, libellé 17 }
  IF copy(s,1,1) = '0' then alactive := false else alactive := true;
  alannee := strtoint(copy(s,2,4));
  almois  := strtoint(copy(s,6,2));
  aljour  := strtoint(copy(s,8,2));
  alheure := strtoint(copy(s,10,2));
  almin   := strtoint(copy(s,12,2));
  alsec   := 0;
  alms    := 0;
  alcolo  := strtoint(copy(s,14,1));
  aldelai := strtoint(copy(s,15,2));
  altexte := copy(s,17,50);
END;

Function  Talarm.getalarme : Tdatetime;
VAR
  wdatetime : Tdatetime;
  imin, iheure : integer;
  wmin, wheure : word;
{}
BEGIN
  wdatetime := encodedate(alannee, almois, aljour);
  imin := almin - aldelai;
  iheure := alheure;
  IF imin < 0 then               { test dépassement horaire }
  begin                          { al est limité à 60 minutes }
    imin := imin+60;
    dec(iheure);
    if iheure < 0 then
    begin
      iheure := iheure+24;
      wdatetime := Wdatetime - 1;  { -1 sur nombre de jours }
    end;
  end;
  wmin := imin;
  wheure := iheure;
  wdatetime := wdatetime+ encodeTime(wheure, wmin, 0,0);
  result := wdatetime;
END;

Function  Talarm.getdatetime : Tdatetime;
begin
  result := encodedate(alannee, almois, aljour)
            + encodeTime(alheure, almin, 0,0);
end;

Procedure Talarm.addminutes(mn : word);  { mn est limité à 0..60 }
var
  wdatetime : Tdatetime;
begin
  almin := almin + mn;
  IF almin > 59 then
  begin
    almin := almin - 60;
    inc(alheure);
    if alheure > 23 then
    begin
      alheure := alheure - 24;
      wdatetime := encodedate(alannee, almois, aljour);
      wdatetime := wdatetime+1;
      decodedate(wdatetime, alannee, almois, aljour);
    end;
  end;
end;

procedure Tform1.applionrestore(Sender : Tobject);
begin
  Timer1.enabled := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
Var
  Fichini : Tinifile;
  decal : integer;
begin
  Application.onrestore := appliOnrestore;
  modif := 0;
  randomize;
  initsincos;
  curdir := extractfiledir(application.exename);
  IF copy(curdir, length(curdir), 1) = '\' then delete(curdir,length(curdir),1);
  Fichini := Tinifile.Create(curdir+'\RCLOCK.INI');
  WITH Fichini DO
  BEGIN
    SZ           := Readinteger(K0,F00, 180);
    Couleurs[01] := Tcolor(Readinteger(K0,F01,clgray));        {cadre centre}
    Couleurs[02] := Tcolor(Readinteger(K0,F02,clsilver));   {cadre extérieur}
    Couleurs[03] := Tcolor(Readinteger(K0,F03,$00D0A040));    {cadran centre}
    Couleurs[04] := Tcolor(Readinteger(K0,F04,$00F8FFFF));       {cadran ext}
    Couleurs[05] := Tcolor(Readinteger(K0,F05,clgray));        {aiguille ext}
    Couleurs[06] := Tcolor(Readinteger(K0,F06,clwhite));    {aiguille centre}
    Couleurs[07] := Tcolor(Readinteger(K0,F07,clred));            {trotteuse}
    Couleurs[08] := Tcolor(Readinteger(K0,F08,clscrollbar));{fond graduation}
    Couleurs[09] := Tcolor(Readinteger(K0,F09,Clred));     {graduation heure}
    Couleurs[10] := Tcolor(Readinteger(K0,F10,clgray));   {graduation minute}
    Couleurs[11] := Tcolor(Readinteger(K0,F11,Clblack));           {chiffres}
    Couleurs[12] := Tcolor(Readinteger(K0,F12,clsilver));    {ombre chiffres}
    Couleurs[13] := Tcolor(Readinteger(K0,F13,clblack));             { date }
    Couleurs[14] := Tcolor(Readinteger(K0,F14,clsilver));       { ombre date}
    Couleurs[15] := Tcolor(readinteger(K0,F15,clyellow)); { libellé défilant}
    Couleurs[16] := Tcolor(readinteger(K0,F16,clblack));  { ombre défilant }
    fond          := readinteger(K0,F19,0);
    IF fond < 0 then fond := 0;
    IF fond > 1 then fond := 1;
    Thefile := Readstring(K0,F20,'');
    cx0           := Readinteger(K0,F21,0);
    cy0           := Readinteger(K0,F22,0);
    r0            := Readinteger(K0,F23,8);
    Fichierwav    := Readstring(K0,F24,'');
    sonor         := Readinteger(K0,F25,1);    {bip bip implicite }
    IF sonor < 0 then sonor := 0;
    IF sonor > 2 then sonor := 2;
    posdate       := Readinteger(K0,F26,1);
    if posdate <0 then posdate := 0;
    if posdate > 3 then posdate := 3;
    Free;
  END;

  creepalette;
  { pour sauver la palette origine }
  oldpal := selectpalette(canvas.handle, newpalette, false);
  curalarm := Talarm.create;
  manoalarm := Talarm.create;
  calculrayons;
  Deplace := false;
  maxalcur := 0;
  maxplage := 0;
  Form1.width  := sz+4;
  Form1.height := sz+4;
  { position initiale en bas à droite de l'écran }
  Form1.left := screen.width  - form1.width -32;
  Form1.top := screen.height - form1.height -32;
  rgn := CreateEllipticrgn(0, 0, sz, sz);
  SetWindowRgn(handle,rgn, true);
  Paintbox1.top := 0;
  Paintbox1.left := 0;
  Paintbox1.width := SZ;
  Paintbox1.height := SZ;
  { création des 3 bitmaps }
  Bmp1 := Tbitmap.create;
  Bmp1.width  := SZ;
  Bmp1.height := SZ;
  bmp1.pixelformat := pf24bit;
  Bmp2 := Tbitmap.create;
  Bmp2.width  := SZ;
  Bmp2.height := SZ;
  bmp2.pixelformat := pf24bit;
  Bmp0 := Tbitmap.create;
  IF Lectureimage(thefile) then
  begin
    lectureImage(thefile);
    decal := (SZ - r4*2) div 2;
    Bmp1.canvas.stretchdraw(bounds(decal,decal,r4*2, r4*2), bmp0);
  end
  else
  begin
    thefile := '';
    Bmp0.width  := 8;
    Bmp0.height := 8;
    Bmp1.palette := Newpalette;
  end;
  horloge(Bmp1.canvas);
  timer1.interval := 1000;
  timer1.enabled := true;
  timer2.enabled := true;
end;


{ teste si device présent }
function DiskInDrive(Drive: Char): Boolean;
var
  ErrorMode: word;
begin
  if Drive in ['a'..'z'] then Dec(Drive, $20);
  ErrorMode := SetErrorMode(SEM_FailCriticalErrors);
  try
    if DiskSize(Ord(Drive) - $40) = -1 then
      Result := False
    else
      Result := True;
  finally    { restaure ancien mode erreur }
    SetErrorMode(ErrorMode);
  end;
end;

Function Tform1.lectureImage(nomfichier : string): boolean;
var
  c : char;
  ext : string;
  ImageJPEG : TJPEGImage;
  typefich : integer;
begin
  result := false;
  Thefile :=  nomfichier;
  IF Thefile = '' then exit;
  c := Thefile[1];
  IF Diskindrive(c) = False Then
  Begin
    Showmessage('Lecteur '+c+ ' non prêt');
    exit;
  end;
  IF fileexists(Thefile) = false then
  begin
    Showmessage('Impossible de trouver le fichier '+Thefile);
    exit;
  end;
  Bmp0.free;
  Bmp0 := Tbitmap.create;
  ext := uppercase(extractfileext(thefile));
  typefich := 0;
  IF ext = '.BMP' then typefich := 1
  else
  IF (ext = '.JPG') OR (ext = '.JPEG') then typefich := 2;
  Case typefich of
  0 : exit;
  1 : Try
        Bmp0.LoadFromFile(thefile);
        result := true;
      except
        on EInvalidgraphic do
        begin
          result := false;
          Bmp0 := NIL;
          showmessage('Erreur lecture fichier '+thefile);
          exit;
        end;
      end;
  2 : Try
        ImageJPEG := TJPEGImage.Create;
        try
          ImageJPEG.LoadFromFile(TheFile);
        except
          on EInvalidGraphic do ImageJPEG := nil;
        end;
        IF imageJPEG <> nil then
        begin
          Bmp0.Width  := ImageJPEG.Width;
          Bmp0.Height := ImageJPEG.Height;
          Bmp0.Canvas.Draw(0,0,ImageJPEG);
         result := true;
        end;
      finally
        ImageJPEG.Free;
      end;
  end;  // du case
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
Var
  Fichini : Tinifile;
begin
  Timer1.enabled := false;
  Timer2.enabled := false;
  IF modif > 0 then
     IF messagedlg('Enregistrer vos paramètres ?', mtconfirmation,
       [mbyes, mbno], 0) = mrYes then modif := 1 else modif := 0;
  IF modif = 1 then
  begin
    Fichini := Tinifile.Create(curdir+'\RCLOCK.INI');
    WITH Fichini DO
    BEGIN
      Writeinteger(K0,F00,SZ);
      Writeinteger(K0,F01,longint(Couleurs[01]));
      Writeinteger(K0,F02,longint(Couleurs[02]));
      Writeinteger(K0,F03,longint(Couleurs[03]));
      Writeinteger(K0,F04,longint(Couleurs[04]));
      Writeinteger(K0,F05,longint(Couleurs[05]));
      Writeinteger(K0,F06,longint(Couleurs[06]));
      Writeinteger(K0,F07,longint(Couleurs[07]));
      Writeinteger(K0,F08,longint(Couleurs[08]));
      Writeinteger(K0,F09,longint(Couleurs[09]));
      Writeinteger(K0,F10,longint(Couleurs[10]));
      Writeinteger(K0,F11,longint(Couleurs[11]));
      Writeinteger(K0,F12,longint(Couleurs[12]));
      Writeinteger(K0,F13,longint(Couleurs[13]));
      Writeinteger(K0,F14,longint(Couleurs[14]));
      Writeinteger(K0,F15,longint(Couleurs[15]));
      Writeinteger(K0,F16,Longint(Couleurs[16]));
      Writeinteger(K0,F19, fond);
      Writestring (K0,F20,Thefile);
      Writeinteger(K0,F21,cx0);
      Writeinteger(K0,F22,cy0);
      Writeinteger(K0,F23,r0);
      Writestring (K0,F24,Fichierwav);
      Writeinteger(K0,F25,sonor);
      Writeinteger(K0,F26,posdate);
      Free;
    end;
  end;
  curalarm.free;
  manoalarm.free;
  Bmp0.free;
  Bmp1.free;
  Bmp2.free;
  { remet couleurs à l'état origine et suprime Newpalette }
  selectpalette(canvas.handle, oldpal, false);
  DeleteObject(newpalette);
end;

Procedure Tform1.initsincos;  // crée la table optimisation des calculs
const
  k = pi/180;
var
  i : integer;
Begin
  For i := 0 TO 90 do
  begin
    zsin[i]     := sin(i*k);
    zcos[i]     := cos(i*k);
    zsin[i+90]  :=  zcos[i];
    zcos[i+90]  := -zsin[i];
    zsin[i+180] := -zsin[i];
    zcos[i+180] := -zcos[i];
    zsin[i+270] := -zcos[i];
    zcos[i+270] :=  zsin[i];
  end;
end;

{ crée la palette nécessaire en mode 256 couleurs. C'est une identity }
{ palette dont les entrées 0..9 et 246..255 sont les couleurs système }
{ on ajoute les 21 couleurs définies pour windows entrées 10 à 30 }
{ dégradés entre colo1 et colo2 aux entrées  31..94 }
{ dégradés entre colo3 et colo4 aux entrées  95..158 }
{ dégradés de gris aux entrées 159..222 }
{ nos 12 couleurs aux entrées  223..234 }

Procedure Tform1.setcolorpalette(n: integer; c: Tcolor);
Var
  r, g, b : byte;
Begin
  IF n < 0   then exit;
  IF n > 255 then exit;
  with pPal^  do
  begin
  {$R-}
    R := GetRvalue(c);
    G := GetGvalue(c);
    B := GetBvalue(c);
    palPalEntry[n].peRed   := R;
    palPalEntry[n].peGreen := G;
    palPalEntry[n].peBlue  := B;
    palPalEntry[n].peFlags := PC_RESERVED;
  {$R+}
  end;
end;

procedure Tform1.Creepalette;
Const
  entries = 256;
  { Les 21 couleurs définies dans windows windows ajoutées à la palette }
  wincolors : array[1..21] of Tcolor = (
  clActiveBorder, clActiveCaption, clAppWorkSpace, clBackground,
  clBtnFace, clBtnHighlight, clBtnShadow, clBtnText,
  clCaptionText, clGrayText, clHighlight, clHighlightText,
  clInactiveBorder, clInactiveCaption, clInactiveCaptionText, clMenu,
  clMenuText, clScrollBar, clWindow, clWindowFrame, clWindowText);
var
  i : word;
  CurPal : Array[0..255] of TPALETTEENTRY;         { entrées de la palette }
  EcranDC : HDC;         { pointeur vers DC de l'écran -> couleurs système }
  Taille : LongInt;                       { taille mémoire palette logique }
  k246 : word;  { constante 246 non acceptée par compilateur pour curpal[] }
  CR1, CR2, CG1, CG2,  CB1, CB2 : integer;  { rouges verts bleus }
begin
  taille := sizeof(TLogPalette) + Entries * sizeof(TPaletteEntry);
  getmem(pPal, taille);
  pPal^.palVersion    := $300;
  pPal^.palNumEntries := Entries;
  { device context de l'écran qui a les 20 couleurs système }
  ecrandc := getdc(0);
  with pPal^  do
  begin
    {$R-}
    { Identity palette : 20 couleurs système dans 0..9 et 246..255 }
    GetSystemPaletteEntries(ecranDC,0,10,Palpalentry[0]);
    k246 := 246;
    GetsystempaletteEntries(ecranDC, k246,10,Palpalentry[k246]);
    { les 21 couleurs de Windows entrées 10 à 30, $02 -> PC_RESERVED }
    For i := 1 TO 21 DO setcolorpalette(i+9, Wincolors[i]);
    { Il reste 215 couleurs utilisables entrées 31 à 245 }
    { On utilise 3 plages de 64 entrées pour les dégradés }
    { entrées 31 à 94 , couleurs 1 à 2 }
    CR1 := GetRvalue(couleurs[1]);
    CG1 := GetGvalue(couleurs[1]);
    CB1 := GetBvalue(couleurs[1]);
    CR2 := GetRvalue(couleurs[2]);
    CG2 := GetGvalue(couleurs[2]);
    CB2 := GetBvalue(couleurs[2]);
    For i := 1 TO 64 do
    begin
      palPalEntry[i+30].peRed   := CR1+((CR2-CR1)*i) div 64;
      palPalEntry[i+30].peGreen := CG1+((CG2-CG1)*i) div 64;
      palPalEntry[i+30].peBlue  := CB1+((CB2-CB1)*i) div 64;
      palPalEntry[i+30].peFlags := PC_RESERVED;
    end;
    { entrées 95 à 158 , couleurs 3 à  4 }
    CR1 := GetRvalue(couleurs[3]);
    CG1 := GetGvalue(couleurs[3]);
    CB1 := GetBvalue(couleurs[3]);
    CR2 := GetRvalue(couleurs[4]);
    CG2 := GetGvalue(couleurs[4]);
    CB2 := GetBvalue(couleurs[4]);
    For i := 1 TO 64 do
    begin
      palPalEntry[i+94].peRed   := CR1+((CR2-CR1)*i) div 64;
      palPalEntry[i+94].peGreen := CG1+((CG2-CG1)*i) div 64;
      palPalEntry[i+94].peBlue  := CB1+((CB2-CB1)*i) div 64;
      palPalEntry[i+94].peFlags := PC_RESERVED;
    end;
    { entrées 159 à  222  dégradés de gris clair pour ombres }
    For i := 1 to 64 do
    begin
      palPalEntry[i+158].peRed   := 127+i*2;
      palPalEntry[i+158].peGreen := 127+i*2;
      palPalEntry[i+158].peBlue  := 127+i*2;
      palPalEntry[i+158].peFlags := PC_RESERVED;
    end;
    { entrées 223..235 nos 13 couleurs utilisateur }
    For i := 1 TO 13 do setcolorpalette(i+222, couleurs[i]);
    { recopie les entrées palette }
    for i := 0 to Entries-1 do CurPal[i] := palPalEntry[i];
    {$R+}
   end;
  Newpalette := CreatePalette(pPal^);
  FreeMem(pPal, taille);
end;

Function Tform1.Calculcolo(code, plage1, plage2, coef: integer): Integer;
var
  i : integer;
BEGIN
  { déterminer le rang palette d'une couleur dans l'un des intervalles }
  { selon code: 0 -> 31..94,  1 -> 95..158 , 2 -> 159..222 }
  IF (plage2 < plage1) or (coef < plage1) or (coef > plage2) then
   i := 1
  else
   i := (64*(coef-plage1+1) ) div (plage2 - plage1+1);
  case code of
   0 : result := 30+i;
   1 : result := 94+i;
   2 : result := 159+i;
   else result := 0;
  end;
end;

{ calcul positions xy en fonction de heure et rayon
  style = 0 calcul heure,      k1 = heure,  k2 = minutes
        = 1 calcul minutes,    k1 = nimutes k2 = secondes
        = 2 calculs secondes }
Procedure Tform1.Timetoxy(style, k1 ,k2, r : integer; var wx, wy: longint );
var
  rs : single;
Begin
  case style of
  0 : begin
      { heure varie dans sens inverse du sens trigonométrique }
      { départ des heures à + 3 heures pour rotation -90 °    }
      { A chaque heure k1 correspond un angle de 360/12 = 30 degrés. }
      { A chaque minute k2 correspond un angle de 30/60 = 1/2 degré }
        if k1 >= 12 then k1 := k1 - 12;
        k1 := (3-k1)*30 - k2 div 2;
      end;
  1 : begin
      { Minutes varie dans sens inverse du sens trigonométrique }
      { départ des minutes à + 15 pour rotation -90 °    }
      { A chaque minute k1 correspond un angle de 360/60 = 6 degrés. }
      { A chaque seconde k2 correspond un angle de 6/60 = 1/10 degré }
        k1 := (15-k1)*6 - k2 div 10;
      end;
  2 : begin
        k1 := (15-k1)*6; { 6° par minute }
      end;
  end;
  { protection accès au tableau des sinus et cosinus }
  While k1 > 360 do k1 := k1 - 360;
  While k1 < 0   do k1 := 360 + k1; {  pas 360-k1 ! }
  rs := r;
  wx :=  round(rs*zcos[k1]);
  { y inversé par rapport aux coordonnées cartésiennes }
  wy := -round(rs*zsin[k1]);
end;

procedure Tform1.calculrayons;
begin
  cx := SZ div 2;         { centre de l'horloge }
  cy := SZ div 2;
  r1 := SZ div 2;         { Rayon bord extérieur }
  r2 := (r1*15) div 16;   { rayon des alarmes et plages horaires }
  r3 := (r1*14) div 16;   { rayon intérieur graduations }
  r4 := 1+(r1*13) Div 16; { rayon fond cadran }
  r5 := (r1*11) Div 16;   { rayon centre des chiffres }
  aig := 1+ SZ div 90;    { largeur des aiguilles }
end;

{ dessin de l'horloge }
Procedure Tform1.horloge(cancan : Tcanvas);
Var
 i : integer;
 x1, y1 : longint;
 x2, y2 : longint;
 dx, dy : integer;
 s : string[20];
 present : Tdatetime;
 m, n : integer;

Begin
  With cancan do
  begin
    Brush.style := bsclear;
    Pen.style := PsSolid;
    Pen.width := 2;  { pour éviter les trous du tracé des cercles }
    IF thefile = ''  then   { si pas de bitmap de fond }
      For i := 4 TO r4 do   { dégradé intérieur du cadran }
      begin
        pen.color := paletteindex(calculcolo(1, 4, r4, i));
        ellipse(cx-i, cy-i, cx+i+1, cy+i+1);
      end;
    n := R5 div (r1- (r3+1)); // delta pour pixels épaisseur extérieur du cadran
    For i := r3 to r1 do    { dégradé extérieur }
    begin
       IF Thefile = '' then
        pen.color := paletteindex(calculcolo(0, r3 , r1, i))
      else
      begin
        //  pixels pris sur le bitmap pour compatibilité palette
        pen.color := pixels[cx , cy + n*(r1-i)];
      end;
      ellipse(cx-i, cy-i, cx+i+1, cy+i+1);
    end;
    pen.color := couleurs[2];
    ellipse(cx-r1, cy-r1, cx+r1, cy+r1);
    pen.color := couleurs[1];
    ellipse(cx-r3-1, cy-r3-1, cx+r3+2, cy+r3+2);
    pen.color := couleurs[8]; { fond graduations }
    For i := r4 to r3 do ellipse(cx-i, cx-i, cx+i+1, cy+i+1);
    { les chiffres }
    font.name := 'Times New Roman';
    font.size := SZ div 11;
    For i := 1 to 12 do
    begin
      s := inttostr(i);
      dx := textwidth(s) div 2; { centre des chiffres }
      dy := textheight(s) div 2;
      Timetoxy(0, i ,0, r5, x1, y1);
      { ombrage décalé 1 pixels bas droite }
      Font.color := couleurs[12];
      Textout(cx+x1-dx+2, cy+y1-dy+2, s);
      font.color := couleurs[11];
      { chiffres }
      Textout(cx+x1-dx+1, cy+y1-dy+1, s);
    end;
    { le jour }
    IF SZ div 18 < 7 then font.size := 7
    else Font.size := SZ div 18;
    present := now;
    s := ' '+formatdatetime('ddd d',present)+' ';
    s[2] := Upcase(s[2]);  { première lettre en majuscules }
    dx  := textwidth(s)  div 2;
    dy  := textheight(s) div 2;
    font.color := couleurs[14];
    case posdate of             { 0 ne pas afficher }
    1 : for m := -1 to 1 do     { entourage }
          for n := -1 to 1 do
           textout(cx+m-dx, cy-n + r5 div 2 , s);  { bas }
    2 : For m := -1 to 1 do
           for n := -1 to 1 do
            textout(cx+m-dx, cy+n - r5 div 2 -dy, s);  { haut }
    3 : For m := -1 to 1 do
          for n := -1 to 1 do
           textout(cx+m+(r5-dx-dx) div 2, cy+n-dy, s);   { droite }
    end;
    font.color  := couleurs[13];
    case posdate of             { 0 ne pas afficher }
    1 : textout(cx-dx, cy + r5 div 2 , s);  { bas }
    2 : textout(cx-dx, cy - r5 div 2 -dy, s);  { haut }
    3 : textout(cx+(r5-dx-dx) div 2, cy-dy, s);   { droite }
    end;
    pen.width := 1;
    For i := 0 to 59 do
    begin               { graduations }
      Timetoxy(2, i, 0, r3+1, x1, y1);
      IF i mod 5 = 0 then
      begin
        pen.color := couleurs[09];
        Timetoxy(2, i, 0, r4-4, x2, y2);
      end
      else
      begin
        pen.color := couleurs[10];
        Timetoxy(2, i, 0, r4-3, x2, y2);
      end;
      moveto(cx+x1, cy+y1);
      lineto(cx+x2, cy+y2);
    end;
  end;
end;
{------------  gestion de form1 ------------------}
{ pas la peine de traiter évènement onpaint car la fenêtre se repeint }
{ complètement chaque seconde }
{-----------------------------------------------------------------------}
{ Trace une aiguille  style = 0 aiguille heures, 1 minutes , 2 secondes }
{ K1 = heure ou mn ou sec,  k2 = mn ou sec  selon le style              }
{ c1 = couleur entourage, c2 = remplissage                              }
Procedure Tform1.affaiguille(cancan : Tcanvas;
                             style, k1, k2 : integer; c1, c2 : tcolor);
Var
  pt : array[0..4] OF Tpoint;
  r : integer;
  i : integer;
  d : integer;
  svaig : integer;
Begin
  Case style of
  0,1:begin
        IF style= 0 then
        begin
          r := (r5*3) div 4;  // rayon aiguille
          d := 1;             // d = décalage 2 heures * 6 = 12 heures -> 360°
        end
        else
        begin
          r := (r5*6) div 5;
          d := 10;
        end;
        timetoxy(style, k1, k2, r, pt[0].x, pt[0].y);  // extrémité aiguille
        svaig := aig;
        IF style = 0 then aig := aig*2;
        timetoxy(style, k1-d*11, k2, - aig-1   , pt[1].x, pt[1].y);
        timetoxy(style, k1-d*12, k2, - aig-2   , pt[2].x, pt[2].y);
        timetoxy(style, k1-d*13, k2, - aig-1   , pt[3].x, pt[3].y);
        aig := svaig;
        pt[4].x := pt[0].x;
        pt[4].y := pt[0].y;
        For i := 0 to 4 do
        begin          { recentrage }
          inc(pt[i].x, cx);
          inc(pt[i].y, cy);
        end;
        With Bmp2.canvas do
        begin
          pen.width := 1;
          pen.color := c1;
          brush.color := c2;
          polygon(pt);
        end;
      end;
  2 : begin
        r := r4-2;
        timetoxy(2, k1, 0, r, pt[0].x, pt[0].y);
        With Bmp2.canvas do
        begin
          pen.width := 1;
          pen.color := c1;
          moveto(cx,cy);
          lineto(cx+pt[0].x,cy+ pt[0].y);
          brush.color := c2;
          ellipse(cx-3, cy-3, cx+3, cy+3);
          pixels[cx, cy] := clblack;
        end;
      end;
  End; { du case }
end;

Procedure Tform1.Affplageh(cancan : Tcanvas;
                           h1, mn1, h2, mn2 : integer; c : tcolor);
var
  x1, y1, x2, y2, x3, y3 , x4, y4, x5, y5, x6,y6: longint;
  a, b : integer;
Begin
  IF h1*60+mn1 >= h2*60+mn2 then exit;
  a := r2+1;
  b := r2-1;
  timetoxy(0, h1, mn1, a, x1, y1);
  timetoxy(0, h2, mn2, a, x2, y2);
  timetoxy(0, h1, mn1, b, x3, y3);
  timetoxy(0, h2, mn2, b, x4, y4);
  timetoxy(0, h1, mn1, r4, x5, y5);
  timetoxy(0, h2, mn2, r4, x6, y6);
  With cancan do
  begin
    pen.width := 1;
    pen.color := c;
    arc(cx-a, cy-a, cx+a, cy+a, cx+x2, cy+y2, cx+x1, cy+y1);
    arc(cx-b, cy-b, cx+b, cy+b, cx+x4, cy+y4, cx+x3, cy+y3);
    moveto(cx+x1, cy+y1); lineto(cx+x5, cy+y5);
    moveto(cx+x2, cy+y2); lineto(cx+x6, cy+y6);
  end;
end;

Procedure Tform1.AffAlarme(cancan : tcanvas; h, mn, tempo : integer; c1, c2 : tcolor);
var
  x1, y1: longint;
Begin
  timetoxy(0, h, mn, r2, x1, y1);
  With cancan do
  begin
    pen.width := 1;
    { tempo règle un clignotement moins rapide que chaque seconde }
    IF tempo mod 3 = 0 then
    begin
      pen.color := c1;
      brush.color := c2;
    end
    else
    begin
      pen.color   := c2;
      brush.color := c1;
    end;
    ellipse(cx+x1-3, cy+y1-3, cx+x1+3, cy+y1+3);
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  Present: TDateTime;
  i : integer;
  Heure, Minute, Sec, MSec : word;
begin
  Present:= Now;
  DecodeTime(Present, Heure, Minute, Sec, MSec);
  IF sec = 0 then horloge(bmp1.canvas);
{ efface les aiguilles par copie de bitmap }
  Bmp2.canvas.draw(0,0,Bmp1);
{ plages horaires }
  For i := 1 to maxplage do
   affplageh(Bmp2.canvas, plagehdeb[i], plagemdeb[i],
                          plagehfin[i], plagemfin[i], plagecolo[i]);
{ affichage des alarmes en cours }
  for i := 1 to maxalcur do
   affalarme(Bmp2.canvas,alcurhh[i], alcurmn[i], sec, clblack, alcurcolo[i]);
 { affichage aiguilles sur Bmp2 en arrière plan }
 { minutes puis heures puis secondes }
  affaiguille(Bmp2.canvas, 0, heure, minute, couleurs[5], couleurs[6]);
  affaiguille(Bmp2.canvas, 1, minute, sec, couleurs[5], couleurs[6]);
  affaiguille(Bmp2.canvas, 2, sec,0, couleurs[7], couleurs[7]);

  SelectPalette(Paintbox1.canvas.handle, Bmp1.palette, false);
  Realizepalette(Paintbox1.canvas.handle);
  paintbox1.canvas.draw(0,0,Bmp2);  { affichage }
end;

procedure TForm1.Quitter1Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  IF Button = mbleft then
  begin
    deplace := true;
    fx := x;
    fy := y;
    timer1.enabled := false;
  end;
end;

procedure TForm1.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 { pour que le déplacement ne laisse pas de trace supprimer If deplace }
  IF deplace then
  begin
    Form1.left := form1.left+x-fx;
    Form1.top := form1.top+y-fy;
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  IF deplace then
  begin
    Form1.left := form1.left+x-fx;
    Form1.top := form1.top+y-fy;
    deplace := false;
    timer1.enabled := true;
  end;
end;

{ réponse au clic menu Alarme pour créer une alarme avec form2 }
procedure TForm1.Alarme1Click(Sender: TObject);
var
  present : Tdatetime;
  s  : shortstring;
  s1 : shortstring;
  s2 : shortstring;
begin
  curalarm.raz;
  present := now;   { date courante }
  curalarm.setdatetime(now);
  with form2 do
  begin
    s := formatdatetime('dddd dd ', present);
    s1 := formatdatetime('mmmm yyyy', present);
    s[1] := upcase(s[1]);
    s1[1] := upcase(s1[1]);
    Panel1.caption := s+s1;
    Curalarm.addminutes(1);
    s1 := inttostr(curalarm.almin);
    while length(s1) < 2 do s1 := '0'+s1;
    edit1.text := inttostr(curalarm.alheure)+' h '+s1;
    curalarm.aldelai := 0;
    edit3.text := ' 0 mn';
    edit2.text := '';
    IF form2.showmodal = mrOK Then
    begin
      curalarm.alactive := true;
      curalarm.altexte := edit2.text;
      curalarm.alarmtostr(s2);
      form3.listbox1.items.add(s2);
    end
    else Curalarm.raz;
  end;
end;

procedure TForm1.ListeClick(Sender: TObject);
begin
  Form3.showmodal;
end;

{ Timer2 :   1) teste à chaque seconde s'il faut déclencher une alarme }
{            2) construit le tableau des alarmes à afficher sur l'horloge }
procedure TForm1.Timer2Timer(Sender: TObject);
var
  i : integer;
  { plage des heures alarmes traitées en fonction de l'heure courante }
  aldeb : Tdatetime;
  alfin : Tdatetime;
  s , s0, s1: shortstring;
  wah, wamn : integer;
begin
  { évite de redéclencher deux fois l'alarme }
  Timer2.enabled := false;
  { Tdate time est un double dont la partie entière représente les jours et }
  { la partie décimale les heures et minutes en fraction de jour }
  { plage valide de 6 heures = 24/4 = 0.25 jour pour affichage alarmes }
  aldeb := Now;
  alfin := aldeb+0.25;
  Maxalcur := 0;  { raz table des alarmes en cours à afficher }
  For i := 0 to Form3.listbox1.items.count-1 do
  begin
    s := form3.listbox1.items[i];
    manoalarm.strtoalarm(s);
    IF manoalarm.alactive AND
      (manoalarm.getalarme >= aldeb) and (manoalarm.getalarme <= alfin) then
    begin
      IF maxalcur < 8 then { 8 alarmes maxi }
      begin
        inc(maxalcur);  { plage horaire visible }
        alcurhh[maxalcur] := manoalarm.alheure;
        alcurmn[maxalcur] := manoalarm.almin;
        alcurcolo[maxalcur] := manoalarm.getcolor;
      end;
    end;
  end;
  { test déclenchement alarme }
  For i := 0 to Form3.listbox1.items.count-1 do
  begin
    s := form3.listbox1.items[i];
    manoalarm.strtoalarm(s);
    IF manoalarm.alactive and (now >= manoalarm.getalarme) then
    begin   { *** ALARME *** }
      IF application.active = false then application.restore;
      setactivewindow(form1.handle);
      manoalarm.alactive := false;
      manoalarm.alarmtostr(s);
      form3.listbox1.items[i] := s;
      s0 := inttostr(manoalarm.almin);
      While length(s0) < 2 do s0 := '0'+s0;
      s0 := 'Alarme '+ inttostr(manoalarm.alheure)+' h '+s0+' mn';
      IF manoalarm.aldelai = 0 then s1 := ''
       else
        IF manoalarm.aldelai = 1 then s1 := ' dans 1 minute'
         else
           s1 := ' dans '+inttostr(manoalarm.aldelai)+' minutes';
      Form5.panel1.caption := s0+s1;
      Form5.panel2.caption := manoalarm.altexte;
      Form5.showmodal;
      IF Form5.checkbox1.checked then  { si recommencer dans }
      begin
        manoalarm.setdatetime(now);
        wah  := manoalarm.alheure;
        wamn := manoalarm.almin + F5mn;
        IF wamn > 59 then
        begin
          inc(wah);
          IF wah > 23 Then wah := 0;
          wamn := wamn - 60;
        end;
        Form3.listbox1.items.delete(i); { effacer ancienne alarme }
        manoalarm.alactive := true;
        manoalarm.alheure := wah;
        manoalarm.almin   := wamn;
        manoalarm.aldelai := 0;
        manoalarm.alarmtostr(s);
        Form3.listbox1.items.add(s); { créer la nouvelle alarme }
      end;
    end;   { de alarme affichée }
  end;   { de for listbox }
  s := 'Rclock';   { affichage du libellé application }
  IF maxalcur > 0 then
  begin
    s0 := inttostr(alcurmn[1]);
    while length(s0) < 2 do s0 := '0'+s0;
    s := s+' '+inttostr(alcurhh[1])+'h'+s0;
  end;
  application.title := s;
  timer2.enabled := true;
end;

procedure Tform1.NouveauxParams;
Var
  decal : integer;
begin
  fond  := form4.radiogroup1.itemindex;
  posdate := form4.radiogroup3.itemindex;
  SZ := Form4.spinedit1.value;
  calculrayons;
  Bmp1.free;
  Bmp2.free;
  width  := sz+8;
  height := sz+8;
  rgn := CreateEllipticrgn(0, 0, sz, sz);
  SetWindowRgn(handle,rgn, true);
  Paintbox1.top := 0;
  Paintbox1.left := 0;
  Paintbox1.width := SZ;
  Paintbox1.height := SZ;
  Bmp1 := Tbitmap.create;
  Bmp1.width := SZ;
  Bmp1.height := SZ;
  bmp1.pixelformat := pf24bit;
  Bmp2 := Tbitmap.create;
  Bmp2.width := SZ;
  Bmp2.height := SZ;
  Bmp2.pixelformat := pf24bit;
  IF Fond = 1 then  { si bitmap de fond }
  begin
    decal := (SZ - r4*2) div 2;
   // Bmp1.canvas.copyrect(bounds(decal,decal,r4*2, r4*2), bmp0.canvas,
   //                       rect(cx0 -r0, cy0-r0, cx0+r0, cy0+r0));
    bmp1.canvas.stretchdraw(bounds(decal, decal, r4*2, r4*2), bmp0);
  end
  else
  begin
    creepalette;
    Bmp1.palette :=  Newpalette;
    Thefile := '';
  end;
  Horloge(bmp1.canvas);  { redessine l'horloge }
end;

procedure TForm1.Options1Click(Sender: TObject);

begin
  Timer1.enabled := false;
  Timer2.enabled := false;
  Form4.spinedit1.value := SZ;
  form4.showmodal;    { la forme des options }
  sonor := form4.radiogroup2.itemindex;
  Nouveauxparams;
  Timer1.enabled := true;
  Timer2.enabled := true;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  IF timer1.enabled then paintbox1.canvas.draw(0,0,bmp2);
end;

procedure TForm1.Reduire1Click(Sender: TObject);
begin
  timer1.enabled := false;
  application.minimize;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  Timer1.enabled := false;
  selectpalette(form1.canvas.handle, bmp1.palette, false);
  realizepalette(form1.canvas.handle);
  Timer1.enabled := true;
end;

procedure TForm1.Plagehoraire1Click(Sender: TObject);
begin
  IF maxplage > 4 then
  begin
    showmessage('Vous utilisez déjà les 4 plages horaires possibles.');
    exit;
  end;
  inc(maxplage);
  plagehdeb[maxplage] := 8;
  plagemdeb[maxplage] := 0;
  plagehfin[maxplage] := 12;
  plagemfin[maxplage] := 0;
  plagecolo[maxplage] := clyellow;
  IF Form7.showmodal <> mrOK then dec(maxplage);  { annulation }
end;

procedure TForm1.Listeplages1Click(Sender: TObject);
begin
  form8.showmodal;
end;

end.
