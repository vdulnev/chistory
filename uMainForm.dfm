object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'CHistory'
  ClientHeight = 600
  ClientWidth = 480
  Color = $002B2B2B
  Font.Charset = DEFAULT_CHARSET
  Font.Color = $00F0F0F0
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object pnlToolbar: TPanel
    Left = 0
    Top = 0
    Width = 480
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    Color = $00202020
    ParentBackground = False
    TabOrder = 0
    object pnlTopItems: TPanel
      Left = 0
      Top = 0
      Width = 480
      Height = 52
      Align = alClient
      BevelOuter = bvNone
      Color = $00202020
      ParentBackground = False
      Padding.Left = 16
      Padding.Top = 6
      Padding.Right = 16
      Padding.Bottom = 6
      TabOrder = 0
      object lblCopy: TLabel
        Left = 16
        Top = 6
        Width = 80
        Height = 40
        Align = alLeft
        Alignment = taCenter
        Caption = 'Copy'
        Color = $00202020
        Font.Charset = DEFAULT_CHARSET
        Font.Color = $00AAAAAA
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        Layout = tlCenter
        ParentFont = False
        Transparent = False
        OnClick = lblCopyClick
        OnMouseEnter = lblMouseEnter
        OnMouseLeave = lblMouseLeave
      end
      object spTop1: TPanel
        Left = 96
        Top = 6
        Width = 42
        Height = 40
        Align = alLeft
        BevelOuter = bvNone
        Caption = ' '
        Color = $00202020
        ParentBackground = False
        TabOrder = 0
      end
      object lblDirectPaste: TLabel
        Left = 138
        Top = 6
        Width = 80
        Height = 40
        Align = alLeft
        Alignment = taCenter
        Caption = 'Direct Paste'
        Color = $00202020
        Font.Charset = DEFAULT_CHARSET
        Font.Color = $00AAAAAA
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        Layout = tlCenter
        ParentFont = False
        Transparent = False
        OnClick = lblDirectPasteClick
        OnMouseEnter = lblMouseEnter
        OnMouseLeave = lblMouseLeave
      end
      object spTop2: TPanel
        Left = 218
        Top = 6
        Width = 43
        Height = 40
        Align = alLeft
        BevelOuter = bvNone
        Caption = ' '
        Color = $00202020
        ParentBackground = False
        TabOrder = 1
      end
      object lblQuickLook: TLabel
        Left = 261
        Top = 6
        Width = 80
        Height = 40
        Align = alLeft
        Alignment = taCenter
        Caption = 'Quick Look'
        Color = $00202020
        Font.Charset = DEFAULT_CHARSET
        Font.Color = $00AAAAAA
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        Layout = tlCenter
        ParentFont = False
        Transparent = False
        OnClick = lblQuickLookClick
        OnMouseEnter = lblMouseEnter
        OnMouseLeave = lblMouseLeave
      end
      object spTop3: TPanel
        Left = 341
        Top = 6
        Width = 43
        Height = 40
        Align = alLeft
        BevelOuter = bvNone
        Caption = ' '
        Color = $00202020
        ParentBackground = False
        TabOrder = 2
      end
      object lblSettings: TLabel
        Left = 384
        Top = 6
        Width = 80
        Height = 40
        Align = alLeft
        Alignment = taCenter
        Caption = #9881
        Color = $00202020
        Font.Charset = DEFAULT_CHARSET
        Font.Color = $00AAAAAA
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = []
        Layout = tlCenter
        ParentFont = False
        Transparent = False
        OnClick = lblSettingsClick
        OnMouseEnter = lblMouseEnter
        OnMouseLeave = lblMouseLeave
      end
    end
  end
  object pnlSepToolbar: TPanel
    Left = 0
    Top = 52
    Width = 480
    Height = 1
    Align = alTop
    BevelOuter = bvNone
    Color = $00444444
    ParentBackground = False
    TabOrder = 1
  end
  object pnlTabs: TPanel
    Left = 0
    Top = 53
    Width = 480
    Height = 34
    Align = alTop
    BevelOuter = bvNone
    Color = $00202020
    ParentBackground = False
    TabOrder = 2
    object pnlTabItems: TPanel
      Left = 0
      Top = 0
      Width = 480
      Height = 34
      Align = alClient
      BevelOuter = bvNone
      Color = $00202020
      ParentBackground = False
      Padding.Left = 16
      Padding.Top = 4
      Padding.Right = 16
      Padding.Bottom = 4
      TabOrder = 0
      object lblTabAll: TLabel
        Left = 16
        Top = 4
        Width = 218
        Height = 26
        Align = alLeft
        Alignment = taCenter
        Caption = 'All'
        Color = $003C3C3C
        Font.Charset = DEFAULT_CHARSET
        Font.Color = $00F0F0F0
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        Layout = tlCenter
        ParentFont = False
        Transparent = False
        OnClick = lblTabAllClick
      end
      object spTab: TPanel
        Left = 234
        Top = 4
        Width = 12
        Height = 26
        Align = alLeft
        BevelOuter = bvNone
        Caption = ' '
        Color = $00202020
        ParentBackground = False
        TabOrder = 0
      end
      object lblTabFav: TLabel
        Left = 246
        Top = 4
        Width = 218
        Height = 26
        Align = alLeft
        Alignment = taCenter
        Caption = 'Favorites '#9729
        Color = $00202020
        Font.Charset = DEFAULT_CHARSET
        Font.Color = $00888888
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Layout = tlCenter
        ParentFont = False
        Transparent = False
        OnClick = lblTabFavClick
      end
    end
  end
  object pnlSepTabs: TPanel
    Left = 0
    Top = 87
    Width = 480
    Height = 1
    Align = alTop
    BevelOuter = bvNone
    Color = $00444444
    ParentBackground = False
    TabOrder = 3
  end
  object lbHistory: TListBox
    Left = 0
    Top = 88
    Width = 480
    Height = 471
    Align = alClient
    BorderStyle = bsNone
    Color = $002B2B2B
    Font.Charset = DEFAULT_CHARSET
    Font.Color = $00F0F0F0
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemHeight = 76
    ParentFont = False
    PopupMenu = pmHistory
    Style = lbOwnerDrawFixed
    TabOrder = 4
    OnDblClick = lbHistoryDblClick
    OnDrawItem = lbHistoryDrawItem
    OnKeyDown = lbHistoryKeyDown
    OnMouseDown = lbHistoryMouseDown
  end
  object pnlSepSearch: TPanel
    Left = 0
    Top = 559
    Width = 480
    Height = 1
    Align = alBottom
    BevelOuter = bvNone
    Color = $00444444
    ParentBackground = False
    TabOrder = 5
  end
  object pnlSearch: TPanel
    Left = 0
    Top = 560
    Width = 480
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = $00202020
    ParentBackground = False
    TabOrder = 6
    object edSearch: TEdit
      Left = 8
      Top = 6
      Width = 464
      Height = 28
      Color = $00383838
      Font.Charset = DEFAULT_CHARSET
      Font.Color = $00F0F0F0
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      TextHint = 'Search...'
      OnChange = edSearchChange
    end
  end
  object TrayIcon: TTrayIcon
    BalloonFlags = bfInfo
    BalloonHint = 'CHistory is monitoring your clipboard.'
    BalloonTitle = 'CHistory'
    Hint = 'CHistory - Clipboard Manager'
    PopupMenu = pmTray
    Visible = False
    OnDblClick = TrayIconDblClick
    Left = 392
    Top = 120
  end
  object pmTray: TPopupMenu
    Left = 392
    Top = 168
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
    Left = 392
    Top = 216
    object miCopyItem: TMenuItem
      Caption = 'Copy to Clipboard'
      OnClick = miCopyItemClick
    end
    object miToggleFav: TMenuItem
      Caption = 'Add to Favorites'
      OnClick = miToggleFavClick
    end
    object miSepHist: TMenuItem
      Caption = '-'
    end
    object miDeleteItem: TMenuItem
      Caption = 'Delete'
      OnClick = miDeleteItemClick
    end
  end
end
