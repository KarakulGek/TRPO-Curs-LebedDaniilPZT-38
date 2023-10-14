unit UTitle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage;

type
  TTitle = class(TForm)
    TitleImage: TImage;
    TitleTimer: TTimer;
    procedure TitleTimerTimer(Sender: TObject);
  private
  public
  end;

var
  Title: TTitle;
  x: byte;

implementation

{$R *.dfm}

uses UStart;


procedure TTitle.TitleTimerTimer(Sender: TObject);
//Процедура делает заставку менее прозрачной, когда она становится полностью непрозрачной начинается отсчёт, после которого форма становится более прозрачной
begin
 if Title.AlphaBlendValue = 255 then x := x+1; //Отсчёт, если форма непрозрачная
 if x = 0 then Title.AlphaBlendValue:= Title.AlphaBlendValue + 5 //Если отсчёта не было, делает форму менее прозрачной
 else if x = 100 then Title.AlphaBlendValue:= Title.AlphaBlendValue - 5;  //Если отсчёт закончился, делает форму более прозрачной
 if Title.AlphaBlendValue = 0 then begin Application.CreateForm(TStart, Start);  //Переход на следующую форму
                                         Start.Show;
                                         TitleTimer.enabled:=False;
                                         Title.Hide; end;
end;

end.
