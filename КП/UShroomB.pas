unit UShroomB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, Grids, Vcl.Imaging.pngimage, Vcl.StdCtrls, mmsystem;

type
//В этой форме происходит модификация класса StringGrid
  TStringGrid = class(Grids.TStringGrid)
  private
    FImageList: TImageList;
  protected
   procedure DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState); override;
   procedure Loaded; override;
   procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer); override;
  end;

type
  TShroomBattle = class(TForm)
    PlayGrid: TStringGrid;
    MushroomImageList: TImageList;
    EImage: TImage;
    PImage: TImage;
    StatGrid: TStringGrid;
    TurnTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TurnTimerTimer(Sender: TObject);
    procedure PlayGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
  end;

var
  ShroomBattle: TShroomBattle;
  x1,y1,x2,y2:integer;

implementation

{$R *.dfm}

uses UGame;


procedure TShroomBattle.FormClose(Sender: TObject; var Action: TCloseAction);
//При закрытии формы выклчает таймер
begin
 TurnTimer.enabled:= False;
end;

procedure TShroomBattle.FormCreate(Sender: TObject);
begin
 TurnTimer.Interval := TurnTimer.Interval div DiffMod;
 for var i:integer := 0 to PlayGrid.RowCount - 1 do begin
 for var j:integer := 0 to PlayGrid.ColCount - 1 do begin
  PlayGrid.Cells[j,i]:='0';
 end;
 end;
  TurnTimer.enabled:= True;   //Включает таймер
  //Заполняет таблицу характеристик
  StatGrid.Cells[0,0]:= 'Игрок';
  StatGrid.Cells[1,0]:= '';
  StatGrid.Cells[2,0]:= 'Грибник';
  StatGrid.Cells[0,1]:= inttostr(p.hp);
  StatGrid.Cells[1,1]:= 'Здоровье';
  StatGrid.Cells[2,1]:= inttostr(EMap[epx,epy].hp);
  StatGrid.Cells[0,2]:= inttostr(p.dmg);
  StatGrid.Cells[1,2]:= 'Урон';
  StatGrid.Cells[2,2]:= inttostr(EMap[epx,epy].dmg);
end;


procedure TShroomBattle.PlayGridSelectCell(Sender: TObject; ACol, ARow: Integer;var CanSelect: Boolean);
//Если в случаае какой-либо ошибки вылезет лишняя ячейка таблицы, то запрещает нажать на нее
begin
 if (ACol < 0) or (ARow < 0) then CanSelect:=false;
end;

procedure TShroomBattle.TurnTimerTimer(Sender: TObject);
var x,y:integer;
//Процедура ставит гриб на случайной позиции, взрывает прошлый неубранный гриб (при этом нанося урон), и убирает взрыв
begin
 repeat
 x:= random(7);
 y:= random(7);
 until (PlayGrid.Cells[x,y] = '0');
 PlayGrid.Cells[x,y] := inttostr(random(3)+1); //Ставит случайный гриб на случайную позицию
 if (PlayGrid.Cells[x1,y1] <> '0') and (PlayGrid.Cells[x1,y1] <> '4') then begin //Взрывает неубранный гриб, нанося урон игроку и играя звук
 PlayGrid.Cells[x1,y1] := '4';
 p.HP := p.HP -  EMap[epx,epy].dmg;
 StatGrid.Cells[0,1]:= inttostr(p.hp);
 PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/MushroomExplode'+inttostr(random(3)+1)+'.wav'),1,SND_ASYNC);
 //Заканчивает игру поражением
 if p.HP <= 0 then begin TurnTimer.enabled:= False;
                         ShroomBattle.Close;
                         PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/Death'+inttostr(random(2)+1)+'.wav'),1,SND_ASYNC);
                         ShowMessage('Вы погибли!');
                         Game.Close;
                          end
 end;
 if PlayGrid.Cells[x2,y2] = '4' then PlayGrid.Cells[x2,y2]:= '0';
 x2 := x1; //Задает координаты позапрошлого гриба
 y2 := y1;
 x1 := x; //Задает координаты прошлого гриба
 y1 := y;
end;

procedure TStringGrid.Loaded;
var
  cmp: TComponent;
//Метод класса StringGrid, привязывающий к нему список картинок грибов
begin
  inherited;
  cmp := Owner.FindComponent('MushroomImageList');
  if Assigned(cmp) and (cmp is TImageList) then
    FImageList := TImageList(cmp);
end;


procedure TStringGrid.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
var
  s: string;
  bmp: TBitmap;
  xOff: Integer;
  YOff: Integer;
//Метод класса StringGrid, рисующий картинку на ячейке таблицы, соответсвующую зодержанию этой ячейки
begin
  inherited;
  //Заканчивает процедуру, если в случае какой-либо ошибки список картинок окажется не привязан и в стучае, если он применяется не к той таблице
  if not Assigned(FImageList) then
    Exit;
  if self <> ShroomBattle.PlayGrid then
    Exit;
  s := Cells[ACol, ARow]; //читает содержимое ячейки
  Canvas.FillRect(ARect);
  bmp := TBitmap.Create; //Создает переменную картинки
  try
  //Определяет нужную картинку
    if (s = '1') then
      FImageList.GetBitmap(1, bmp)
    else if (s = '2') then
      FImageList.GetBitmap(2, bmp)
    else if (s = '3') then
      FImageList.GetBitmap(3, bmp)
    else if (s = '0') then
      FImageList.GetBitmap(0, bmp)
    else if (s = '4') then
      FImageList.GetBitmap(4, bmp);
    //Определяет положение нужное картнки и рисует её
    xOff := ARect.Left + ((ARect.Right - ARect.Left) - bmp.Width) div 2;
    YOff := ARect.Top + ((ARect.Bottom - ARect.Top) - bmp.Height) div 2;
    Canvas.Draw(xOff, YOff, bmp);
  finally
    FreeAndNil(bmp); //Освобождает переменную картинки, даже если при выполнении try что-то пошло не так
  end;
end;
 procedure TStringGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  C: Integer;
  r: Integer;
//Метод класса StringGrid, который обрабатывает щелчки мышью по таблице и, если нажатие происходит по грибу, то убирает его и наносит противнику урон
begin
  inherited;
  MouseToCell(X, Y, C, r); //Определяет ячейку, на которую нажал игрок
  if (c<0) or (r<0) then  //Проверяет, не было ли в случае какой-либо ошибки выхода за границу таблицы и выходит из процедуры если было
    Exit;
  if (Button = mbleft) and (Self.Cells[c,r] <> '0') and (Self.Cells[c,r] <> '4') then begin  //Проверяет, было ли нажатие по существующему грибу
  //Убирает гриб, наносит урон противнику и играет звук
  Self.Cells[c,r]:='0';
  EMap[epx,epy].hp := EMap[epx,epy].hp - p.Dmg;
  ShroomBattle.StatGrid.Cells[2,1]:= inttostr(EMap[epx,epy].hp);
  PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/MushroomClear'+inttostr(random(4)+1)+'.wav'),1,SND_ASYNC);
  //Заканчивает бой победой
  if EMap[epx,epy].hp <= 0 then begin EMap[epx,epy]:=Nil;
                                      Game.SMap.Cells[epx,epy]:= '1';
                                      ShroomBattle.TurnTimer.enabled:= False;
                                      Points := Points + 150;
                                      PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/BattleVictory.wav'),1,SND_ASYNC);
                                      ShowMessage('Вы выиграли!'+#13+#10+'Вы получили 150 очков');
                                      ShroomBattle.Close;
                                      end;
  end;
end;
end.
