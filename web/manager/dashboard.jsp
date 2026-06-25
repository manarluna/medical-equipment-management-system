<%--Equipment stats, ticket stats, critical alert banner
Recent fault reports + recent tickets side by side
Upcoming maintenance table --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("Technical_Manager")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "dashboard");

    int totalEquipment = (Integer) request.getAttribute("totalEquipment");
    int activeEquipment  = (Integer) request.getAttribute("activeEquipment");
    int underMaintenance = (Integer) request.getAttribute("underMaintenance");
    int outOfService  = (Integer) request.getAttribute("outOfService");
    int openTickets  = (Integer) request.getAttribute("openTickets");
    int inProgressTickets = (Integer) request.getAttribute("inProgressTickets");
    int resolvedThisMonth = (Integer) request.getAttribute("resolvedThisMonth");
    int pendingFaultReports  = (Integer) request.getAttribute("pendingFaultReports");
    int criticalFaultReports = (Integer) request.getAttribute("criticalFaultReports");

    List<FaultReport> recentFaultReports = (List<FaultReport>)  request.getAttribute("recentFaultReports");
    List<MaintenanceTicket> recentTickets = (List<MaintenanceTicket>) request.getAttribute("recentTickets");
    List<MaintenanceTicket> upcomingMaintenance= (List<MaintenanceTicket>) request.getAttribute("upcomingMaintenance");

    if (recentFaultReports  == null) recentFaultReports  = new ArrayList<>();
    if (recentTickets       == null) recentTickets       = new ArrayList<>();
    if (upcomingMaintenance == null) upcomingMaintenance = new ArrayList<>();

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg  = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Manager Dashboard</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
    
.page-hero {
    background: linear-gradient(135deg,#021B2F 0%,#0B385A 55%,#1C8BC0 100%);
    border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem;
    display:flex; align-items:center; justify-content:space-between;
    position:relative; overflow:hidden;
}
.page-hero::before {
    content:''; position:absolute; top:-60px; right:-60px;
    width:220px; height:220px; border-radius:50%;
    background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%);
    animation:glow 4s ease-in-out infinite;
}
@keyframes glow { 0%,100%{transform:scale(1);opacity:.6;} 50%{transform:scale(1.1);opacity:1;} }
.page-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.page-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }
.hero-actions { display:flex; gap:0.6rem; position:relative; z-index:2; }

.section-label {
    font-size:0.68rem; font-weight:600; text-transform:uppercase;
    letter-spacing:1.5px; color:var(--text-muted); margin:1.4rem 0 0.8rem;
    display:flex; align-items:center; gap:8px;
}
.section-label::after { content:''; flex:1; height:1px; background:var(--border); }

