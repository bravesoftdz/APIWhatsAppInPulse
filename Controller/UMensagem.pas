unit UMensagemWhatsApp;

interface

uses
  System.SysUtils, VCL.Graphics, FireDAC.Comp.Client, FireDAC.DApt,
  FireDAC.Stan.Param, uInterfaceMensagem, UConexao, JSON;

type

   TMensagem = class(TInterfacedObject, iMensagem)

  public
    FTelefone: string;
    FMensagem: string;

    class function New: iMensagem;
    function BuscarMensagemWhats: iMensagem;
    function RetornarMensagemWhats(AConexao: TFDConnection): iMensagem;
    function VerificarClienteInPulse(ATelefone, AMensagem: string): iMensagem;
    function Mensagem: string; overload;
    function Mensagem(AMensagem: string): iMensagem; overload;
    function Telefone: string; overload;
    function Telefone(ATelefone: string): iMensagem; overload;

  end;

implementation


{ TMensagem }

function TMensagem.BuscarMensagemWhats: iMensagem;
var
  lConexaoBDWhatsApp: TConexaoBDWhatsApp;
begin
  lConexaoBDWhatsApp := TConexaoBDWhatsApp.Create;
  try
    //Busca Mensagem do banco do WhatsApp
    RetornarMensagemWhats(lConexaoBDWhatsApp.Connection);

    //Verifica se existe cliente no In.Pulse
    VerificarClienteInPulse(FTelefone, FMensagem);

  finally
    lConexaoBDWhatsApp.Free;
  end;
end;

function TMensagem.Mensagem(AMensagem: string): iMensagem;
begin
  Result := Self;
  FMensagem := AMensagem;
end;

function TMensagem.Mensagem: string;
begin
  Result := FMensagem;
end;

class function TMensagem.New: iMensagem;
begin
  Result := TMensagem.Create;
end;

function TMensagem.RetornarMensagemWhats(AConexao: TFDConnection): iMensagem;
var
  FQuery: TFDQuery;
begin
  FQuery := TFDQuery.Create(nil);
  try
    FQuery.Active := False;
    FQuery.Connection := AConexao;

    FQuery.SQL.Clear;
    FQuery.SQL.Add('SELECT TELEFONE, MENSAGEM ');
    FQuery.SQL.Add('FROM MENSAGEM ');
    FQuery.SQL.Add('WHERE DATA_PROCESSADO_API IS NULL AND ');
    FQuery.SQL.Add('STATUS = ''NP'' ');
    FQuery.SQL.Add('LIMIT 1');
    FQuery.Active := True;

    Mensagem(FQuery.FieldByName('MENSAGEM').AsString);
    Telefone(FQuery.FieldByName('TELEFONE').AsString);

    Result := Self;
  except
    on ex: exception do
      raise exception.Create('Erro ao consultar : '
                             + ex.Message);
  end;
end;

function TMensagem.Telefone(ATelefone: string): iMensagem;
begin
  Result := Self;
  FTelefone := ATelefone;
end;

function TMensagem.VerificarClienteInPulse(ATelefone,
  AMensagem: string): iMensagem;
var
  lConexaoBDInPulse: TConexaoBDInpulse;
begin
  lConexaoBDInPulse := TConexaoBDInpulse.Create;
  try

  finally
    lConexaoBDInPulse.Free;
  end;
end;

function TMensagem.Telefone: string;
begin
  Result := FTelefone;
end;

end.
