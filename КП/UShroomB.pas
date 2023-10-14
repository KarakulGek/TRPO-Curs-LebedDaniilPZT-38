unit UShroomB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, Grids, Vcl.Imaging.pngimage, Vcl.StdCtrls, mmsystem;

type
//� ���� ����� ���������� ����������� ������ StringGrid
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
//��� �������� ����� �������� ������
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
  TurnTimer.enabled:= True;   //�������� ������
  //��������� ������� �������������
  StatGrid.Cells[0,0]:= '�����';
  StatGrid.Cells[1,0]:= '';
  StatGrid.Cells[2,0]:= '�������';
  StatGrid.Cells[0,1]:= inttostr(p.hp);
  StatGrid.Cells[1,1]:= '��������';
  StatGrid.Cells[2,1]:= inttostr(EMap[epx,epy].hp);
  StatGrid.Cells[0,2]:= inttostr(p.dmg);
  StatGrid.Cells[1,2]:= '����';
  StatGrid.Cells[2,2]:= inttostr(EMap[epx,epy].dmg);
end;


procedure TShroomBattle.PlayGridSelectCell(Sender: TObject; ACol, ARow: Integer;var CanSelect: Boolean);
//���� � ������� �����-���� ������ ������� ������ ������ �������, �� ��������� ������ �� ���
begin
 if (ACol < 0) or (ARow < 0) then CanSelect:=false;
end;

procedure TShroomBattle.TurnTimerTimer(Sender: TObject);
var x,y:integer;
//��������� ������ ���� �� ��������� �������, �������� ������� ���������� ���� (��� ���� ������ ����), � ������� �����
begin
 repeat
 x:= random(7);
 y:= random(7);
 until (PlayGrid.Cells[x,y] = '0');
 PlayGrid.Cells[x,y] := inttostr(random(3)+1); //������ ��������� ���� �� ��������� �������
 if (PlayGrid.Cells[x1,y1] <> '0') and (PlayGrid.Cells[x1,y1] <> '4') then begin //�������� ���������� ����, ������ ���� ������ � ����� ����
 PlayGrid.Cells[x1,y1] := '4';
 p.HP := p.HP -  EMap[epx,epy].dmg;
 StatGrid.Cells[0,1]:= inttostr(p.hp);
 PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/MushroomExplode'+inttostr(random(3)+1)+'.wav'),1,SND_ASYNC);
 //����������� ���� ����������
 if p.HP <= 0 then begin TurnTimer.enabled:= False;
                         ShroomBattle.Close;
                         PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/Death'+inttostr(random(2)+1)+'.wav'),1,SND_ASYNC);
                         ShowMessage('�� �������!');
                         Game.Close;
                          end
 end;
 if PlayGrid.Cells[x2,y2] = '4' then PlayGrid.Cells[x2,y2]:= '0';
 x2 := x1; //������ ���������� ������������ �����
 y2 := y1;
 x1 := x; //������ ���������� �������� �����
 y1 := y;
end;

procedure TStringGrid.Loaded;
var
  cmp: TComponent;
//����� ������ StringGrid, ������������� � ���� ������ �������� ������
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
//����� ������ StringGrid, �������� �������� �� ������ �������, �������������� ���������� ���� ������
begin
  inherited;
  //����������� ���������, ���� � ������ �����-���� ������ ������ �������� �������� �� �������� � � ������, ���� �� ����������� �� � ��� �������
  if not Assigned(FImageList) then
    Exit;
  if self <> ShroomBattle.PlayGrid then
    Exit;
  s := Cells[ACol, ARow]; //������ ���������� ������
  Canvas.FillRect(ARect);
  bmp := TBitmap.Create; //������� ���������� ��������
  try
  //���������� ������ ��������
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
    //���������� ��������� ������ ������� � ������ �
    xOff := ARect.Left + ((ARect.Right - ARect.Left) - bmp.Width) div 2;
    YOff := ARect.Top + ((ARect.Bottom - ARect.Top) - bmp.Height) div 2;
    Canvas.Draw(xOff, YOff, bmp);
  finally
    FreeAndNil(bmp); //����������� ���������� ��������, ���� ���� ��� ���������� try ���-�� ����� �� ���
  end;
end;
 procedure TStringGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  C: Integer;
  r: Integer;
//����� ������ StringGrid, ������� ������������ ������ ����� �� ������� �, ���� ������� ���������� �� �����, �� ������� ��� � ������� ���������� ����
begin
  inherited;
  MouseToCell(X, Y, C, r); //���������� ������, �� ������� ����� �����
  if (c<0) or (r<0) then  //���������, �� ���� �� � ������ �����-���� ������ ������ �� ������� ������� � ������� �� ��������� ���� ����
    Exit;
  if (Button = mbleft) and (Self.Cells[c,r] <> '0') and (Self.Cells[c,r] <> '4') then begin  //���������, ���� �� ������� �� ������������� �����
  //������� ����, ������� ���� ���������� � ������ ����
  Self.Cells[c,r]:='0';
  EMap[epx,epy].hp := EMap[epx,epy].hp - p.Dmg;
  ShroomBattle.StatGrid.Cells[2,1]:= inttostr(EMap[epx,epy].hp);
  PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/MushroomClear'+inttostr(random(4)+1)+'.wav'),1,SND_ASYNC);
  //����������� ��� �������
  if EMap[epx,epy].hp <= 0 then begin EMap[epx,epy]:=Nil;
                                      Game.SMap.Cells[epx,epy]:= '1';
                                      ShroomBattle.TurnTimer.enabled:= False;
                                      Points := Points + 150;
                                      PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/BattleVictory.wav'),1,SND_ASYNC);
                                      ShowMessage('�� ��������!'+#13+#10+'�� �������� 150 �����');
                                      ShroomBattle.Close;
                                      end;
  end;
end;
end.
