unit UStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, System.ImageList, Vcl.ImgList;

type
  TStart = class(TForm)
    BStart: TButton;
    BExit: TButton;
    DiffRadioGroup: TRadioGroup;
    StartTitleImage: TImage;
    BLoad: TButton;
    SaveComboBox: TComboBox;
    BackgroundImage: TImage;
    procedure BStartClick(Sender: TObject);
    procedure BExitClick(Sender: TObject);
    procedure DiffRadioGroupClick(Sender: TObject);
    procedure SaveComboBoxSelect(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
  private
  public
  end;

var
  Start: TStart;
  FName: string;

implementation

{$R *.dfm}

uses UGame, UInv, UStats;

procedure TStart.BExitClick(Sender: TObject);
begin
 Application.Terminate;   //Закрывает проект
end;

procedure TStart.BLoadClick(Sender: TObject);
begin
 FName := SaveComboBox.Items[SaveComboBox.Itemindex];  //Задание переменной, означающей название файла, из которого загружается карта
 Application.CreateForm(TInventory, Inventory);
 Application.CreateForm(TGame, Game);
 Application.CreateForm(TStats, Stats);
 Game.show;
 Start.hide;   //Переход на следующую форму
end;

procedure TStart.BStartClick(Sender: TObject);
begin
 FName := 'OriginalMap.txt';    //Задание переменной, означающей название файла, из которого загружается карта
 Application.CreateForm(TInventory, Inventory);
 Application.CreateForm(TGame, Game);
 Application.CreateForm(TStats, Stats);
 Game.show;
 Start.hide;   //Переход на следующую форму
end;

procedure TStart.DiffRadioGroupClick(Sender: TObject);
begin
 BStart.Enabled := True;   //Активация кнопки
end;


procedure TStart.FormShow(Sender: TObject);
var k: integer;
var  sr: TSearchRec;
begin
 Canvas.Draw(0,0,BackgroundImage.Picture.Bitmap);  //Рисует фон
 SaveComboBox.Items.Clear;  //Очищает списое сохранений
 k := 0;
 if FindFirst(ExtractFilePath(Application.ExeName)+'Saves/Save_*.txt', faAnyFile, sr)=0  then  //ищем  файлы сохранений  в каталоге
  repeat
   SaveComboBox.Items.Add(sr.Name); //выводим список в ComboBox
  until FindNext(sr)<>0;
  FindClose(sr);
end;

procedure TStart.SaveComboBoxSelect(Sender: TObject);
begin
 BLoad.Enabled := True;  //Активирует кнопку загрузки
end;

end.
