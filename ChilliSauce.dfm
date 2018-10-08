object ChilliSauceV1: TChilliSauceV1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'ChilliSauceV1'
  ClientHeight = 609
  ClientWidth = 984
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 24
    Top = 24
    Width = 913
    Height = 329
    ColCount = 6
    DefaultColWidth = 150
    FixedCols = 0
    FixedRows = 0
    TabOrder = 0
  end
  object Log: TMemo
    Left = 24
    Top = 376
    Width = 465
    Height = 201
    Lines.Strings = (
      'Log')
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Button1: TButton
    Left = 600
    Top = 392
    Width = 193
    Height = 73
    Caption = 'Force Refresh'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = Button1Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 528
    Top = 472
  end
end
