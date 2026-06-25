<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    if (!role.equals("Doctor") && !role.equals("Nurse")
            && !role.equals("Administrator") && !role.equals("Technical_Manager")) {
        response.sendRedirect(request.getContextPath() + "/dashboard"); return;
    }
    request.setAttribute("currentPage", "report");

    // ── Data from FaultReportServlet ─────────────────────────
    List<FaultReport> reports = (List<FaultReport>) request.getAttribute("reports");
    // FIX BUG 2: if reports is null (happens after sendRedirect which loses request attributes),
    // fetch directly from DB using the current user's ID instead of showing an empty list
    if (reports == null) reports = FaultReport.getByReporter(currentUser.getUserId());

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg"); session.removeAttribute("errorMsg");

    long pendingCount    = reports.stream().filter(r -> "pending".equalsIgnoreCase(r.getStatus())).count();
    long inProgCount     = reports.stream().filter(r -> "in_progress".equalsIgnoreCase(r.getStatus())).count();
    long resolvedCount   = reports.stream().filter(r -> "resolved".equalsIgnoreCase(r.getStatus())).count();
%>
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — My Reports</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
:root { --bg-page: #EEF2F7; }

/* ── Hero ── */
.page-hero { background:linear-gradient(135deg,#0D1B2A 0%,#1B3A5C 55%,#0096C7 100%); border-radius:14px; padding:1.8rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-60px; right:-50px; width:220px; height:220px; border-radius:50%; background:radial-gradient(circle,rgba(0,180,216,.15),transparent 70%); animation:ph 4s ease-in-out infinite; }
.page-hero::after  { content:''; position:absolute; bottom:-40px; left:25%; width:160px; height:160px; border-radius:50%; background:radial-gradient(circle,rgba(0,180,216,.1),transparent 70%); animation:ph 4s ease-in-out infinite reverse; }
@keyframes ph { 0%,100%{transform:scale(1);opacity:.6} 50%{transform:scale(1.15);opacity:1} }
.page-hero h1 { font-size:1.35rem; font-weight:700; color:#fff; margin-bottom:4px; }
.page-hero p  { font-size:.78rem; color:rgba(186,230,253,.9); font-family:'Space Mono',monospace; }

/* ── Stat mini-cards ── */
.stats-row { display:grid; grid-template-columns:repeat(3,1fr); gap:.8rem; margin-bottom:1.4rem; }
.stat-mini { background:#fff; border:1px solid var(--border); border-radius:12px; padding:.9rem 1.1rem; display:flex; align-items:center; gap:.8rem; }
.stat-mini-icon { width:36px; height:36px; border-radius:9px; flex-shrink:0; display:flex; align-items:center; justify-content:center; }
.stat-mini-icon svg { width:17px; height:17px; }
.stat-mini-icon.gold  { background:rgba(222,172,76,.12);  color:#a07a1e; }
.stat-mini-icon.blue  { background:rgba(0,180,216,.12);  color:#00B4D8; }
.stat-mini-icon.teal  { background:rgba(0,180,216,.12);  color:#0096C7; }
.stat-mini-val  { font-size:1.3rem; font-weight:700; color:var(--text); line-height:1; font-family:'Space Mono',monospace; }
.stat-mini-lbl  { font-size:.68rem; color:var(--text-muted); margin-top:2px; }

/* ── Toolbar ── */
.doc-toolbar { display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1.1rem; flex-wrap:wrap; }
.search-wrap { position:relative; }
.search-wrap svg { position:absolute; left:10px; top:50%; transform:translateY(-50%); width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-wrap input { height:36px; padding:0 12px 0 34px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:.82rem; color:var(--text); background:#fff; outline:none; width:220px; transition:all .2s; }
.search-wrap input:focus { border-color:#00B4D8; box-shadow:0 0 0 3px rgba(0,180,216,.12); width:260px; }

.btn-new { display:inline-flex; align-items:center; gap:6px; padding:.5rem 1.1rem; border-radius:8px; font-family:'Sora',sans-serif; font-size:.82rem; font-weight:600; cursor:pointer; border:none; background:#00B4D8; color:#fff; text-decoration:none; box-shadow:0 2px 10px rgba(0,180,216,.3); transition:all .2s; }
.btn-new:hover { background:#0096C7; transform:translateY(-1px); }
.btn-new svg { width:13px; height:13px; }

/* ── Table ── */
.table-wrap { background:#fff; border:1px solid var(--border); border-radius:14px; overflow:hidden; box-shadow:0 2px 12px rgba(0,0,0,.05); }
.reports-table { width:100%; border-collapse:collapse; font-size:.84rem; }
.reports-table thead tr { background:linear-gradient(135deg,rgba(0,180,216,.06),transparent); border-bottom:2px solid rgba(0,180,216,.15); }
.reports-table thead th { padding:.85rem 1.1rem; text-align:left; font-size:.68rem; font-weight:700; text-transform:uppercase; letter-spacing:.8px; color:var(--text-muted); white-space:nowrap; }
.reports-table tbody tr { border-bottom:1px solid var(--border); transition:background .15s; }
.reports-table tbody tr:last-child { border-bottom:none; }
.reports-table tbody tr:hover { background:rgba(0,180,216,.04); }
.reports-table tbody td { padding:.85rem 1.1rem; color:var(--text); vertical-align:middle; }

/* ── Badges ── */
.urgency-badge { display:inline-flex; align-items:center; padding:3px 9px; border-radius:20px; font-size:.67rem; font-weight:700; text-transform:uppercase; letter-spacing:.4px; }
.u-low      { background:rgba(0,180,216,.12); color:#0096C7; }
.u-medium   { background:rgba(222,172,76,.12);  color:#a07a1e; }
.u-high     { background:rgba(239,68,68,.1);    color:#dc2626; }
.u-critical { background:rgba(139,0,0,.12);     color:#991b1b; font-weight:800; }

.status-pill { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:600; white-space:nowrap; }
.status-pill::before { content:''; width:6px; height:6px; border-radius:50%; }
.s-pending     { background:rgba(222,172,76,.12);  color:#a07a1e; }
.s-pending::before     { background:#DEAC4C; }
.s-in_progress { background:rgba(0,180,216,.12);  color:#0096C7; }
.s-in_progress::before { background:#00B4D8; }
.s-resolved    { background:rgba(0,180,216,.12);  color:#0096C7; }
.s-resolved::before    { background:#00B4D8; animation:blink 2s ease-in-out infinite; }
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.3} }

/* ── Empty state ── */
.empty-state { text-align:center; padding:4rem 1rem; color:var(--text-muted); }
.empty-state svg { opacity:.25; display:block; margin:0 auto .8rem; }
.empty-state p { font-size:.85rem; }
.empty-state a { display:inline-flex; align-items:center; gap:6px; margin-top:1rem; padding:.55rem 1.2rem; border-radius:8px; background:#00B4D8; color:#fff; font-size:.82rem; font-weight:600; text-decoration:none; transition:all .2s; }
.empty-state a:hover { background:#0096C7; }
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
                    <span style="color:var(--text);font-weight:500;">My Reports</span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;"><%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %></span>
            </div>
        </div>

        <div class="content">

            <% if (successMsg != null) { %>
            <div class="flash flash-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;width:16px;height:16px;"><polyline points="20 6 9 17 4 12"/></svg>
                <%= successMsg %>
            </div>
            <% } %>
            <% if (errorMsg != null) { %>
            <div class="flash flash-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;width:16px;height:16px;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <%= errorMsg %>
            </div>
            <% } %>

            <!-- HERO -->
            <div class="page-hero">
                <div style="position:relative;z-index:2;">
                    <h1>📋 My Issue Reports</h1>
                    <p>// Track the status of your reports in real time</p>
                </div>
                <a href="<%= request.getContextPath() %>/faultreports?action=new" class="btn-new" style="position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    New Report
                </a>
            </div>

            <!-- STATS -->
            <div class="stats-row">
                <div class="stat-mini">
                    <div class="stat-mini-icon gold">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    </div>
                    <div>
                        <div class="stat-mini-val"><%= pendingCount %></div>
                        <div class="stat-mini-lbl">Pending</div>
                    </div>
                </div>
                <div class="stat-mini">
                    <div class="stat-mini-icon blue">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                    </div>
                    <div>
                        <div class="stat-mini-val"><%= inProgCount %></div>
                        <div class="stat-mini-lbl">In Progress</div>
                    </div>
                </div>
                <div class="stat-mini">
                    <div class="stat-mini-icon teal">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                    </div>
                    <div>
                        <div class="stat-mini-val"><%= resolvedCount %></div>
                        <div class="stat-mini-lbl">Resolved</div>
                    </div>
                </div>
            </div>

            <!-- TOOLBAR -->
            <div class="doc-toolbar">
                <div style="display:flex;align-items:center;gap:.7rem;">
                    <div class="search-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Rechercher par description…" oninput="filterRows(this.value)"/>
                    </div>
                    <span id="rowCount" style="font-size:.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;padding:4px 10px;background:var(--bg-page);border:1px solid var(--border);border-radius:20px;"><%= reports.size() %> rapport<%= reports.size()!=1?"s":"" %></span>
                </div>
                <select onchange="filterByStatus(this.value)" style="height:36px;padding:0 10px;border:1px solid var(--border);border-radius:8px;font-family:'Sora',sans-serif;font-size:.82rem;color:var(--text);background:#fff;outline:none;cursor:pointer;">
                    <option value="">All Statuses</option>
                    <option value="pending">Pending</option>
                    <option value="in_progress">In progress</option>
                    <option value="resolved">Resolved</option>
                </select>
            </div>

            <!-- TABLE -->
            <% if (reports.isEmpty()) { %>
            <div class="table-wrap">
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="48" height="48">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/>
                    </svg>
                    <p>No reports submitted yet.</p>
                    <a href="<%= request.getContextPath() %>/faultreports?action=new">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" width="13" height="13"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Submit My First Report
                    </a>
                </div>
            </div>
            <% } else { %>
            <div class="table-wrap">
                <table class="reports-table" id="reportsTable">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Equipment</th>
                            <th>Room</th>
                            <th>Description</th>
                            <th>Urgency</th>
                            <th>Status</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (FaultReport r : reports) {
                        String urg    = r.getUrgency() != null ? r.getUrgency().toLowerCase() : "low";
                        String urgCls = urg.equals("critical") ? "u-critical" : (urg.equals("high") ? "u-high" : (urg.equals("medium") ? "u-medium" : "u-low"));
                        String st     = r.getStatus() != null ? r.getStatus().toLowerCase() : "pending";
                        String stCls  = st.equals("resolved") ? "s-resolved" : (st.equals("in_progress") ? "s-in_progress" : "s-pending");

                        // Try to get equipment name
                        Equipment eq = null;
                        try { eq = Equipment.chercher_id(r.getEquipmentId()); } catch(Exception ignored) {}
                        String eqName = eq != null ? eq.getName() + " — " + eq.getAssetId() : "ID #" + r.getEquipmentId();
                    %>
                    <tr data-desc="<%= r.getDescription() != null ? r.getDescription().toLowerCase() : "" %>"
                        data-status="<%= st %>">
                        <td style="font-family:'Space Mono',monospace;font-size:.72rem;color:var(--text-muted);">#<%= r.getFaultId() %></td>
                        <td>
                            <div style="font-weight:600;font-size:.83rem;"><%= eqName %></div>
                        </td>
                        <td style="color:var(--text-muted);font-size:.82rem;"><%= r.getRoom() != null && !r.getRoom().isEmpty() ? r.getRoom() : "—" %></td>
                        <td style="max-width:280px;">
                            <div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:.82rem;" title="<%= r.getDescription() %>">
                                <%= r.getDescription() %>
                            </div>
                        </td>
                        <td><span class="urgency-badge <%= urgCls %>"><%= r.getUrgency() != null ? r.getUrgency() : "—" %></span></td>
                        <td><span class="status-pill <%= stCls %>"><%= r.getStatus() != null ? r.getStatus().replace("_"," ") : "—" %></span></td>
                        <td style="font-size:.78rem;color:var(--text-muted);white-space:nowrap;">
                            <% if (r.getReportDate() != null) { %>
                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(r.getReportDate()) %>
                            <% } else { %>—<% } %>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>

        </div>
    </div>
</div>
<script>
var activeStatus = '';
function filterRows(q) {
    const v = q.toLowerCase().trim();
    const rows = document.querySelectorAll('#reportsTable tbody tr');
    let count = 0;
    rows.forEach(row => {
        const descMatch  = !v || row.dataset.desc.includes(v);
        const statMatch  = !activeStatus || row.dataset.status === activeStatus;
        const show = descMatch && statMatch;
        row.style.display = show ? '' : 'none';
        if (show) count++;
    });
    document.getElementById('rowCount').textContent = count + ' rapport' + (count !== 1 ? 's' : '');
}
function filterByStatus(val) {
    activeStatus = val;
    const inp = document.querySelector('.search-wrap input');
    filterRows(inp ? inp.value : '');
}
</script>
</body>
</html>
