<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("Administrator")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "departments");

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    if (departments == null) departments = Department.liste();

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    long activeCount   = departments.stream().filter(Department::isActive).count();
    long inactiveCount = departments.stream().filter(d -> !d.isActive()).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Departments</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
.dept-hero {
    background: linear-gradient(135deg,#021B2F 0%,#0B385A 55%,#1C8BC0 100%);
    border-radius: 14px;
    padding: 1.6rem 2rem;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: relative;
    overflow: hidden;
}
.dept-hero::before {
    content:'';
    position:absolute;
    top:-60px; right:-60px;
    width:200px; height:200px;
    border-radius:50%;
    background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%);
    animation:glow 4s ease-in-out infinite;
}
@keyframes glow { 0%,100%{transform:scale(1);opacity:.6;} 50%{transform:scale(1.1);opacity:1;} }
.dept-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.dept-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }

.dept-stats { display:flex; gap:0.8rem; margin-bottom:1.5rem; flex-wrap:wrap; }
.dept-stat  { background:var(--bg-card); border:1px solid var(--border); border-radius:10px; padding:0.8rem 1.2rem; display:flex; align-items:center; gap:10px; box-shadow:var(--shadow); min-width:130px; }
.dept-stat-icon { width:34px; height:34px; border-radius:8px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.dept-stat-icon svg { width:16px; height:16px; }
.dept-stat-icon.cyan  { background:rgba(45,186,225,0.1);  color:var(--cyan); }
.dept-stat-icon.green { background:rgba(34,197,94,0.1);   color:#22c55e; }
.dept-stat-icon.red   { background:rgba(239,68,68,0.1);   color:#ef4444; }
.dept-stat-val { font-size:1.1rem; font-weight:700; color:var(--text); font-family:'Space Mono',monospace; line-height:1; }
.dept-stat-lbl { font-size:0.67rem; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.5px; font-weight:500; }

.toolbar { display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem; flex-wrap:wrap; }
.toolbar-left  { display:flex; align-items:center; gap:0.6rem; }
.toolbar-right { display:flex; align-items:center; gap:0.6rem; }

.filter-pill { display:inline-flex; align-items:center; gap:5px; padding:5px 12px; border-radius:20px; border:1px solid var(--border); background:var(--bg-card); font-size:0.73rem; font-weight:600; color:var(--text-muted); cursor:pointer; transition:all 0.18s; }
.filter-pill:hover        { border-color:var(--cyan); color:var(--cyan); }
.filter-pill.active       { background:var(--cyan); border-color:var(--cyan); color:#fff; }
.filter-pill.green.active { background:#22c55e; border-color:#22c55e; color:#fff; }
.filter-pill.red.active   { background:#ef4444; border-color:#ef4444; color:#fff; }

.search-box { position:relative; display:flex; align-items:center; }
.search-box svg { position:absolute; left:10px; width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-box input { height:34px; padding:0 12px 0 32px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:0.8rem; color:var(--text); background:var(--bg-card); outline:none; width:200px; transition:all 0.2s; }
.search-box input:focus { border-color:var(--cyan); box-shadow:0 0 0 3px rgba(45,186,225,0.1); width:240px; }

.result-count { font-size:0.72rem; color:var(--text-muted); font-family:'Space Mono',monospace; padding:4px 10px; background:var(--bg-page); border:1px solid var(--border); border-radius:20px; }

.dept-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:1rem; }

.dept-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; overflow:hidden; transition:all 0.25s; animation:card-in 0.35s ease both; }
@keyframes card-in { from{opacity:0;transform:translateY(14px);} to{opacity:1;transform:translateY(0);} }
.dept-card:hover { box-shadow:0 8px 28px rgba(2,27,47,0.12); transform:translateY(-3px); border-color:var(--cyan); }
.dept-card.inactive-card { opacity:0.65; }
.dept-card.inactive-card:hover { opacity:1; }

.dept-card-bar { height:4px; background:linear-gradient(90deg,var(--cyan),var(--blue)); }
.dept-card.inactive-card .dept-card-bar { background:linear-gradient(90deg,#94a3b8,#cbd5e1); }

.dept-card-body { padding:1.3rem; }
.dept-card-top { display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:0.8rem; }

.dept-icon { width:44px; height:44px; border-radius:10px; background:linear-gradient(135deg,var(--navy),var(--blue)); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.dept-icon svg { width:20px; height:20px; color:var(--cyan-light); }
.dept-card.inactive-card .dept-icon { background:linear-gradient(135deg,#64748b,#94a3b8); }

.dept-status { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:0.68rem; font-weight:600; }
.dept-status::before { content:''; width:6px; height:6px; border-radius:50%; }
.dept-status.active   { background:rgba(34,197,94,0.1);   color:#15803d; }
.dept-status.active::before   { background:#22c55e; }
.dept-status.inactive { background:rgba(100,116,139,0.1); color:#475569; }
.dept-status.inactive::before { background:#94a3b8; }

.dept-name { font-size:1rem; font-weight:700; color:var(--text); margin-bottom:3px; }
.dept-code { font-size:0.68rem; font-family:'Space Mono',monospace; color:var(--cyan); background:rgba(45,186,225,0.08); border:1px solid rgba(45,186,225,0.15); padding:2px 8px; border-radius:6px; display:inline-block; margin-bottom:0.7rem; }
.dept-card.inactive-card .dept-code { color:var(--text-muted); background:var(--bg-page); border-color:var(--border); }

.dept-description { font-size:0.78rem; color:var(--text-muted); line-height:1.5; margin-bottom:1rem; min-height:2.3rem; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }

.dept-card-actions { display:flex; gap:0.4rem; padding-top:0.8rem; border-top:1px solid var(--border); }
.dept-card-actions .btn { flex:1; justify-content:center; font-size:0.72rem; padding:0.35rem 0.5rem; }

.empty-depts { text-align:center; padding:5rem 1rem; grid-column:1/-1; }
.empty-depts .empty-icon { width:72px; height:72px; background:linear-gradient(135deg,rgba(45,186,225,0.1),rgba(28,139,192,0.05)); border-radius:18px; display:flex; align-items:center; justify-content:center; margin:0 auto 1rem; border:1px solid rgba(45,186,225,0.15); }
.empty-depts .empty-icon svg { width:32px; height:32px; color:var(--cyan); opacity:0.5; }
.empty-depts h3 { font-size:1rem; font-weight:600; color:var(--text); margin-bottom:4px; }
.empty-depts p  { font-size:0.82rem; color:var(--text-muted); margin-bottom:1rem; }
</style>
</head>
<body>
<div class="app">

    <%@ include file="sidebar.jsp" %>

    <div class="main">
        <div class="topbar">
            <div class="topbar-left">
                <div class="topbar-breadcrumb">
                    <span>ME2MS</span><span class="sep">/</span>
                    <span style="color:var(--text);font-weight:500;">Departments</span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:0.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                    <%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %>
                </span>
            </div>
        </div>

        <div class="content">

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

            <div class="dept-hero">
                <div>
                    <h1>🏥 Departments</h1>
                    <p>// <%= departments.size() %> total · <%= activeCount %> active · <%= inactiveCount %> inactive</p>
                </div>
                <a href="<%= request.getContextPath() %>/departments?action=new" class="btn btn-cyan" style="position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    New Department
                </a>
            </div>

            <div class="dept-stats">
                <div class="dept-stat">
                    <div class="dept-stat-icon cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                    </div>
                    <div><div class="dept-stat-val"><%= departments.size() %></div><div class="dept-stat-lbl">Total</div></div>
                </div>
                <div class="dept-stat">
                    <div class="dept-stat-icon green">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                    </div>
                    <div><div class="dept-stat-val"><%= activeCount %></div><div class="dept-stat-lbl">Active</div></div>
                </div>
                <div class="dept-stat">
                    <div class="dept-stat-icon red">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                    </div>
                    <div><div class="dept-stat-val"><%= inactiveCount %></div><div class="dept-stat-lbl">Inactive</div></div>
                </div>
            </div>

            <div class="toolbar">
                <div class="toolbar-left">
                    <button class="filter-pill active" onclick="filterDepts('all',this)">All</button>
                    <button class="filter-pill green"  onclick="filterDepts('active',this)">Active</button>
                    <button class="filter-pill red"    onclick="filterDepts('inactive',this)">Inactive</button>
                </div>
                <div class="toolbar-right">
                    <div class="search-box">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Search departments..." oninput="searchDepts(this.value)"/>
                    </div>
                    <span class="result-count" id="resultCount"><%= departments.size() %> departments</span>
                </div>
            </div>

            <div class="dept-grid" id="deptGrid">
                <% if (departments.isEmpty()) { %>
                <div class="empty-depts">
                    <div class="empty-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                    </div>
                    <h3>No departments yet</h3>
                    <p>Create your first department to get started.</p>
                    <a href="<%= request.getContextPath() %>/departments?action=new" class="btn btn-cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        New Department
                    </a>
                </div>
                <% } else { int delay = 0; for (Department d : departments) { %>
                <div class="dept-card <%= !d.isActive() ? "inactive-card" : "" %>"
                     data-name="<%= d.getName().toLowerCase() %>"
                     data-code="<%= d.getCode() != null ? d.getCode().toLowerCase() : "" %>"
                     data-status="<%= d.isActive() ? "active" : "inactive" %>"
                     style="animation-delay:<%= delay * 60 %>ms">
                    <div class="dept-card-bar"></div>
                    <div class="dept-card-body">
                        <div class="dept-card-top">
                            <div class="dept-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                            </div>
                            <span class="dept-status <%= d.isActive() ? "active" : "inactive" %>">
                                <%= d.isActive() ? "Active" : "Inactive" %>
                            </span>
                        </div>
                        <div class="dept-name"><%= d.getName() %></div>
                        <div class="dept-code"><%= d.getCode() != null && !d.getCode().isEmpty() ? d.getCode() : "NO CODE" %></div>
                        <div class="dept-description"><%= d.getDescription() != null && !d.getDescription().isEmpty() ? d.getDescription() : "No description provided." %></div>
                        <div class="dept-card-actions">
                            <a href="<%= request.getContextPath() %>/departments?action=edit&id=<%= d.getDepartmentId() %>" class="btn btn-outline btn-sm">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                Edit
                            </a>
                            <% if (d.isActive()) { %>
                            <form method="post" action="<%= request.getContextPath() %>/departments" style="flex:1;">
                                <input type="hidden" name="action" value="deactivate"/>
                                <input type="hidden" name="departmentId" value="<%= d.getDepartmentId() %>"/>
                                <button type="submit" class="btn btn-danger btn-sm" style="width:100%;justify-content:center;"
                                        onclick="return confirm('Deactivate <%= d.getName() %>?')">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                                    Deactivate
                                </button>
                            </form>
                            <% } else { %>
                            <form method="post" action="<%= request.getContextPath() %>/departments" style="flex:1;">
                                <input type="hidden" name="action" value="reactivate"/>
                                <input type="hidden" name="departmentId" value="<%= d.getDepartmentId() %>"/>
                                <button type="submit" class="btn btn-sm" style="width:100%;justify-content:center;background:rgba(34,197,94,0.1);border-color:rgba(34,197,94,0.3);color:#15803d;">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                    Reactivate
                                </button>
                            </form>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% delay++; } } %>
            </div>

        </div>
    </div>
</div>

<script>
let currentFilter = 'all';

function filterDepts(status, btn) {
    currentFilter = status;
    document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    applyFilters();
}

function searchDepts(query) { applyFilters(query); }

function applyFilters(query) {
    const q = (query !== undefined ? query : document.querySelector('.search-box input').value).toLowerCase().trim();
    const cards = document.querySelectorAll('.dept-card');
    let count = 0;
    cards.forEach(card => {
        const statusMatch = currentFilter === 'all' || card.dataset.status === currentFilter;
        const searchMatch = !q || card.dataset.name.includes(q) || card.dataset.code.includes(q);
        const show = statusMatch && searchMatch;
        card.style.display = show ? '' : 'none';
        if (show) count++;
    });
    document.getElementById('resultCount').textContent = count + ' department' + (count !== 1 ? 's' : '');
}
</script>
</body>
</html>
