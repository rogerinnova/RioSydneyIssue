program AndroidPermRioSydney;

uses
  System.StartUpCopy,
  FMX.Forms,
  PermissionsForm in 'PermissionsForm.pas' {Form4},
  IsPermissions in 'IsPermissions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
