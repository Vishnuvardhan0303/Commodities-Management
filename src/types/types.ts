export type UserRole = 'manager' | 'store_keeper';

export interface Profile {
  id: string;
  username: string;
  email: string;
  role: UserRole;
  created_at: string;
}

export interface Product {
  id: string;
  name: string;
  category: string;
  quantity: number;
  unit: string;
  price: number;
  description: string | null;
  created_by: string | null;
  created_at: string;
  updated_at: string;
}

export interface ProductFormData {
  name: string;
  category: string;
  quantity: number;
  unit: string;
  price: number;
  description?: string;
}

export interface DashboardStats {
  totalProducts: number;
  totalValue: number;
  lowStockItems: number;
  categories: number;
}
