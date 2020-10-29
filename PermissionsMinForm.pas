unit PermissionsMinForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  System.ioUtils, FMX.DialogService,
  System.Permissions, System.generics.collections, System.DateUtils,
{$IFDEF Android}
  Androidapi.JNI.JavaTypes, Androidapi.JNIBridge,
  Androidapi.Helpers, Androidapi.JNI.Os,
  Androidapi.IOUtils,
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
    FFailedPermissions { , FAcceptedPermissions } : string;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.fmx}

// uses IsPermissions;
Procedure PermissionsGrant(ADataOnly: Boolean);
Var
  PermArray: TArray<string>;
Begin
{$IFDEF Android}
  if ADataOnly then
  Begin
    SetLength(PermArray, 2);
    PermArray[0] := JStringToString
      (TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE);
    PermArray[1] := JStringToString
      (TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE);
  End
  Else
  Begin
    SetLength(PermArray, 4);
    PermArray[0] := JStringToString
      (TJManifest_permission.JavaClass.ACCESS_COARSE_LOCATION);
    PermArray[1] := JStringToString
      (TJManifest_permission.JavaClass.ACCESS_FINE_LOCATION);
    PermArray[2] := JStringToString
      (TJManifest_permission.JavaClass.ACCESS_LOCATION_EXTRA_COMMANDS);
    PermArray[3] := JStringToString(TJManifest_permission.JavaClass.Camera);
  End;
  PermissionsService.RequestPermissions(PermArray,
    procedure(const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>)
    var
      ii: integer;
      GrantedTxt, GrantFailedTxt: String;
      GoodResult: Boolean;
    begin
      GrantedTxt := '';
      GrantFailedTxt := '';
      if (Length(AGrantResults) > 0) then
      Begin
        for ii := 0 to High(AGrantResults) do
        begin
          if (AGrantResults[ii] = TPermissionStatus.Granted) then
          Begin
            GrantedTxt := GrantedTxt + StringReplace(PermArray[ii],
              'android.permission.', #13#10, []);
          End
          else
          begin
            GrantFailedTxt := GrantFailedTxt + StringReplace(PermArray[ii],
              'android.permission.', #13#10, []);
          end;
        end;
        if (GrantFailedTxt <> '') then
          TDialogService.ShowMessage('Permissions not granted:' +
            GrantFailedTxt);
        if (GrantFailedTxt <> '') then
          Form4.FFailedPermissions := GrantFailedTxt;
        TDialogService.ShowMessage('Granted:' + GrantedTxt);
      End
      else
      begin
        TDialogService.ShowMessage('Permissions not granted');
      end;
    end);
{$ENDIF}
End;

procedure TForm4.BtnAllPermissionsClick(Sender: TObject);
begin
  PermissionsGrant(False);
end;

procedure TForm4.BtnDataPermissioonClick(Sender: TObject);
begin
  PermissionsGrant(True);
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
  // if FAcceptedPermissions <> '' then
  // Begin
  // MmoSamplingDetails.Lines.Add('PERMISSIONS GRANTED');
  // MmoSamplingDetails.Lines.Add(FAcceptedPermissions);
  // MmoSamplingDetails.Lines.Add('');
  // end;
  if FFailedPermissions <> '' then
  Begin
    MmoSamplingDetails.Lines.Add('PERMISSIONS NOT GRANTED');
    MmoSamplingDetails.Lines.Add(FFailedPermissions);
    MmoSamplingDetails.Lines.Add('');
  end;
  TstList := TStringList.Create;
  Try
{$IFDEF VER340}
    MmoSamplingDetails.Lines.Add('This is Sydney');
    TstList.Add('This is Sydney');
{$Else}
    MmoSamplingDetails.Lines.Add('Not Sydney');
    TstList.Add('Not Sydney');
{$Endif}
   TstList.Add('Testing File save');
    TstList.Add('Testing File Line2');
    TstList.Add(FormatdateTime('dd mmm yy hh:nn:ss', now));
    TstList.Add('GetExternalDocumentsDir::'+GetExternalDocumentsDir);
    TstList.Add('TPath.GetSharedCameraPath::'+TPath.GetSharedCameraPath);
    TstList.Add('TPath.GetSharedDocumentsPath::'+TPath.GetSharedDocumentsPath);
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
    LFileDataDir := TPath.Combine(TPath.GetCameraPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetCameraPath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetDocumentsPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetDocumentsPath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetDownloadsPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetDownloadsPath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(GetExternalDocumentsDir, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetExternalDocumentsDir',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetSharedDocumentsPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetSharedDocumentsPath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetSharedPicturesPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetSharedPicturesPath',
      LFileDataDir));
    LFileDataDir := TPath.Combine(TPath.GetSharedCameraPath, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetSharedCameraPath',
      LFileDataDir));
  Finally
    freeAndNil(TstList);
  End;
end;

end.
