unit UMensagemInpulse;

interface

uses
  System.SysUtils, VCL.Graphics, FireDAC.Comp.Client, FireDAC.DApt,
  FireDAC.Stan.Param, uInterfaceMensagem, UConexao, JSON, Data.DB, uLogger;

type

   TMensagemInpulse = class(TInterfacedObject, iMensagemInpulse)

  public
    FCodigoCliente: Integer;
    FCampanha: Integer;
    FOperador: Integer;
    FTelefone: string;
    FMensagemCM: string;
    FTelefoneCM: string;
    FCodigoCM: Integer;
    FIDConversaCM: string;

    property Telefone: string read FTelefone write FTelefone;
    property CodigoCliente: Integer read FCodigoCliente write FCodigoCliente;
    property Operador: Integer read FOperador write FOperador;
    property Campanha: Integer read FCampanha write FCampanha;
    property MensagemCM: string read FMensagemCM write FMensagemCM;
    property TelefoneCM: string read FTelefoneCM write FTelefoneCM;
    property CodigoCM: Integer read FCodigoCM write FCodigoCM;
    property IDConversaCM: string read FIDConversaCM write FIDConversaCM;

    class function New: iMensagemInpulse;
    function BuscarRespostas: iMensagemInpulse;
    function RetornarCampanhaCadastrada(AConexao: TFDConnection;
                                        ACliente: Integer): iMensagemInpulse;
    function CadastrarCampanhaCliente(AConexao: TFDConnection;
                                      ACodigoCliente,
                                      ACampanha: Integer): iMensagemInpulse;
    function ProcessarMensagemCM(AConexao: TFDConnection;
                                 ACodigo: Integer): iMensagemInpulse;
    function VerificarExistenciaCliente(AConexao: TFDConnection;
                                        ATelefone: string): Boolean;
    function VerificarClienteInPulse(ATelefone, AMensagem: string): Boolean;
    function CadastrarCampanhaMensagem(AConexao: TFDConnection;
                                       ACampanha: Integer;
                                       AMensagem,
                                       ATelefone,
                                       AIDConversa: string): iMensagemInpulse;
    function RetornarCampanhaMensagem(AConexao: TFDConnection):
      iMensagemInpulse;
    function CadastrarResposta(AConexao: TFDConnection;
                               ATelefone,
                               AMensagem,
                               AIdConversa: string): iMensagemInpulse;
    function CadastrarClienteInPulse(AConexao: TFDConnection;
                                     ATelefone,
                                     AMensagem: string): iMensagemInpulse;

  end;

implementation

{ TMensagemInpulse }

class function TMensagemInpulse.New: iMensagemInpulse;
begin
  Result := TMensagemInpulse.Create;
end;

function TMensagemInpulse.VerificarExistenciaCliente(AConexao: TFDConnection;
  ATelefone: string): Boolean;
var
  lQuery: TFDQuery;
begin
  Result := False;

  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('SELECT CODIGO, OPERADOR, COD_CAMPANHA ');
    lQuery.SQL.Add('FROM CLIENTES ');
    lQuery.SQL.Add('WHERE ');
    lQuery.SQL.Add('(CONCAT(AREA1,FONE1) = ' + QuotedStr(ATelefone) + ') OR ');
    lQuery.SQL.Add('(CONCAT(AREA2,FONE2) = ' + QuotedStr(ATelefone) + ') OR ');
    lQuery.SQL.Add('(CONCAT(AREA3,FONE3) = ' + QuotedStr(ATelefone) + ') OR ');
    lQuery.SQL.Add('(CONCAT(AREAFAX,FAX) = ' + QuotedStr(ATelefone) + ')');
    lQuery.SQL.Add(' AND ATIVO = ''SIM'' ');
    lQuery.Active := True;

    if not (lQuery.IsEmpty) then
    begin
      Result := True;
      FCodigoCliente := lQuery.FieldByName('CODIGO').AsInteger;
      FOperador := lQuery.FieldByName('OPERADOR').AsInteger;
      FCampanha := lQuery.FieldByName('COD_CAMPANHA').AsInteger;
    end;
  except
    TLogger.New()
           .RegistrarLog('VerificarExistenciaCliente',
                         'Erro ao consultar o cliente');
  end;
end;

function TMensagemInpulse.VerificarClienteInPulse(ATelefone,
  AMensagem: string): Boolean;
var
  lConexaoBDinPulse: TConexaoBDInpulse;
   lQuery: TFDQuery;
