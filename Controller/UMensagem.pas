unit UMensagem;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.ConsoleUI.Wait,
  Data.DB, FireDAC.Phys.PG, FireDAC.Phys.PGDef,FireDAC.DApt,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Comp.Client,
  System.JSON, REST.Json;

type

  TMensagem = class

  public
    function RetornarMensagem: string;
    procedure AtualizarMensagemProcessada;
  end;

implementation

uses
  UConexao;

{ TMensagem }

procedure TMensagem.AtualizarMensagemProcessada;
begin

end;

function TMensagem.RetornarMensagem: string;
var
  lConexao: TConexaoFD;
begin
  lConexao := TConexaoFD.Create;
  Result := '';
end;

end.
