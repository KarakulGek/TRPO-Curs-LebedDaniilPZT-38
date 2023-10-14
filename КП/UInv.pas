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
//Процедура читает пункт меню, который выбрал игрок и выводит соответствующий текст и картинку
begin
 if ItemListBox.ItemIndex > -1 then begin
  if ItemListBox.Items[ItemListBox.ItemIndex] = 'Меч' then begin
   ItemsImageList.GetIcon(0,ItemImage.Picture.Icon);
   ItemMemo.Text := 'Позолоченный меч'+#13+#10+'Прибавляет 5 к урону игрока'+#13+#10+'Используется не больше одного'+#13+#10+'Стоит 150 очков';
  end
  else if ItemListBox.Items[ItemListBox.ItemIndex] = 'Амулет' then begin
   ItemsImageList.GetIcon(1,ItemImage.Picture.Icon);
   ItemMemo.Text := 'Магический амулет'+#13+#10+'Прибавляет 50 к здоровью игрока'+#13+#10+'Используется не больше одного'+#13+#10+'Стоит 100 очков';
  end
  else if ItemListBox.Items[ItemListBox.ItemIndex] = 'Зелье' then begin
   ItemsImageList.GetIcon(2,ItemImage.Picture.Icon);
   ItemMemo.Text := 'Лечебное зелье'+#13+#10+'Прибавляет 20 к здоровью игрока'+#13+#10+'Эффекты нескольких зелий складываются'+#13+#10+'Стоит 50 очков';
  end;
 end;
end;

end.
