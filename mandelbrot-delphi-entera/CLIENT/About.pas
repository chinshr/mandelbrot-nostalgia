(*----------------------------------------------------------------------------
 *
 *  About.pas
 *
 *  Copyright (c) 1998 Inprise Corporation. All Rights Reserved.
 *
 *  Entera Samples Group
 *
 *----------------------------------------------------------------------------*)
unit About;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    Button1: TButton;
    procedure OKButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutBox.Button1Click(Sender: TObject);
begin
     Close;
end;

end.
 
