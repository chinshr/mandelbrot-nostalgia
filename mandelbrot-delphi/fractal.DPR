program Fractal;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  About in 'ABOUT.PAS' {AboutBox};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
