(*----------------------------------------------------------------------------
 *
 *  StatsDlg.pas
 *
 *  Copyright (c) 1998 Inprise Corporation. All Rights Reserved.
 *
 *  Entera Samples Group
 *
 *----------------------------------------------------------------------------*)
unit StatsDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TStatsDialog = class(TForm)
    CloseButton: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    TotalTime: TLabel;
    TotalRpcTime: TLabel;
    TotalRpc: TLabel;
    AverageRpcTime: TLabel;
    Label5: TLabel;
    OpenServerHandles: TLabel;
    Label6: TLabel;
    InitialRpcTime: TLabel;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StatsDialog: TStatsDialog;

implementation

{$R *.DFM}

procedure TStatsDialog.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TStatsDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Close;
end;

end.
