program APIWhatsAppInPulse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.JSON,
  REST.Json,
  Horse.Commons,
  UConexao in 'Model\UConexao.pas',
  UMensagem in 'Controller\UMensagem.pas';

begin
  THorse.Get('/mensagens',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
    //
    end);
  THorse.Listen(9001);
end.
