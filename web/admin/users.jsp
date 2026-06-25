<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("Administrator")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "users");

    List<Users> users = (List<Users>) request.getAttribute("users");
    if (users == null) users = new ArrayList<>();

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    // Count by role
    long admins   = users.stream().filter(u -> "Administrator".equals(u.getRole())).count();
    long managers = users.stream().filter(u -> "Technical_Manager".equals(u.getRole())).count();
    long doctors  = users.stream().filter(u -> "Doctor".equals(u.getRole())).count();
    long nurses   = users.stream().filter(u -> "Nurse".equals(u.getRole())).count();
    long active   = users.stream().filter(u -> u.isActive()).count();
    long inactive = users.stream().filter(u -> !u.isActive()).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — User Management</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
/* ── USERS PAGE EXTRAS ─────────────────────────────── */

/* Animated gradient header */
.users-hero {
    position: relative;
    background: linear-gradient(135deg, #021B2F 0%, #0B385A 50%, #1C8BC0 100%);
    border-radius: 14px;
    padding: 1.8rem 2rem;
    margin-bottom: 1.5rem;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
}

.users-hero::before {
    content: '';
    position: absolute;
    top: -60px; right: -60px;
    width: 220px; height: 220px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(45,186,225,0.2), transparent 70%);
    animation: pulse-glow 4s ease-in-out infinite;
}

.users-hero::after {
    content: '';
    position: absolute;
    bottom: -40px; left: 30%;
    width: 140px; height: 140px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(144,230,255,0.08), transparent 70%);
    animation: pulse-glow 4s ease-in-out infinite reverse;
}

@keyframes pulse-glow {
    0%, 100% { transform: scale(1); opacity: 0.6; }
    50%       { transform: scale(1.15); opacity: 1; }
}

.hero-left h1 {
    font-size: 1.5rem;
    font-weight: 700;
    color: #fff;
    margin-bottom: 4px;
    letter-spacing: -0.3px;
}

.hero-left p {
    font-size: 0.8rem;
    color: rgba(144,230,255,0.7);
    font-family: 'Space Mono', monospace;
}

.hero-right {
    display: flex;
    gap: 0.6rem;
    flex-shrink: 0;
    position: relative;
    z-index: 2;
}

/* Role pill stats */
.role-strip {
    display: flex;
    gap: 0.75rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}

.role-pill {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 0.5rem 1rem;
    border-radius: 30px;
    border: 1px solid transparent;
    font-size: 0.78rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    background: var(--bg-card);
    position: relative;
    overflow: hidden;
}

.role-pill::before {
    content: '';
    position: absolute;
    inset: 0;
    opacity: 0;
    transition: opacity 0.2s;
}

.role-pill:hover::before { opacity: 1; }
.role-pill:hover { transform: translateY(-2px); box-shadow: 0 4px 14px rgba(0,0,0,0.1); }

.role-pill .count {
    font-family: 'Space Mono', monospace;
    font-size: 0.85rem;
    font-weight: 700;
}

