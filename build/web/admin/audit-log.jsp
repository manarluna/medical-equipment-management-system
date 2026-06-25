<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("Administrator")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "audit-log");

    List<AuditLog> logs = (List<AuditLog>) request.getAttribute("logs");
    if (logs == null) logs = AuditLog.liste();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Audit Log</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
/* ── AUDIT LOG PAGE ─────────────────────────────── */

.audit-hero {
    background: linear-gradient(135deg, #021B2F 0%, #0B385A 60%, #1C8BC0 100%);
    border-radius: 14px;
    padding: 1.6rem 2rem;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: relative;
    overflow: hidden;
}

.audit-hero::before {
    content: '';
    position: absolute;
    top: -50px; right: -50px;
    width: 200px; height: 200px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(45,186,225,0.15), transparent 70%);
    animation: pulse 4s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); opacity: 0.6; }
    50%       { transform: scale(1.1); opacity: 1; }
}

.audit-hero h1 {
    font-size: 1.3rem;
    font-weight: 700;
    color: #fff;
    margin-bottom: 3px;
}

.audit-hero p {
    font-size: 0.78rem;
    color: rgba(144,230,255,0.7);
    font-family: 'Space Mono', monospace;
}

/* Stats strip */
.audit-stats {
    display: flex;
    gap: 0.8rem;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
}

.audit-stat {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 0.8rem 1.2rem;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: var(--shadow);
    min-width: 130px;
}

.audit-stat-icon {
    width: 34px; height: 34px;
    border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}

.audit-stat-icon svg { 
    width: 16px; 
    height: 16px;
}
.audit-stat-icon.cyan  { 
    background: rgba(45,186,225,0.1); 
    color: var(--cyan); }
