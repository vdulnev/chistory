unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Math, System.IniFiles, System.UITypes, System.Generics.Collections,
  System.NetEncoding,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Clipbrd, uHotkeyDialog;

const
  WM_CLIPBOARDUPDATE = $031D;
  MAX_HISTORY        = 100;
  HOTKEY_ID          = 1;
  ITEM_H             = 76;
  THUMB_SZ           = 52;

  // Dark theme  (Delphi stores colors as $00BBGGRR)
  CLR_BG       = $002B2B2B;
  CLR_TOOLBAR  = $00202020;
  CLR_ITEM_ALT = $00313131;
  CLR_SEL      = $00C86020;   // vivid blue selection
  CLR_TEXT     = $00F0F0F0;
  CLR_DIM      = $00888888;
  CLR_SEP      = $00444444;
  CLR_THUMB_BG = $00383838;
  CLR_THUMB_BR = $00606060;
  CLR_TAB_ACT  = $003C3C3C;
  CLR_BTN_HOV  = $00383838;
  CLR_GOLD     = $0000BFFF;   // gold star: RGB(255,191,0)
  CLR_BTN_TXT  = $00AAAAAA;

type
  TClipItem = record
    Text:       string;
    AddedAt:    TDateTime;
    IsFavorite: Boolean;
  end;

  TfrmMain = class(TForm)
    pnlToolbar:     TPanel;
    lblCopy:        TLabel;
    lblDirectPaste: TLabel;
    lblQuickLook:   TLabel;
    lblPlainText:   TLabel;
    lblSettings:    TLabel;
    pnlSepToolbar:  TPanel;
    pnlTabs:        TPanel;
    lblTabAll:      TLabel;
    lblTabFav:      TLabel;
    pnlSepTabs:     TPanel;
    lbHistory:      TListBox;
    pnlSepSearch:   TPanel;
    pnlSearch:      TPanel;
    edSearch:       TEdit;
    TrayIcon:       TTrayIcon;
    pmTray:         TPopupMenu;
    miRestore:      TMenuItem;
    miSep1:         TMenuItem;
    miExit:         TMenuItem;
    pmHistory:      TPopupMenu;
    miCopyItem:     TMenuItem;
    miToggleFav:    TMenuItem;
    miSepHist:      TMenuItem;
    miDeleteItem:   TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbHistoryDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbHistoryDblClick(Sender: TObject);
    procedure lbHistoryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbHistoryMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblCopyClick(Sender: TObject);
    procedure lblDirectPasteClick(Sender: TObject);
    procedure lblQuickLookClick(Sender: TObject);
    procedure lblPlainTextClick(Sender: TObject);
    procedure lblSettingsClick(Sender: TObject);
    procedure lblTabAllClick(Sender: TObject);
    procedure lblTabFavClick(Sender: TObject);
    procedure lblMouseEnter(Sender: TObject);
    procedure lblMouseLeave(Sender: TObject);
    procedure edSearchChange(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure miRestoreClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miCopyItemClick(Sender: TObject);
    procedure miToggleFavClick(Sender: TObject);
    procedure miDeleteItemClick(Sender: TObject);
    procedure pmHistoryPopup(Sender: TObject);
  private
    FItems:          TList<TClipItem>;
    FFiltered:       TList<Integer>;
    FIgnoreNext:     Boolean;
    FShowFav:        Boolean;
    FSearchText:     string;
    FHotKeyShortCut: TShortCut;
    FPrevWindow:     HWND;
    procedure WMClipboardUpdate(var Msg: TMessage); message WM_CLIPBOARDUPDATE;
    procedure WMHotKey(var Msg: TMessage);          message WM_HOTKEY;
    procedure AddToHistory(const S: string);
    procedure DeleteHistoryItem(FilteredIdx: Integer);
    procedure CopyItemToClipboard(FilteredIdx: Integer);
    procedure DirectPasteItem(FilteredIdx: Integer);
    procedure ToggleFavorite(FilteredIdx: Integer);
    procedure RebuildFilter;
    function  GetFilteredItem(Idx: Integer): TClipItem;
    function  GetRealIndex(FilteredIdx: Integer): Integer;
    function  GetItemPreview(const S: string; MaxLen: Integer = 140): string;
    function  FormatAge(T: TDateTime): string;
    procedure SetTab(ShowFav: Boolean);
    procedure ApplyDarkTheme;
    procedure RegisterAppHotKey;
    procedure UnregisterAppHotKey;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure LoadHistory;
    procedure SaveHistory;
    function  SettingsPath: string;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

// -----------------------------------------------------------------------
// Dark theme
// -----------------------------------------------------------------------

procedure TfrmMain.ApplyDarkTheme;
  procedure StyleToolBtn(L: TLabel; FontSize: Integer = 10);
  begin
    L.Font.Color    := CLR_BTN_TXT;
    L.Font.Size     := FontSize;
    L.Font.Name     := 'Segoe UI';
    L.Color         := CLR_TOOLBAR;
    L.Transparent   := False;
    L.Alignment     := taCenter;
    L.Layout        := tlCenter;
    L.Cursor        := crHandPoint;
    L.OnMouseEnter  := lblMouseEnter;
    L.OnMouseLeave  := lblMouseLeave;
  end;
begin
  Color                    := CLR_BG;
  DoubleBuffered           := True;
  pnlToolbar.Color         := CLR_TOOLBAR;
  pnlSepToolbar.Color      := CLR_SEP;
  pnlTabs.Color            := CLR_TOOLBAR;
  pnlSepTabs.Color         := CLR_SEP;
  pnlSearch.Color          := CLR_TOOLBAR;
  pnlSepSearch.Color       := CLR_SEP;

  StyleToolBtn(lblCopy);
  StyleToolBtn(lblDirectPaste);
  StyleToolBtn(lblQuickLook);
  StyleToolBtn(lblPlainText);
  StyleToolBtn(lblSettings, 14);

  // Tab labels base style
  for var L in [lblTabAll, lblTabFav] do
  begin
    L.Font.Name   := 'Segoe UI';
    L.Alignment   := taCenter;
    L.Layout      := tlCenter;
    L.Cursor      := crHandPoint;
    L.Transparent := False;
  end;

  lbHistory.Color      := CLR_BG;
  lbHistory.Font.Color := CLR_TEXT;
  lbHistory.Font.Name  := 'Segoe UI';

  edSearch.Color       := CLR_THUMB_BG;
  edSearch.Font.Color  := CLR_TEXT;
  edSearch.Font.Name   := 'Segoe UI';
  edSearch.Font.Size   := 11;
  edSearch.BorderStyle := bsNone;
  edSearch.TextHint    := 'Search...';

  SetTab(False);
end;

procedure TfrmMain.SetTab(ShowFav: Boolean);
begin
  FShowFav := ShowFav;

  lblTabAll.Color      := CLR_TOOLBAR;
  lblTabAll.Font.Color := CLR_DIM;
  lblTabAll.Font.Size  := 11;
  lblTabAll.Font.Style := [];

  lblTabFav.Color      := CLR_TOOLBAR;
  lblTabFav.Font.Color := CLR_DIM;
  lblTabFav.Font.Size  := 11;
  lblTabFav.Font.Style := [];

  if not ShowFav then
  begin
    lblTabAll.Color      := CLR_TAB_ACT;
    lblTabAll.Font.Color := CLR_TEXT;
    lblTabAll.Font.Style := [fsBold];
  end
  else
  begin
    lblTabFav.Color      := CLR_TAB_ACT;
    lblTabFav.Font.Color := CLR_TEXT;
    lblTabFav.Font.Style := [fsBold];
  end;

  RebuildFilter;
end;

// -----------------------------------------------------------------------
// Form lifetime
// -----------------------------------------------------------------------

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FItems      := TList<TClipItem>.Create;
  FFiltered   := TList<Integer>.Create;
  FIgnoreNext := False;
  FPrevWindow := 0;
  AddClipboardFormatListener(Handle);
  ApplyDarkTheme;
  LoadSettings;
  LoadHistory;
  RegisterAppHotKey;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  UnregisterAppHotKey;
  RemoveClipboardFormatListener(Handle);
  SaveHistory;
  SaveSettings;
  FFiltered.Free;
  FItems.Free;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
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
  try
    S := Clipboard.AsText;
    if S.Trim <> '' then
      AddToHistory(S);
  except
  end;
end;

// -----------------------------------------------------------------------
// Global hotkey
// -----------------------------------------------------------------------

procedure TfrmMain.WMHotKey(var Msg: TMessage);
begin
  if Msg.WParam <> HOTKEY_ID then Exit;
  FPrevWindow := GetForegroundWindow;
  if not Visible or (WindowState = wsMinimized) then
    miRestoreClick(nil)
  else
  begin
    SetForegroundWindow(Handle);
    BringToFront;
  end;
end;

// -----------------------------------------------------------------------
// History management
// -----------------------------------------------------------------------

procedure TfrmMain.AddToHistory(const S: string);
var
  I: Integer;
  Item: TClipItem;
begin
  if (FItems.Count > 0) and (FItems[0].Text = S) then Exit;

  for I := 0 to FItems.Count - 1 do
    if FItems[I].Text = S then
    begin
      FItems.Delete(I);
      Break;
    end;

  Item.Text       := S;
  Item.AddedAt    := Now;
  Item.IsFavorite := False;
  FItems.Insert(0, Item);

  while FItems.Count > MAX_HISTORY do
    FItems.Delete(FItems.Count - 1);

  RebuildFilter;
  SaveHistory;
end;

procedure TfrmMain.DeleteHistoryItem(FilteredIdx: Integer);
var
  RealIdx: Integer;
begin
  RealIdx := GetRealIndex(FilteredIdx);
  if RealIdx < 0 then Exit;
  FItems.Delete(RealIdx);
  RebuildFilter;
  SaveHistory;
  if lbHistory.Count > 0 then
    lbHistory.ItemIndex := Min(FilteredIdx, lbHistory.Count - 1);
end;

procedure TfrmMain.ToggleFavorite(FilteredIdx: Integer);
var
  RealIdx: Integer;
  Item: TClipItem;
begin
  RealIdx := GetRealIndex(FilteredIdx);
  if RealIdx < 0 then Exit;
  Item := FItems[RealIdx];
  Item.IsFavorite := not Item.IsFavorite;
  FItems[RealIdx] := Item;
  RebuildFilter;
  SaveHistory;
end;

procedure TfrmMain.CopyItemToClipboard(FilteredIdx: Integer);
var
  RealIdx: Integer;
  Item: TClipItem;
begin
  RealIdx := GetRealIndex(FilteredIdx);
  if RealIdx < 0 then Exit;
  FIgnoreNext := True;
  Item := FItems[RealIdx];
  Clipboard.AsText := Item.Text;
  Item.AddedAt := Now;
  FItems.Delete(RealIdx);
  FItems.Insert(0, Item);
  RebuildFilter;
  SaveHistory;
  lbHistory.ItemIndex := 0;
end;

procedure TfrmMain.DirectPasteItem(FilteredIdx: Integer);
var
  RealIdx: Integer;
  PrevWnd: HWND;
begin
  RealIdx := GetRealIndex(FilteredIdx);
  if RealIdx < 0 then Exit;
  FIgnoreNext := True;
  Clipboard.AsText := FItems[RealIdx].Text;
  PrevWnd := FPrevWindow;
  Hide;
  TrayIcon.Visible := True;
  if IsWindow(PrevWnd) then
  begin
    SetForegroundWindow(PrevWnd);
    Application.ProcessMessages;
    keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), 0, 0);
    keybd_event(Ord('V'),   MapVirtualKey(Ord('V'),   0), 0, 0);
    keybd_event(Ord('V'),   MapVirtualKey(Ord('V'),   0), KEYEVENTF_KEYUP, 0);
    keybd_event(VK_CONTROL, MapVirtualKey(VK_CONTROL, 0), KEYEVENTF_KEYUP, 0);
  end;
