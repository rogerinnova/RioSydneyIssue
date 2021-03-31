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
  Androidapi.ioUtils,
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
    BtnReadFiles: TButton;
    procedure BtnTestDataClick(Sender: TObject);
    procedure BtnDataPermissioonClick(Sender: TObject);
    procedure BtnAllPermissionsClick(Sender: TObject);
    procedure BtnReadFilesClick(Sender: TObject);
  private
    FLastTextFileName,
    { Private declarations }
    FFailedPermissions { , FAcceptedPermissions } : string;
    Function ListFilesInDirectory(ADir: String; ADirLimit: Integer): String;
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
      ii: Integer;
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

procedure TForm4.BtnReadFilesClick(Sender: TObject);
Var
  NxtDir, FileText: String;
  Limit,DirSrchLimit: Integer;
  TextFileStrm: TFileStream;
begin
  Try
    Limit := 5;
    DirSrchLimit:=10;
    FLastTextFileName := '';
{$IFDEF VER340}
    MmoSamplingDetails.Lines.Add('This is Sydney');
{$ELSE}
    MmoSamplingDetails.Lines.Add('Not Sydney');
{$ENDIF}

{$IFDEF MSWINDOWS}
    MmoSamplingDetails.Lines.Add('Windows c:\');
    NxtDir := ListFilesInDirectory('c:\',DirSrchLimit);
{$ELSE}
    MmoSamplingDetails.Lines.Add('______________________com.embarcadero.AndroidPermRioSydneyMin/files/Documents');
    NxtDir := ListFilesInDirectory('/storage/emulated/0/Android/data/com.embarcadero.AndroidPermRioSydneyMin/files',DirSrchLimit);
    MmoSamplingDetails.Lines.Add('Android/data______________________');
    NxtDir := ListFilesInDirectory('/storage/emulated/0/Android/data',DirSrchLimit);
    MmoSamplingDetails.Lines.Add('DCIM');
    NxtDir := ListFilesInDirectory('/storage/emulated/0/DCIM',DirSrchLimit);
{$ENDIF}
    while (NxtDir <> '') and (Limit > 0) do
    Begin
      Dec(Limit);
      MmoSamplingDetails.Lines.Add(IntToStr(Limit) + '/ ' +
        ExtractFileName(NxtDir));
      NxtDir := ListFilesInDirectory(NxtDir,DirSrchLimit);
    End;
    if FLastTextFileName <> '' then
      Try
        TextFileStrm := TFileStream.Create(FLastTextFileName, fmOpenRead);
        if TextFileStrm <> nil then
        Begin
          FileText :=
            '-----------------------------------------------------------' +
            '.....................................................................'
            + ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,';
          SetLength(FileText, 80);
          if TextFileStrm.Read(FileText[1], 30) > 20 then
            MmoSamplingDetails.Lines.Add(FileText);
        End;

      Except
        On E: Exception Do
          MmoSamplingDetails.Lines.Add('Exception FLastTextFileName::' +
            E.Message)
      End;
  Except
    On E: Exception Do
      MmoSamplingDetails.Lines.Add('Exception Read Files::' + E.Message)
  End;

end;

procedure TForm4.BtnTestDataClick(Sender: TObject);
  Function DoTestWrite(Const ATstList: TStringList; Const Test: String;
  AFileDir: String): String;
  var
    Ext, FileName: String;
    i: Integer;
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
        Result := 'Exception::' + Test + #13#10 + E.Message + #13#10 + FileName;
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
{$ELSE}
    MmoSamplingDetails.Lines.Add('Not Sydney');
    TstList.Add('Not Sydney');
{$ENDIF}
    TstList.Add('Testing File save');
    TstList.Add('Testing File Line2');
    TstList.Add(FormatdateTime('dd mmm yy hh:nn:ss', now));
{$IFNDEF MSWINDOWS}
    TstList.Add('GetExternalDocumentsDir::' + GetExternalDocumentsDir);
{$ENDIF}
    TstList.Add('TPath.GetSharedCameraPath::' + TPath.GetSharedCameraPath);
    TstList.Add('TPath.GetSharedDocumentsPath::' +
      TPath.GetSharedDocumentsPath);
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
{$IFNDEF MSWINDOWS}
    LFileDataDir := TPath.Combine(GetExternalDocumentsDir, 'TestSaveDir');
    MmoSamplingDetails.Lines.Add(DoTestWrite(TstList, 'GetExternalDocumentsDir',
      LFileDataDir));
{$ENDIF}
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

Function TForm4.ListFilesInDirectory(ADir: String; ADirLimit: Integer): String;
Var
  SearchRec: TSearchRec;
  SrchRslt, Limit: Integer;
  Srch:String;
begin
  Result := '';
  SrchRslt := 0;
  Limit := 5;
  Dec(ADirLimit);
  if DirectoryExists(ADir) then
  Begin
//    Srch:=TPath.Combine(ADir, '*.*');
    Srch:=TPath.Combine(ADir, '*');
    SrchRslt := FindFirst(Srch, faAnyFile, SearchRec);
    while (SrchRslt = 0) do
      Try
        if (SearchRec.Name <> '') then
{$IFDEF NextGen}
          if not(SearchRec.Name[0] = '.') then
{$ELSE}
          if not(SearchRec.Name[1] = '.') then
{$ENDIF}
            if DirectoryExists(System.ioUtils.TPath.Combine(ADir,
              SearchRec.Name)) then
            Begin
              MmoSamplingDetails.Lines.Add('Directory-' + SearchRec.Name);
              Result := System.ioUtils.TPath.Combine(ADir, SearchRec.Name);
              // Last Directory
              if ADirLimit > 0 then
                if Result <> '' then
                  ListFilesInDirectory(Result,ADirLimit);
            End
            Else if (Limit > 0) then
            begin
              if (Pos('.txt', SearchRec.Name) > 3) or
                (Pos('.csv', SearchRec.Name) > 3) then
                FLastTextFileName := System.ioUtils.TPath.Combine(ADir,
                  SearchRec.Name);
              MmoSamplingDetails.Lines.Add('     ' + SearchRec.Name);
              Dec(Limit);
            end;
        SrchRslt := FindNext(SearchRec);
      Except
        On E: Exception do
        Begin
          SrchRslt := -1;
          MmoSamplingDetails.Lines.Add('Error :=' + E.Message);
        end;
      End;
    FindClose(SearchRec);
  end
  Else
    MmoSamplingDetails.Lines.Add('No Such Dir ' + ADir);

end;

end.
