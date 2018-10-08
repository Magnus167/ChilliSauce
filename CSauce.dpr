program CSauce;

uses
  Vcl.Forms,
  ChilliSauce in 'ChilliSauce.pas' {ChilliSauceV1},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TChilliSauceV1, ChilliSauceV1);
  Application.Run;
end.
