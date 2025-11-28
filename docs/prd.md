# Commodities Management System Requirements Document

## 1. Project Overview
### 1.1 Project Name\nCommodities Management System

### 1.2 Project Description
A role-based commodities management platform designed to diversify product variety and meet customer expectations. The system features structured access control, comprehensive product management capabilities, and modern UI enhancements.

### 1.3 Target Users
- **Manager**: Full system access with dashboard oversight and complete product management capabilities
- **Store Keeper**: Limited access for viewing and managing product inventory
\n## 2. Core Features
\n### 2.1 Authentication & Access (5 Points)
- User login via email and password
- API endpoint: POST /auth/login
- Secure session storage
- Role-based access validation

### 2.2 Dashboard (30 Points)
- **Access**: Manager only
- Display statistics and insights for commodities
- Overview of operations and key metrics
- Role-based gating to restrict unauthorized access

### 2.3 View All Products (10 Points)
- **Access**: Manager and Store Keeper
- API endpoint: GET /products
- Display comprehensive product listing
- Product information overview
\n### 2.4 Add/Edit Products (15 Points) [Optional]
- **Access**: Manager and Store Keeper
- API endpoints: POST /products, PUT /products
- Form-based product creation and modification
- Product inventory management

### 2.5 Light/Dark Mode (15 Points)\n- Theme switching functionality
- Toggle between light and dark themes
- Persistent theme preference using localStorage
- Consistent styling across all pages

### 2.6 Role-Based Menu Restrictions (Bonus: 25 Points)
- Dynamic menu display based on user role
- Router guards to prevent unauthorized access
- Disabled state for restricted buttons and options
- Real-time UI adaptation to user permissions

## 3. Role-Based Access Matrix

| Feature | Manager | Store Keeper |\n|---------|---------|-------------|
| Login | ✅ | ✅ |\n| Dashboard | ✅ | ❌ |
| View Products | ✅ | ✅ |
| Add/Edit Products | ✅ | ✅ |
| Role-Based UI | ✅ | ✅ |
\n## 4. Implementation Requirements

### 4.1 Login Flow
- Login page with email and password validation
- API request to POST /auth/login
- Secure session detail storage
- Error handling for invalid credentials

### 4.2 Dashboard Flow
- Statistics and insights display
- Role-based access gating
- Manager-only access enforcement
\n### 4.3 Product Management Flow
- Fetch product data via GET /products\n- Add/edit functionality through forms
- API integration for POST/PUT /products operations

### 4.4 UI Enhancement Implementation
- Light/Dark Mode toggle with localStorage persistence
- Role-based UI restrictions for platform features
- Dynamic menu item visibility\n- Router-level access control

## 5. Design Style\n- **Layout**: Clean dashboard-style interface with card-based components for statistics and data tables for product listings
- **Color Scheme**: Professional dual-theme support - light mode with neutral grays and blues, dark mode with deep charcoal backgrounds and accent highlights
- **Navigation**: Role-adaptive sidebar menu with clear visual indicators for active states and disabled options
- **Form Design**: Structured input fields with inline validation feedback and clear action buttons
- **Visual Hierarchy**: Prominent dashboard metrics with iconography, organized product tables with sorting capabilities, and contextual action buttons