begin
  Result := False;

  lConexaoBDinPulse := TConexaoBDInpulse.Create;
  try
    //Caso não exista na tabela cliente verifica na tabela campanha_cliente
    if not VerificarExistenciaCliente(lConexaoBDinPulse.Connection,
                                      ATelefone) then
    begin
      lQuery := TFDQuery.Create(nil);
      try
        lQuery.Active := False;
        lQuery.Connection := lConexaoBDinPulse.Connection;

        lQuery.SQL.Clear;
        lQuery.SQL.Add('SELECT CODIGO, CLIENTE, OPERADOR');
        lQuery.SQL.Add('FROM CAMPANHAS_CLIENTES ');
        lQuery.SQL.Add('WHERE ');
        lQuery.SQL.Add('(FONE1 = ' + QuotedStr(ATelefone) + ') OR ');
        lQuery.SQL.Add('(FONE2 = ' + QuotedStr(ATelefone) + ') OR ');
        lQuery.SQL.Add('(FONE3 = ' + QuotedStr(ATelefone) + ')');
        lQuery.Active := True;

        if not (lQuery.IsEmpty) then
        begin
          Result := True;
          FCampanha := lQuery.FieldByName('CODIGO').AsInteger;
          FCodigoCliente := lQuery.FieldByName('CLIENTE').AsInteger;
          FOperador := lQuery.FieldByName('OPERADOR').AsInteger;
        end
        else
        begin
          CadastrarClienteInPulse(lConexaoBDinPulse.Connection,
                                  ATelefone,
                                  AMensagem);
        end;
      except
        TLogger.New()
               .RegistrarLog('RetornarClienteInPulse',
                             'Erro ao consultar campanha cliente');
      end;
    end else
      Result := True;

  finally
    lConexaoBDinPulse.Free;
  end;
end;

function TMensagemInpulse.BuscarRespostas: iMensagemInpulse;
var
  lConexaoBDInpulse: TConexaoBDInpulse;
begin
  lConexaoBDInpulse := TConexaoBDInpulse.Create;
  try
    RetornarCampanhaMensagem(lConexaoBDInpulse.Connection);

    ProcessarMensagemCM(lConexaoBDInpulse.Connection,
                        FCodigoCM);

    CadastrarResposta(lConexaoBDInpulse.Connection,
                      FTelefoneCM,
                      FMensagemCM,
                      FIDConversaCM);
  finally
    lConexaoBDInpulse.Free;
  end;
end;

function TMensagemInpulse.CadastrarCampanhaCliente(AConexao: TFDConnection;
  ACodigoCliente, ACampanha: Integer): iMensagemInpulse;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('INSERT INTO CAMPANHAS_CLIENTES(CAMPANHA,CLIENTE,');
    lQuery.SQL.Add('DT_AGENDAMENTO)');
    lQuery.SQL.Add('VALUES (:CAMPANHA,:CLIENTE, :DT_AGENDAMENTO)');
    lQuery.ParamByName('CLIENTE').AsInteger := ACodigoCliente;
    lQuery.ParamByName('CAMPANHA').AsInteger := ACampanha;
    lQuery.ParamByName('DT_AGENDAMENTO').AsString :=
      FormatDateTime('YYYY-MM-DD HH:MM:SS', Now());
    lQuery.ExecSQL;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('CadastrarCampanhaCliente',
                         'Erro ao inserir campanha de cliente');
  end;
end;

function TMensagemInpulse.RetornarCampanhaCadastrada(AConexao: TFDConnection;
  ACliente: Integer): iMensagemInpulse;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('SELECT CODIGO');
    lQuery.SQL.Add('FROM CAMPANHAS_CLIENTES ');
    lQuery.SQL.Add('WHERE CLIENTE  = :CLIENTE ');
    lQuery.SQL.Add('ORDER BY DT_AGENDAMENTO DESC ');
    lQuery.SQL.Add('LIMIT 1');
    lQuery.ParamByName('CLIENTE').AsInteger := ACliente;

    lQuery.Active := True;

    if not (lQuery.IsEmpty) then
      FCampanha := lQuery.FieldByName('CODIGO').AsInteger;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('RetornarCampanhaCadastrada',
                         'Erro ao consultar campanha cliente');
  end;
end;

