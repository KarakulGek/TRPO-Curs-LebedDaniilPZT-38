unit UInv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.ImageList,
  Vcl.ImgList, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TInventory = class(TForm)
    ItemListBox: TListBox;
    ItemImage: TImage;
    ItemsImageList: TImageList;
    ItemMemo: TMemo;
    procedure ItemListBoxClick(Sender: TObject);
  private
  public
  end;

var
  Inventory: TInventory;

implementation

{$R *.dfm}

procedure TInventory.ItemListBoxClick(Sender: TObject);
//��������� ������ ����� ����, ������� ������ ����� � ������� ��������������� ����� � ��������
begin
 if ItemListBox.ItemIndex > -1 then begin
  if ItemListBox.Items[ItemListBox.ItemIndex] = '���' then begin
   ItemsImageList.GetIcon(0,ItemImage.Picture.Icon);
   ItemMemo.Text := '������������ ���'+#13+#10+'���������� 5 � ����� ������'+#13+#10+'������������ �� ������ ������'+#13+#10+'����� 150 �����';
  end
  else if ItemListBox.Items[ItemListBox.ItemIndex] = '������' then begin
   ItemsImageList.GetIcon(1,ItemImage.Picture.Icon);
   ItemMemo.Text := '���������� ������'+#13+#10+'���������� 50 � �������� ������'+#13+#10+'������������ �� ������ ������'+#13+#10+'����� 100 �����';
  end
  else if ItemListBox.Items[ItemListBox.ItemIndex] = '�����' then begin
   ItemsImageList.GetIcon(2,ItemImage.Picture.Icon);
   ItemMemo.Text := '�������� �����'+#13+#10+'���������� 20 � �������� ������'+#13+#10+'������� ���������� ����� ������������'+#13+#10+'����� 50 �����';
  end;
 end;
end;

end.