end;

// -----------------------------------------------------------------------
// Filter & display
// -----------------------------------------------------------------------

procedure TfrmMain.RebuildFilter;
var
  I, SelReal, NewSel: Integer;
  Item: TClipItem;
begin
  SelReal := GetRealIndex(lbHistory.ItemIndex);

  FFiltered.Clear;
  for I := 0 to FItems.Count - 1 do
  begin
    Item := FItems[I];
    if FShowFav and not Item.IsFavorite then Continue;
    if (FSearchText <> '') and
       (Pos(FSearchText.ToLower, Item.Text.ToLower) = 0) then Continue;
    FFiltered.Add(I);
  end;

  lbHistory.Items.BeginUpdate;
  try
    lbHistory.Items.Clear;
    for I := 0 to FFiltered.Count - 1 do
      lbHistory.Items.Add('');
  finally
    lbHistory.Items.EndUpdate;
  end;

  NewSel := -1;
  if SelReal >= 0 then
    for I := 0 to FFiltered.Count - 1 do
      if FFiltered[I] = SelReal then
      begin
        NewSel := I;
        Break;
      end;
  if (NewSel < 0) and (FFiltered.Count > 0) then
    NewSel := 0;
  lbHistory.ItemIndex := NewSel;
end;

function TfrmMain.GetFilteredItem(Idx: Integer): TClipItem;
begin
  Result := FItems[FFiltered[Idx]];