.audit-stat-icon.green { background: rgba(34,197,94,0.1);   color: #22c55e; }
.audit-stat-icon.amber { background: rgba(245,158,11,0.1);  color: #f59e0b; }
.audit-stat-icon.red   { background: rgba(239,68,68,0.1);   color: #ef4444; }
.audit-stat-icon.blue  { background: rgba(28,139,192,0.1);  color: var(--blue); }

.audit-stat-val  { font-size: 1.1rem; font-weight: 700; color: var(--text); font-family: 'Space Mono', monospace; line-height: 1; }
.audit-stat-lbl  { font-size: 0.67rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; font-weight: 500; }

/* Toolbar */
.log-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 1rem;
    flex-wrap: wrap;
}

.log-toolbar-left  { display: flex; align-items: center; gap: 0.6rem; flex-wrap: wrap; }
.log-toolbar-right { display: flex; align-items: center; gap: 0.6rem; }

/* Filter pills */
.filter-pill {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 5px 12px;
    border-radius: 20px;
    border: 1px solid var(--border);
    background: var(--bg-card);
    font-size: 0.73rem;
    font-weight: 600;
    color: var(--text-muted);
    cursor: pointer;
    transition: all 0.18s;
}

.filter-pill:hover { border-color: var(--cyan); color: var(--cyan); }
.filter-pill.active { background: var(--cyan); border-color: var(--cyan); color: #fff; }
.filter-pill.green.active  { background: #22c55e; border-color: #22c55e; color: #fff; }
.filter-pill.red.active    { background: #ef4444; border-color: #ef4444; color: #fff; }
.filter-pill.amber.active  { background: #f59e0b; border-color: #f59e0b; color: #fff; }
.filter-pill.blue.active   { background: var(--blue); border-color: var(--blue); color: #fff; }
.filter-pill.purple.active { background: #8b5cf6; border-color: #8b5cf6; color: #fff; }

/* Search */
.log-search {
    position: relative;
    display: flex;
    align-items: center;
}

.log-search svg {
    position: absolute;
    left: 10px;
    width: 14px; height: 14px;
    color: var(--text-muted);
    pointer-events: none;
}

.log-search input {
    height: 34px;
    padding: 0 12px 0 32px;
    border: 1px solid var(--border);
    border-radius: 8px;
    font-family: 'Sora', sans-serif;
    font-size: 0.8rem;
    color: var(--text);
    background: var(--bg-card);
    outline: none;
    width: 220px;
    transition: all 0.2s;
}

.log-search input:focus {
    border-color: var(--cyan);
    box-shadow: 0 0 0 3px rgba(45,186,225,0.1);
    width: 260px;
}

/* Log table card */
.log-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: 14px;
    overflow: hidden;
    box-shadow: var(--shadow);
}

.log-card-header {
    padding: 1rem 1.4rem;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #f8fafc;
}

.log-card-header h3 {
    font-size: 0.88rem;
    font-weight: 600;
    color: var(--text);
    display: flex;
    align-items: center;
    gap: 8px;
}

.log-card-header h3 svg { width: 16px; height: 16px; color: var(--cyan); }

/* Row count badge */
.row-count {
    font-size: 0.72rem;
    color: var(--text-muted);
    font-family: 'Space Mono', monospace;
    padding: 3px 10px;
    background: var(--bg-page);
    border: 1px solid var(--border);
    border-radius: 20px;
}

/* Table */
.log-table-wrap { overflow-x: auto; }

.log-table-wrap table { margin: 0; }

/* Action badge */
.action-badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 3px 10px;
    border-radius: 20px;
    font-size: 0.68rem;
    font-weight: 700;
    letter-spacing: 0.3px;
    white-space: nowrap;
    text-transform: uppercase;
}

/* ID cell */
.log-id {
    font-family: 'Space Mono', monospace;
    font-size: 0.72rem;
    color: var(--text-muted);
}

/* Details cell */
.log-details {
    font-size: 0.8rem;
    color: var(--text-muted);
    max-width: 300px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* Date cell */
.log-date {
    font-family: 'Space Mono', monospace;
    font-size: 0.72rem;
    color: var(--text-muted);
    white-space: nowrap;
}

/* User ID cell */
.log-user {
    font-family: 'Space Mono', monospace;
    font-size: 0.72rem;
    color: var(--text-muted);
    text-align: center;
}

/* Hidden rows */
.log-row[data-hidden="true"] { display: none; }

/* Empty state */
.log-empty {
    text-align: center;
    padding: 4rem 1rem;
    color: var(--text-muted);
}
.log-empty svg { width: 40px; height: 40px; margin-bottom: 0.8rem; opacity: 0.25; }
.log-empty p { font-size: 0.85rem; }

/* Timeline dot (left of row) */
tbody tr:hover td { background: #f8fafc; }
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
                    <span style="color:var(--text);font-weight:500;">Audit Log</span>
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
            <%
                String successMsg = (String) session.getAttribute("successMsg");
                session.removeAttribute("successMsg");
            %>
            <% if (successMsg != null) { %>
            <div class="flash flash-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                <%= successMsg %>
            </div>
            <% } %>

            <!-- HERO -->
            <div class="audit-hero">
                <div>
                    <h1>📋 Audit Log</h1>
                    <p>// Complete record of all system actions — <%= logs.size() %> entries total</p>
                </div>
                <% if (!logs.isEmpty()) { %>
                <form method="post" action="<%= request.getContextPath() %>/audit-log" style="position:relative;z-index:2;">
                    <input type="hidden" name="action" value="deleteAll"/>
                    <button type="submit" class="btn btn-danger"
                            onclick="return confirm('Delete ALL <%= logs.size() %> log entries? This cannot be undone.')">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/></svg>
                        Clear All Logs
                    </button>
                </form>
                <% } %>
            </div>

            <%
                // Count by action type
                int loginCount = 0, logoutCount = 0, createCount = 0,
                    updateCount = 0, deleteCount = 0, otherCount = 0;
                for (AuditLog log : logs) {
                    String a = log.getAction();
                    if (a.contains("LOGIN") && !a.contains("LOGOUT")) loginCount++;
                    else if (a.contains("LOGOUT")) logoutCount++;
                    else if (a.contains("CREATE")) createCount++;
                    else if (a.contains("UPDATE") || a.contains("RESET") || a.contains("REACTIVATE") || a.contains("DEACTIVATE")) updateCount++;
                    else if (a.contains("DELETE")) deleteCount++;
                    else otherCount++;
                }
            %>

            <!-- STATS STRIP -->
            <div class="audit-stats">
                <div class="audit-stat">
                    <div class="audit-stat-icon cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                    </div>
                    <div>
                        <div class="audit-stat-val"><%= logs.size() %></div>
                        <div class="audit-stat-lbl">Total Events</div>
                    </div>
                </div>
                <div class="audit-stat">
                    <div class="audit-stat-icon green">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                    </div>
                    <div>
                        <div class="audit-stat-val"><%= loginCount %></div>
                        <div class="audit-stat-lbl">Logins</div>
                    </div>
                </div>
                <div class="audit-stat">
                    <div class="audit-stat-icon blue">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    </div>
                    <div>
                        <div class="audit-stat-val"><%= createCount %></div>
                        <div class="audit-stat-lbl">Created</div>
                    </div>
                </div>
                <div class="audit-stat">
                    <div class="audit-stat-icon amber">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    </div>
                    <div>
                        <div class="audit-stat-val"><%= updateCount %></div>
                        <div class="audit-stat-lbl">Updates</div>
                    </div>
                </div>
                <div class="audit-stat">
                    <div class="audit-stat-icon red">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/></svg>
                    </div>
                    <div>
                        <div class="audit-stat-val"><%= deleteCount %></div>
                        <div class="audit-stat-lbl">Deleted</div>
                    </div>
                </div>
            </div>

            <!-- TOOLBAR -->
            <div class="log-toolbar">
                <div class="log-toolbar-left">
                    <button class="filter-pill active" onclick="filterLogs('all', this)">All</button>
                    <button class="filter-pill green"  onclick="filterLogs('LOGIN', this)">Login</button>
                    <button class="filter-pill blue"   onclick="filterLogs('CREATE', this)">Create</button>
                    <button class="filter-pill amber"  onclick="filterLogs('UPDATE', this)">Update</button>
                    <button class="filter-pill red"    onclick="filterLogs('DELETE', this)">Delete</button>
                </div>
                <div class="log-toolbar-right">
                    <div class="log-search">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Search logs..." oninput="searchLogs(this.value)"/>
                    </div>
                </div>
            </div>

            <!-- LOG TABLE -->
            <div class="log-card">
                <div class="log-card-header">
                    <h3>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                        System Activity
                    </h3>
                    <span class="row-count" id="rowCount"><%= logs.size() %> entries</span>
                </div>

                <div class="log-table-wrap">
                    <% if (logs.isEmpty()) { %>
                    <div class="log-empty">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
                        <p>No activity recorded yet.</p>
                    </div>
                    <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Action</th>
                                <th>Details</th>
                                <th style="text-align:center;">User ID</th>
                                <th>Date &amp; Time</th>
                                <th style="text-align:center;">Delete</th>
                            </tr>
                        </thead>
                        <tbody id="logTableBody">
                            <% for (AuditLog log : logs) {
                                String action = log.getAction();
                                String badgeClass =
                                    action.contains("LOGIN") && !action.contains("LOGOUT") ? "badge-green"  :
                                    action.contains("LOGOUT")    ? "badge-gray"   :
                                    action.contains("CREATE")    ? "badge-cyan"   :
                                    action.contains("DELETE")    ? "badge-red"    :
                                    action.contains("UPDATE")    ? "badge-amber"  :
                                    action.contains("RESET")     ? "badge-blue"   :
                                    action.contains("DEACTIVATE")? "badge-red"    :
                                    action.contains("REACTIVATE")? "badge-green"  : "badge-blue";

                                String category =
                                    action.contains("LOGIN") && !action.contains("LOGOUT") ? "LOGIN"  :
                                    action.contains("LOGOUT")    ? "LOGOUT"  :
                                    action.contains("CREATE")    ? "CREATE"  :
                                    action.contains("DELETE")    ? "DELETE"  : "UPDATE";
                            %>
                            <tr class="log-row" data-action="<%= category %>"
                                data-details="<%= log.getDetails() != null ? log.getDetails().toLowerCase() : "" %>">
                                <td class="log-id">#<%= log.getAuditLogId() %></td>
                                <td>
                                    <span class="action-badge <%= badgeClass %>">
                                        <%= action %>
                                    </span>
                                </td>
                                <td class="log-details" title="<%= log.getDetails() != null ? log.getDetails() : "" %>">
                                    <%= log.getDetails() != null ? log.getDetails() : "—" %>
                                </td>
                                <td class="log-user"><%= log.getUserId() %></td>
                                <td class="log-date">
                                    <%= log.getActionDate() != null
                                        ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(log.getActionDate())
                                        : "—" %>
                                </td>
                                <td style="text-align:center;">
                                    <form method="post" action="<%= request.getContextPath() %>/audit-log" style="display:inline;">
                                        <input type="hidden" name="action" value="delete"/>
                                        <input type="hidden" name="logId" value="<%= log.getAuditLogId() %>"/>
                                        <button type="submit" class="icon-btn danger"
                                                title="Delete this entry"
                                                onclick="return confirm('Delete log entry #<%= log.getAuditLogId() %>?')">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/></svg>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } %>
                </div>
            </div>

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /app -->

<script>
let currentFilter = 'all';

// ── Filter by action type ─────────────────────────
function filterLogs(type, btn) {
    currentFilter = type;
    document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    applyFilters();
}

// ── Search ────────────────────────────────────────
function searchLogs(query) {
    applyFilters(query);
}

function applyFilters(query) {
    const q = (query !== undefined ? query : document.querySelector('.log-search input').value).toLowerCase().trim();
    const rows = document.querySelectorAll('.log-row');
    let count = 0;

    rows.forEach(row => {
        const actionMatch = currentFilter === 'all' || row.dataset.action === currentFilter;
        const searchMatch = !q || row.dataset.details.includes(q) ||
                            row.querySelector('.action-badge').textContent.toLowerCase().includes(q);
        const show = actionMatch && searchMatch;
        row.style.display = show ? '' : 'none';
        if (show) count++;
    });

    const el = document.getElementById('rowCount');
    if (el) el.textContent = count + ' entr' + (count !== 1 ? 'ies' : 'y');
}
</script>
</body>
</html>