.role-pill.all    { border-color: var(--cyan);    color: var(--cyan);    }
.role-pill.admin  { border-color: #8b5cf6;        color: #8b5cf6;        }
.role-pill.manager{ border-color: var(--blue);    color: var(--blue);    }
.role-pill.doctor { border-color: var(--success); color: var(--success); }
.role-pill.nurse  { border-color: var(--warning); color: var(--warning); }
.role-pill.active-pill  { border-color: #22c55e; color: #22c55e; }
.role-pill.inactive-pill{ border-color: #ef4444; color: #ef4444; }

.role-pill.selected { color: #fff !important; }
.role-pill.all.selected     { background: var(--cyan);    border-color: var(--cyan); }
.role-pill.admin.selected   { background: #8b5cf6;        border-color: #8b5cf6; }
.role-pill.manager.selected { background: var(--blue);    border-color: var(--blue); }
.role-pill.doctor.selected  { background: var(--success); border-color: var(--success); }
.role-pill.nurse.selected   { background: var(--warning); border-color: var(--warning); }

/* Toolbar */
.toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 1rem;
    flex-wrap: wrap;
}

.toolbar-left { display: flex; align-items: center; gap: 0.6rem; }
.toolbar-right { display: flex; align-items: center; gap: 0.6rem; }

/* View toggle */
.view-toggle {
    display: flex;
    background: var(--bg-page);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 3px;
    gap: 2px;
}

.view-btn {
    width: 32px; height: 32px;
    display: flex; align-items: center; justify-content: center;
    border-radius: 6px;
    border: none;
    background: transparent;
    color: var(--text-muted);
    cursor: pointer;
    transition: all 0.2s;
}

.view-btn svg { width: 15px; height: 15px; }
.view-btn.active { background: var(--bg-card); color: var(--cyan); box-shadow: 0 1px 4px rgba(0,0,0,0.08); }

/* Search */
.search-box {
    position: relative;
    display: flex;
    align-items: center;
}

.search-box svg {
    position: absolute;
    left: 10px;
    width: 15px; height: 15px;
    color: var(--text-muted);
    pointer-events: none;
}

.search-box input {
    height: 36px;
    padding: 0 12px 0 34px;
    border: 1px solid var(--border);
    border-radius: 8px;
    font-family: 'Sora', sans-serif;
    font-size: 0.82rem;
    color: var(--text);
    background: var(--bg-card);
    outline: none;
    width: 240px;
    transition: all 0.2s;
}

.search-box input:focus {
    border-color: var(--cyan);
    box-shadow: 0 0 0 3px rgba(45,186,225,0.1);
    width: 280px;
}

/* ── USER CARDS GRID ──────────────────────────────── */
.users-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 1rem;
}

.user-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 1.4rem;
    transition: all 0.25s;
    position: relative;
    overflow: hidden;
    animation: card-in 0.4s ease both;
}

@keyframes card-in {
    from { opacity: 0; transform: translateY(16px); }
    to   { opacity: 1; transform: translateY(0); }
}

.user-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
    border-radius: 14px 14px 0 0;
    transition: opacity 0.2s;
}

.user-card.role-Administrator::before {
    background: linear-gradient(90deg, #8b5cf6, #a78bfa); 
}
.user-card.role-Technical_Manager::before { 
    background: linear-gradient(90deg, var(--blue), var(--cyan)); 
}
.user-card.role-Doctor::before { 
    background: linear-gradient(90deg, #22c55e, #86efac); 
}
.user-card.role-Nurse::before  {
    background: linear-gradient(90deg, #f59e0b, #fcd34d); 
}

.user-card:hover {
    box-shadow: 0 8px 32px rgba(2,27,47,0.12);
    transform: translateY(-3px);
    border-color: var(--cyan);
}

.user-card.inactive-card { 
    opacity: 0.6; 
}
.user-card.inactive-card:hover { 
    opacity: 1; 
}

/* Card header */
.card-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 1rem;
}

.user-avatar-lg {
    width: 48px; height: 48px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.2rem;
    font-weight: 700;
    color: #fff;
    flex-shrink: 0;
    position: relative;
}

.user-avatar-lg.role-Administrator {
    background: linear-gradient(135deg, #7c3aed, #a78bfa);
}
.user-avatar-lg.role-Technical_Manager { background: linear-gradient(135deg, var(--navy), var(--blue)); }
.user-avatar-lg.role-Doctor  { background: linear-gradient(135deg, #15803d, #22c55e); }
.user-avatar-lg.role-Nurse   { background: linear-gradient(135deg, #b45309, #f59e0b); }

.status-dot {
    position: absolute;
    bottom: -2px; right: -2px;
    width: 12px; height: 12px;
    border-radius: 50%;
    border: 2px solid var(--bg-card);
}
.status-dot.active   { background: #22c55e; }
.status-dot.inactive { background: #ef4444; }

/* Card body */
.user-name {
    font-size: 0.95rem;
    font-weight: 700;
    color: var(--text);
    margin-bottom: 2px;
}

.user-login {
    font-size: 0.72rem;
    color: var(--text-muted);
    font-family: 'Space Mono', monospace;
    margin-bottom: 0.6rem;
}

.user-email {
    font-size: 0.75rem;
    color: var(--text-muted);
    margin-bottom: 0.8rem;
    display: flex;
    align-items: center;
    gap: 5px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.user-email svg { width: 12px; height: 12px; flex-shrink: 0; }

/* Role badge on card */
.role-tag {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.67rem;
    font-weight: 600;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    margin-bottom: 1rem;
}

.role-tag.role-Administrator { background: rgba(139,92,246,0.12); color: #7c3aed; }
.role-tag.role-Technical_Manager { background: rgba(28,139,192,0.12); color: var(--blue); }
.role-tag.role-Doctor { background: rgba(34,197,94,0.12); color: #15803d; }
.role-tag.role-Nurse  { background: rgba(245,158,11,0.12); color: #b45309; }

/* Card actions */
.card-actions {
    display: flex;
    gap: 0.4rem;
    padding-top: 0.8rem;
    border-top: 1px solid var(--border);
}

.card-actions .btn { flex: 1; justify-content: center; font-size: 0.72rem; padding: 0.35rem 0.5rem; }

/* ── TABLE VIEW ──────────────────────────────────── */
.users-table-wrap {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: 14px;
    overflow: hidden;
    box-shadow: var(--shadow);
}

.users-table-wrap table { margin: 0; }

.user-row-avatar {
    width: 34px; height: 34px;
    border-radius: 9px;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.85rem;
    font-weight: 700;
    color: #fff;
    flex-shrink: 0;
}

.user-row-avatar.role-Administrator { background: linear-gradient(135deg, #7c3aed, #a78bfa); }
.user-row-avatar.role-Technical_Manager { background: linear-gradient(135deg, var(--navy), var(--blue)); }
.user-row-avatar.role-Doctor  { background: linear-gradient(135deg, #15803d, #22c55e); }
.user-row-avatar.role-Nurse   { background: linear-gradient(135deg, #b45309, #f59e0b); }

.user-info-cell { display: flex; align-items: center; gap: 10px; }
.user-info-cell .name { font-weight: 600; font-size: 0.85rem; color: var(--text); }
.user-info-cell .login { font-size: 0.72rem; color: var(--text-muted); font-family: 'Space Mono', monospace; }

.status-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.7rem;
    font-weight: 600;
}

.status-badge::before {
    content: '';
    width: 6px; height: 6px;
    border-radius: 50%;
}

.status-badge.active   { background: rgba(34,197,94,0.1);  color: #15803d; }
.status-badge.active::before  { background: #22c55e; }
.status-badge.inactive { background: rgba(239,68,68,0.1); color: #dc2626; }
.status-badge.inactive::before{ background: #ef4444; }

/* Actions dropdown */
.actions-cell { display: flex; align-items: center; gap: 0.35rem; }
.icon-btn {
    width: 30px; height: 30px;
    border-radius: 7px;
    display: flex; align-items: center; justify-content: center;
    border: 1px solid var(--border);
    background: transparent;
    color: var(--text-muted);
    cursor: pointer;
    transition: all 0.18s;
    text-decoration: none;
}
.icon-btn svg { width: 13px; height: 13px; }
.icon-btn:hover { border-color: var(--cyan); color: var(--cyan); background: rgba(45,186,225,0.06); }
.icon-btn.danger:hover { border-color: var(--danger); color: var(--danger); background: rgba(239,68,68,0.06); }
.icon-btn.success:hover { border-color: var(--success); color: var(--success); background: rgba(34,197,94,0.06); }

/* Empty state unique */
.empty-users {
    text-align: center;
    padding: 5rem 1rem;
}

.empty-users .empty-icon {
    width: 80px; height: 80px;
    background: linear-gradient(135deg, rgba(45,186,225,0.1), rgba(28,139,192,0.05));
    border-radius: 20px;
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 1rem;
    border: 1px solid rgba(45,186,225,0.15);
}

.empty-users .empty-icon svg { width: 36px; height: 36px; color: var(--cyan); opacity: 0.5; }
.empty-users h3 { font-size: 1rem; font-weight: 600; color: var(--text); margin-bottom: 4px; }
.empty-users p  { font-size: 0.82rem; color: var(--text-muted); }

/* Hidden rows for filter */
.user-row[data-hidden="true"] { display: none; }
.user-card[data-hidden="true"] { display: none; }

/* Count indicator */
.result-count {
    font-size: 0.75rem;
    color: var(--text-muted);
    font-family: 'Space Mono', monospace;
    padding: 0.4rem 0.8rem;
    background: var(--bg-page);
    border: 1px solid var(--border);
    border-radius: 20px;
}
</style>
</head>
<body>
<div class="app">

    <%@ include file="sidebar.jsp" %>

    <div class="main">

        <!-- TOP BAR -->
        <div class="topbar">
            <div class="topbar-left">
                <div class="topbar-breadcrumb">
                    <span>ME2MS</span>
                    <span class="sep">/</span>
                    <span style="color:var(--text);font-weight:600;">User Management</span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:0.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                    <%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %>
                </span>
            </div>
        </div>

        <!-- CONTENT -->
        <div class="content">

            <!-- Flash messages -->
            <% if (successMsg != null) { %>
            <div class="flash flash-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                <%= successMsg %>
            </div>
            <% } %>
            <% if (errorMsg != null) { %>
            <div class="flash flash-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <%= errorMsg %>
            </div>
            <% } %>

            <!-- HERO BANNER -->
            <div class="users-hero">
                <div class="hero-left">
                    <h1>👥 User Management</h1>
                    <p>// <%= users.size() %> total · <%= active %> active · <%= inactive %> inactive</p>
                </div>
                <div class="hero-right">
                    <a href="<%= request.getContextPath() %>/users?action=new" class="btn btn-cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Add User
                    </a>
                </div>
            </div>

            <!-- ROLE PILLS FILTER -->
            <div class="role-strip">
                <button class="role-pill all selected" onclick="filterRole('all', this)">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    All
                    <span class="count"><%= users.size() %></span>
                </button>
                <button class="role-pill admin" onclick="filterRole('Administrator', this)">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    Administrators
                    <span class="count"><%= admins %></span>
                </button>
                <button class="role-pill manager" onclick="filterRole('Technical_Manager', this)">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                    Tech Managers
                    <span class="count"><%= managers %></span>
                </button>
                <button class="role-pill doctor" onclick="filterRole('Doctor', this)">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                    Doctors
                    <span class="count"><%= doctors %></span>
                </button>
                <button class="role-pill nurse" onclick="filterRole('Nurse', this)">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                    Nurses
                    <span class="count"><%= nurses %></span>
                </button>
            </div>

            <!-- TOOLBAR -->
            <div class="toolbar">
                <div class="toolbar-left">
                    <div class="search-box">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" id="searchInput" placeholder="Search users..." oninput="searchUsers(this.value)"/>
                    </div>
                    <span class="result-count" id="resultCount"><%= users.size() %> users</span>
                </div>
                <div class="toolbar-right">
                    <div class="view-toggle">
                        <button class="view-btn active" id="gridViewBtn" onclick="setView('grid')" title="Grid view">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                        </button>
                        <button class="view-btn" id="listViewBtn" onclick="setView('list')" title="List view">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
                        </button>
                    </div>
                </div>
            </div>

            <!-- ── GRID VIEW ── -->
            <div id="gridView">
                <% if (users.isEmpty()) { %>
                <div class="empty-users">
                    <div class="empty-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                    <h3>No users found</h3>
                    <p>Create your first user to get started.</p>
                </div>
                <% } else { %>
                <div class="users-grid" id="usersGrid">
                    <% int cardDelay = 0; for (Users u : users) {
                        String initials = u.getFirstName().substring(0,1).toUpperCase() +
                                         (u.getLastName() != null && !u.getLastName().isEmpty() ? u.getLastName().substring(0,1).toUpperCase() : "");
                    %>
                    <div class="user-card role-<%= u.getRole() %> <%= !u.isActive() ? "inactive-card" : "" %>"
                         data-role="<%= u.getRole() %>"
                         data-name="<%= u.getFirstName().toLowerCase() + " " + u.getLastName().toLowerCase() %>"
                         data-login="<%= u.getLogin().toLowerCase() %>"
                         style="animation-delay: <%= cardDelay * 60 %>ms">

                        <div class="card-top">
                            <div class="user-avatar-lg role-<%= u.getRole() %>">
                                <%= initials %>
                                <div class="status-dot <%= u.isActive() ? "active" : "inactive" %>"></div>
                            </div>
                            <div class="role-tag role-<%= u.getRole() %>">
                                <%= u.getRole().replace("_"," ") %>
                            </div>
                        </div>

                        <div class="user-name"><%= u.getFirstName() %> <%= u.getLastName() %></div>
                        <div class="user-login">@<%= u.getLogin() %></div>
                        <div class="user-email">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            <%= u.getEmail() != null && !u.getEmail().isEmpty() ? u.getEmail() : "No email set" %>
                        </div>

                        <div class="card-actions">
                            <a href="<%= request.getContextPath() %>/users?action=edit&id=<%= u.getUserId() %>"
                               class="btn btn-outline btn-sm">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                Edit
                            </a>
                            <% if (u.getUserId() != currentUser.getUserId()) { %>
                                <% if (u.isActive()) { %>
                                <form method="post" action="<%= request.getContextPath() %>/users" style="flex:1;">
                                    <input type="hidden" name="action" value="deactivate"/>
                                    <input type="hidden" name="userId" value="<%= u.getUserId() %>"/>
                                    <button type="submit" class="btn btn-danger btn-sm" style="width:100%;justify-content:center;"
                                            onclick="return confirm('Deactivate <%= u.getFirstName() %>?')">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                                        Deactivate
                                    </button>
                                </form>
                                <% } else { %>
                                <form method="post" action="<%= request.getContextPath() %>/users" style="flex:1;">
                                    <input type="hidden" name="action" value="reactivate"/>
                                    <input type="hidden" name="userId" value="<%= u.getUserId() %>"/>
                                    <button type="submit" class="btn btn-sm" style="width:100%;justify-content:center;background:rgba(34,197,94,0.1);border-color:rgba(34,197,94,0.3);color:#15803d;">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                        Reactivate
                                    </button>
                                </form>
                                <% } %>
                            <% } else { %>
                                <button class="btn btn-sm btn-outline" disabled style="flex:1;justify-content:center;opacity:0.4;cursor:not-allowed;">You</button>
                            <% } %>
                        </div>
                    </div>
                    <% cardDelay++; } %>
                </div>
                <% } %>
            </div>

            <!-- ── LIST VIEW ── -->
            <div id="listView" style="display:none;">
                <div class="users-table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Role</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th style="text-align:right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="usersTableBody">
                            <% if (users.isEmpty()) { %>
                            <tr><td colspan="5">
                                <div class="empty-state"><p>No users yet.</p></div>
                            </td></tr>
                            <% } else { for (Users u : users) {
                                String initials2 = u.getFirstName().substring(0,1).toUpperCase() +
                                                   (u.getLastName() != null && !u.getLastName().isEmpty() ? u.getLastName().substring(0,1).toUpperCase() : "");
                            %>
                            <tr class="user-row"
                                data-role="<%= u.getRole() %>"
                                data-name="<%= u.getFirstName().toLowerCase() + " " + u.getLastName().toLowerCase() %>"
                                data-login="<%= u.getLogin().toLowerCase() %>">
                                <td>
                                    <div class="user-info-cell">
                                        <div class="user-row-avatar role-<%= u.getRole() %>"><%= initials2 %></div>
                                        <div>
                                            <div class="name"><%= u.getFirstName() %> <%= u.getLastName() %></div>
                                            <div class="login">@<%= u.getLogin() %></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="role-tag role-<%= u.getRole() %>">
                                        <%= u.getRole().replace("_"," ") %>
                                    </span>
                                </td>
                                <td style="font-size:0.8rem;color:var(--text-muted);">
                                    <%= u.getEmail() != null && !u.getEmail().isEmpty() ? u.getEmail() : "—" %>
                                </td>
                                <td>
                                    <span class="status-badge <%= u.isActive() ? "active" : "inactive" %>">
                                        <%= u.isActive() ? "Active" : "Inactive" %>
                                    </span>
                                </td>
                                <td>
                                    <div class="actions-cell" style="justify-content:flex-end;">
                                        <a href="<%= request.getContextPath() %>/users?action=edit&id=<%= u.getUserId() %>"
                                           class="icon-btn" title="Edit">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                        </a>
                                        <% if (u.getUserId() != currentUser.getUserId()) { %>
                                            <% if (u.isActive()) { %>
                                            <form method="post" action="<%= request.getContextPath() %>/users" style="display:inline;">
                                                <input type="hidden" name="action" value="deactivate"/>
                                                <input type="hidden" name="userId" value="<%= u.getUserId() %>"/>
                                                <button type="submit" class="icon-btn danger" title="Deactivate"
                                                        onclick="return confirm('Deactivate <%= u.getFirstName() %>?')">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                                                </button>
                                            </form>
                                            <% } else { %>
                                            <form method="post" action="<%= request.getContextPath() %>/users" style="display:inline;">
                                                <input type="hidden" name="action" value="reactivate"/>
                                                <input type="hidden" name="userId" value="<%= u.getUserId() %>"/>
                                                <button type="submit" class="icon-btn success" title="Reactivate">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                                </button>
                                            </form>
                                            <% } %>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /app -->

<script>
// ── View toggle ──────────────────────────────────
let currentView = 'grid';

function setView(view) {
    currentView = view;
    document.getElementById('gridView').style.display = view === 'grid' ? '' : 'none';
    document.getElementById('listView').style.display = view === 'list' ? '' : 'none';
    document.getElementById('gridViewBtn').classList.toggle('active', view === 'grid');
    document.getElementById('listViewBtn').classList.toggle('active', view === 'list');
}

// ── Role filter ──────────────────────────────────
let currentRole = 'all';

function filterRole(role, btn) {
    currentRole = role;

    // Update pill styles
    document.querySelectorAll('.role-pill').forEach(p => p.classList.remove('selected'));
    btn.classList.add('selected');

    applyFilters();
}

// ── Search ───────────────────────────────────────
function searchUsers(query) {
    applyFilters(query);
}

function applyFilters(query) {
    const q = (query !== undefined ? query : document.getElementById('searchInput').value).toLowerCase().trim();

    // Grid cards
    const cards = document.querySelectorAll('.user-card');
    let visibleCount = 0;

    cards.forEach(card => {
        const roleMatch = currentRole === 'all' || card.dataset.role === currentRole;
        const nameMatch = !q || card.dataset.name.includes(q) || card.dataset.login.includes(q);
        const show = roleMatch && nameMatch;
        card.dataset.hidden = !show;
        card.style.display = show ? '' : 'none';
        if (show) visibleCount++;
    });

    // Table rows
    const rows = document.querySelectorAll('.user-row');
    rows.forEach(row => {
        const roleMatch = currentRole === 'all' || row.dataset.role === currentRole;
        const nameMatch = !q || row.dataset.name.includes(q) || row.dataset.login.includes(q);
        row.style.display = (roleMatch && nameMatch) ? '' : 'none';
    });

    document.getElementById('resultCount').textContent = visibleCount + ' user' + (visibleCount !== 1 ? 's' : '');
}
</script>
</body>
</html>
