<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || (!currentUser.getRole().equals("Nurse") && !currentUser.getRole().equals("Doctor"))) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String role = currentUser.getRole();
    boolean isDoctor = role.equals("Doctor");
    boolean isNurse  = role.equals("Nurse");
    request.setAttribute("currentPage", "dashboard");
    List<FaultReport> myReports   = (List<FaultReport>) request.getAttribute("myReports");
    List<Equipment>   myEquipment = (List<Equipment>)   request.getAttribute("myEquipment");
    int pendingCount    = request.getAttribute("pendingCount")    != null ? (Integer)request.getAttribute("pendingCount")    : 0;
    int inProgressCount = request.getAttribute("inProgressCount") != null ? (Integer)request.getAttribute("inProgressCount") : 0;
    int resolvedCount   = request.getAttribute("resolvedCount")   != null ? (Integer)request.getAttribute("resolvedCount")   : 0;
    if (myReports   == null) myReports   = new ArrayList<>();
    if (myEquipment == null) myEquipment = new ArrayList<>();
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg"); session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Dashboard</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
:root { --bg-page: #EEF2F7; }
/* ── Role-based palette ── */
.page-hero {
    background: linear-gradient(135deg,#0D1B2A 0%,#1B3A5C 55%,#0096C7 100%);
    border-radius:14px; padding:1.8rem 2rem; margin-bottom:1.5rem;
    display:flex; align-items:center; justify-content:space-between;
    position:relative; overflow:hidden;
}
.page-hero::before { content:''; position:absolute; top:-60px; right:-50px; width:220px; height:220px; border-radius:50%; background:radial-gradient(circle,rgba(0,180,216,.15),transparent 70%); animation:pulse 4s ease-in-out infinite; }
.page-hero::after  { content:''; position:absolute; bottom:-40px; left:30%; width:150px; height:150px; border-radius:50%; background:radial-gradient(circle,rgba(0,180,216,.1),transparent 70%); animation:pulse 4s ease-in-out infinite reverse; }
@keyframes pulse { 0%,100%{transform:scale(1);opacity:.6;} 50%{transform:scale(1.15);opacity:1;} }
.page-hero h1 { font-size:1.4rem; font-weight:700; color:#fff; margin-bottom:4px; }
.page-hero p  { font-size:.78rem; color:rgba(186,230,253,.9); font-family:'Space Mono',monospace; }
.hero-actions { display:flex; gap:.6rem; position:relative; z-index:2; }

.btn-slate { display:inline-flex; align-items:center; gap:6px; padding:.5rem 1.1rem; border-radius:8px; font-family:'Sora',sans-serif; font-size:.82rem; font-weight:600; cursor:pointer; border:none; background:#00B4D8; color:#fff; text-decoration:none; box-shadow:0 2px 10px rgba(0,180,216,.35); transition:all .2s; }
.btn-slate:hover { background:#0096C7; box-shadow:0 4px 16px rgba(0,180,216,.5); transform:translateY(-1px); }
.btn-slate svg  { width:14px; height:14px; }
.btn-slate-out  { display:inline-flex; align-items:center; gap:6px; padding:.5rem 1.1rem; border-radius:8px; font-family:'Sora',sans-serif; font-size:.82rem; font-weight:500; cursor:pointer; border:1px solid rgba(0,180,216,.35); color:rgba(186,230,253,.9); background:transparent; text-decoration:none; transition:all .2s; }
.btn-slate-out:hover { background:rgba(0,180,216,.1); }
.btn-slate-out svg { width:14px; height:14px; }

/* Stat icon overrides */
.stat-icon.slate { background:rgba(0,180,216,.12);  color:#00B4D8; }
.stat-icon.lav   { background:rgba(0,180,216,.12);  color:#00B4D8; }
.stat-icon.gold  { background:rgba(222,172,76,.12);  color:#a07a1e; }
.stat-icon.sky   { background:rgba(0,180,216,.12);  color:#0096C7; }

.section-label { font-size:.68rem; font-weight:600; text-transform:uppercase; letter-spacing:1.5px; color:var(--text-muted); margin:1.4rem 0 .8rem; display:flex; align-items:center; gap:8px; }
.section-label::after { content:''; flex:1; height:1px; background:var(--border); }

.urgency-badge { display:inline-flex; align-items:center; padding:2px 9px; border-radius:20px; font-size:.67rem; font-weight:700; text-transform:uppercase; }
.urgency-low      { background:rgba(0,180,216,.12);  color:#0096C7; }
.urgency-medium   { background:rgba(222,172,76,.12);  color:#a07a1e; }
.urgency-high     { background:rgba(239,68,68,.1);    color:#dc2626; }
.urgency-critical { background:rgba(139,0,0,.12);     color:#991b1b; font-weight:800; }

.status-pill { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:600; }
.status-pill::before { content:''; width:6px; height:6px; border-radius:50%; }
.s-pending      { background:rgba(222,172,76,.12);  color:#a07a1e; }
.s-pending::before     { background:#DEAC4C; }
.s-in_progress  { background:rgba(0,180,216,.12);  color:#0096C7; }
.s-in_progress::before { background:#00B4D8; }
.s-resolved     { background:rgba(0,180,216,.12);  color:#0096C7; }
.s-resolved::before    { background:#00B4D8; }

.equip-card { background:var(--bg-card); border:1px solid var(--border); border-radius:12px; padding:1rem; display:flex; align-items:center; gap:.8rem; transition:all .2s; }
.equip-card:hover { border-color:#00B4D8; box-shadow:0 4px 16px rgba(0,180,216,.1); }
.equip-icon { width:38px; height:38px; border-radius:9px; flex-shrink:0; background:rgba(0,180,216,.1); color:#0096C7; display:flex; align-items:center; justify-content:center; }
.equip-icon svg { width:18px; height:18px; }
</style>
</head>
<body>
<div class="app">
    <%@ include file="../admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <div class="topbar-left">
                <div class="topbar-breadcrumb"><span>ME2MS</span><span class="sep">/</span><span style="color:var(--text);font-weight:500;">Dashboard</span></div>
            </div>
            <div class="topbar-right">
                <span style="font-size:.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;"><%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %></span>
            </div>
        </div>
        <div class="content">
            <% if (successMsg != null) { %><div class="flash flash-success"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg><%= successMsg %></div><% } %>
            <% if (errorMsg   != null) { %><div class="flash flash-error"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg><%= errorMsg %></div><% } %>

            <!-- HERO -->
            <div class="page-hero">
                <div style="position:relative;z-index:2;">
                    <h1>🏥 Hello, <%= currentUser.getFirstName() %></h1>
                    <p>// <%= myReports.size() %> reports · <%= pendingCount %> pending · <%= resolvedCount %> resolved</p>
                </div>
                <div class="hero-actions">
                    <a href="<%= request.getContextPath() %>/faultreports?action=new" class="btn-slate">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Report a Fault
                    </a>
                    <a href="<%= request.getContextPath() %>/manuals" class="btn-slate-out">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                        Manuals Library
                    </a>
                </div>
            </div>

            <!-- STATS -->
            <div class="stats-grid" style="margin-bottom:1.5rem;">
                <div class="stat-card"><div class="stat-icon gold"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div><div><div class="stat-value"><%= pendingCount %></div><div class="stat-label">Pending</div></div></div>
                <div class="stat-card"><div class="stat-icon slate"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg></div><div><div class="stat-value"><%= inProgressCount %></div><div class="stat-label">In Progress</div></div></div>
                <div class="stat-card"><div class="stat-icon sky"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></div><div><div class="stat-value"><%= resolvedCount %></div><div class="stat-label">Resolved</div></div></div>
                <div class="stat-card"><div class="stat-icon lav"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div><div><div class="stat-value"><%= myReports.size() %></div><div class="stat-label">Total</div></div></div>
            </div>

            <!-- RECENT REPORTS -->
            <div class="section-label"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>My Latest Reports</div>
            <div class="card" style="margin-bottom:1.5rem;">
                <div class="card-header">
                    <h3><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color:#0096C7;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>Fault Reports</h3>
                    <a href="<%= request.getContextPath() %>/faultreports" class="btn btn-outline btn-sm">View all</a>
                </div>
                <div class="table-wrap">
                    <% if (myReports.isEmpty()) { %>
                    <div class="empty-state"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="36" height="36"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg><p>No reports submitted yet.</p></div>
                    <% } else { %>
                    <table>
                        <thead><tr><th>#</th><th>Equipment</th><th>Room</th><th>Description</th><th>Urgency</th><th>Status</th><th>Date</th></tr></thead>
                        <tbody>
                        <% for (int i = 0; i < Math.min(myReports.size(), 8); i++) {
                            FaultReport r = myReports.get(i);
                            String st  = r.getStatus()  != null ? r.getStatus().toLowerCase().replace(" ","_") : "pending";
                            String urg = r.getUrgency() != null ? r.getUrgency().toLowerCase() : "low";
                        %>
                        <tr>
                            <td style="font-family:'Space Mono',monospace;font-size:.72rem;color:var(--text-muted);">#<%= r.getFaultId() %></td>
                            <td style="font-size:.8rem;font-weight:600;">Equip. #<%= r.getEquipmentId() %></td>
                            <td style="font-size:.78rem;color:var(--text-muted);"><%= r.getRoom()!=null&&!r.getRoom().isEmpty()?r.getRoom():"—" %></td>
                            <td style="font-size:.76rem;color:var(--text-muted);max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<%= r.getDescription() %>"><%= r.getDescription() %></td>
                            <td><span class="urgency-badge urgency-<%= urg %>"><%= r.getUrgency() %></span></td>
                            <td><span class="status-pill s-<%= st %>"><%= r.getStatus() %></span></td>
                            <td style="font-size:.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;white-space:nowrap;"><%= r.getReportDate()!=null?new java.text.SimpleDateFormat("dd/MM/yy HH:mm").format(r.getReportDate()):"—" %></td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                    <% } %>
                </div>
            </div>

            <!-- EQUIPMENT -->
            <div class="section-label"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="13" height="13"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>My Department Equipment</div>
            <% if (myEquipment.isEmpty()) { %>
            <div class="card"><div class="empty-state"><p>No equipment linked to your department.</p></div></div>
            <% } else { %>
            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:.8rem;margin-bottom:1.5rem;">
                <% for (Equipment eq : myEquipment) { %>
                <div class="equip-card">
                    <div class="equip-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg></div>
                    <div style="min-width:0;">
                        <div style="font-size:.82rem;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"><%= eq.getName() %></div>
                        <div style="font-size:.7rem;color:var(--text-muted);font-family:'Space Mono',monospace;"><%= eq.getBrand()!=null?eq.getBrand():"" %> <%= eq.getModel()!=null?eq.getModel():"" %></div>
                        <span class="badge <%= "active".equalsIgnoreCase(eq.getStatus())?"badge-green":"badge-amber" %>" style="font-size:.62rem;padding:1px 7px;margin-top:4px;display:inline-flex;"><%= eq.getStatus() %></span>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
</div>
</body>
</html>
