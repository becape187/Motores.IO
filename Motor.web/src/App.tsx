import { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Motors from './pages/Motors';
import History from './pages/History';
import Maintenance from './pages/Maintenance';
import Alarms from './pages/Alarms';
import Users from './pages/Users';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleLogin = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
  };

  return (
    <Router>
      <Routes>
        <Route 
          path="/login" 
          element={
            isAuthenticated ? <Navigate to="/" /> : <Login onLogin={handleLogin} />
          } 
        />
        <Route
          path="/*"
          element={
            isAuthenticated ? (
              <Layout onLogout={handleLogout}>
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
    </Router>
  );
}

export default App;
