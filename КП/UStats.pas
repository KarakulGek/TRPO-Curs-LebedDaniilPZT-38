unit UStats;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.Grids, System.ImageList, Vcl.ImgList;

type
  TStats = class(TForm)
    StatGrid: TStringGrid;
    PImage: TImage;
    EButton: TButton;
    SwordImage: TImage;
    AmuletImage: TImage;
    procedure FormShow(Sender: TObject);
    procedure EButtonClick(Sender: TObject);
  private
  public
  end;

var
  Stats: TStats;

implementation

{$R *.dfm}

uses UGame, UInv;


procedure TStats.EButtonClick(Sender: TObject);
begin
 Stats.Close;   //�������� �����
end;

procedure TStats.FormShow(Sender: TObject);
begin
  SwordImage.Visible := False;
  AmuletImage.Visible := False;
  for var j:integer := 0 to Inventory.ItemListBox.Items.Count - 1 do begin
   //���� � ��������� ������������ ��� ��� ������, �� ������ ��������������� �������� ��������
   if Inventory.ItemListBox.Items[j] = '���' then SwordImage.Visible := True
   else if Inventory.ItemListBox.Items[j] = '������' then AmuletImage.Visible := True;
  end;
  //��������� ������� �������������
  StatGrid.Cells[1,0]:= inttostr(p.hp);
  StatGrid.Cells[0,0]:= '��������';
  StatGrid.Cells[1,1]:= inttostr(p.dmg);
  StatGrid.Cells[0,1]:= '����';
  StatGrid.Cells[1,2]:= inttostr(Points);
  StatGrid.Cells[0,2]:= '����';
end;

end.
