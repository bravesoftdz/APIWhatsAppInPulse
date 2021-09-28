unit UMensagemWhatsApp;

interface

uses
  System.SysUtils, VCL.Graphics, FireDAC.Comp.Client, FireDAC.DApt,
  FireDAC.Stan.Param, uInterfaceMensagem, UConexao, JSON, UMensagemInpulse,
  Data.DB, uLogger, System.StrUtils;

type

   TMensagemWhats = class(TInterfacedObject, iMensagemWhats)

  public
    FTelefone: string;
    FMensagem: string;
    FCodMensagem: Integer;
    FIDConversa: string;

    class function New: iMensagemWhats;
    function BuscarMensagemWhats: iMensagemWhats;
    function RetornarMensagemWhats(AConexao: TFDConnection): iMensagemWhats;
    function ProcessarMensagem(AConexao: TFDConnection;
                               ACodMensagem: Integer): iMensagemWhats;

    function Mensagem: string; overload;
    function Mensagem(AMensagem: string): iMensagemWhats; overload;
    function Telefone: string; overload;
    function Telefone(ATelefone: string): iMensagemWhats; overload;
    function CodMensagem: Integer; overload;
    function CodMensagem(ACodMensagem: Integer): iMensagemWhats; overload;
    function IDConversa: string; overload;
    function IDConversa(AIdConversa: string): iMensagemWhats; overload;

  end;

implementation

{ TMensagemWhats }

function TMensagemWhats.BuscarMensagemWhats: iMensagemWhats;
var
  lConexaoBDWhatsApp: TConexaoBDWhatsApp;
  lConexaoBDInpulse: TConexaoBDInpulse;
  lMensagemInpulse: TMensagemInpulse;
begin
  lConexaoBDWhatsApp := TConexaoBDWhatsApp.Create;
  lConexaoBDInpulse := TConexaoBDInpulse.Create;
  try
    //Busca Mensagem do banco do WhatsApp
    RetornarMensagemWhats(lConexaoBDWhatsApp.Connection);

    if not (FTelefone = EmptyStr) then
    begin
//      ProcessarMensagem(lConexaoBDWhatsApp.Connection, FCodMensagem);

      lMensagemInpulse := TMensagemInpulse.Create;
      lMensagemInpulse.Telefone := FTelefone;

      //Verifica se existe cliente no In.Pulse
      if lMensagemInpulse.VerificarClienteInPulse(FTelefone, FMensagem) then
      begin
        lMensagemInpulse.
          CadastrarCampanhaCliente(lConexaoBDInpulse.Connection,
                                   lMensagemInpulse.CodigoCliente,
                                   lMensagemInpulse.Campanha);

        lMensagemInpulse.RetornarCampanhaCadastrada(
          lConexaoBDInpulse.Connection,
          lMensagemInpulse.CodigoCliente);

        lMensagemInpulse.CadastrarCampanhaMensagem(
          lConexaoBDInpulse.Connection,
          lMensagemInpulse.Campanha,
          FMensagem,
          FTelefone,
          FIDConversa);
      end;
    end else
    begin
      TLogger.New()
             .RegistrarLog('BuscarMensagemWhats',
                           'Telefone não encontrado!');
    end;
  finally
    lConexaoBDWhatsApp.Free;
    lConexaoBDInpulse.Free;
  end;
end;

function TMensagemWhats.CodMensagem(ACodMensagem: Integer): iMensagemWhats;
begin
  Result := Self;
  FCodMensagem := ACodMensagem;
end;

function TMensagemWhats.IDConversa(AIdConversa: string): iMensagemWhats;
begin
  Result := Self;
  FIDConversa := AIdConversa;
end;

function TMensagemWhats.IDConversa: string;
begin
  Result := FIDConversa;
end;

function TMensagemWhats.CodMensagem: Integer;
begin
  Result := FCodMensagem;
end;

function TMensagemWhats.Mensagem(AMensagem: string): iMensagemWhats;
begin
  Result := Self;
  FMensagem := AMensagem;
end;

function TMensagemWhats.ProcessarMensagem(
  AConexao: TFDConnection; ACodMensagem: Integer): iMensagemWhats;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('UPDATE MENSAGEM SET STATUS = ''P'' ');
    lQuery.SQL.Add(' WHERE COD_MENSAGEM = :COD_MENSAGEM');
    lQuery.ParamByName('COD_MENSAGEM').AsInteger := ACodMensagem;
    lQuery.ExecSQL;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('MensagemProcessada',
                         'Erro ao atualizar o status da mensagem lida');
  end;
end;

function TMensagemWhats.Mensagem: string;
begin
  Result := FMensagem;
end;

class function TMensagemWhats.New: iMensagemWhats;
begin
  Result := TMensagemWhats.Create;
end;

function TMensagemWhats.RetornarMensagemWhats(AConexao: TFDConnection): iMensagemWhats;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('SELECT COD_MENSAGEM, TELEFONE, MENSAGEM, IDCONVERSA ');
    lQuery.SQL.Add('FROM MENSAGEM ');
    lQuery.SQL.Add('WHERE DATA_PROCESSADO_API IS NULL AND ');
    lQuery.SQL.Add('STATUS = ''NP'' ');
    lQuery.SQL.Add('LIMIT 1');
    lQuery.Active := True;

    if not (lQuery.IsEmpty) then
    begin
      CodMensagem(lQuery.FieldByName('COD_MENSAGEM').AsInteger);
      Mensagem(lQuery.FieldByName('MENSAGEM').AsString);
      Telefone(lQuery.FieldByName('TELEFONE').AsString);
      IDConversa(lQuery.FieldByName('IDCONVERSA').AsString);
    end;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('RetornarMensagemWhats',
                         'Erro ao retornar  a mensagem');
  end;
end;

function TMensagemWhats.Telefone(ATelefone: string): iMensagemWhats;
begin
  Result := Self;
  FTelefone := ATelefone;
end;

function TMensagemWhats.Telefone: string;
begin
  Result := FTelefone;
end;

end.