.urgency-badge { display:inline-flex; align-items:center; gap:4px; padding:2px 9px; border-radius:20px; font-size:0.67rem; font-weight:700; text-transform:uppercase; }
.urgency-low      { background:rgba(34,197,94,0.1);   color:#15803d; }
.urgency-medium   { background:rgba(245,158,11,0.1);  color:#b45309; }
.urgency-high     { background:rgba(239,68,68,0.1);   color:#dc2626; }
.urgency-critical { background:rgba(139,0,0,0.12);    color:#991b1b; }

.ticket-status { display:inline-flex; align-items:center; gap:5px; padding:2px 9px; border-radius:20px; font-size:0.67rem; font-weight:600; }
.ticket-status::before { content:''; width:5px; height:5px; border-radius:50%; }
.status-open        { background:rgba(245,158,11,0.1);  color:#b45309; }
.status-open::before        { background:#f59e0b; }
.status-in_progress { background:rgba(28,139,192,0.1);  color:var(--blue); }
.status-in_progress::before { background:var(--blue); }
.status-resolved    { background:rgba(34,197,94,0.1);   color:#15803d; }
.status-resolved::before    { background:#22c55e; }
.status-received    { background:rgba(100,116,139,0.1); color:#475569; }
.status-received::before    { background:#94a3b8; }

.two-col { display:grid; grid-template-columns:1fr 1fr; gap:1rem; }
@media(max-width:900px){ .two-col { grid-template-columns:1fr; } }

.alert-critical {
    background:rgba(239,68,68,0.06); border:1px solid rgba(239,68,68,0.2);
    border-radius:10px; padding:0.8rem 1rem; margin-bottom:1rem;
    display:flex; align-items:center; gap:10px; font-size:0.82rem; color:#dc2626;
}
.alert-critical svg { width:16px; height:16px; flex-shrink:0; }
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
                    <span style="color:var(--text);font-weight:500;">Dashboard</span>
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
            <div class="flash flash-success"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg><%= successMsg %></div>
            <% } %>
            <% if (errorMsg != null) { %>
            <div class="flash flash-error"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg><%= errorMsg %></div>
            <% } %>

            <!-- HERO -->
            <div class="page-hero">
                <div>
                    <h1>🔧 Technical Manager Dashboard</h1>
                    <p>// Welcome back, <%= currentUser.getFirstName() %> — <%= new java.text.SimpleDateFormat("EEEE dd MMMM yyyy").format(new java.util.Date()) %></p>
                </div>
                <div class="hero-actions">
                    <a href="<%= request.getContextPath() %>/equipment?action=new" class="btn btn-cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Add Equipment
                    </a>
                    <a href="<%= request.getContextPath() %>/faultreports" class="btn btn-outline" style="border-color:rgba(144,230,255,0.3);color:rgba(144,230,255,0.8);background:rgba(0,0,0,0.2);">
                        View Tickets
                    </a>
                </div>
            </div>

            <!-- Critical alert -->
            <% if (criticalFaultReports > 0) { %>
            <div class="alert-critical">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                <strong><%= criticalFaultReports %> CRITICAL</strong> fault report(s) require immediate attention!
                <a href="<%= request.getContextPath() %>/faultreports" style="margin-left:auto;color:#dc2626;font-weight:600;text-decoration:none;">View →</a>
            </div>
            <% } %>

            <!-- EQUIPMENT STATS -->
            <div class="section-label">Equipment Overview</div>
            <div class="stats-grid" style="margin-bottom:1rem;">
                <div class="stat-card">
                    <div class="stat-icon cyan"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg></div>
                    <div><div class="stat-value"><%= totalEquipment %></div><div class="stat-label">Total Equipment</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></div>
                    <div><div class="stat-value"><%= activeEquipment %></div><div class="stat-label">Active</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93l-1.41 1.41M4.93 4.93l1.41 1.41M19.07 19.07l-1.41-1.41M4.93 19.07l1.41-1.41M12 2v2M12 20v2M2 12h2M20 12h2"/></svg></div>
                    <div><div class="stat-value"><%= underMaintenance %></div><div class="stat-label">Under Maintenance</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg></div>
                    <div><div class="stat-value"><%= outOfService %></div><div class="stat-label">Out of Service</div></div>
                </div>
            </div>

            <!-- TICKET STATS -->
            <div class="section-label">Ticket Overview</div>
            <div class="stats-grid" style="margin-bottom:1.5rem;">
                <div class="stat-card">
                    <div class="stat-icon amber"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg></div>
                    <div><div class="stat-value"><%= pendingFaultReports %></div><div class="stat-label">Pending Reports</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                    <div><div class="stat-value"><%= openTickets %></div><div class="stat-label">Open Tickets</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon cyan"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77"/></svg></div>
                    <div><div class="stat-value"><%= inProgressTickets %></div><div class="stat-label">In Progress</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
                    <div><div class="stat-value"><%= resolvedThisMonth %></div><div class="stat-label">Resolved This Month</div></div>
                </div>
            </div>

            <!-- TWO COLUMN: Recent Fault Reports + Upcoming Maintenance -->
            <div class="two-col">

                <!-- Recent Fault Reports -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                            Recent Fault Reports
                        </h3>
                        <a href="<%= request.getContextPath() %>/faultreports" class="btn btn-outline btn-sm">View All</a>
                    </div>
                    <div class="table-wrap">
                        <table>
                            <thead><tr><th>ID</th><th>Equipment</th><th>Urgency</th><th>Status</th></tr></thead>
                            <tbody>
                                <% if (recentFaultReports.isEmpty()) { %>
                                <tr><td colspan="4"><div class="empty-state"><p>No fault reports yet.</p></div></td></tr>
                                <% } else { for (FaultReport fr : recentFaultReports) { %>
                                <tr>
                                    <td class="log-id">#<%= fr.getFaultId() %></td>
                                    <td style="font-size:0.8rem;">Equip. #<%= fr.getEquipmentId() %></td>
                                    <td><span class="urgency-badge urgency-<%= fr.getUrgency() != null ? fr.getUrgency().toLowerCase() : "low" %>"><%= fr.getUrgency() %></span></td>
                                    <td><span class="ticket-status status-<%= fr.getStatus() != null ? fr.getStatus().toLowerCase().replace(" ","_") : "pending" %>"><%= fr.getStatus() %></span></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Recent Maintenance Tickets -->
                <div class="card">
                    <div class="card-header">
                        <h3>
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93l-1.41 1.41M4.93 4.93l1.41 1.41M19.07 19.07l-1.41-1.41M4.93 19.07l1.41-1.41M12 2v2M12 20v2M2 12h2M20 12h2"/></svg>
                            Recent Tickets
                        </h3>
                        <a href="<%= request.getContextPath() %>/maintenance" class="btn btn-outline btn-sm">View All</a>
                    </div>
                    <div class="table-wrap">
                        <table>
                            <thead><tr><th>ID</th><th>Type</th><th>Equipment</th><th>Status</th></tr></thead>
                            <tbody>
                                <% if (recentTickets.isEmpty()) { %>
                                <tr><td colspan="4"><div class="empty-state"><p>No tickets yet.</p></div></td></tr>
                                <% } else { for (MaintenanceTicket t : recentTickets) { %>
                                <tr>
                                    <td class="log-id">#<%= t.getMaintenanceId() %></td>
                                    <td style="font-size:0.8rem;"><span class="badge <%= "Preventive".equals(t.getType()) ? "badge-cyan" : "badge-amber" %>"><%= t.getType() %></span></td>
                                    <td style="font-size:0.8rem;">Equip. #<%= t.getEquipmentid() %></td>
                                    <td><span class="ticket-status status-<%= t.getStatus() != null ? t.getStatus().toLowerCase().replace(" ","_") : "open" %>"><%= t.getStatus() %></span></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div><!-- /two-col -->

            <!-- Upcoming Preventive Maintenance -->
            <% if (!upcomingMaintenance.isEmpty()) { %>
            <div class="section-label" style="margin-top:1.5rem;">Upcoming Preventive Maintenance</div>
            <div class="card">
                <div class="card-header">
                    <h3>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        Due Within 7 Days
                    </h3>
                    <span class="badge badge-amber"><%= upcomingMaintenance.size() %> upcoming</span>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Ticket ID</th><th>Equipment</th><th>Due Date</th><th>Status</th></tr></thead>
                        <tbody>
                            <% for (MaintenanceTicket t : upcomingMaintenance) { %>
                            <tr>
                                <td class="log-id">#<%= t.getMaintenanceId() %></td>
                                <td style="font-size:0.8rem;">Equipment #<%= t.getEquipmentid() %></td>
                                <td style="font-size:0.78rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                                    <%= t.getClosureDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(t.getClosureDate()) : "—" %>
                                </td>
                                <td><span class="ticket-status status-<%= t.getStatus() != null ? t.getStatus().toLowerCase() : "open" %>"><%= t.getStatus() %></span></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% } %>

        </div>
    </div>
</div>
</body>
</html>
