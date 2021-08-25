program APIWhatsAppInPulse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  System.JSON,
  REST.Json,
  Horse.Commons,
  UConexao in 'Model\UConexao.pas';

begin
  THorse.Get('/xx',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      //
    end);

  THorse.Get('/api/xxx',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      //
    end);

  THorse.Post('/api/xxx',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      //
    end);

  THorse.Listen(9001);
end.