end;

function TfrmMain.GetRealIndex(FilteredIdx: Integer): Integer;
begin
  if (FilteredIdx < 0) or (FilteredIdx >= FFiltered.Count) then
    Result := -1
  else
    Result := FFiltered[FilteredIdx];
end;

function TfrmMain.GetItemPreview(const S: string; MaxLen: Integer = 140): string;
begin
  Result := S;
  Result := StringReplace(Result, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10,    ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13,    ' ', [rfReplaceAll]);
  Result := Result.Trim;
  if Length(Result) > MaxLen then
    Result := Copy(Result, 1, MaxLen) + '...';
end;

function TfrmMain.FormatAge(T: TDateTime): string;
var
  Mins, Hours, Days: Integer;
begin
  Mins  := Max(0, Trunc((Now - T) * 1440));
  Hours := Mins div 60;
  Days  := Hours div 24;
  if Mins < 1    then Result := 'now'
  else if Mins < 60  then Result := Format('%d m', [Mins])
  else if Hours < 24 then Result := Format('%d h', [Hours])
  else                    Result := Format('%d d', [Days]);
end;

// -----------------------------------------------------------------------
// Owner-draw list
// -----------------------------------------------------------------------

procedure TfrmMain.lbHistoryDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
const
  M = 8;
  GAP = 8;
