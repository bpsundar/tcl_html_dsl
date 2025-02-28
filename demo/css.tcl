#### base
# /* Define the base styles */
variable base_styles {
    :root {
	--primary: #2D3047;
	--sidebar-bg: #f8f9fa;
	--text: #666;
	--border: #eee;
	--hover: rgba(0, 0, 0, 0.05);
    }
    
    * {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
    }
    
    body, html {
	height: 100%;
	font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
}

#### dashboard
# /* Define dashboard-specific styles */
variable dashboard_styles {
    .dashboard {
	display: grid;
	grid-template-columns: 250px 1fr;
	height: 100%;
    }
    
    .sidebar {
	background: var(--sidebar-bg);
	padding: 2rem 1rem;
	border-right: 1px solid var(--border);
    }
    
    .nav-menu {
	display: flex;
	flex-direction: column;
	gap: 0.5rem;
    }
    
    .nav-link {
	display: block;
	padding: 0.75rem 1rem;
	color: var(--text);
	text-decoration: none;
	border-radius: 6px;
	transition: all 0.2s ease;
    }
    
    .nav-link:hover {
	background: var(--hover);
	color: var(--primary);
    }
    
    .nav-link.active {
	background: var(--primary);
	color: white;
    }

    .nav-link .icon {
	width: 16px;
	height: 16px;
	margin-right: 8px; /* Space between icon and text */
	fill: currentColor; /* Match icon color to text */
    }

    .nav-link span {
	flex-grow: 1; /* Ensure text aligns well */
    }
    
    .content {
	padding: 2rem;
	overflow-y: auto;
    }
    
    .content-header {
	margin-bottom: 2rem;
    }
    
    .card-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 2rem;
    }
    
    @media (max-width: 768px) {
	.dashboard {
	    grid-template-columns: 1fr;
	}
	
	.sidebar {
	    display: none;
	}
    }
}

#### form
variable field_styles {
    .form-field {
	margin-bottom: 1.5rem;
    }
    .field-label {
	display: block;
	font-size: 0.875rem;
	font-weight: 500;
	margin-bottom: 0.5rem;
	color: var(--primary, #2D3047);
    }
    .field-input {
	width: 100%;
	padding: 0.75rem;
	font-size: 1rem;
	border: 1px solid var(--border, #eee);
	border-radius: 6px;
	background: white;
	transition: border-color 0.2s ease, box-shadow 0.2s ease;
    }
    .field-input:focus {
	outline: none;
	border-color: var(--primary, #2D3047);
	box-shadow: 0 0 0 3px rgba(45, 48, 71, 0.1);
    }
    .field-hint {
	font-size: 0.75rem;
	margin-top: 0.5rem;
	color: var(--text, #666);
    }
    .field-error {
	color: var(--error, #dc3545);
	font-size: 0.75rem;
	margin-top: 0.5rem;
    }
}

variable form_styles {
    .form {
	max-width: 32rem;
	margin: 0 auto;
    }
    .form-title {
	font-size: 1.5rem;
	font-weight: 600;
	margin-bottom: 1.5rem;
	color: var(--primary, #2D3047);
    }
    .form-description {
	color: var(--text, #666);
	margin-bottom: 2rem;
    }
    .form-submit {
	background: var(--primary, #2D3047);
	color: white;
	border: none;
	border-radius: 6px;
	padding: 0.75rem 1.5rem;
	font-size: 1rem;
	font-weight: 500;
	cursor: pointer;
	transition: background-color 0.2s ease;
    }
    .form-submit:hover {
	background-color: var(--primary-dark, #1a1c2e);
    }
}

#### card
variable card_styles {
    .card {
	background: white;
	border-radius: 8px;
	padding: 1.5rem;
	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
	transition: transform 0.2s ease;
    }
    .card:hover {
	transform: translateY(-2px);
    }
    .card-title {
	font-size: 1.25rem;
	font-weight: 600;
	margin: 0 0 1rem 0;
	color: var(--primary, #2D3047);
    }
    .card-content {
	color: var(--text, #666);
	line-height: 1.6;
    }
    .card-footer {
	margin-top: 1.5rem;
	padding-top: 1rem;
	border-top: 1px solid #eee;
    }
}

#### table
variable table_styles {
    .table-container {
        overflow-x: auto;
        margin: 1rem 0;
    }
    .table {
        width: 100%;
        border-collapse: collapse;
        background: white;
    }
    .table th {
        background: var(--primary-light, #f5f6f9);
        text-align: left;
        padding: 1rem;
        font-weight: 600;
        color: var(--primary, #2D3047);
    }
    .table td {
        padding: 1rem;
        border-bottom: 1px solid var(--border, #eee);
        color: var(--text, #666);
    }
    .table tr:hover {
        background: var(--hover, #f9f9f9);
    }
}

#### select
variable select_styles {
    .select-container {
        position: relative;
        width: 100%;
    }
    .select-label {
        display: block;
        font-size: 0.875rem;
        font-weight: 500;
        margin-bottom: 0.5rem;
        color: var(--primary, #2D3047);
    }
    .select {
	width: 100%;
	padding: 0.75rem;
	padding-right: 2.5rem; # Added extra padding for arrow
	font-size: 1rem;
	border: 1px solid var(--border, #eee);
	border-radius: 6px;
	background: white;
	background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23666666' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
	background-repeat: no-repeat;
	background-position: right 0.75rem center;
	cursor: pointer;
	appearance: none;
    }
    .select:focus {
        outline: none;
        border-color: var(--primary, #2D3047);
        box-shadow: 0 0 0 3px rgba(45, 48, 71, 0.1);
    }
}

#### pagination
# Basic styles for demonstration
variable table_pa_styles {
    .table-container { width: 100%; margin: 20px 0; }
    .table { width: 100%; border-collapse: collapse; }
    .table th, .table td { padding: 8px; border: 1px solid #ddd; }
    .table th { background-color: #f5f5f5; }
    .pagination-controls { display: flex; gap: 5px; margin-top: 15px; justify-content: center; }
    .pagination-btn { padding: 5px 10px; border: 1px solid #ddd; background: white; cursor: pointer; }
    .pagination-btn.active { background: #007bff; color: white; }
    .pagination-btn.disabled { opacity: 0.5; cursor: not-allowed; }
    .pagination-ellipsis { padding: 5px 10px; }
    .table-info { margin-bottom: 10px; }
}

#### icons
set icon_style {
    .icon {width: 16px; height: 16px; }
}

#### tabs
variable tab_styles {
    .tabs { margin: 20px 0; }
    .tab-list { border-bottom: 1px solid #ccc; }
    .tab { 
	padding: 10px 20px;
	border: none;
	background: none;
	cursor: pointer;
    }
    .tab.selected { 
	border-bottom: 2px solid blue;
    }
    .tab-panel { padding: 20px 0; }
}
