unit UGame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Grids, System.ImageList,
  Vcl.ImgList, Vcl.StdCtrls, mmsystem, ShellAPI;

type
//� ���� ����� ���������� ����������� ������ StringGrid
  TStringGrid = class(Grids.TStringGrid)
  private
    FImageList: TImageList;
  protected
   procedure KeyPress(var Key: Char); override;
   procedure DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState); override;
   procedure Loaded; override;
  end;

type
  TGame = class(TForm)
    GameMainMenu: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    SpriteImageList: TImageList;
    SMap: TStringGrid;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
  private
  public
  end;

 type
 //�������� ������ ������
  Player = class
  public
    HP: integer;
    Dmg: integer;
    PosX:integer;
    PosY:integer;
    constructor Create(HP:integer;Dmg:integer;PosX,PosY:integer);
    procedure Move(x,y:integer;SMap:TStringGrid);
  end;

 type
 //�������� ������ ����������
  Enemy = class
  public
    HP: integer;
    PosX:integer;
    PosY:integer;
    kind:string;
    dmg:integer;
    constructor Create(HP,dmg:integer;kind:string;PosX,PosY:integer);
  end;

var
  Game: TGame;
  EMap: array of array of Enemy; //����� ������. ������ � ��� ���� ������, ���� �������� ������ ������ ����������. ����� ����� ��� ������� ������ � �������� ���� ������
  p: Player;
  epx: integer;
  epy: integer;
  DiffMod: byte;  //����������� ���������, �������� �� �������� � ���� ������, � ��� �� �� �������� ����-���
  Points: Cardinal; //����, ����������� ��� ������, ������� ������ �� ��������� ��������� � ������ ��� �������

implementation

{$R *.dfm}

uses UStart,UInv, UOrkB, UShroomB, USnakeB, UStats;

procedure TGame.FormClose(Sender: TObject; var Action: TCloseAction);
//��� �������� ����� ��������� ��������� ����
begin
 Start.show;
end;

constructor Player.Create(HP:integer;Dmg:integer;PosX,PosY:integer);
//����������� ������ ������
begin
 Self.HP := HP;
 Self.Dmg := Dmg;
 Self.PosX := Posx;
 Self.PosY := PosY;
end;

constructor Enemy.Create(HP,dmg:integer;kind:string;PosX,PosY:integer);
//����������� ������ ����������
begin
 Self.HP := Hp;
 Self.PosX := Posx;
 Self.PosY := PosY;
 Self.kind := kind;
 Self.dmg := dmg;
end;