var
  C: TCanvas;
  Item: TClipItem;
  ThumbR, ContentR, TextR: TRect;
  OldBkMode: Integer;
begin
  if (Index < 0) or (Index >= FFiltered.Count) then Exit;
  C    := lbHistory.Canvas;
  Item := GetFilteredItem(Index);

  // Background
  if odSelected in State then
    C.Brush.Color := CLR_SEL
  else if Odd(Index) then
    C.Brush.Color := CLR_ITEM_ALT
  else
    C.Brush.Color := CLR_BG;
  C.Brush.Style := bsSolid;
  C.FillRect(Rect);

  // Bottom separator
  C.Pen.Color := CLR_SEP;
  C.Pen.Style := psSolid;
  C.MoveTo(Rect.Left, Rect.Bottom - 1);
  C.LineTo(Rect.Right, Rect.Bottom - 1);

  OldBkMode := SetBkMode(C.Handle, TRANSPARENT);
  try
    // ---- Thumbnail ----
    ThumbR.Left   := Rect.Left + M;
    ThumbR.Top    := Rect.Top + (Rect.Height - THUMB_SZ) div 2;
    ThumbR.Width  := THUMB_SZ;
    ThumbR.Height := THUMB_SZ;

    C.Brush.Color := CLR_THUMB_BG;
    C.Brush.Style := bsSolid;
    C.FillRect(ThumbR);

    C.Pen.Color   := CLR_THUMB_BR;
    C.Pen.Style   := psDash;
    C.Brush.Style := bsClear;
    C.RoundRect(ThumbR.Left, ThumbR.Top, ThumbR.Right, ThumbR.Bottom, 8, 8);
    C.Pen.Style   := psSolid;

    // Mini text inside thumbnail
    C.Font.Name  := 'Segoe UI';
    C.Font.Size  := 7;
    C.Font.Style := [];
    C.Font.Color := CLR_DIM;
    var TinyR := ThumbR;
    InflateRect(TinyR, -5, -5);
    DrawText(C.Handle, PChar(GetItemPreview(Item.Text, 35)), -1, TinyR,
      DT_WORDBREAK or DT_NOPREFIX);

    // ---- Content area ----
    ContentR.Left   := ThumbR.Right + GAP;
    ContentR.Top    := Rect.Top + 6;
    ContentR.Right  := Rect.Right - M;
    ContentR.Bottom := Rect.Bottom - 6;

    // Meta: "Text, N characters" — small, centered, dimmed
    C.Font.Size  := 9;
    C.Font.Color := CLR_DIM;
    C.Font.Style := [];
    TextR        := ContentR;
    TextR.Bottom := ContentR.Top + 17;
    DrawText(C.Handle,
      PChar(Format('Text,  %d characters', [Length(Item.Text)])),
      -1, TextR, DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_NOPREFIX);

    // Preview text — white, larger
    C.Font.Size  := 11;
    C.Font.Color := CLR_TEXT;
    C.Font.Style := [];
    TextR.Top    := ContentR.Top + 19;
    TextR.Bottom := ContentR.Bottom - 19;
    TextR.Left   := ContentR.Left;
    TextR.Right  := ContentR.Right;
    DrawText(C.Handle, PChar(GetItemPreview(Item.Text)), -1, TextR,
      DT_WORDBREAK or DT_END_ELLIPSIS or DT_NOPREFIX);

    // Bottom row: age (right) + star (before age)
    TextR.Top    := ContentR.Bottom - 17;
    TextR.Bottom := ContentR.Bottom;
    TextR.Left   := ContentR.Left;
    TextR.Right  := ContentR.Right;

    C.Font.Size  := 9;
    C.Font.Color := CLR_DIM;
    C.Font.Style := [];
    DrawText(C.Handle, PChar(FormatAge(Item.AddedAt)), -1, TextR,
      DT_SINGLELINE or DT_RIGHT or DT_VCENTER or DT_NOPREFIX);

    if Item.IsFavorite then
    begin
      C.Font.Size  := 11;
      C.Font.Color := CLR_GOLD;
      var StarR := TextR;
      StarR.Right := StarR.Right - 32;
      DrawText(C.Handle, '★', -1, StarR,
        DT_SINGLELINE or DT_RIGHT or DT_VCENTER or DT_NOPREFIX);
    end;
  finally
    SetBkMode(C.Handle, OldBkMode);
  end;
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

