unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Math, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Clipbrd;

const
  WM_CLIPBOARDUPDATE = $031D;
  MAX_HISTORY = 100;

type
  TfrmMain = class(TForm)
    lblTitle: TLabel;
    lbHistory: TListBox;
    pnlBottom: TPanel;
    btnCopy: TButton;
    btnClear: TButton;
    btnClose: TButton;
    sbStatus: TStatusBar;
    TrayIcon: TTrayIcon;
    pmTray: TPopupMenu;
    miRestore: TMenuItem;
    miSep1: TMenuItem;
    miExit: TMenuItem;
    pmHistory: TPopupMenu;
    miCopyItem: TMenuItem;
    miDeleteItem: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbHistoryDblClick(Sender: TObject);
    procedure lbHistoryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnCopyClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure miRestoreClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miCopyItemClick(Sender: TObject);
    procedure miDeleteItemClick(Sender: TObject);
    procedure pmHistoryPopup(Sender: TObject);
  private
    FHistory: TStringList;
    FIgnoreNext: Boolean;
    procedure WMClipboardUpdate(var Msg: TMessage); message WM_CLIPBOARDUPDATE;
    procedure AddToHistory(const S: string);
    procedure DeleteHistoryItem(Index: Integer);
    procedure CopyItemToClipboard(Index: Integer);
    procedure UpdateListBox;
    procedure UpdateStatus;
    function GetItemPreview(const S: string): string;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FHistory := TStringList.Create;
  FIgnoreNext := False;
  AddClipboardFormatListener(Handle);
  UpdateStatus;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  RemoveClipboardFormatListener(Handle);
  FHistory.Free;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // Minimize to system tray instead of closing
  Action := caNone;
  Hide;
  TrayIcon.Visible := True;
  TrayIcon.ShowBalloonHint;
end;

// -----------------------------------------------------------------------
// Clipboard monitoring
// -----------------------------------------------------------------------

procedure TfrmMain.WMClipboardUpdate(var Msg: TMessage);
var
  S: string;
begin
  if FIgnoreNext then
  begin
    FIgnoreNext := False;
    Exit;
  end;

  if Clipboard.HasFormat(CF_UNICODETEXT) or Clipboard.HasFormat(CF_TEXT) then
  begin
    try
      S := Clipboard.AsText;
      if S.Trim <> '' then
        AddToHistory(S);
    except
      // Ignore transient clipboard access errors
    end;
  end;
end;

// -----------------------------------------------------------------------
// History management
// -----------------------------------------------------------------------

procedure TfrmMain.AddToHistory(const S: string);
var
  I: Integer;
begin
  // Already at the top — nothing to do
  if (FHistory.Count > 0) and (FHistory[0] = S) then
    Exit;

  // Move to top if already exists elsewhere
  I := FHistory.IndexOf(S);
  if I > 0 then
    FHistory.Delete(I);

  FHistory.Insert(0, S);

  // Trim to limit
  while FHistory.Count > MAX_HISTORY do
    FHistory.Delete(FHistory.Count - 1);

  UpdateListBox;
  UpdateStatus;
end;

procedure TfrmMain.DeleteHistoryItem(Index: Integer);
begin
  if (Index < 0) or (Index >= FHistory.Count) then
    Exit;
  FHistory.Delete(Index);
  UpdateListBox;
  UpdateStatus;
  if lbHistory.Count > 0 then
    lbHistory.ItemIndex := Min(Index, lbHistory.Count - 1);
end;

procedure TfrmMain.CopyItemToClipboard(Index: Integer);
begin
  if (Index < 0) or (Index >= FHistory.Count) then
    Exit;

  FIgnoreNext := True;
  Clipboard.AsText := FHistory[Index];

  // Move accessed item to top
  if Index > 0 then
  begin
    FHistory.Move(Index, 0);
    UpdateListBox;
  end;
  lbHistory.ItemIndex := 0;
end;

// -----------------------------------------------------------------------
// UI helpers
// -----------------------------------------------------------------------

function TfrmMain.GetItemPreview(const S: string): string;
begin
  Result := S;
  Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10,    ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13,    ' ', [rfReplaceAll]);
  Result := Result.Trim;
  if Length(Result) > 150 then
    Result := Copy(Result, 1, 150) + '...';
end;

procedure TfrmMain.UpdateListBox;
var
  I, Sel: Integer;
begin
  Sel := lbHistory.ItemIndex;
  lbHistory.Items.BeginUpdate;
  try
    lbHistory.Items.Clear;
    for I := 0 to FHistory.Count - 1 do
      lbHistory.Items.Add(GetItemPreview(FHistory[I]));
  finally
    lbHistory.Items.EndUpdate;
  end;
  if (Sel >= 0) and (Sel < lbHistory.Count) then
    lbHistory.ItemIndex := Sel;
end;

procedure TfrmMain.UpdateStatus;
begin
  sbStatus.SimpleText := Format(' %d item(s) in history  |  Max: %d',
    [FHistory.Count, MAX_HISTORY]);
end;

// -----------------------------------------------------------------------
// List box events
// -----------------------------------------------------------------------

procedure TfrmMain.lbHistoryDblClick(Sender: TObject);
begin
  CopyItemToClipboard(lbHistory.ItemIndex);
end;

procedure TfrmMain.lbHistoryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: CopyItemToClipboard(lbHistory.ItemIndex);
    VK_DELETE: DeleteHistoryItem(lbHistory.ItemIndex);
  end;
end;

// -----------------------------------------------------------------------
// Button events
// -----------------------------------------------------------------------

procedure TfrmMain.btnCopyClick(Sender: TObject);
begin
  CopyItemToClipboard(lbHistory.ItemIndex);
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  if MessageDlg('Clear all clipboard history?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    FHistory.Clear;
    UpdateListBox;
    UpdateStatus;
  end;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  Close; // triggers FormClose -> minimize to tray
end;

// -----------------------------------------------------------------------
// Tray icon events
// -----------------------------------------------------------------------

procedure TfrmMain.TrayIconDblClick(Sender: TObject);
begin
  miRestoreClick(Sender);
end;

procedure TfrmMain.miRestoreClick(Sender: TObject);
begin
  Show;
  WindowState := wsNormal;
  SetForegroundWindow(Handle);
  TrayIcon.Visible := False;
end;

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  TrayIcon.Visible := False;
  Application.Terminate;
end;

// -----------------------------------------------------------------------
// History context menu
// -----------------------------------------------------------------------

procedure TfrmMain.pmHistoryPopup(Sender: TObject);
var
  HasSel: Boolean;
begin
  HasSel := lbHistory.ItemIndex >= 0;
  miCopyItem.Enabled  := HasSel;
  miDeleteItem.Enabled := HasSel;
end;

procedure TfrmMain.miCopyItemClick(Sender: TObject);
begin
  CopyItemToClipboard(lbHistory.ItemIndex);
end;

procedure TfrmMain.miDeleteItemClick(Sender: TObject);
begin
  DeleteHistoryItem(lbHistory.ItemIndex);
end;

end.
