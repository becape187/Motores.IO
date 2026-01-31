import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import { Key, Copy, Check, AlertTriangle, Shield } from 'lucide-react';
import './PlantaTokens.css';

interface TokenInfo {
  possuiToken: boolean;
  tokenOculto?: string;
  geradoEm?: string;
}

function PlantaTokens() {
  const { plantaSelecionada } = useAuth();
  const [tokenInfo, setTokenInfo] = useState<TokenInfo | null>(null);
  const [novoToken, setNovoToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);

  useEffect(() => {
    if (plantaSelecionada) {
      carregarTokenInfo();
    }
  }, [plantaSelecionada]);

  const carregarTokenInfo = async () => {
    if (!plantaSelecionada) return;
    
    try {
      const info = await api.verificarTokenPlanta(plantaSelecionada.id);
      setTokenInfo(info);
    } catch (error) {
      console.error('Erro ao carregar informações do token:', error);
    }
  };

  const handleGerarToken = async () => {
    if (!plantaSelecionada) return;

    if (tokenInfo?.possuiToken) {
      setShowConfirmDialog(true);
      return;
    }

    await gerarNovoToken();
  };

  const gerarNovoToken = async () => {
    if (!plantaSelecionada) return;

    setLoading(true);
    setShowConfirmDialog(false);
    
    try {
      const response = await api.gerarTokenPlanta(plantaSelecionada.id);
      setNovoToken(response.token);
      setTokenInfo({
        possuiToken: true,
        geradoEm: response.geradoEm,
      });
    } catch (error: any) {
      alert('Erro ao gerar token: ' + (error.message || 'Erro desconhecido'));
    } finally {
      setLoading(false);
    }
  };

  const copiarToken = async () => {
    if (novoToken) {
      await navigator.clipboard.writeText(novoToken);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  if (!plantaSelecionada) {
    return (
      <div className="planta-tokens-container">
        <div className="empty-state">
          <Shield size={48} />
          <h2>Selecione uma Planta</h2>
          <p>Por favor, selecione uma planta para gerenciar seus tokens de API.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="planta-tokens-container">
      <div className="tokens-header">
        <div className="header-icon">
          <Key size={32} />
        </div>
        <div>
          <h1>Tokens de API - {plantaSelecionada.nome}</h1>
          <p>Gere tokens para que a HMI possa acessar a API desta planta</p>
        </div>
      </div>

      {/* Aviso se já existe token */}
      {tokenInfo?.possuiToken && !novoToken && (
        <div className="warning-box">
          <AlertTriangle size={20} />
          <div>
            <strong>Token já existe</strong>
            <p>
              Já existe um token ativo para esta planta. Gerar um novo token irá invalidar o token atual,
              o que pode comprometer dispositivos (HMIs) que já estão usando o token atual.
            </p>
            {tokenInfo.geradoEm && (
              <p className="token-date">
                Token gerado em: {new Date(tokenInfo.geradoEm).toLocaleString('pt-BR')}
              </p>
            )}
          </div>
        </div>
      )}

      {/* Novo token gerado */}
      {novoToken && (
        <div className="token-display-box">
          <div className="token-header">
            <Shield size={20} />
            <h3>Token Gerado com Sucesso!</h3>
          </div>
          <div className="token-warning">
            <AlertTriangle size={16} />
            <p>
              <strong>Importante:</strong> Guarde este token com segurança. Você não poderá vê-lo novamente.
              Se perder este token, será necessário gerar um novo.
            </p>
          </div>
          <div className="token-value-container">
            <code className="token-value">{novoToken}</code>
            <button
              className="copy-button"
              onClick={copiarToken}
              title="Copiar token"
            >
              {copied ? <Check size={18} /> : <Copy size={18} />}
            </button>
          </div>
          <p className="token-hint">
            Copie este token e configure-o na HMI para permitir acesso à API.
          </p>
        </div>
      )}

      {/* Botão para gerar token */}
      <div className="actions-section">
        <button
          className="generate-button"
          onClick={handleGerarToken}
          disabled={loading}
        >
          {loading ? (
            'Gerando...'
          ) : tokenInfo?.possuiToken && !novoToken ? (
            'Gerar Novo Token'
          ) : (
            'Gerar Token'
          )}
        </button>
      </div>

      {/* Dialog de confirmação */}
      {showConfirmDialog && (
        <div className="modal-overlay" onClick={() => setShowConfirmDialog(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <AlertTriangle size={24} className="warning-icon" />
              <h2>Confirmar Geração de Novo Token</h2>
            </div>
            <div className="modal-body">
              <p>
                <strong>Atenção!</strong> Já existe um token ativo para esta planta.
              </p>
              <p>
                Ao gerar um novo token, o token atual será invalidado. Isso pode causar:
              </p>
              <ul>
                <li>Interrupção no acesso de HMIs que estão usando o token atual</li>
                <li>Necessidade de reconfigurar todos os dispositivos com o novo token</li>
                <li>Possível perda de dados se os dispositivos não conseguirem se reconectar</li>
              </ul>
              <p>
                <strong>Deseja continuar?</strong>
              </p>
            </div>
            <div className="modal-actions">
              <button
                className="cancel-button"
                onClick={() => setShowConfirmDialog(false)}
              >
                Cancelar
              </button>
              <button
                className="confirm-button"
                onClick={gerarNovoToken}
                disabled={loading}
              >
                {loading ? 'Gerando...' : 'Sim, Gerar Novo Token'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default PlantaTokens;
