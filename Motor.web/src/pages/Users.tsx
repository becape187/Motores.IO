import { useState, useEffect } from 'react';
import { UserPlus, Edit2, Trash2, Save, X, Search, Shield, Eye, UserCheck, ArrowLeft } from 'lucide-react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import { Usuario } from '../types';
import './Users.css';

function Users() {
  const { user: userLogado, clienteSelecionado } = useAuth();
  const [users, setUsers] = useState<Usuario[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [selectedUser, setSelectedUser] = useState<Usuario | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [isAdding, setIsAdding] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [showDetails, setShowDetails] = useState(false);
  const [plantasDisponiveis, setPlantasDisponiveis] = useState<Array<{id: string; nome: string; codigo?: string}>>([]);
  const [plantasSelecionadas, setPlantasSelecionadas] = useState<string[]>([]);
  const [senha, setSenha] = useState('');
  const [confirmarSenha, setConfirmarSenha] = useState('');

  const [formData, setFormData] = useState<Partial<Usuario>>({
    nome: '',
    email: '',
    perfil: 'visualizador',
    ativo: true,
  });

  const handleSelectUser = async (user: Usuario) => {
    setSelectedUser(user);
    setFormData(user);
    setIsEditing(false);
    setIsAdding(false);
    setShowDetails(true);
    
    // Carregar plantas do usuário
    try {
      const usuarioCompleto = await api.getUsuario(user.id);
      setPlantasSelecionadas((usuarioCompleto.plantas || []).map((p: any) => p.id));
    } catch (err) {
      console.error('Erro ao carregar plantas do usuário:', err);
    }
  };

  const handleBackToList = () => {
    setShowDetails(false);
    setSelectedUser(null);
    setIsEditing(false);
    setIsAdding(false);
  };

  // Carregar usuários da API
  useEffect(() => {
    const loadUsers = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await api.getUsuarios();
        
        const usersData: Usuario[] = data.map((u: any) => ({
          id: u.id,
          nome: u.nome,
          email: u.email,
          perfil: u.perfil as Usuario['perfil'],
          ativo: u.ativo,
          ultimoAcesso: u.ultimoAcesso ? new Date(u.ultimoAcesso) : undefined,
        }));
        
        setUsers(usersData);
      } catch (err: any) {
        setError(err.message || 'Erro ao carregar usuários');
        console.error('Erro ao carregar usuários:', err);
      } finally {
        setLoading(false);
      }
    };

    loadUsers();
  }, []);

  // Carregar plantas disponíveis quando entrar em modo de edição/criação
  useEffect(() => {
    if ((isEditing || isAdding) && userLogado?.perfil === 'admin') {
      api.getPlantasDisponiveis().then(setPlantasDisponiveis).catch(console.error);
    }
  }, [isEditing, isAdding, userLogado]);

  const handleAddNew = () => {
    setIsAdding(true);
    setIsEditing(true);
    setSelectedUser(null);
    setShowDetails(true);
    setFormData({
      nome: '',
      email: '',
      perfil: 'visualizador',
      ativo: true,
    });
    setSenha('');
    setConfirmarSenha('');
    setPlantasSelecionadas([]);
  };

  const handleEdit = () => {
    setIsEditing(true);
  };

  const handleCancel = () => {
    setIsEditing(false);
    setIsAdding(false);
    if (selectedUser) {
      setFormData(selectedUser);
    }
  };

  const handleSave = async () => {
    if (!userLogado) return;

    // Validar senha se estiver criando ou se forneceu senha
    if (isAdding && !senha) {
      alert('Senha é obrigatória ao criar usuário');
      return;
    }

    if (senha && senha !== confirmarSenha) {
      alert('As senhas não coincidem');
      return;
    }

    // Validar cliente selecionado (se global)
    if (userLogado.perfil === 'global' && !clienteSelecionado) {
      alert('Selecione um cliente primeiro');
      return;
    }

    try {
      setSaving(true);
      setError(null);

      // Obter clienteId: se global usa cliente selecionado, senão usa cliente do usuário logado
      let clienteId: string;
      if (userLogado.perfil === 'global') {
        if (!clienteSelecionado) {
          alert('Selecione um cliente primeiro');
          return;
        }
        clienteId = clienteSelecionado.id;
      } else {
        // Buscar cliente do usuário logado
        const usuarioLogadoCompleto = await api.getUsuario(userLogado.id);
        clienteId = usuarioLogadoCompleto.clienteId;
      }

      if (isAdding) {
        // Criar novo usuário
        const newUser = await api.createUsuario({
          nome: formData.nome ?? '',
          email: formData.email ?? '',
          senha: senha,
          perfil: formData.perfil ?? 'visualizador',
          ativo: formData.ativo ?? true,
          clienteId: clienteId,
          plantaIds: formData.perfil === 'global' ? [] : plantasSelecionadas,
        });

        const convertedUser: Usuario = {
          id: newUser.id,
          nome: newUser.nome,
          email: newUser.email,
          perfil: newUser.perfil as Usuario['perfil'],
          ativo: newUser.ativo,
          ultimoAcesso: newUser.ultimoAcesso ? new Date(newUser.ultimoAcesso) : undefined,
        };

        setUsers([...users, convertedUser]);
        setSelectedUser(convertedUser);
      } else if (selectedUser) {
        // Atualizar usuário existente
        await api.updateUsuario(selectedUser.id, {
          id: selectedUser.id,
          nome: formData.nome ?? '',
          email: formData.email ?? '',
          senha: senha || undefined,
          perfil: formData.perfil ?? 'visualizador',
          ativo: formData.ativo ?? true,
          clienteId: clienteId,
          plantaIds: formData.perfil === 'global' ? [] : plantasSelecionadas,
        });

        // Recarregar usuário atualizado
        const updatedUser = await api.getUsuario(selectedUser.id);
        const convertedUser: Usuario = {
          id: updatedUser.id,
          nome: updatedUser.nome,
          email: updatedUser.email,
          perfil: updatedUser.perfil as Usuario['perfil'],
          ativo: updatedUser.ativo,
          ultimoAcesso: updatedUser.ultimoAcesso ? new Date(updatedUser.ultimoAcesso) : undefined,
        };

        setUsers(users.map(u => u.id === selectedUser.id ? convertedUser : u));
        setSelectedUser(convertedUser);
      }

      setIsEditing(false);
      setIsAdding(false);
      setSenha('');
      setConfirmarSenha('');
    } catch (err: any) {
      setError(err.message || 'Erro ao salvar usuário');
      console.error('Erro ao salvar usuário:', err);
      alert('Erro ao salvar usuário: ' + (err.message || 'Erro desconhecido'));
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (userId: string) => {
    if (!window.confirm('Tem certeza que deseja excluir este usuário?')) {
      return;
    }

    try {
      await api.deleteUsuario(userId);
      setUsers(users.filter(u => u.id !== userId));
      if (selectedUser?.id === userId) {
        setSelectedUser(null);
        setShowDetails(false);
      }
    } catch (err: any) {
      alert('Erro ao excluir usuário: ' + (err.message || 'Erro desconhecido'));
      console.error('Erro ao excluir usuário:', err);
    }
  };

  const handleTogglePlanta = (plantaId: string) => {
    if (plantasSelecionadas.includes(plantaId)) {
      setPlantasSelecionadas(plantasSelecionadas.filter(id => id !== plantaId));
    } else {
      setPlantasSelecionadas([...plantasSelecionadas, plantaId]);
    }
  };

  const handleInputChange = (field: keyof Usuario, value: any) => {
    setFormData({ ...formData, [field]: value });
  };

  const getPerfilIcon = (perfil: string) => {
    switch (perfil) {
      case 'admin':
        return <Shield size={18} />;
      case 'operador':
        return <UserCheck size={18} />;
      case 'visualizador':
        return <Eye size={18} />;
      default:
        return <Eye size={18} />;
    }
  };

  const getPerfilColor = (perfil: string) => {
    switch (perfil) {
      case 'global':
        return '#9b59b6';
      case 'admin':
        return '#e74c3c';
      case 'operador':
        return '#3498db';
      case 'visualizador':
        return '#95a5a6';
      default:
        return '#95a5a6';
    }
  };

  const filteredUsers = users.filter(user =>
    user.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const stats = {
    total: users.length,
    ativos: users.filter(u => u.ativo).length,
    admins: users.filter(u => u.perfil === 'admin').length,
    operadores: users.filter(u => u.perfil === 'operador').length,
  };

  return (
    <div className="users-page fade-in">
      {/* Stats */}
      <div className="user-stats">
        <div className="stat-card">
          <span className="stat-number">{stats.total}</span>
          <span className="stat-text">Total de Usuários</span>
        </div>
        <div className="stat-card">
          <span className="stat-number">{stats.ativos}</span>
          <span className="stat-text">Usuários Ativos</span>
        </div>
        <div className="stat-card">
          <span className="stat-number">{stats.admins}</span>
          <span className="stat-text">Administradores</span>
        </div>
        <div className="stat-card">
          <span className="stat-number">{stats.operadores}</span>
          <span className="stat-text">Operadores</span>
        </div>
      </div>

      {/* Header */}
      {!showDetails && (
        <div className="users-header">
          <div className="search-box">
            <Search size={20} />
            <input
              type="text"
              placeholder="Buscar usuário..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <button className="btn-primary" onClick={handleAddNew}>
            <UserPlus size={20} />
            Adicionar Usuário
          </button>
        </div>
      )}

      {loading && (
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>Carregando usuários...</p>
        </div>
      )}

      {error && (
        <div style={{ textAlign: 'center', padding: '2rem', color: '#e74c3c' }}>
          <p>Erro: {error}</p>
        </div>
      )}

      <div className="users-container">
        {/* Users List */}
        {!showDetails && !loading && !error && (
          <div className="users-list visible">
            {filteredUsers.length === 0 ? (
              <div className="no-users">
                <UserPlus size={64} />
                <h3>Nenhum usuário encontrado</h3>
                <p>Não há usuários que correspondam à busca</p>
              </div>
            ) : (
              <div className="users-cards-list">
                {filteredUsers.map((user) => (
                  <div
                    key={user.id}
                    className={`user-card ${!user.ativo ? 'inactive' : ''}`}
                    style={{ borderLeftColor: getPerfilColor(user.perfil) }}
                    onClick={() => handleSelectUser(user)}
                  >
                    <div className="user-card-icon" style={{ background: getPerfilColor(user.perfil) }}>
                      {getPerfilIcon(user.perfil)}
                    </div>
                    <div className="user-card-content">
                      <div className="user-card-header">
                        <div className="user-card-info">
                          <h4>{user.nome}</h4>
                          <p className="user-email">{user.email}</p>
                        </div>
                        <div className="user-card-badges">
                          <span
                            className="user-perfil-badge"
                            style={{ background: getPerfilColor(user.perfil) }}
                          >
                            {getPerfilIcon(user.perfil)}
                            {user.perfil}
                          </span>
                          <span
                            className="user-status-badge"
                            style={{ background: user.ativo ? '#27ae60' : '#95a5a6' }}
                          >
                            {user.ativo ? 'Ativo' : 'Inativo'}
                          </span>
                        </div>
                      </div>
                      {user.ultimoAcesso && (
                        <div className="user-card-details">
                          <span className="detail-label">Último acesso:</span>
                          <span className="detail-value">
                            {format(user.ultimoAcesso, 'dd/MM/yyyy', { locale: ptBR })}
                          </span>
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        ) : (
          <div className={`user-details ${showDetails ? 'visible' : 'hidden'}`}>
            {selectedUser || isAdding ? (
              <>
                <button className="btn-back" onClick={handleBackToList}>
                  <ArrowLeft size={20} />
                  Voltar
                </button>
                <div className="details-header">
                  <h3>{isAdding ? 'Novo Usuário' : isEditing ? 'Editar Usuário' : 'Detalhes do Usuário'}</h3>
                {!isAdding && !isEditing && (
                  <div className="header-actions">
                    <button className="btn-secondary" onClick={handleEdit}>
                      <Edit2 size={18} />
                      Editar
                    </button>
                    <button
                      className="btn-danger"
                      onClick={() => selectedUser && handleDelete(selectedUser.id)}
                    >
                      <Trash2 size={18} />
                      Excluir
                    </button>
                  </div>
                )}
                {(isEditing || isAdding) && (
                  <div className="header-actions">
                    <button className="btn-secondary" onClick={handleCancel}>
                      <X size={18} />
                      Cancelar
                    </button>
                    <button className="btn-primary" onClick={handleSave} disabled={saving}>
                      <Save size={18} />
                      {saving ? 'Salvando...' : 'Salvar'}
                    </button>
                  </div>
                )}
              </div>

              <div className="details-form">
                {!isEditing && !isAdding && selectedUser && (
                  <div className="user-profile-header">
                    <img
                      className="profile-avatar"
                      src={`https://ui-avatars.com/api/?name=${encodeURIComponent(selectedUser.nome)}&background=${getPerfilColor(selectedUser.perfil).replace('#', '')}&color=fff&size=120`}
                      alt={selectedUser.nome}
                    />
                    <div className="profile-info">
                      <h2>{selectedUser.nome}</h2>
                      <p>{selectedUser.email}</p>
                      <span
                        className="profile-badge"
                        style={{ background: getPerfilColor(selectedUser.perfil) }}
                      >
                        {getPerfilIcon(selectedUser.perfil)}
                        {selectedUser.perfil}
                      </span>
                    </div>
                  </div>
                )}

                <div className="form-section">
                  <h4>Informações Básicas</h4>
                  <div className="form-grid">
                    <div className="form-field full-width">
                      <label>Nome Completo *</label>
                      <input
                        type="text"
                        value={formData.nome}
                        onChange={(e) => handleInputChange('nome', e.target.value)}
                        disabled={!isEditing && !isAdding}
                        placeholder="Digite o nome completo"
                      />
                    </div>

                    <div className="form-field full-width">
                      <label>E-mail *</label>
                      <input
                        type="email"
                        value={formData.email}
                        onChange={(e) => handleInputChange('email', e.target.value)}
                        disabled={!isEditing && !isAdding}
                        placeholder="email@exemplo.com"
                      />
                    </div>

                    <div className="form-field">
                      <label>Perfil de Acesso *</label>
                      <select
                        value={formData.perfil}
                        onChange={(e) => {
                          handleInputChange('perfil', e.target.value);
                          // Se mudar para global, limpar plantas selecionadas
                          if (e.target.value === 'global') {
                            setPlantasSelecionadas([]);
                          }
                        }}
                        disabled={!isEditing && !isAdding}
                      >
                        {userLogado?.perfil === 'global' && (
                          <option value="global">Global</option>
                        )}
                        <option value="admin">Administrador</option>
                        <option value="operador">Operador</option>
                        <option value="visualizador">Visualizador</option>
                      </select>
                      <span className="field-hint">
                        {formData.perfil === 'global' && 'Acesso irrestrito a todas as plantas'}
                        {formData.perfil === 'admin' && 'Acesso total ao sistema'}
                        {formData.perfil === 'operador' && 'Pode operar e configurar motores'}
                        {formData.perfil === 'visualizador' && 'Apenas visualização'}
                      </span>
                    </div>

                    <div className="form-field">
                      <label>Status</label>
                      <select
                        value={formData.ativo ? 'true' : 'false'}
                        onChange={(e) => handleInputChange('ativo', e.target.value === 'true')}
                        disabled={!isEditing && !isAdding}
                      >
                        <option value="true">Ativo</option>
                        <option value="false">Inativo</option>
                      </select>
                    </div>
                  </div>
                </div>

                {/* Campos de senha */}
                {(isAdding || isEditing) && (
                  <div className="form-section">
                    <h4>Senha {isAdding ? '*' : '(deixe em branco para não alterar)'}</h4>
                    <div className="form-grid">
                      <div className="form-field">
                        <label>Senha {isAdding ? '*' : ''}</label>
                        <input
                          type="password"
                          value={senha}
                          onChange={(e) => setSenha(e.target.value)}
                          disabled={!isEditing && !isAdding}
                          placeholder={isAdding ? "Digite a senha" : "Deixe em branco para manter"}
                        />
                      </div>
                      {isAdding && (
                        <div className="form-field">
                          <label>Confirmar Senha *</label>
                          <input
                            type="password"
                            value={confirmarSenha}
                            onChange={(e) => setConfirmarSenha(e.target.value)}
                            disabled={!isEditing && !isAdding}
                            placeholder="Confirme a senha"
                          />
                        </div>
                      )}
                    </div>
                  </div>
                )}

                {/* Checkboxes de Plantas (apenas se não for global) */}
                {(isAdding || isEditing) && formData.perfil !== 'global' && (
                  <div className="form-section">
                    <h4>Plantas de Acesso *</h4>
                    <p style={{ fontSize: '0.9rem', color: '#666', marginBottom: '1rem' }}>
                      Selecione as plantas que este usuário poderá acessar
                    </p>
                    {loading ? (
                      <p>Carregando plantas...</p>
                    ) : plantasDisponiveis.length === 0 ? (
                      <p style={{ color: '#e74c3c' }}>
                        Nenhuma planta disponível. Você precisa ter acesso a pelo menos uma planta para associar usuários.
                      </p>
                    ) : (
                      <div style={{ 
                        display: 'grid', 
                        gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', 
                        gap: '0.75rem',
                        maxHeight: '300px',
                        overflowY: 'auto',
                        padding: '0.5rem'
                      }}>
                        {plantasDisponiveis.map((planta) => (
                          <label
                            key={planta.id}
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              gap: '0.5rem',
                              padding: '0.75rem',
                              border: '1px solid #ddd',
                              borderRadius: '8px',
                              cursor: 'pointer',
                              backgroundColor: plantasSelecionadas.includes(planta.id) ? '#e8f5e9' : 'white',
                              transition: 'all 0.2s'
                            }}
                          >
                            <input
                              type="checkbox"
                              checked={plantasSelecionadas.includes(planta.id)}
                              onChange={() => handleTogglePlanta(planta.id)}
                              disabled={!isEditing && !isAdding}
                            />
                            <span style={{ fontWeight: plantasSelecionadas.includes(planta.id) ? '600' : '400' }}>
                              {planta.nome}
                              {planta.codigo && <span style={{ color: '#666', fontSize: '0.85rem' }}> ({planta.codigo})</span>}
                            </span>
                          </label>
                        ))}
                      </div>
                    )}
                  </div>
                )}

                {!isEditing && !isAdding && selectedUser && (
                  <div className="form-section">
                    <h4>Informações de Acesso</h4>
                    <div className="info-grid">
                      <div className="info-item">
                        <span className="info-label">Status da Conta</span>
                        <span className={`info-badge ${selectedUser.ativo ? 'active' : 'inactive'}`}>
                          {selectedUser.ativo ? 'Ativo' : 'Inativo'}
                        </span>
                      </div>
                      <div className="info-item">
                        <span className="info-label">Último Acesso</span>
                        <span className="info-value">
                          {selectedUser.ultimoAcesso
                            ? format(selectedUser.ultimoAcesso, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })
                            : 'Nunca acessou'}
                        </span>
                      </div>
                      <div className="info-item">
                        <span className="info-label">Nível de Permissão</span>
                        <span className="info-value">{selectedUser.perfil}</span>
                      </div>
                    </div>
                  </div>
                )}

                <div className="permissions-info">
                  <h4>Permissões do Perfil</h4>
                  <div className="permissions-grid">
                    <div className="permission-card">
                      <h5>Administrador</h5>
                      <ul>
                        <li>✓ Acesso total ao sistema</li>
                        <li>✓ Gerenciar usuários</li>
                        <li>✓ Configurar motores</li>
                        <li>✓ Visualizar histórico e alarmes</li>
                        <li>✓ Exportar dados</li>
                      </ul>
                    </div>
                    <div className="permission-card">
                      <h5>Operador</h5>
                      <ul>
                        <li>✓ Operar motores</li>
                        <li>✓ Configurar parâmetros</li>
                        <li>✓ Visualizar histórico</li>
                        <li>✓ Reconhecer alarmes</li>
                        <li>✗ Gerenciar usuários</li>
                      </ul>
                    </div>
                    <div className="permission-card">
                      <h5>Visualizador</h5>
                      <ul>
                        <li>✓ Visualizar dashboard</li>
                        <li>✓ Visualizar motores</li>
                        <li>✓ Visualizar histórico</li>
                        <li>✗ Editar configurações</li>
                        <li>✗ Gerenciar usuários</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
              </>
            ) : null}
          </div>
        )}
      </div>
    </div>
  );
}

export default Users;
