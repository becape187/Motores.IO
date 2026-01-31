import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { MotorsCacheProvider } from './contexts/MotorsCacheContext';
import Login from './pages/Login';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Motors from './pages/Motors';
import History from './pages/History';
import Maintenance from './pages/Maintenance';
import Alarms from './pages/Alarms';
import Users from './pages/Users';
import './App.css';

function AppRoutes() {
  const { isAuthenticated, logout } = useAuth();

  return (
    <Routes>
      <Route 
        path="/login" 
        element={
          isAuthenticated ? <Navigate to="/" /> : <Login />
        } 
      />
      <Route
        path="/*"
        element={
          isAuthenticated ? (
            <Layout onLogout={logout}>
              <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/motors" element={<Motors />} />
                <Route path="/history" element={<History />} />
                <Route path="/maintenance" element={<Maintenance />} />
                <Route path="/alarms" element={<Alarms />} />
                <Route path="/users" element={<Users />} />
              </Routes>
            </Layout>
          ) : (
            <Navigate to="/login" />
          )
        }
      />
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <MotorsCacheProvider>
        <Router>
          <AppRoutes />
        </Router>
      </MotorsCacheProvider>
    </AuthProvider>
  );
}

export default App;
