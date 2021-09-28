unit uInterfaceMensagem;

interface

uses
  FireDAC.Comp.Client;

type
  iMensagemWhats = interface
    ['{4CE85399-D512-4EED-8852-C601AB5A2F40}']

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

  iMensagemInpulse = interface
    ['{D3A84728-1FAB-4A07-8EF6-F39389A61F2A}']
  function BuscarRespostas: iMensagemInpulse;
  function RetornarCampanhaCadastrada(AConexao: TFDConnection;
                                      ACampanha: Integer): iMensagemInpulse;
  function CadastrarCampanhaCliente(AConexao: TFDConnection;
                                    ACodigoCliente,
                                    ACampanha: Integer): iMensagemInpulse;
  function RetornarCampanhaMensagem(AConexao: TFDConnection): iMensagemInpulse;
  function ProcessarMensagemCM(AConexao: TFDConnection;
                               ACodigo: Integer): iMensagemInpulse;
  function CadastrarCampanhaMensagem(AConexao: TFDConnection;
                                       ACampanha: Integer;
                                       AMensagem,
                                       ATelefone,
                                       AIDConversa: string): iMensagemInpulse;
  function CadastrarResposta(AConexao: TFDConnection;
                             ATelefone,
                             AMensagem,
                             AIdConversa: string): iMensagemInpulse;
  function CadastrarClienteInPulse(AConexao: TFDConnection;
                                   ATelefone,
                                   AMensagem: string): iMensagemInpulse;


  end;

implementation

end.
