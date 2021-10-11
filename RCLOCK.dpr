program RCLOCK;

uses
  Forms,
  UCLOCK1 in 'UCLOCK1.pas' {Form1},
  UClock2 in 'UClock2.pas' {Form2},
  Uclock3 in 'Uclock3.pas' {Form3},
  Uclock4 in 'Uclock4.pas' {Form4},
  Uclock5 in 'Uclock5.pas' {Form5},
  Uclock6 in 'Uclock6.pas' {Form6},
  Uclock7 in 'Uclock7.pas' {Form7},
  Uclock8 in 'Uclock8.pas' {Form8};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Rclock';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm8, Form8);
  Application.Run;
end.
