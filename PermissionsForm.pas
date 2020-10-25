unit PermissionsForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  System.ioUtils, FMX.DialogService,
  System.Permissions, System.generics.collections, System.DateUtils,
{$IFDEF Android}
  Androidapi.JNI.JavaTypes, Androidapi.JNIBridge,
  Androidapi.Helpers, Androidapi.JNI.Os,
{$ENDIF}
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Memo.Types;

type
  TForm4 = class(TForm)
    BtnDataPermissioon: TButton;
    BtnTestData: TButton;
    BtnAllPermissions: TButton;
    Panel1: TPanel;
    MmoSamplingDetails: TMemo;
    procedure BtnTestDataClick(Sender: TObject);
    procedure BtnDataPermissioonClick(Sender: TObject);
    procedure BtnAllPermissionsClick(Sender: TObject);
  private
    { Private declarations }
    FFailedPermissions{, FAcceptedPermissions}: string;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation


{$R *.fmx}

uses IsPermissions;

procedure TForm4.BtnAllPermissionsClick(Sender: TObject);
begin
    PermissionsGranted([Pmsion.Gps, Pmsion.Camera, Pmsion.DataAcc,
      Pmsion.Network, Pmsion.WiFi, Pmsion.BlueTooth], False, False,
      Procedure(Const AllGood: Boolean;
        Const AAllGranted, APartialGranted: PmsmSet; Const AFailed: String)
      Begin
        FFailedPermissions:=AFailed;
        if AFailed <> '' then
          TDialogService.ShowMessage('Permission Fail:' + AFailed);
      End);
end;

procedure TForm4.BtnDataPermissioonClick(Sender: TObject);
begin
  PermissionsGranted([Pmsion.DataAcc], False, False,
      Procedure(Const AllGood: Boolean;
        Const AAllGranted, APartialGranted: PmsmSet; Const AFailed: String)
      Begin
        FFailedPermissions:=AFailed;
        if AFailed <> '' then
          TDialogService.ShowMessage('Permission Fail:' + AFailed);
      End);
end;

procedure TForm4.BtnTestDataClick(Sender: TObject);
  Function DoTestWrite(Const ATstList: TStringList; Const Test: String;
    AFileDir: String): String;
  var
    Ext, FileName: String;
    i: integer;
  begin
    i := 1;
    try
      FileName := TPath.Combine(AFileDir, 'Save.Txt');
      Ext := ExtractFileExt(FileName);

      if Not DirectoryExists(AFileDir) then
        ForceDirectories(AFileDir);
      while FileExists(FileName) do
      Begin
        If not DeleteFile(FileName) then
        Begin
          FileName := ChangeFileExt(FileName, IntToStr(i) + Ext);
          Inc(i); // 1234.ext
        End;
      End;
      ATstList.SaveToFile(FileName);

      if FileExists(FileName) then
        Result := 'Passed:' + Test + '::' + ExtractFileName(FileName)
      else
        Result := 'Failed:' + Test + '::' + FileName;

    Except
      On E: Exception Do
      Begin
        Result := 'Exception::' + Test + #13#10 + E.message + #13#10 + FileName;
        // TDialogService.ShowMessage('Data Write Fail:' + Test + '::' + FileName);
      end
    end;

  end;

Var
  TstList: TStringList;
  LFileDataDir: String;
begin
  MmoSamplingDetails.Lines.Clear;
//  if FAcceptedPermissions <> '' then
//  Begin
//    MmoSamplingDetails.Lines.Add('PERMISSIONS GRANTED');
//    MmoSamplingDetails.Lines.Add(FAcceptedPermissions);
//    MmoSamplingDetails.Lines.Add('');
//  end;
  if FFailedPermissions <> '' then
  Begin
    MmoSamplingDetails.Lines.Add('PERMISSIONS NOT GRANTED');
    MmoSamplingDetails.Lines.Add(FFailedPermissions);
    MmoSamplingDetails.Lines.Add('');
  end;
  TstList := TStringList.Create;
  Try
    TstList.Add('Testing File save');
    TstList.Add('Testing File Line2');
    TstList.Add(FormatdateTime('dd mmm yy hh:nn:ss', now));
    TstList.Add(TPath.GetSharedDocumentsPath);
    MmoSamplingDetails.Lines.Add(TPath.GetSharedDocumentsPath);
    LFileDataDir := TPath.Combine(TPath.GetHomePath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetHomePath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetTempPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetTempPath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetPicturesPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetPicturesPath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetSharedDocumentsPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetSharedDocumentsPath',
      LFileDataDir));
  Finally
    freeAndNil(TstList);
  End;
end;

end.