procedure TfrmMain.lbHistoryMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
begin
  if Button = mbRight then
  begin
    Idx := lbHistory.ItemAtPos(Point(X, Y), True);
    if Idx >= 0 then
      lbHistory.ItemIndex := Idx;
  end;
end;

// -----------------------------------------------------------------------
// Toolbar button events
// -----------------------------------------------------------------------

procedure TfrmMain.lblCopyClick(Sender: TObject);
begin
  CopyItemToClipboard(lbHistory.ItemIndex);
end;

procedure TfrmMain.lblDirectPasteClick(Sender: TObject);
begin
  DirectPasteItem(lbHistory.ItemIndex);
end;

procedure TfrmMain.lblQuickLookClick(Sender: TObject);
var
  I: Integer;
begin
  I := lbHistory.ItemIndex;
  if (I < 0) or (I >= FFiltered.Count) then Exit;
  ShowMessage(GetFilteredItem(I).Text);
end;

procedure TfrmMain.lblPlainTextClick(Sender: TObject);
begin
  CopyItemToClipboard(lbHistory.ItemIndex);
end;

procedure TfrmMain.lblSettingsClick(Sender: TObject);
var
  Dlg: TdlgHotkey;
begin
  Dlg := TdlgHotkey.Create(Self);
  try
    Dlg.hkInput.HotKey := FHotKeyShortCut;
    if Dlg.ShowModal = mrOk then
    begin
      FHotKeyShortCut := Dlg.hkInput.HotKey;
      RegisterAppHotKey;
      SaveSettings;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmMain.lblMouseEnter(Sender: TObject);
begin
  (Sender as TLabel).Font.Color := CLR_TEXT;
  (Sender as TLabel).Color      := CLR_BTN_HOV;
end;

procedure TfrmMain.lblMouseLeave(Sender: TObject);
begin
  (Sender as TLabel).Font.Color := CLR_BTN_TXT;
  (Sender as TLabel).Color      := CLR_TOOLBAR;
end;

// -----------------------------------------------------------------------
// Tab events
// -----------------------------------------------------------------------

procedure TfrmMain.lblTabAllClick(Sender: TObject);
begin
  SetTab(False);
end;

procedure TfrmMain.lblTabFavClick(Sender: TObject);
begin
  SetTab(True);
end;

// -----------------------------------------------------------------------
// Search
// -----------------------------------------------------------------------

procedure TfrmMain.edSearchChange(Sender: TObject);
begin
  FSearchText := edSearch.Text;
  RebuildFilter;
end;

// -----------------------------------------------------------------------
// Context menu
// -----------------------------------------------------------------------

procedure TfrmMain.pmHistoryPopup(Sender: TObject);
var
  HasSel: Boolean;
  RealIdx: Integer;
begin
  HasSel := (lbHistory.ItemIndex >= 0) and (lbHistory.ItemIndex < FFiltered.Count);
  miCopyItem.Enabled   := HasSel;
  miToggleFav.Enabled  := HasSel;
  miDeleteItem.Enabled := HasSel;
  if HasSel then
  begin
    RealIdx := GetRealIndex(lbHistory.ItemIndex);
    if (RealIdx >= 0) and FItems[RealIdx].IsFavorite then
      miToggleFav.Caption := 'Remove from Favorites ★'
    else
      miToggleFav.Caption := 'Add to Favorites ☆';
  end;
