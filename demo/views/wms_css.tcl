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
##### card3
variable card_3_styles {
    .card-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 2rem;
	padding: 2rem;
    }
  .rental-card {
	background-color: white;
	border-radius: 8px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
	overflow: hidden;
    }

    .card-title {
	background-color: #2196F3;
	color: white;
	margin: 0;
	padding: 12px 16px;
	font-size: 16px;
	font-weight: 500;
	display: flex;
	align-items: center;
    }

    .card-title::before {
	content: "";
	display: inline-block;
	width: 18px;
	height: 18px;
	background-color: white;
	margin-right: 8px;
	-webkit-mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M19 4h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 20a2 2 0 0 0 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V10h14v10zM5 8V6h14v2H5z'/%3E%3C/svg%3E") center/contain no-repeat;
	mask: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath d='M19 4h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 20a2 2 0 0 0 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V10h14v10zM5 8V6h14v2H5z'/%3E%3C/svg%3E") center/contain no-repeat;
    }

    .card-amount {
	font-size: 22px;
	font-weight: bold;
	text-align: right;
	padding: 16px 16px 8px;
    }

    .breakdown {
	padding: 0 16px 16px;
	border-top: 1px solid #eee;
    }

    .breakdown-item {
	display: flex;
	justify-content: space-between;
	padding: 8px 0;
	font-size: 14px;
	color: #666;
    }

    .breakdown-item.pre-tax {
	border-bottom: 1px solid #eee;
	padding-bottom: 12px;
	margin-bottom: 4px;
    }

    .breakdown-item.total {
	font-weight: bold;
	color: #333;
	border-top: 1px solid #eee;
	padding-top: 12px;
	margin-top: 4px;
    }

    .breakdown-item .label {
	font-weight: normal;
    }

    .breakdown-item.pre-tax .label,
    .breakdown-item.total .label {
	font-weight: 500;
    }

    .breakdown-item .amount {
	text-align: right;
    }
}

##### card2
variable form_card_styles {
    .card-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 2rem;
	padding: 2rem;
    }
    .card {
        border: 1px solid #ddd;
        border-radius: 8px;
        padding: 1rem;
        max-width: 300px;
        background: #fff;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        font-family: Arial, sans-serif;
    }
    .form-card {
        justify-self: start;
        width: 600px;  /* Match max-width to prevent stretching */
    }
    .card-tabs {
        display: flex;
        gap: 1rem;
        border-bottom: 1px solid #ddd;
        margin-bottom: 1rem;
    }
    .tab {
        padding: 0.5rem 0;
        color: #757575;
        font-size: 0.9rem;
        cursor: pointer;
    }
    .tab.active {
        color: #d32f2f;
        border-bottom: 2px solid #d32f2f;
    }
    .card-title {
        font-size: 1.2rem;
        font-weight: bold;
        margin: 1rem 0 0.5rem;
    }
    form {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
    }
    select, input {
        width: 100%;
        padding: 0.5rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 0.9rem;
        color: #333;
    }
    select {
        appearance: none;
        background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="10" height="5" viewBox="0 0 10 5"><path fill="#757575" d="M0 0h10L5 5z"/></svg>') no-repeat right 0.5rem center;
        background-size: 10px;
    }
    input[type="date"] {
        color: #757575;
    }
    label {
        font-size: 0.9rem;
        color: #757575;
    }
    .card-buttons {
        display: flex;
        gap: 0.5rem;
        margin-top: 1rem;
    }
    button {
        padding: 0.5rem 1rem;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.9rem;
    }
    button.add-property {
        color: #ab47bc;
        background: none;
    }
    button.save {
        background: #ab47bc;
        color: white;
    }
}