function TMensagemInpulse.CadastrarCampanhaMensagem(AConexao: TFDConnection;
  ACampanha: Integer; AMensagem, ATelefone, AIDConversa: string): iMensagemInpulse;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('INSERT INTO CAMPANHA_MENSAGEM(CODIGO_CAMPANHA_CLIENTE,');
    lQuery.SQL.Add('DATA_HORA_CRIACAO, MENSAGEM, STATUS, EM_CONVERSACAO, ');
    lQuery.SQL.Add('TELEFONE)');
    lQuery.SQL.Add('VALUES (:CODIGO_CAMPANHA_CLIENTE,:DATA_HORA_CRIACAO,');
    lQuery.SQL.Add(':MENSAGEM, ''NP'',''S'', :TELEFONE)');
    lQuery.ParamByName('CODIGO_CAMPANHA_CLIENTE').AsInteger := ACampanha;
    lQuery.ParamByName('DATA_HORA_CRIACAO').AsString :=
      FormatDateTime('YYYY-MM-DD HH:MM:SS', Now());
    lQuery.ParamByName('MENSAGEM').AsString := QuotedStr(AMensagem);
    lQuery.ParamByName('TELEFONE').AsString := QuotedStr(ATelefone);

    lQuery.ExecSQL;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('CadastrarCampanhaMensagem',
                         'Erro ao inserir campanha mensagem');
  end;
end;

function TMensagemInpulse.CadastrarClienteInPulse(AConexao: TFDConnection;
  ATelefone, AMensagem: string): iMensagemInpulse;
begin
  try

  except
    TLogger.New()
           .RegistrarLog('CadastrarClienteInPulse',
                         'Erro ao cadastrar o cliente');
  end;
end;

function TMensagemInpulse.CadastrarResposta(AConexao: TFDConnection; ATelefone,
  AMensagem, AIdConversa: string): iMensagemInpulse;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.SQL.Clear;
    lQuery.SQL.Add('INSERT INTO MENSAGEM(CONTATO,TELEFONE,MENSAGEM,');
    lQuery.SQL.Add('IDCONVERSA,DATA_ENVIO_RECEBIDO, TIPO_MENSAGEM)');
    lQuery.SQL.Add('VALUES (:CONTATO,:TELEFONE,:MENSAGEM,:IDCONVERSA,');
    lQuery.SQL.Add(':DATA_ENVIO_RECEBIDO,''M'')');
    lQuery.ParamByName('TELEFONE').AsString := ATelefone;
    lQuery.ParamByName('MENSAGEM').AsString := AMensagem;
    lQuery.ParamByName('IDCONVERSA').AsString := AIdConversa;
    lQuery.ParamByName('DATA_ENVIO_RECEBIDO').AsString :=
      FormatDateTime('YYYY-MM-DD HH:MM:SS', now());
    lQuery.ExecSQL;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('CadastrarResposta',
                         'Erro ao cadastar a mensagem');
  end;
end;

function TMensagemInpulse.RetornarCampanhaMensagem(AConexao: TFDConnection):
  iMensagemInpulse;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('SELECT CODIGO, MENSAGEM, TELEFONE, IDCONVERSA');
    lQuery.SQL.Add('FROM CAMPANHA_MENSAGEM ');
    lQuery.SQL.Add('WHERE STATUS  = ''NP'' ');
    lQuery.SQL.Add('LIMIT 1');

    lQuery.Active := True;

    if not (lQuery.IsEmpty) then
    begin
      FCodigoCM := lQuery.FieldByName('CODIGO').AsInteger;
      FMensagemCM := lQuery.FieldByName('MENSAGEM').AsString;
      FTelefoneCM := lQuery.FieldByName('TELEFONE').AsString;
      FIDConversaCM := lQuery.FieldByName('IDCONVERSA').AsString;
    end;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('RetornarCampanhaMensagem',
                         'Erro ao consultar campanha mensagem');
  end;
end;

function TMensagemInpulse.ProcessarMensagemCM(AConexao: TFDConnection;
  ACodigo: Integer): iMensagemInpulse;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := AConexao;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('UPDATE CAMPANHA_MENSAGEM SET STATUS = ''P'' ');
    lQuery.SQL.Add(' WHERE CODIGO = :CODIGO');
    lQuery.ParamByName('CODIGO').AsInteger := ACodigo;
    lQuery.ExecSQL;

    Result := Self;
  except
    TLogger.New()
           .RegistrarLog('ProcessarMensagemCM',
                         'Erro ao atualizar o status da mensagem lida');
  end;
end;

end.
