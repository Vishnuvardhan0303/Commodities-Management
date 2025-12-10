import { supabase } from './supabase';
import type { Profile, Product, ProductFormData } from '@/types/types';

// Authentication API
export const authApi = {
  signIn: async (username: string, password: string) => {
    const email = `${username}@miaoda.com`;
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    return data;
  },

  signUp: async (username: string, password: string) => {
    const email = `${username}@miaoda.com`;
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    if (error) throw error;
    return data;
  },

  signOut: async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  },

  getCurrentUser: async () => {
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error) throw error;
    return user;
  },
};

// Profile API
export const profileApi = {
  getProfile: async (userId: string): Promise<Profile | null> => {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();
    
    if (error) throw error;
    return data;
  },

  getAllProfiles: async (): Promise<Profile[]> => {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  },
};

// Product API
export const productApi = {
  getAllProducts: async (): Promise<Product[]> => {
    const { data, error } = await supabase
      .from('products')
      .select('*')
      .order('created_at', { ascending: false });
    
    if (error) throw error;
    return Array.isArray(data) ? data : [];
  },

  getProductById: async (id: string): Promise<Product | null> => {
    const { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    
    if (error) throw error;
    return data;
  },

  createProduct: async (productData: ProductFormData): Promise<Product> => {
    const user = await authApi.getCurrentUser();
    
    const { data, error } = await supabase
      .from('products')
      .insert({
        ...productData,
        created_by: user?.id || null,
      })
      .select()
      .maybeSingle();
    
    if (error) throw error;
    if (!data) throw new Error('Failed to create product');
    return data;
  },

  updateProduct: async (id: string, productData: Partial<ProductFormData>): Promise<Product> => {
    const { data, error } = await supabase
      .from('products')
      .update(productData)
      .eq('id', id)
      .select()
      .maybeSingle();
    
    if (error) throw error;
    if (!data) throw new Error('Failed to update product');
    return data;
  },

  deleteProduct: async (id: string): Promise<void> => {
    const { error } = await supabase
      .from('products')
      .delete()
      .eq('id', id);
    
    if (error) throw error;
  },

  getDashboardStats: async () => {
    const products = await productApi.getAllProducts();
    
    const totalProducts = products.length;
    const totalValue = products.reduce((sum, p) => sum + (p.price * p.quantity), 0);
    const lowStockItems = products.filter(p => p.quantity < 10).length;
    const categories = new Set(products.map(p => p.category)).size;
    
    return {
      totalProducts,
      totalValue,
      lowStockItems,
      categories,
    };
  },
};
