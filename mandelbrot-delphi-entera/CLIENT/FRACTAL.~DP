(*----------------------------------------------------------------------------
 *
 *  Fractal.pas
 *
 *  Copyright (c) 1998 Inprise Corporation. All Rights Reserved.
 *
 *  Entera Samples Group
 *
 *----------------------------------------------------------------------------*)
program Fractal;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  About in 'ABOUT.PAS' {AboutBox},
  fractal_c in 'fractal_c.pas',
  Thread in 'Thread.pas',
  StatsDlg in 'StatsDlg.pas' {StatsDialog};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TStatsDialog, StatsDialog);
  Application.Run;
end.
