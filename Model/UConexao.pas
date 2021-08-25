unit UConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, IniFiles, Vcl.Forms, FireDAC.Phys.PG;

type
  TConexaoFD = class
  private
    FConexao : TFDConnection;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
  public
    constructor Create(ADriver, ADataBase, AUserName, APassword, APorta, AServidor: string); overload;
	  destructor Destroy; override;
    function Connection: TFDConnection;
  end;

implementation

{ TConexaoFD }

function TConexaoFD.Connection: TFDConnection;
begin
  Result := FConexao;
end;

constructor TConexaoFD.Create(ADriver, ADataBase, AUserName, APassword, APorta,
  AServidor: string);
begin
  try
    FConexao := TFDConnection.Create(nil);

    FConexao.Connected := False;
    FConexao.Params.Values['DriverID'] := ADriver;
    FConexao.Params.Values['Server'] := AServidor;
    FConexao.Params.Values['Port'] := APorta;
    FConexao.Params.Values['Database'] := ADataBase;
    FConexao.Params.Values['User_name'] := AUserName;
    FConexao.Params.Values['Password'] := APassword;
    FConexao.Connected := True;

  except on E:Exception do
    raise Exception.Create(E.Message);
  end;
end;

destructor TConexaoFD.Destroy;
begin
   FreeAndNil(FConexao);

   inherited;
end;

end.
