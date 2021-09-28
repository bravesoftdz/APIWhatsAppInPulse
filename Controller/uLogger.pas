unit uLogger;

interface

uses
  FireDAC.Comp.Client, UConexao, SysUtils, FireDAC.Stan.Param;

type
  TLogger = class
  private
    FConexaoBDinPulse: TConexaoBDInpulse;
    constructor Create;
  public
    class function New: TLogger;
    procedure RegistrarLog(AMetodo, ATexto: string);
    destructor Destroy; override;
  end;

implementation

{ TLogger }

constructor TLogger.Create;
begin
  FConexaoBDinPulse := TConexaoBDInpulse.Create;
end;

destructor TLogger.Destroy;
begin
  FConexaoBDinPulse.Free;
  inherited;
end;

class function TLogger.New: TLogger;
begin
  Result := TLogger.Create;
end;

procedure TLogger.RegistrarLog(AMetodo, ATexto: string);
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Active := False;
    lQuery.Connection := FConexaoBDinPulse.Connection;

    lQuery.SQL.Clear;
    lQuery.SQL.Add('INSERT INTO LOG_MENSAGEM(DATA_HORA_CRIACAO_LOG, ');
    lQuery.SQL.Add('METODO, ERRO) ');
    lQuery.SQL.Add('VALUES (:DATA_HORA_CRIACAO_LOG,:METODO,:ERRO)');
    lQuery.ParamByName('DATA_HORA_CRIACAO_LOG').AsString :=
      FormatDateTime('YYYY-MM-DD HH:MM:SS', Now());
    lQuery.ParamByName('METODO').AsString := AMetodo;
    lQuery.ParamByName('ERRO').AsString := ATexto;
    lQuery.ExecSQL;

  finally
    lQuery.Free;
  end;
end;

end.
