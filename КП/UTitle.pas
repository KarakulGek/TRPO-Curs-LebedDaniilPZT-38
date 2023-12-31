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
//��������� ������ �������� ����� ����������, ����� ��� ���������� ��������� ������������ ���������� ������, ����� �������� ����� ���������� ����� ����������
begin
 if Title.AlphaBlendValue = 255 then x := x+1; //������, ���� ����� ������������
 if x = 0 then Title.AlphaBlendValue:= Title.AlphaBlendValue + 5 //���� ������� �� ����, ������ ����� ����� ����������
 else if x = 100 then Title.AlphaBlendValue:= Title.AlphaBlendValue - 5;  //���� ������ ����������, ������ ����� ����� ����������
 if Title.AlphaBlendValue = 0 then begin Application.CreateForm(TStart, Start);  //������� �� ��������� �����
                                         Start.Show;
                                         TitleTimer.enabled:=False;
                                         Title.Hide; end;
end;

end.
