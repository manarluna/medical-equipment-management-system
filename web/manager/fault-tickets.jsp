<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    request.setAttribute("currentPage", "faultreports");

    List<FaultReport> reports = (List<FaultReport>) request.getAttribute("reports");
    if (reports == null) reports = FaultReport.liste();

    boolean canManage = role.equals("Administrator") || role.equals("Technical_Manager");

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    long pending    = reports.stream().filter(r -> "pending".equalsIgnoreCase(r.getStatus())).count();
    long inProgress = reports.stream().filter(r -> r.getStatus() != null && r.getStatus().toLowerCase().contains("progress")).count();
    long resolved   = reports.stream().filter(r -> "resolved".equalsIgnoreCase(r.getStatus())).count();
    long critical   = reports.stream().filter(r -> "critical".equalsIgnoreCase(r.getUrgency())).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Fault Reports</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
.page-hero { background:linear-gradient(135deg,#021B2F 0%,#0B385A 55%,#1C8BC0 100%); border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-60px; right:-60px; width:200px; height:200px; border-radius:50%; background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%); }
.page-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.page-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }

.toolbar { display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem; flex-wrap:wrap; }
.toolbar-left { display:flex; align-items:center; gap:0.6rem; flex-wrap:wrap; }
.toolbar-right { display:flex; align-items:center; gap:0.6rem; }

.filter-pill { display:inline-flex; align-items:center; gap:5px; padding:5px 12px; border-radius:20px; border:1px solid var(--border); background:var(--bg-card); font-size:0.73rem; font-weight:600; color:var(--text-muted); cursor:pointer; transition:all 0.18s; }
.filter-pill:hover        { border-color:var(--cyan); color:var(--cyan); }
.filter-pill.active       { background:var(--cyan); border-color:var(--cyan); color:#fff; }
.filter-pill.amber.active { background:#f59e0b; border-color:#f59e0b; color:#fff; }
.filter-pill.blue.active  { background:var(--blue); border-color:var(--blue); color:#fff; }
.filter-pill.green.active { background:#22c55e; border-color:#22c55e; color:#fff; }
.filter-pill.red.active   { background:#ef4444; border-color:#ef4444; color:#fff; }

.search-box { position:relative; display:flex; align-items:center; }
.search-box svg { position:absolute; left:10px; width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-box input { height:34px; padding:0 12px 0 32px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:0.8rem; color:var(--text); background:var(--bg-card); outline:none; width:200px; transition:all 0.2s; }
.search-box input:focus { border-color:var(--cyan); box-shadow:0 0 0 3px rgba(45,186,225,0.1); width:240px; }
.result-count { font-size:0.72rem; color:var(--text-muted); font-family:'Space Mono',monospace; padding:4px 10px; background:var(--bg-page); border:1px solid var(--border); border-radius:20px; }

.urgency-badge { display:inline-flex; align-items:center; padding:2px 9px; border-radius:20px; font-size:0.67rem; font-weight:700; text-transform:uppercase; }
.urgency-low      { background:rgba(34,197,94,0.1);   color:#15803d; }
.urgency-medium   { background:rgba(245,158,11,0.1);  color:#b45309; }
.urgency-high     { background:rgba(239,68,68,0.1);   color:#dc2626; }
.urgency-critical { background:rgba(139,0,0,0.12);    color:#991b1b; font-weight:800; }

.status-pill { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:0.68rem; font-weight:600; }
.status-pill::before { content:''; width:6px; height:6px; border-radius:50%; }
.s-pending     { background:rgba(245,158,11,0.1);  color:#b45309; }
.s-pending::before     { background:#f59e0b; }
.s-in_progress { background:rgba(28,139,192,0.1);  color:var(--blue); }
.s-in_progress::before { background:var(--blue); }
.s-resolved    { background:rgba(34,197,94,0.1);   color:#15803d; }
.s-resolved::before    { background:#22c55e; }

.icon-btn { width:30px; height:30px; border-radius:7px; display:flex; align-items:center; justify-content:center; border:1px solid var(--border); background:transparent; color:var(--text-muted); cursor:pointer; transition:all 0.18s; text-decoration:none; }
.icon-btn svg { width:13px; height:13px; }
.icon-btn:hover { border-color:var(--cyan); color:var(--cyan); background:rgba(45,186,225,0.06); }
.icon-btn.danger:hover { border-color:var(--danger); color:var(--danger); background:rgba(239,68,68,0.06); }

/* Inline status update form */
.status-select { height:28px; padding:0 8px; border:1px solid var(--border); border-radius:6px; font-family:'Sora',sans-serif; font-size:0.75rem; color:var(--text); background:var(--bg-card); cursor:pointer; outline:none; }
.status-select:focus { border-color:var(--cyan); }

.report-row[data-hidden="true"] { display:none; }
</style>
</head>
<body>
<div class="app">
    <%@ include file="../admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <div class="topbar-left">
                <div class="topbar-breadcrumb">
                    <span>ME2MS</span><span class="sep">/</span>
                    <span style="color:var(--text);font-weight:500;">Fault Reports</span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:0.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                    <%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %>
                </span>
            </div>
        </div>

        <div class="content">
            <% if (successMsg != null) { %><div class="flash flash-success"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg><%= successMsg %></div><% } %>
            <% if (errorMsg   != null) { %><div class="flash flash-error"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg><%= errorMsg %></div><% } %>

            <div class="page-hero">
                <div>
                    <h1>⚠️ Fault Reports</h1>
                    <p>// <%= reports.size() %> total · <%= pending %> pending · <%= critical %> critical</p>
                </div>
                <% if (role.equals("Doctor") || role.equals("Nurse")) { %>
                <a href="<%= request.getContextPath() %>/faultreports?action=new" class="btn btn-cyan" style="position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    New Report
                </a>
                <% } %>
            </div>

            <!-- Stats -->
            <div style="display:flex;gap:0.8rem;margin-bottom:1.5rem;flex-wrap:wrap;">
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(245,158,11,0.1);color:#f59e0b;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= pending %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Pending</div></div></div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(28,139,192,0.1);color:var(--blue);display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= inProgress %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">In Progress</div></div></div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(34,197,94,0.1);color:#22c55e;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><polyline points="20 6 9 17 4 12"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= resolved %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Resolved</div></div></div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(139,0,0,0.08);color:#991b1b;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= critical %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Critical</div></div></div>
            </div>

            <!-- Toolbar -->
            <div class="toolbar">
                <div class="toolbar-left">
                    <button class="filter-pill active" onclick="filterReports('all',this)">All</button>
                    <button class="filter-pill amber"  onclick="filterReports('pending',this)">Pending</button>
                    <button class="filter-pill blue"   onclick="filterReports('in_progress',this)">In Progress</button>
                    <button class="filter-pill green"  onclick="filterReports('resolved',this)">Resolved</button>
                    <button class="filter-pill red"    onclick="filterReports('critical',this)">Critical</button>
                </div>
                <div class="toolbar-right">
                    <div class="search-box">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Search reports..." oninput="searchReports(this.value)"/>
                    </div>
                    <span class="result-count" id="resultCount"><%= reports.size() %> reports</span>
                </div>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="table-wrap">
                    <% if (reports.isEmpty()) { %>
                    <div class="empty-state" style="padding:4rem 1rem;">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="40" height="40"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>
                        <p>No fault reports yet.</p>
                    </div>
                    <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Equipment</th>
                                <th>Room</th>
                                <th>Description</th>
                                <th>Urgency</th>
                                <th>Status</th>
                                <th>Date</th>
                                <% if (canManage) { %><th style="text-align:right;">Actions</th><% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (FaultReport r : reports) {
                                String st  = r.getStatus()  != null ? r.getStatus().toLowerCase().replace(" ","_")  : "pending";
                                String urg = r.getUrgency() != null ? r.getUrgency().toLowerCase() : "low";
                            %>
                            <tr class="report-row"
                                data-status="<%= st %>"
                                data-urgency="<%= urg %>"
                                data-desc="<%= r.getDescription() != null ? r.getDescription().toLowerCase() : "" %>">
                                <td style="font-family:'Space Mono',monospace;font-size:0.72rem;color:var(--text-muted);">#<%= r.getFaultId() %></td>
                                <td style="font-size:0.8rem;font-weight:600;">Equip. #<%= r.getEquipmentId() %></td>
                                <td style="font-size:0.8rem;color:var(--text-muted);"><%= r.getRoom() != null && !r.getRoom().isEmpty() ? r.getRoom() : "—" %></td>
                                <td style="font-size:0.78rem;color:var(--text-muted);max-width:220px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<%= r.getDescription() %>"><%= r.getDescription() %></td>
                                <td><span class="urgency-badge urgency-<%= urg %>"><%= r.getUrgency() %></span></td>
                                <td><span class="status-pill s-<%= st %>"><%= r.getStatus() %></span></td>
                                <td style="font-size:0.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;white-space:nowrap;">
                                    <%= r.getReportDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(r.getReportDate()) : "—" %>
                                </td>
                                <% if (canManage) { %>
                                <td>
                                    <form method="post" action="<%= request.getContextPath() %>/faultreports" style="display:flex;align-items:center;gap:0.4rem;justify-content:flex-end;">
                                        <input type="hidden" name="action"   value="updateStatus"/>
                                        <input type="hidden" name="reportId" value="<%= r.getFaultId() %>"/>
                                        <select name="status" class="status-select" onchange="this.form.submit()">
                                            <option value="pending"     <%= "pending".equals(st)     ? "selected" : "" %>>Pending</option>
                                            <option value="in_progress" <%= "in_progress".equals(st) ? "selected" : "" %>>In Progress</option>
                                            <option value="resolved"    <%= "resolved".equals(st)    ? "selected" : "" %>>Resolved</option>
                                        </select>
                                    </form>
                                </td>
                                <% } %>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } %>
                </div>
            </div>

        </div>
    </div>
</div>
<script>
let currentFilter = 'all';
function filterReports(f, btn) {
    currentFilter = f;
    document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    applyFilters();
}
function searchReports(q) { applyFilters(q); }
function applyFilters(query) {
    const q = (query !== undefined ? query : document.querySelector('.search-box input').value).toLowerCase().trim();
    const rows = document.querySelectorAll('.report-row');
    let count = 0;
    rows.forEach(row => {
        const fMatch = currentFilter === 'all' ||
                       row.dataset.status === currentFilter ||
                       (currentFilter === 'critical' && row.dataset.urgency === 'critical');
        const sMatch = !q || row.dataset.desc.includes(q);
        const show = fMatch && sMatch;
        row.style.display = show ? '' : 'none';
        if (show) count++;
    });
    document.getElementById('resultCount').textContent = count + ' report' + (count !== 1 ? 's' : '');
}
</script>
</body>
</html>
