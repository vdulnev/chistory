object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'CHistory - Clipboard Manager'
  ClientHeight = 540
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object lblTitle: TLabel
    Left = 0
    Top = 0
    Width = 500
    Height = 36
    Align = alTop
    Alignment = taCenter
    Caption = 'Clipboard History'
    Color = clHighlight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
    Transparent = False
  end
  object lbHistory: TListBox
    Left = 0
    Top = 36
    Width = 500
    Height = 443
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemHeight = 20
    ParentFont = False
    PopupMenu = pmHistory
    TabOrder = 0
    OnDblClick = lbHistoryDblClick
    OnKeyDown = lbHistoryKeyDown
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 479
    Width = 500
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    Color = clBtnFace
    TabOrder = 1
    object btnCopy: TButton
      Left = 8
      Top = 6
      Width = 115
      Height = 30
      Caption = 'Copy Selected'
      TabOrder = 0
      OnClick = btnCopyClick
    end
    object btnClear: TButton
      Left = 131
      Top = 6
      Width = 115
      Height = 30
      Caption = 'Clear All'
      TabOrder = 1
      OnClick = btnClearClick
    end
    object btnHotkey: TButton
      Left = 254
      Top = 6
      Width = 115
      Height = 30
      Caption = 'Set Hotkey...'
      TabOrder = 2
      OnClick = btnHotkeyClick
    end
    object btnClose: TButton
      Left = 377
      Top = 6
      Width = 115
      Height = 30
      Caption = 'Minimize to Tray'
      TabOrder = 3
      OnClick = btnCloseClick
    end
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 521
    Width = 500
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = ' 0 item(s)  |  Hotkey: none'
  end
  object TrayIcon: TTrayIcon
    BalloonFlags = bfInfo
    BalloonHint = 'CHistory is monitoring your clipboard.'
    BalloonTitle = 'CHistory'
    Hint = 'CHistory - Clipboard Manager'
    PopupMenu = pmTray
    Visible = False
    OnDblClick = TrayIconDblClick
    Left = 408
    Top = 56
  end
  object pmTray: TPopupMenu
    Left = 408
    Top = 104
    object miRestore: TMenuItem
      Caption = 'Restore'
      Default = True
      OnClick = miRestoreClick
    end
    object miSep1: TMenuItem
      Caption = '-'
    end
    object miExit: TMenuItem
      Caption = 'Exit'
      OnClick = miExitClick
    end
  end
  object pmHistory: TPopupMenu
    OnPopup = pmHistoryPopup
    Left = 408
    Top = 152
    object miCopyItem: TMenuItem
      Caption = 'Copy to Clipboard'
      OnClick = miCopyItemClick
    end
    object miDeleteItem: TMenuItem
      Caption = 'Delete'
      OnClick = miDeleteItemClick
    end
  end
end
