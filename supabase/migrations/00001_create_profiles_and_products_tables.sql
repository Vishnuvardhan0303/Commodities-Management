/*
# Create profiles and products tables

## 1. New Tables

### profiles
- `id` (uuid, primary key, references auth.users)
- `username` (text, unique, not null)
- `email` (text, unique, not null)
- `role` (user_role enum: 'manager', 'store_keeper', default: 'store_keeper')
- `created_at` (timestamptz, default: now())

### products
- `id` (uuid, primary key, default: gen_random_uuid())
- `name` (text, not null)
- `category` (text, not null)
- `quantity` (integer, not null, default: 0)
- `unit` (text, not null)
- `price` (numeric(10,2), not null)
- `description` (text)
- `created_by` (uuid, references profiles(id))
- `created_at` (timestamptz, default: now())
- `updated_at` (timestamptz, default: now())

## 2. Security

- Enable RLS on both tables
- Create `is_manager` helper function to check user role
- Profiles policies:
  - Managers have full access to all profiles
  - Users can view their own profile
  - Users can update their own profile (except role)
- Products policies:
  - All authenticated users can view products
  - All authenticated users can insert products
  - All authenticated users can update products
  - Only managers can delete products

## 3. Triggers

- Auto-sync new users to profiles table when confirmed
- First user becomes manager, subsequent users become store_keeper
- Update updated_at timestamp on products table

## 4. Notes

- Using username + password authentication (simulated with @miaoda.com)
- Email verification is disabled
- First registered user automatically becomes manager
*/

-- Create user_role enum
CREATE TYPE user_role AS ENUM ('manager', 'store_keeper');

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  role user_role DEFAULT 'store_keeper'::user_role NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  quantity integer NOT NULL DEFAULT 0,
  unit text NOT NULL,
  price numeric(10,2) NOT NULL,
  description text,
  created_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create helper function to check if user is manager
CREATE OR REPLACE FUNCTION is_manager(uid uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles p
    WHERE p.id = uid AND p.role = 'manager'::user_role
  );
$$;

-- Profiles policies
CREATE POLICY "Managers have full access to profiles" ON profiles
  FOR ALL TO authenticated
  USING (is_manager(auth.uid()));

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile without changing role" ON profiles
  FOR UPDATE TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (role IS NOT DISTINCT FROM (SELECT role FROM profiles WHERE id = auth.uid()));

-- Products policies
CREATE POLICY "Authenticated users can view all products" ON products
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert products" ON products
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update products" ON products
  FOR UPDATE TO authenticated
  USING (true);

CREATE POLICY "Only managers can delete products" ON products
  FOR DELETE TO authenticated
  USING (is_manager(auth.uid()));

-- Create trigger function to sync new users to profiles
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  user_count int;
  user_email text;
  user_name text;
BEGIN
  SELECT COUNT(*) INTO user_count FROM profiles;
  
  -- Extract username from email (before @)
  user_email := NEW.email;
  user_name := split_part(user_email, '@', 1);
  
  INSERT INTO profiles (id, username, email, role)
  VALUES (
    NEW.id,
    user_name,
    user_email,
    CASE WHEN user_count = 0 THEN 'manager'::user_role ELSE 'store_keeper'::user_role END
  );
  
  RETURN NEW;
END;
$$;

-- Create trigger to auto-sync users
DROP TRIGGER IF EXISTS on_auth_user_confirmed ON auth.users;
CREATE TRIGGER on_auth_user_confirmed
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  WHEN (OLD.confirmed_at IS NULL AND NEW.confirmed_at IS NOT NULL)
  EXECUTE FUNCTION handle_new_user();

-- Create trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Create trigger for products updated_at
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create public_profiles view for shareable info
CREATE VIEW public_profiles AS
SELECT
  id,
  username,
  role,
  created_at
FROM profiles;