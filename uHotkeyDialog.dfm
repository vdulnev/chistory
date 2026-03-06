object dlgHotkey: TdlgHotkey
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Set Global Hotkey'
  ClientHeight = 112
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 15
  object lblInstruction: TLabel
    Left = 8
    Top = 10
    Width = 304
    Height = 15
    AutoSize = False
    Caption = 'Press a key combination (e.g. Ctrl+Alt+V):'
  end
  object lblClear: TLabel
    Left = 8
    Top = 58
    Width = 304
    Height = 15
    AutoSize = False
    Caption = 'Use "Clear" to remove the hotkey.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object hkInput: THotKey
    Left = 8
    Top = 30
    Width = 304
    Height = 24
    HotKey = 0
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 72
    Top = 76
    Width = 75
    Height = 28
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 155
    Top = 76
    Width = 75
    Height = 28
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnClear: TButton
    Left = 238
    Top = 76
    Width = 75
    Height = 28
    Caption = 'Clear'
    TabOrder = 3
    OnClick = btnClearClick
  end
end