procedure Player.Move(x,y:integer;SMap:TStringGrid);
//��������� �������� ������
const r = 7;
var i,k:byte;
begin
 if ((self.PosX + x) < 0) or ((self.PosY + y) < 0) or ((self.PosX + x) > SMap.ColCount - 1) or ((self.PosY + y) > SMap.RowCount - 1) then Exit;   //���������, �� �������� �� ����� ����� �� ������� �������
 //���� ����� ��������� �� ������ ���� � ��� ��� ����������, �� ���������� ���
 if (EMap[self.PosX + x,self.PosY + y] = Nil) and (SMap.Cells[self.PosX + x,self.PosY + y] = '1') then begin
  self.PosX:= self.PosX + x;
  self.PosY:= self.PosY + y;
         //���������� ��������� ������� ���, ��� �� ������ ��� ����� �����, ����������� � ������� �� ������ � ��� ��� �� �������� �� ������� �������
         if ((self.PosX + x*r) >= 0) and ((self.PosY + y*r) >= 0) and ((self.PosX + x*r) <= SMap.ColCount - 1) and ((self.PosY + y*r) <= SMap.RowCount - 1) then begin
           SMap.Row := self.Posy + y * r;
           SMap.Col := self.Posx + x * r;
 end; end
 //���� ����� ��������� �� ����������, �� �������� ��������������� ���, ��������� ��� ���� ��������� ����������
 else if EMap[self.PosX + x,self.PosY + y] <> Nil then begin
  if EMap[self.PosX + x,self.PosY + y].kind = 'ork' then begin epx:= self.PosX + x;
                                                                  epy:= self.PosY + y;
                                                                  Application.CreateForm(TOrkBattle, OrkBattle);
                                                                  OrkBattle.showmodal end else
  if EMap[self.PosX + x,self.PosY + y].kind = 'snake' then begin epx:= self.PosX + x;
                                                                  epy:= self.PosY + y;
                                                                  Application.CreateForm(TSnakeBattle, SnakeBattle);
                                                                  SnakeBattle.showmodal end else
  if EMap[self.PosX + x,self.PosY + y].kind = 'shroom' then begin epx:= self.PosX + x;
                                                                  epy:= self.PosY + y;
                                                                  Application.CreateForm(TShroomBattle, ShroomBattle);
                                                                  ShroomBattle.showmodal end;
  end
  //���� ����� ��������� �� ������, �� ������ ������, ���� ������ ��������� ������� � ������� ���������
  else if SMap.Cells[self.PosX + x,self.PosY + y] = '2' then begin
   SMap.Cells[self.PosX + x,self.PosY + y] := '1';
   i := random(3);
   k := 0;
   PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/GainItem.wav'),1,SND_ASYNC); //������ ����
   //�����������, ����� ������� ������� �����, ���������� ��� � ��������� � ����������� � ���������������
   if i = 0 then begin
    for var j:integer := 0 to Inventory.ItemListBox.Items.Count - 1 do
    //���� ����� ��������� ��� ������ ���, �� �� �������� �������������� ������
    if Inventory.ItemListBox.Items[j] = '���' then k:=1;
    if k = 0 then p.Dmg := p.Dmg + 5;
    Inventory.ItemListBox.Items.Add('���');
    ShowMessage('�� ����� ���!'+#13+#10+'�� ����� 150 �����');
    Points := Points + 150;
   end
   else if i = 1 then begin
    for var j:integer := 0 to Inventory.ItemListBox.Items.Count - 1 do
    //���� ����� ��������� ��� ������ ������, �� �� �������� �������������� ������
    if Inventory.ItemListBox.Items[j] = '������' then k:=1;
    if k = 0 then p.hp := p.hp + 50;
    Inventory.ItemListBox.Items.Add('������');
    Points := Points + 100;
    ShowMessage('�� ����� ������!'+#13+#10+'�� ����� 100 �����')
   end
   //��� ������� ����� �������������� ���������� ������ ���
   else if i = 2 then begin
    p.hp := p.hp + 20;
    Inventory.ItemListBox.Items.Add('�����');
    Points := Points + 50;
    ShowMessage('�� ����� �����!'+#13+#10+'�� ����� 50 �����');
   end;
  end
  //���� ����� ��������� �� �����, �� ������� ���������, ����������� ��� ����� ���� ����� �� �������, ��� ����������� ���� ������� ���� ����� �������
  else if SMap.Cells[self.PosX + x,self.PosY + y] = '3' then begin
   if Points < 1000 then ShowMessage('�� �� ������ ���� � ������� ������!'+#13+#10+'��� ������ �������� ���� �� 1000 �����')
   else begin
     //������ ���� � ������� ��������� ������, ��������� ���������� �����
     PlaySound(pchar(ExtractFilePath(Application.Exename)+'Sounds/Victory.wav'),1,SND_ASYNC);
     ShowMessage('������!'+#13+#10+'�� ������� '+IntToStr(Points)+' �����');
     Game.Close;
   end;
  end;
end;

procedure TGame.FormCreate(Sender: TObject);
var
f : textfile;
a,ik:char;
c,ec,px,py,eh,ex,ey,ed,ph,pd:Cardinal;
ek: string;
//��������� ������ ���� ������������ ����� ��� ���� ���������� � ���� �����, �������������� ������ � ��������� ������ �� ����
begin
 assignfile(f,ExtractFilePath(Application.Exename)+'Saves/'+FName);
 reset(f);
 //���� ������ ���������� ������������ �����, �� ��������� ����������� �� ���������� ����, ����� ��� �������� �� �����
 if FName = 'OriginalMap.txt' then
   case Start.DiffRadioGroup.ItemIndex of
    0: DiffMod:=1;
    1: DiffMod:=2;
    2: DiffMod:=3;
   end
 else readln(f,DiffMod);
 //������ ������� �����
 read(f,c);
 SMap.ColCount := c;
 readln(f,c);
 SMap.RowCount := c;
 //������ ����� �����
 for var i:integer := 0 to SMap.RowCount -1 do begin
 for var j:integer := 0 to SMap.ColCount -1 do begin
  read(f, a);
  SMap.Cells[j,i]:=a;
 end;
  readln(f)
 end;
 //������ ������������� ������
 read(f,px);
 read(f,py);
 read(f,ph);
 read(f,pd);
 readln(f,Points);
 p := Player.Create(ph,pd,px,py);
 //������ ���������� ������ � ����� ������, �������� ��� ���� ����� ������
 readln(f, ec);
 SetLength(EMap,SMap.ColCount,SMap.RowCount);
 if ec > 0 then
   for var k: integer := 0 to ec - 1 do begin
    read(f,ex);
    readln(f,ey);
    readln(f,ek);
    ed:=0;
    eh:=0;
    //�������� � ���� ������ �������� � ����������� �� �� ���� � ���������
    if ek = 'shroom' then begin ed := 5 * DiffMod;
                                eh := 50* DiffMod; end
    else if ek = 'ork' then begin ed := 5* DiffMod;
                                  eh := 50* DiffMod; end
    else if ek = 'snake' then begin ed := 9* DiffMod;
                                    eh := 30* DiffMod; end;
    EMap[ex,ey] := Enemy.Create(eh,ed,ek,ex,ey);
   end;
 //������ ���������� ���������, ���� ��� ������������
 while not Eof(f) do begin
  read(f,ik);
  if ik = '0' then Inventory.ItemListBox.Items.Add('������')
   else if ik = '1' then Inventory.ItemListBox.Items.Add('���')
    else if ik = '2' then Inventory.ItemListBox.Items.Add('�����');
 end;
 closefile(f);
end;

procedure TGame.N1Click(Sender: TObject);
//��������� ���������
begin
 Inventory.ShowModal;
end;

procedure TGame.N2Click(Sender: TObject);
//��������� ��������������
begin
 Stats.ShowModal;
end;

procedure TGame.N3Click(Sender: TObject);
var f: TextFile;
fk, ec:integer;
//��������� ����, ��������� � � ���� Save_*.txt
begin
 fk:=0;
 //���������� ��� ����������, ��������� ��������� ����� � ��������, �� ����� �� ��
 if not DirectoryExists(ExtractFilePath(Application.Exename)+'Saves') then CreateDir(ExtractFilePath(Application.Exename)+'Saves');
 Repeat
  inc(fk)
 Until not FileExists(ExtractFilePath(Application.Exename)+'Saves/'+'Save_'+inttostr(fk)+'.txt');
 AssignFile(F,ExtractFilePath(Application.Exename)+'Saves/'+'Save_'+inttostr(fk)+'.txt');
 //����� �� ����� ��������� ������������ �� �� ��������, ��� ������ ��������� FormCreate
 Rewrite(f);
 writeln(f,DiffMod);
 write(f,SMap.ColCount);
 write(f,' ');
 writeln(F,SMap.RowCount);
 ec := 0;
 for var i:integer := 0 to SMap.RowCount -1 do begin
   for var j:integer := 0 to SMap.ColCount -1 do begin
    write(f,SMap.Cells[j,i]);
    if EMap[j,i] <> Nil then inc(ec);
   end;
  writeln(f)
 end;
 write(f,p.PosX);
 write(f,' ');
 write(f,p.PosY);
 write(f,' ');
 write(f,p.HP);
 write(f,' ');
 write(f,p.Dmg);
 write(f,' ');
 writeln(f,Points);
 writeln(f,ec);
 for var i:integer := 0 to SMap.RowCount -1 do begin
   for var j:integer := 0 to SMap.ColCount -1 do begin
    if EMap[j,i] <> Nil then begin
      write(f,j);
      write(f,' ');
      writeln(f,i);
      writeln(f,EMap[j,i].kind);
    end;
   end;
 end;
 for var i:integer := 0 to Inventory.ItemListBox.Items.Count - 1 do
  if Inventory.ItemListBox.Items[i] = '������' then write(f,'0 ')
   else if Inventory.ItemListBox.Items[i] = '���' then write(f,'1 ')
    else if Inventory.ItemListBox.Items[i] = '�����' then write(f,'2 ');
 ShowMessage('���� ���� ���� ������� ��������� ��� Save_'+inttostr(fk)+'.txt');
 CloseFile(f);
end;

procedure TGame.N4Click(Sender: TObject);
//��������� ���� �������
begin
 ShellExecute(0,PChar('Open'),PChar(ExtractFilePath(Application.Exename)+'ProjectHelp.chm'),Nil,Nil,SW_SHOW);
end;

procedure TStringGrid.Loaded;
var
  cmp: TComponent;
//����� ������ StringGrid, ������������� ������ �������� � �������
begin
  inherited;
  cmp := Owner.FindComponent('SpriteImageList');
  if Assigned(cmp) and (cmp is TImageList) then
    FImageList := TImageList(cmp);
end;

procedure TStringGrid.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
var
  s: string;
  bmp: TBitmap;
  xOff: Integer;
  YOff: Integer;
//����� ������ StringGrid, ������� ������ ���������� ������ ������� �����, ������� ���������� � ��������� ������ � ������ ��������������� �������� �� �������
begin
  inherited;
  if not Assigned(FImageList) then  //���������, �������� �� ������ �������� � �������
    Exit;
  s := Cells[ACol, ARow];  //������ ������ �������
  Canvas.FillRect(ARect);
  bmp := TBitmap.Create;   //������� ���������� ��������
  try
    //��������� �������� ������ �����, �������� ������ ������� ����������� � ��������� ������ � �������� ��������������� ��������
    if s='0' then FImageList.GetBitmap(0, bmp)
    else if s='1' then FImageList.GetBitmap(1, bmp)
    else if s='2' then FImageList.GetBitmap(6, bmp)
    else if s='3' then FImageList.GetBitmap(7, bmp);
    if (p.PosX = ACol) and (p.PosY = ARow) then
      FImageList.GetBitmap(2, bmp)
    else if EMap[ACol,ARow] <> Nil then
      if EMap[ACol,ARow].kind = 'snake' then FImageList.GetBitmap(3, bmp)
      else if EMap[ACol,ARow].kind = 'ork' then FImageList.GetBitmap(4, bmp)
      else if EMap[ACol,ARow].kind = 'shroom' then FImageList.GetBitmap(5, bmp);
    //���������� ��������� ������ ������� � ������ �
    xOff := ARect.Left + ((ARect.Right - ARect.Left) - bmp.Width) div 2;
    YOff := ARect.Top + ((ARect.Bottom - ARect.Top) - bmp.Height) div 2;
    Canvas.Draw(xOff, YOff, bmp);
  finally
    FreeAndNil(bmp);  //����������� ���������� ��������, ���� ���� ��� ���������� try ���-�� ����� �� ���
  end;
end;

procedure TStringGrid.KeyPress(var Key: Char);
//����� ������ StringGrid, ������� �������� ��������� Move � �������� ��
begin
//�������, �� ������� ��������� ����� �� � ����� ����������� ������ �������� �������� ������ ���� ��� ����, ��� �� ������� ��������� DrawCell
 Self.Cells[p.PosX,p.PosY] := '1';
 if (Key = 'a') or (Key = 'A') or (Key = '�') or (Key = '�') then p.Move(-1,0,Self);
 if (Key = 'w') or (Key = 'W') or (Key = '�') or (Key = '�') then p.Move(0,-1,Self);
 if (Key = 'd') or (Key = 'D') or (Key = '�') or (Key = '�') then p.Move(1,0,Self);
 if (Key = 's') or (Key = 'S') or (Key = '�') or (Key = '�') then p.Move(0,1,Self);
 Self.Cells[p.PosX,p.PosY] := '1';
end;

end.
