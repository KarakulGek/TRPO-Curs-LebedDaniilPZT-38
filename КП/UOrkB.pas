unit UOrkB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Grids,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.StdCtrls, mmsystem;

type
  TOrkBattle = class(TForm)
    PImage: TImage;
    StatGrid: TStringGrid;
    EImage: TImage;
    DrumsImage: TImage;
    DrumsBar: TProgressBar;
    DrumsTimer: TTimer;
    TimeLabel: TLabel;
    RestTimer: TTimer;
    CountLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure DrumsImageClick(Sender: TObject);
    procedure DrumsTimerTimer(Sender: TObject);
    procedure RestTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
  end;

var
  OrkBattle: TOrkBattle;
  x,y,t:Integer;

implementation

{$R *.dfm}

uses UGame;

procedure TOrkBattle.DrumsImageClick(Sender: TObject);
//Процедура запускает таймер, ведёт счёт нажатий и играет соответствующий звук
begin
 if DrumsTimer.Enabled = False then begin
  DrumsTimer.Enabled := True;
  DrumsBar.State:= pbsNormal;
 end;
 inc(x);
 PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/Drums'+inttostr(random(4)+1)+'.wav'),1,SND_ASYNC);
 DrumsBar.Position := x;
 CountLabel.Caption := inttostr(x);
 //Цвет надписи меняется от количества нажатий
 if x <= 5 then CountLabel.Font.Color := clRed
 else if x <= 10 then CountLabel.Font.Color := clYellow
 else if x > 10 then CountLabel.Font.Color := clGreen;
 if x = 15 then DrumsImage.Enabled := False;
end;

procedure TOrkBattle.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//При закрытии формы выключает таймеры
 DrumsTimer.Enabled := False;
 RestTimer.Enabled := False;
end;

procedure TOrkBattle.FormCreate(Sender: TObject);
begin
  //Таймеры поумолчанию выключены
  DrumsBar.State:= pbsError;
  DrumsTimer.Enabled	:= False;
  RestTimer.Enabled	:= False;
  //Устанавливает время для нажатий
  t := 9 div DiffMod + 1;
  TimeLabel.Caption := inttostr(t);
  //Заполняет таблицу характеристик
  StatGrid.Cells[0,0]:= 'Игрок';
  StatGrid.Cells[1,0]:= '';
  StatGrid.Cells[2,0]:= 'Орк';
  StatGrid.Cells[0,1]:= inttostr(p.hp);
  StatGrid.Cells[1,1]:= 'Здоровье';
  StatGrid.Cells[2,1]:= inttostr(EMap[epx,epy].hp);
  StatGrid.Cells[0,2]:= inttostr(p.dmg);
  StatGrid.Cells[1,2]:= 'Урон';
  StatGrid.Cells[2,2]:= inttostr(EMap[epx,epy].dmg);
end;

procedure TOrkBattle.RestTimerTimer(Sender: TObject);
//Процедура считает время, пока игра находится в режиме отдыха, затем опять активирует нужные компоненты и обнуляет значения
begin
 inc(y);
 TimeLabel.Caption := TimeLabel.Caption + '.';
 if y = 4 then begin
  DrumsImage.Enabled := True;
  t := 9 div DiffMod + 1;
  TimeLabel.Caption := inttostr(t);
  DrumsBar.Position := 0;
  x := 0;
  y := 0;
  RestTimer.Enabled := False;
  CountLabel.Caption := '0';
  DrumsBar.Position := 0;
 end;
end;

procedure TOrkBattle.DrumsTimerTimer(Sender: TObject);
//Процедура уменьшает счётчик времени. Когда время кончается, наносит игроку и противнику урон, зависящий от количества нажатий и переходит в режим отдыха
begin
 dec(t);
 TimeLabel.Caption := inttostr(t);
 if TimeLabel.Caption = '0' then begin
  EMap[epx,epy].hp := EMap[epx,epy].hp - Round(10*p.dmg*x/15);
  p.hp := p.hp - Round((EMap[epx,epy].dmg/(x/15))-EMap[epx,epy].dmg);
  StatGrid.Cells[2,1]:= inttostr(EMap[epx,epy].hp);
  StatGrid.Cells[0,1]:= inttostr(p.hp);
  //Обнуляет счётчики
  x := 0;
  y := 0;
  //Переход в режим отдыха
  DrumsTimer.Enabled	:= False;
  DrumsBar.State:= pbsError;
  RestTimer.Enabled := True;
  DrumsImage.Enabled := False;
  TimeLabel.Caption := 'Отдых';
  //Оканчивает игру поражением
  if p.HP <= 0 then begin DrumsTimer.Enabled := False;
                          RestTimer.Enabled := False;
                          OrkBattle.Close;
                          PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/Death'+inttostr(random(2)+1)+'.wav'),1,SND_ASYNC);
                          ShowMessage('Вы погибли!');
                          Game.Close;
                          end
  //Оканчивает сражение победой
  else if EMap[epx,epy].hp <= 0 then begin EMap[epx,epy]:=Nil;
                                     Game.SMap.Cells[epx,epy]:= '1';
                                     DrumsTimer.Enabled := False;
                                     RestTimer.Enabled := False;
                                     Points := Points + 150;
                                     PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/BattleVictory.wav'),1,SND_ASYNC);
                                     ShowMessage('Вы выиграли!'+#13+#10+'Вы получили 150 очков');
                                     OrkBattle.Close;
                                     end;
 end;

end;

end.