##### card1
variable card_1_styles {
    .card-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 2rem;
	padding: 2rem;
    }
    
    .card {
	background-color: white;
	border-radius: 8px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
	padding: 16px;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
    }

    .card-header {
	display: flex;
	flex-direction: column;
    }

    .card-title {
	font-size: 16px;
	font-weight: bold;
	color: #333;
	margin: 0 0 4px 0;
	text-transform: uppercase;
    }

    .card-seller {
	font-size: 14px;
	color: #666;
	margin: 0 0 16px 0;
    }

    .card-date {
	font-size: 14px;
	color: #666;
	margin-bottom: 12px;
    }

    .card-amount {
	font-size: 18px;
	font-weight: bold;
	margin: 0 0 12px 0;
    }

    .progress-bar {
	height: 24px;
	border-radius: 4px;
	margin-bottom: 8px;
    }
    
    .progress-remaining {
	font-size: 13px;
	color: #666;
	margin: 8px 0 24px 0;
    }

    .status-item {
	display: flex;
	align-items: center;
	margin-bottom: 16px;
	gap: 12px;
    }

    .status-dot {
	display: inline-block;
	width: 20px;
	height: 20px;
	background-color: #aaa;
	border-radius: 50%;
    }

    .card-buttons {
	display: flex;
	justify-content: space-between;
	margin-top: 16px;
	border-top: 1px solid #eee;
	padding-top: 16px;
    }

    button {
	background: none;
	border: none;
	text-transform: uppercase;
	font-size: 14px;
	font-weight: 500;
	cursor: pointer;
    }

    button.send {
	color: #b066ff;
    }

    button.edit {
	color: #b066ff;
    }
}
# .progress-bar {
#   height: 24px;
#   background: linear-gradient(to right, #ff8c00 60%, #ffb347 60%);
#   border-radius: 4px;
#   margin-bottom: 8px;
# }

# variable card_styles {
#     .card {
# 	background: white;
# 	border-radius: 8px;
# 	padding: 1.5rem;
# 	box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
# 	transition: transform 0.2s ease;
#     }
#     .card:hover {
# 	transform: translateY(-2px);
#     }
#     .card-title {
# 	font-size: 1.25rem;
# 	font-weight: 600;
# 	margin: 0 0 1rem 0;
# 	color: var(--primary, #2D3047);
#     }
#     .card-content {
# 	color: var(--text, #666);
# 	line-height: 1.6;
#     }
#     .card-footer {
# 	margin-top: 1.5rem;
# 	padding-top: 1rem;
# 	border-top: 1px solid #eee;
#     }
# }

