import { Navigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { Loader2 } from 'lucide-react';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiresManager?: boolean;
}

export default function ProtectedRoute({ children, requiresManager = false }: ProtectedRouteProps) {
  const { user, profile, loading, isManager } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (requiresManager && !isManager) {
    return <Navigate to="/products" replace />;
  }

  return <>{children}</>;
}
