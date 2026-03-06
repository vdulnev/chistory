unit uHotkeyDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls;

type
  TdlgHotkey = class(TForm)
    lblInstruction: TLabel;
    hkInput: THotKey;
    lblClear: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnClear: TButton;
    procedure btnClearClick(Sender: TObject);
  end;

implementation

{$R *.dfm}

procedure TdlgHotkey.btnClearClick(Sender: TObject);
begin
  hkInput.HotKey := 0;
end;

end.
