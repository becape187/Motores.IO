import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import { useWebSocketConsole } from '../hooks/useWebSocketConsole';
import { File, Trash2, Save, Edit2, X, Folder, FileText, Database, Loader, AlertCircle, Wifi, WifiOff } from 'lucide-react';
import './Files.css';

interface ArquivoInfo {
  nome: string;
  caminho: string;
  tipo: string;
  tamanho: number;
  localizacao?: string;
}

export default function Files() {
  const { plantaSelecionada } = useAuth();
  const [arquivos, setArquivos] = useState<ArquivoInfo[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [arquivoSelecionado, setArquivoSelecionado] = useState<ArquivoInfo | null>(null);
  const [conteudoArquivo, setConteudoArquivo] = useState<string>('');
  const [editando, setEditando] = useState(false);
  const [salvando, setSalvando] = useState(false);
  const [pathAtual, setPathAtual] = useState('/flash');

  // WebSocket para verificar conexão com IHM (usa o mesmo endpoint do console)
  const handleConsoleMessage = useCallback(() => {
    // Não precisamos processar mensagens do console aqui
    // Apenas usamos o hook para verificar a conexão
  }, []);
  
  const { isConnected } = useWebSocketConsole(
    plantaSelecionada?.id,
    handleConsoleMessage
  );

  // Limpar erros de conexão quando conectar
  useEffect(() => {
    if (isConnected && error) {
      const erroLower = error.toLowerCase();
      if (erroLower.includes('ihm não conectada') || erroLower.includes('não está conectada')) {
        setError(null);
      }
    }
  }, [isConnected, error]);

  useEffect(() => {
    if (plantaSelecionada) {
      carregarArquivos();
    }
  }, [plantaSelecionada, pathAtual]);

  const carregarArquivos = async () => {
    if (!plantaSelecionada) return;

    setLoading(true);
    setError(null);

    try {
      const response = await api.listarArquivos(plantaSelecionada.id, pathAtual);
      
      if (response.sucesso && response.dados) {
        const todosArquivos = [
          ...(response.dados.arquivos || []),
          ...(response.dados.diretorios || [])
        ];
        setArquivos(todosArquivos);
        setError(null); // Limpar erro ao ter sucesso
      } else {
        const erroMsg = response.erro || 'Erro ao carregar arquivos';
        // Não mostrar erro de conexão se o WebSocket indica que está conectado
        if (!isConnected && (erroMsg.toLowerCase().includes('ihm não conectada') || erroMsg.toLowerCase().includes('não está conectada'))) {
          // Não definir erro, apenas deixar o warning aparecer
        } else {
          setError(erroMsg);
        }
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar arquivos');
    } finally {
      setLoading(false);
    }
  };

  const carregarBancosDados = async () => {
    if (!plantaSelecionada) return;

    setLoading(true);
    setError(null);

    try {
      const response = await api.listarBancosDados(plantaSelecionada.id);
      
      if (response.sucesso && response.dados) {
        setArquivos(response.dados || []);
        setError(null); // Limpar erro ao ter sucesso
      } else {
        const erroMsg = response.erro || 'Erro ao carregar bancos de dados';
        // Não mostrar erro de conexão se o WebSocket indica que está conectado
        if (!isConnected && (erroMsg.toLowerCase().includes('ihm não conectada') || erroMsg.toLowerCase().includes('não está conectada'))) {
          // Não definir erro, apenas deixar o warning aparecer
        } else {
          setError(erroMsg);
        }
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar bancos de dados');
    } finally {
      setLoading(false);
    }
  };

  const selecionarArquivo = async (arquivo: ArquivoInfo) => {
    if (arquivo.tipo === 'diretorio') {
      setPathAtual(arquivo.caminho);
      return;
    }

    setArquivoSelecionado(arquivo);
    setEditando(false);
    setConteudoArquivo('');

    if (!plantaSelecionada) return;

    setLoading(true);
    setError(null);

    try {
      const response = await api.lerArquivo(plantaSelecionada.id, arquivo.caminho);
      
      if (response.sucesso && response.dados) {
        let conteudo = response.dados.conteudo || '';
        
        // Se o conteúdo está em Base64, decodificar
        if (response.dados.base64 && conteudo) {
          try {
            // Decodificar Base64 para string binária
            const binaryString = atob(conteudo);
            // Converter para string legível (para arquivos de texto)
            // Para arquivos binários (como .db), manter como está
            conteudo = binaryString;
          } catch (err) {
            console.error('Erro ao decodificar Base64:', err);
            setError('Erro ao decodificar conteúdo do arquivo');
            return;
          }
        }
        
        setConteudoArquivo(conteudo);
      } else {
        setError(response.erro || 'Erro ao ler arquivo');
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao ler arquivo');
    } finally {
      setLoading(false);
    }
  };

  const salvarArquivo = async () => {
    if (!plantaSelecionada || !arquivoSelecionado) return;

    setSalvando(true);
    setError(null);

    try {
      const response = await api.salvarArquivo(
        plantaSelecionada.id,
        arquivoSelecionado.caminho,
        conteudoArquivo
      );
      
      if (response.sucesso) {
        setEditando(false);
        alert('Arquivo salvo com sucesso!');
      } else {
        setError(response.erro || 'Erro ao salvar arquivo');
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao salvar arquivo');
    } finally {
      setSalvando(false);
    }
  };

  const apagarArquivo = async (arquivo: ArquivoInfo) => {
    if (!plantaSelecionada) return;
    
    if (!confirm(`Tem certeza que deseja apagar o arquivo "${arquivo.nome}"?`)) {
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await api.apagarArquivo(plantaSelecionada.id, arquivo.caminho);
      
      if (response.sucesso) {
        if (arquivoSelecionado?.caminho === arquivo.caminho) {
          setArquivoSelecionado(null);
          setConteudoArquivo('');
        }
        carregarArquivos();
        alert('Arquivo apagado com sucesso!');
      } else {
        setError(response.erro || 'Erro ao apagar arquivo');
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao apagar arquivo');
    } finally {
      setLoading(false);
    }
  };

  const formatarTamanho = (bytes: number): string => {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(2) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(2) + ' MB';
  };

  const getIcone = (tipo: string) => {
    if (tipo === 'diretorio') return <Folder size={20} />;
    if (tipo === 'arquivo') {
      if (arquivoSelecionado?.nome.endsWith('.db')) return <Database size={20} />;
      return <FileText size={20} />;
    }
    return <File size={20} />;
  };

  if (!plantaSelecionada) {
    return (
      <div className="files-page">
        <div className="files-empty">
          <p>Selecione uma planta para visualizar os arquivos</p>
        </div>
      </div>
    );
  }

  return (
    <div className="files-page">
      <div className="files-header">
        <div className="files-header-title">
          <h1>Gerenciamento de Arquivos</h1>
          <div className={`files-connection-status ${isConnected ? 'connected' : 'disconnected'}`}>
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
        <div className="files-actions">
          <button onClick={carregarArquivos} className="btn-secondary" disabled={loading}>
            <File size={20} />
            Listar Arquivos
          </button>
          <button onClick={carregarBancosDados} className="btn-secondary" disabled={loading}>
            <Database size={20} />
            Listar Bancos de Dados
          </button>
        </div>
      </div>

      {error && !error.toLowerCase().includes('ihm não conectada') && !error.toLowerCase().includes('não está conectada') && (
        <div className="files-error">
          <AlertCircle size={20} />
          <span>{error}</span>
        </div>
      )}
      
      {!isConnected && plantaSelecionada && (
        <div className="files-warning">
          <AlertCircle size={20} />
          <span>Aguardando conexão com a IHM... As operações podem falhar enquanto desconectado.</span>
        </div>
      )}

      <div className="files-content">
        <div className="files-list">
          <div className="files-path">
            <span>Caminho: {pathAtual}</span>
            {pathAtual !== '/flash' && (
              <button onClick={() => setPathAtual('/flash')} className="btn-link">
                Voltar
              </button>
            )}
          </div>

          {loading ? (
            <div className="files-loading">
              <Loader className="spin" size={32} />
              <p>Carregando arquivos...</p>
            </div>
          ) : (
            <div className="files-items">
              {arquivos.length === 0 ? (
                <div className="files-empty">
                  <p>Nenhum arquivo encontrado</p>
                </div>
              ) : (
                arquivos.map((arquivo, index) => (
                  <div
                    key={index}
                    className={`files-item ${arquivoSelecionado?.caminho === arquivo.caminho ? 'selected' : ''}`}
                    onClick={() => selecionarArquivo(arquivo)}
                  >
                    <div className="files-item-icon">
                      {getIcone(arquivo.tipo)}
                    </div>
                    <div className="files-item-info">
                      <div className="files-item-name">{arquivo.nome}</div>
                      <div className="files-item-details">
                        {arquivo.tipo === 'arquivo' && (
                          <span>{formatarTamanho(arquivo.tamanho)}</span>
                        )}
                        {arquivo.localizacao && (
                          <span className="files-location">{arquivo.localizacao}</span>
                        )}
                      </div>
                    </div>
                    {arquivo.tipo === 'arquivo' && (
                      <button
                        className="files-item-delete"
                        onClick={(e) => {
                          e.stopPropagation();
                          apagarArquivo(arquivo);
                        }}
                      >
                        <Trash2 size={16} />
                      </button>
                    )}
                  </div>
                ))
              )}
            </div>
          )}
        </div>

        {arquivoSelecionado && (
          <div className="files-editor">
            <div className="files-editor-header">
              <h2>{arquivoSelecionado.nome}</h2>
              <div className="files-editor-actions">
                {!editando ? (
                  <button onClick={() => setEditando(true)} className="btn-primary">
                    <Edit2 size={16} />
                    Editar
                  </button>
                ) : (
                  <>
                    <button
                      onClick={salvarArquivo}
                      disabled={salvando}
                      className="btn-primary"
                    >
                      {salvando ? (
                        <>
                          <Loader className="spin" size={16} />
                          Salvando...
                        </>
                      ) : (
                        <>
                          <Save size={16} />
                          Salvar
                        </>
                      )}
                    </button>
                    <button
                      onClick={() => {
                        setEditando(false);
                        selecionarArquivo(arquivoSelecionado);
                      }}
                      className="btn-secondary"
                    >
                      <X size={16} />
                      Cancelar
                    </button>
                  </>
                )}
              </div>
            </div>
            <div className="files-editor-content">
              {editando ? (
                <textarea
                  value={conteudoArquivo}
                  onChange={(e) => setConteudoArquivo(e.target.value)}
                  className="files-textarea"
                  placeholder="Conteúdo do arquivo..."
                />
              ) : (
                <pre className="files-preview">{conteudoArquivo || 'Arquivo vazio'}</pre>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
