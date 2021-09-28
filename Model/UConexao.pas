unit UConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, IniFiles, Vcl.Forms, FireDAC.Phys.MySQL;

type
  TConexaoBDWhatsApp = class
  public
    FConexao : TFDConnection;
    function Connection: TFDConnection;

    constructor Create;
	  destructor Destroy; override;
  end;

  TConexaoBDInpulse = class
  public
    FConexao : TFDConnection;
    function Connection: TFDConnection;

    constructor Create;
	  destructor Destroy; override;
  end;

  TDBConfINI = class
	private
		fHostNameWhats: String;
    fHostNameInPulse: String;
		fDataBaseWhats: String;
    fDataBaseInPulse: String;
		fPortaWhats: String;
    fPortaInPulse: String;
		fUserName: String;
	public
		constructor Create;
		procedure LeArquivo;

		property HostNameWhats: String read fHostNameWhats;
    property HostNameInPulse: String read fHostNameInPulse;
		property DataBaseWhatsApp: String read fDataBaseWhats;
    property DataBaseInPulse: String read fDataBaseInPulse;
		property PortaWhatsApp: String read fPortaWhats;
    property PortaInPulse: String read fPortaInPulse;
		property UserName: String read fUserName;
	end;

implementation

{ TConexaoFD }

function TConexaoBDInpulse.Connection: TFDConnection;
begin
  Result := FConexao;
end;

constructor TConexaoBDInpulse.Create;
var
  lDBConfINI: TDBConfINI;
begin
	lDBConfINI := TDBConfINI.Create;
  try
    if (Assigned(lDBConfINI)) then
    begin
      try
        FConexao := TFDConnection.Create(nil);

        FConexao.Connected := False;
        FConexao.Params.Values['DriverID'] := 'MySQL';
        FConexao.Params.Values['Server'] := lDBConfINI.fHostNameInPulse;
        FConexao.Params.Values['Port'] := lDBConfINI.fPortaInPulse;
        FConexao.Params.Values['Database'] := lDBConfINI.fDataBaseInPulse;
        FConexao.Params.Values['User_name'] := lDBConfINI.fUserName;
        FConexao.Params.Values['Password'] := 'fat0516fat';
        FConexao.Connected := True;

      except on E:Exception do
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    lDBConfINI.Free;
  end;
end;

destructor TConexaoBDInpulse.Destroy;
begin
  if Assigned(FConexao) then
    FreeAndNil(FConexao);

   inherited Destroy;
end;

{ TDBConfINI }

constructor TDBConfINI.Create;
begin
  inherited;
  LeArquivo;
end;

procedure TDBConfINI.LeArquivo;
var
	lExiste: Boolean;
	lCaminhoIni: String;
	lIni: TInifile;
	lValor: String;
begin
	lCaminhoIni := ExtractFilePath(Application.ExeName) + 'dbconf.ini';
	lExiste := FileExists(lCaminhoIni);

	if not lExiste then
	begin
    raise Exception.Create('Não foi possível localizar o arquivo de ' +
                           'informações do banco de dados. ' +
                           'A aplicação será fechada.');
		Application.Terminate;
	end;

	lIni := TInifile.Create(lCaminhoIni);
	try
		lValor := lIni.ReadString('hostname', 'hostnameinpulse', '');
		if (lValor <> '') then
			fHostNameInPulse := lValor;
    lValor := lIni.ReadString('hostname', 'hostnamewhats', '');
		if (lValor <> '') then
			fHostNameWhats := lValor;

		lValor := lIni.ReadString('database', 'databaseinpulse', '');
		if (lValor <> '') then
			fDataBaseInPulse := lValor;
    lValor := lIni.ReadString('database', 'databasewhats', '');
		if (lValor <> '') then
			fDataBaseWhats := lValor;

		lValor := lIni.ReadString('porta', 'portainpulse', '');
		if (lValor <> '') then
			fPortaInPulse := lValor;
    lValor := lIni.ReadString('porta', 'portawhats', '');
		if (lValor <> '') then
			fPortaWhats := lValor;

		lValor := lIni.ReadString('USUARIO', 'username', '');
		if (lValor <> '') then
			fUserName := lValor;
	finally
		lIni.Free;
	end;
end;

{ TConexaoBDWhatsApp }

function TConexaoBDWhatsApp.Connection: TFDConnection;
begin
  Result := FConexao;
end;

constructor TConexaoBDWhatsApp.Create;
var
  lDBConfINI: TDBConfINI;
begin
	lDBConfINI := TDBConfINI.Create;
  try
    if (Assigned(lDBConfINI)) then
    begin
      try
        FConexao := TFDConnection.Create(nil);

        FConexao.Connected := False;
        FConexao.Params.Values['DriverID'] := 'MySQL';
        FConexao.Params.Values['Server'] := lDBConfINI.fHostNameWhats;
        FConexao.Params.Values['Port'] := lDBConfINI.fPortaWhats;
        FConexao.Params.Values['Database'] := lDBConfINI.fDataBaseWhats;
        FConexao.Params.Values['User_name'] := lDBConfINI.fUserName;
        FConexao.Params.Values['Password'] := 'fat0516fat';
        FConexao.Connected := True;

      except on E:Exception do
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    lDBConfINI.Free;
  end;
end;

destructor TConexaoBDWhatsApp.Destroy;
begin
  FreeAndNil(FConexao);

  inherited;
end;

end.
