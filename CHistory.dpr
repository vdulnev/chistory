program CHistory;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {frmMain},
  uHotkeyDialog in 'uHotkeyDialog.pas' {dlgHotkey};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.Title := 'CHistory - Clipboard Manager';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