##### card
variable card_styles {
    .card-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
	gap: 2rem;
	padding: 2rem;
    }
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
    .pagination-table {
        width: 100%;
        border-collapse: collapse;
        font-family: Arial, sans-serif;
    }
    .pagination-table th {
        background-color: #f4f4f4;
        padding: 0.75rem;
        text-align: left;
        border-bottom: 2px solid #ddd;
    }
    .pagination-table td {
        padding: 0.75rem;
        border-bottom: 1px solid #ddd;
    }
    .pagination-table tr:nth-child(even) {
        background-color: #f9f9f9;
    }
    .pagination-table tr:hover {
        background-color: #f1f1f1;
    }
    .pagination-nav {
        margin-top: 1rem;
        display: flex;
        gap: 1rem;
        justify-content: center;
        align-items: center;
    }
    .pagination-nav a {
        text-decoration: none;
        color: #007bff;
        padding: 0.5rem 1rem;
        border: 1px solid #007bff;
        border-radius: 4px;
    }
    .pagination-nav a:hover {
        background-color: #007bff;
        color: white;
    }
    .pagination-nav span {
        font-weight: bold;
    }
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
#### ad_styles
variable ad_styles {
        .ad-container { text-align: center; padding: 2rem; background: #1c2526; color: white; font-family: Arial }
        .ad-title { font-size: 2rem; font-weight: bold; text-transform: uppercase }
        .ad-subtitle { font-size: 1.2rem; margin: 1rem 0 }
        .ad-image { max-width: 300px; margin: 1rem auto }
        .ad-cta { background: #ff0000; color: white; padding: 0.5rem 1rem; text-decoration: none }
}

#### todos
variable todos {
    .todos {
	max-width: 400px;
	margin: 20px auto;
	font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
	background-color: #f4f4f4;
	padding: 20px;
	border-radius: 8px;
	box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .todos form {
	display: flex;
	margin-bottom: 15px;
    }

    .todos input[type="text"] {
	flex-grow: 1;
	padding: 10px;
	border: 1px solid #ddd;
	border-radius: 4px 0 0 4px;
	font-size: 16px;
    }

    .todos button {
	padding: 10px 15px;
	background-color: #4CAF50;
	color: white;
	border: none;
	border-radius: 0 4px 4px 0;
	cursor: pointer;
	font-size: 16px;
	transition: background-color 0.3s ease;
    }

    .todos button:hover {
	background-color: #45a049;
    }

    .todos button:disabled {
	background-color: #cccccc;
	cursor: not-allowed;
    }

    .todos > button {
	display: block;
	width: 100%;
	margin-bottom: 15px;
	border-radius: 4px;
    }

    .icon {width: 16px; height: 16px;}
    .invisible { display: none; }
    .group:hover .visible { display: block; margin-left: auto; }
    .todo-container {
	max-width: 400px;
    }
    .group {
	display: flex;
	align-items: center;
	gap: 2rem;
	flex-direction: row;
    }

}

#### movie
variable movie_style {
    .main {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	min-height: 100vh;
	--s: 30px;
	--r: 1;
	--m: 1px;
	--mh: var(--m);
    }
    .button {
	padding: 10px 15px;
	background-color: #4CAF50;
	color: white;
	border: none;
	border-radius: 0 4px 4px 0;
	cursor: pointer;
	font-size: 16px;
	transition: background-color 0.3s ease;
    }

    .counter {
	font-size: calc(var(--s) * 0.8);
	margin-bottom: 10px;
	font-family: Arial, sans-serif;
    }

    .container {
	font-size: 0;
	display: flex;
	flex-wrap: wrap;
	width: calc((var(--s) + 2 * var(--m)) * var(--columns) + 2 * 10px); /* Dynamic columns */
	height: calc((var(--s) + 2 * var(--m)) * var(--rows) + 2 * 10px); /* Dynamic rows */
	background: #f0f0f0;
	padding: 10px;
	box-sizing: border-box;
	background-image: linear-gradient(to right, #ccc 1px, transparent 1px),
	linear-gradient(to bottom, #ccc 1px, transparent 1px);
	background-size: calc(var(--s) + 2 * var(--m)) calc(var(--s) + 2 * var(--m));
	background-position: 10px 10px;
    }

    .container .rows {
	display: block;
    }

    .container input.seat {
	width: var(--s);
	height: calc(var(--s) * var(--r));
	margin: var(--m);
	display: inline-block;
	appearance: none;
	border: 1px solid black;
	background: white;
	position: relative;
	box-sizing: border-box;
    }

    .container input.seat.flagged::after {
	content: "🚩";
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	font-size: calc(var(--s) * 0.7);
    }
    .container input.seat.hidden {
	visibility: hidden;
    }
    .container input.seat.disabled {
	background: #e0e0e0; /* Gray background for disabled seats */
	cursor: not-allowed;
	pointer-events: none;
    }
    .container input.gameover {
	background: #e0e0e0; /* Gray background for disabled seats */
	cursor: not-allowed;
	pointer-events: none;
    }
	
    .container input.seat.revealed::after {
	content: attr(content);
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	font-size: calc(var(--s) * 0.7);
	color: blue;
    }
    .container input.seat.revealed[content="m"]::after {
	content: "💣";
	color: red;
    }
    .container input.seat.revealed[content="f"]::after {
	content: "😎";
	color: red;  
    }

}
