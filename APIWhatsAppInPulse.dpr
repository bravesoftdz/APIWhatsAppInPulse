program APIWhatsAppInPulse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.JSON,
  REST.Json,
  Horse.Commons,
  UConexao in 'Model\UConexao.pas',
  UMensagemWhatsApp in 'Controller\UMensagemWhatsApp.pas',
  UMensagemInpulse in 'Controller\UMensagemInpulse.pas',
  uInterfaceMensagem in 'Controller\uInterfaceMensagem.pas',
  uLogger in 'Controller\uLogger.pas';

var
  FMensagem: iMensagemWhats;
  FResposta: iMensagemInpulse;
begin
   THorse.Get('/mensagens',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      FMensagem := TMensagemWhats.New();
      FMensagem.BuscarMensagemWhats;
    end);

    THorse.Get('/respostas',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      FResposta := TMensagemInpulse.New();
      FResposta.BuscarRespostas;
    end);

    THorse.Get('/cadastros',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
//      FMensagem := TMensagemWhats.New();
//      FMensagem.ResponderMensagem;
    end);

  THorse.Listen(9001);
end.
