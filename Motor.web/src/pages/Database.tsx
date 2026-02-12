import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Database as DatabaseIcon, Table, ChevronRight, Loader, Wifi, WifiOff, ChevronLeft } from 'lucide-react';
import { useWebSocketDatabase } from '../hooks/useWebSocketDatabase';
import './Database.css';

interface TabelaInfo {
  nome: string;
  linhas: number;
}

interface ListarTabelasResult {
  tabelas: TabelaInfo[];
  caminhoBanco?: string;
}

interface LinhaTabela {
  [key: string]: any;
}

export default function Database() {
  const { plantaSelecionada } = useAuth();
  const [tabelas, setTabelas] = useState<TabelaInfo[]>([]);
  const [caminhoBanco, setCaminhoBanco] = useState<string>('');
  const [tabelaSelecionada, setTabelaSelecionada] = useState<string | null>(null);
  const [dados, setDados] = useState<LinhaTabela[]>([]);
  const [colunas, setColunas] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadingDados, setLoadingDados] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pageSize, setPageSize] = useState(50);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalLinhas, setTotalLinhas] = useState(0);

  const { isConnected, listarTabelas, consultarTabela } = useWebSocketDatabase(
    plantaSelecionada?.id
  );

  // Carregar lista de tabelas ao montar componente
  useEffect(() => {
    if (plantaSelecionada && isConnected) {
      carregarTabelas();
    }
  }, [plantaSelecionada, isConnected]);

  const carregarTabelas = async () => {
    setLoading(true);
    setError(null);
    try {
      const resultado = await listarTabelas() as ListarTabelasResult;
      if (resultado && resultado.tabelas) {
        setTabelas(resultado.tabelas);
        if (resultado.caminhoBanco) {
          setCaminhoBanco(resultado.caminhoBanco);
        }
      } else {
        setError('Nenhuma tabela encontrada');
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar tabelas');
    } finally {
      setLoading(false);
    }
  };

  const carregarDadosTabela = async (nomeTabela: string, page: number = 1, size: number = pageSize) => {
    setLoadingDados(true);
    setError(null);
    try {
      const resultado = await consultarTabela(nomeTabela, page, size);
      if (resultado && resultado.dados) {
        setDados(resultado.dados);
        setColunas(resultado.colunas || []);
        setTotalLinhas(resultado.totalLinhas || 0);
        setCurrentPage(page);
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar dados da tabela');
    } finally {
      setLoadingDados(false);
    }
  };

  const handleTabelaClick = (nomeTabela: string) => {
    setTabelaSelecionada(nomeTabela);
    setCurrentPage(1);
    carregarDadosTabela(nomeTabela, 1, pageSize);
  };

  const handlePageSizeChange = (newSize: number) => {
    setPageSize(newSize);
    setCurrentPage(1);
    if (tabelaSelecionada) {
      carregarDadosTabela(tabelaSelecionada, 1, newSize);
    }
  };

  const handlePageChange = (newPage: number) => {
    if (tabelaSelecionada) {
      carregarDadosTabela(tabelaSelecionada, newPage, pageSize);
    }
  };

  const totalPages = Math.ceil(totalLinhas / pageSize);

  if (!plantaSelecionada) {
    return (
      <div className="database-page fade-in">
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>Selecione uma planta para visualizar o banco de dados</p>
        </div>
      </div>
    );
  }

  return (
    <div className="database-page fade-in">
      <div className="database-header">
        <div>
          <h2>
            <DatabaseIcon size={24} />
            Banco de Dados Local da IHM
          </h2>
          {caminhoBanco && (
            <p className="database-path">
              <span className="path-label">Caminho:</span>
              <span className="path-value">{caminhoBanco}</span>
            </p>
          )}
        </div>
        <div className={`connection-status ${isConnected ? 'connected' : 'disconnected'}`}>
          {isConnected ? (
            <>
              <Wifi size={16} />
              <span>IHM Conectada</span>
            </>
          ) : (
            <>
              <WifiOff size={16} />
              <span>IHM Desconectada</span>
            </>
          )}
        </div>
      </div>

      {error && (
        <div className="error-message">
          <span>{error}</span>
          <button onClick={() => setError(null)}>✕</button>
        </div>
      )}

      <div className="database-container">
        {/* Lista de Tabelas */}
        <div className="tabelas-section">
          <h3>Tabelas do Banco</h3>
          {loading ? (
            <div className="loading-container">
              <Loader className="spin" size={20} />
              <span>Carregando tabelas...</span>
            </div>
          ) : (
            <div className="tabelas-list">
              {tabelas.length === 0 ? (
                <p className="empty-message">Nenhuma tabela encontrada</p>
              ) : (
                tabelas.map((tabela) => (
                  <div
                    key={tabela.nome}
                    className={`tabela-item ${tabelaSelecionada === tabela.nome ? 'selected' : ''}`}
                    onClick={() => handleTabelaClick(tabela.nome)}
                  >
                    <Table size={18} />
                    <div className="tabela-info">
                      <span className="tabela-nome">{tabela.nome}</span>
                      <span className="tabela-linhas">{tabela.linhas} linhas</span>
                    </div>
                    <ChevronRight size={18} />
                  </div>
                ))
              )}
            </div>
          )}
        </div>

        {/* Dados da Tabela Selecionada */}
        <div className="dados-section">
          {tabelaSelecionada ? (
            <>
              <div className="dados-header">
                <h3>Dados da Tabela: {tabelaSelecionada}</h3>
                <div className="pagination-controls">
                  <label>Linhas por página:</label>
                  <select
                    value={pageSize}
                    onChange={(e) => handlePageSizeChange(Number(e.target.value))}
                  >
                    <option value={10}>10</option>
                    <option value={50}>50</option>
                    <option value={100}>100</option>
                    <option value={1000}>1000</option>
                  </select>
                </div>
              </div>

              {loadingDados ? (
                <div className="loading-container">
                  <Loader className="spin" size={20} />
                  <span>Carregando dados...</span>
                </div>
              ) : (
                <>
                  {dados.length === 0 ? (
                    <p className="empty-message">Nenhum dado encontrado</p>
                  ) : (
                    <>
                      <div className="table-wrapper">
                        <table className="data-table">
                          <thead>
                            <tr>
                              {colunas.map((coluna) => (
                                <th key={coluna}>{coluna}</th>
                              ))}
                            </tr>
                          </thead>
                          <tbody>
                            {dados.map((linha, index) => (
                              <tr key={index}>
                                {colunas.map((coluna) => (
                                  <td key={coluna}>
                                    {linha[coluna] !== null && linha[coluna] !== undefined
                                      ? String(linha[coluna])
                                      : 'NULL'}
                                  </td>
                                ))}
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>

                      {/* Paginação */}
                      <div className="pagination">
                        <button
                          onClick={() => handlePageChange(currentPage - 1)}
                          disabled={currentPage === 1}
                        >
                          <ChevronLeft size={18} />
                          Anterior
                        </button>
                        <span className="page-info">
                          Página {currentPage} de {totalPages} ({totalLinhas} linhas)
                        </span>
                        <button
                          onClick={() => handlePageChange(currentPage + 1)}
                          disabled={currentPage >= totalPages}
                        >
                          Próxima
                          <ChevronRight size={18} />
                        </button>
                      </div>
                    </>
                  )}
                </>
              )}
            </>
          ) : (
            <div className="empty-selection">
              <DatabaseIcon size={64} />
              <p>Selecione uma tabela para visualizar os dados</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