end;

procedure TfrmMain.miCopyItemClick(Sender: TObject);
begin
  CopyItemToClipboard(lbHistory.ItemIndex);
end;

procedure TfrmMain.miToggleFavClick(Sender: TObject);
begin
  ToggleFavorite(lbHistory.ItemIndex);
end;

procedure TfrmMain.miDeleteItemClick(Sender: TObject);
begin
  DeleteHistoryItem(lbHistory.ItemIndex);
end;

// -----------------------------------------------------------------------
// Tray icon
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
  SaveHistory;
  SaveSettings;
  Application.Terminate;
end;

// -----------------------------------------------------------------------
// Settings & hotkey
// -----------------------------------------------------------------------

function TfrmMain.SettingsPath: string;
begin
  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('APPDATA'))
            + 'CHistory\settings.ini';
end;

procedure TfrmMain.LoadSettings;
var
  Ini: TIniFile;
begin
  ForceDirectories(ExtractFileDir(SettingsPath));
  Ini := TIniFile.Create(SettingsPath);
  try
    FHotKeyShortCut := Ini.ReadInteger('Hotkey', 'ShortCut', 0);
  finally
    Ini.Free;
  end;
end;

procedure TfrmMain.SaveSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(SettingsPath);
  try
    Ini.WriteInteger('Hotkey', 'ShortCut', FHotKeyShortCut);
  finally
    Ini.Free;
  end;
end;

procedure TfrmMain.LoadHistory;
var
  Ini: TIniFile;
  I, Cnt: Integer;
  Item: TClipItem;
  EncText: string;
begin
  Ini := TIniFile.Create(SettingsPath);
  try
    Cnt := Max(0, Ini.ReadInteger('History', 'Count', 0));
    for I := 0 to Cnt - 1 do
    begin
      EncText := Ini.ReadString('History', Format('Item%d_Text', [I]), '');
      if EncText = '' then
        Continue;
      try
        Item.Text := TNetEncoding.Base64.Decode(EncText);
      except
        Continue;
      end;
      if Item.Text.Trim = '' then
        Continue;
      Item.AddedAt := Ini.ReadFloat('History', Format('Item%d_AddedAt', [I]), Now);
      Item.IsFavorite := Ini.ReadBool('History', Format('Item%d_Favorite', [I]), False);
      FItems.Add(Item);
      if FItems.Count >= MAX_HISTORY then
        Break;
    end;
  finally
    Ini.Free;
  end;
  RebuildFilter;
end;

procedure TfrmMain.SaveHistory;
var
  Ini: TIniFile;
  I, Cnt: Integer;
  Item: TClipItem;
begin
  ForceDirectories(ExtractFileDir(SettingsPath));
  Ini := TIniFile.Create(SettingsPath);
  try
    Ini.EraseSection('History');
    Cnt := Min(FItems.Count, MAX_HISTORY);
    Ini.WriteInteger('History', 'Count', Cnt);
    for I := 0 to Cnt - 1 do
    begin
      Item := FItems[I];
      Ini.WriteString('History', Format('Item%d_Text', [I]),
        TNetEncoding.Base64.Encode(Item.Text));
      Ini.WriteFloat('History', Format('Item%d_AddedAt', [I]), Item.AddedAt);
      Ini.WriteBool('History', Format('Item%d_Favorite', [I]), Item.IsFavorite);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TfrmMain.RegisterAppHotKey;
var
  Key:   Word;
  Shift: TShiftState;
  Mods:  UINT;
begin
  UnregisterHotKey(Handle, HOTKEY_ID);
  if FHotKeyShortCut = 0 then Exit;
  ShortCutToKey(FHotKeyShortCut, Key, Shift);
  if Key = 0 then Exit;
  Mods := 0;
  if ssShift in Shift then Mods := Mods or MOD_SHIFT;
  if ssCtrl  in Shift then Mods := Mods or MOD_CONTROL;
  if ssAlt   in Shift then Mods := Mods or MOD_ALT;
  if not RegisterHotKey(Handle, HOTKEY_ID, Mods, Key) then
    MessageDlg('Could not register hotkey — it may be in use by another application.',
      mtWarning, [mbOK], 0);
end;

procedure TfrmMain.UnregisterAppHotKey;
begin
  UnregisterHotKey(Handle, HOTKEY_ID);
end;

end.
