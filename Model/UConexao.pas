unit UConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, IniFiles, Vcl.Forms, FireDAC.Phys.PG;

type

  TConexaoFD = class
  public
    FConexao : TFDConnection;
    function Connection: TFDConnection;

    constructor Create;
	  destructor Destroy; override;
  end;

  TDBConfINI = class
	private
		fHostName: String;
		fDataBase: String;
		fPorta: String;
		fUserName: String;
	public
		constructor Create;
		procedure LeArquivo;
		property HostName: String read fHostName;
		property DataBase: String read fDataBase;
		property Porta: String read fPorta;
		property UserName: String read fUserName;
	end;

  TCriarConexao = class
  public
    procedure CriarConexao;
  end;

implementation

{ TConexaoFD }

function TConexaoFD.Connection: TFDConnection;
begin
  Result := FConexao;
end;

constructor TConexaoFD.Create;
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
        FConexao.Params.Values['Server'] := lDBConfINI.fHostName;
        FConexao.Params.Values['Port'] := lDBConfINI.fPorta;
        FConexao.Params.Values['Database'] := lDBConfINI.fDataBase;
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

destructor TConexaoFD.Destroy;
begin
   FreeAndNil(FConexao);

   inherited;
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
	S: String;
begin
	lCaminhoIni := ExtractFilePath(Application.ExeName) + 'ConfTInject.ini';
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
		S := lIni.ReadString('hostname', 'hostname', '');
		if (S <> '') then
			fHostName := S;
		S := lIni.ReadString('database', 'database', '');
		if (S <> '') then
			fDataBase := S;
		S := lIni.ReadString('porta', 'porta', '');
		if (S <> '') then
			fPorta := S;
		S := lIni.ReadString('USUARIO', 'username', '');
		if (S <> '') then
			fUserName := S;
	finally
		lIni.Free;
	end;
end;

{ TCriarConexao }

procedure TCriarConexao.CriarConexao;
begin

end;

end.
