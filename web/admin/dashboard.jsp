<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("Administrator")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "dashboard");

    // Data from DashboardServlet
    int totalUsers        = (Integer) request.getAttribute("totalUsers");
    int totalAdmins       = (Integer) request.getAttribute("totalAdmins");
    int totalManagers     = (Integer) request.getAttribute("totalManagers");
    int totalDoctors      = (Integer) request.getAttribute("totalDoctors");
    int totalNurses       = (Integer) request.getAttribute("totalNurses");
    int totalDepartments  = (Integer) request.getAttribute("totalDepartments");
    int activeDepartments = (Integer) request.getAttribute("activeDepartments");
    List<AuditLog> recentActivity = (List<AuditLog>) request.getAttribute("recentActivity");

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Admin Dashboard</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
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
                    <span style="color:var(--text);font-weight:500;">Dashboard</span>
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

            <!-- Page header -->
            <div class="page-header">
                <div class="page-header-left">
                    <h1>Administrator Dashboard</h1>
                    <p>System overview and recent activity</p>
                </div>
                <div style="display:flex;gap:0.6rem;">
                    <a href="<%= request.getContextPath() %>/users?action=new" class="btn btn-primary">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        New User
                    </a>
                    <a href="<%= request.getContextPath() %>/departments?action=new" class="btn btn-outline">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        New Department
                    </a>
                </div>
            </div>

            <!-- Stats row 1 — Users -->
            <div style="margin-bottom:0.5rem;">
                <p style="font-size:0.72rem;font-weight:600;text-transform:uppercase;letter-spacing:1px;color:var(--text-muted);margin-bottom:0.8rem;">User Statistics</p>
            </div>
            <div class="stats-grid" style="margin-bottom:1rem;">
                <div class="stat-card">
                    <div class="stat-icon cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalUsers %></div>
                        <div class="stat-label">Total Users</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon navy">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalAdmins %></div>
                        <div class="stat-label">Administrators</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon blue">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalManagers %></div>
                        <div class="stat-label">Tech Managers</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalDoctors %></div>
                        <div class="stat-label">Doctors</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon amber">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalNurses %></div>
                        <div class="stat-label">Nurses</div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalDepartments %></div>
                        <div class="stat-label">Departments</div>
                    </div>
                </div>
            </div>

            <!-- Recent activity table -->
            <div class="card">
                <div class="card-header">
                    <h3>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                        <line x1="16" y1="13" x2="8" y2="13"/>
                        <line x1="16" y1="17" x2="8" y2="17"/></svg>
                        Recent System Activity
                    </h3>
                    <a href="<%= request.getContextPath() %>/audit-log" class="btn btn-outline btn-sm">View All</a>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Action</th>
                                <th>Details</th>
                                <th>User ID</th>
                                <th>Date &amp; Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (recentActivity == null || recentActivity.isEmpty()) { %>
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/></svg>
                                        <p>No activity recorded yet.</p>
                                    </div>
                                </td>
                            </tr>
                            <% } else {
                                for (AuditLog log : recentActivity) { %>
                            <tr>
                                <td style="font-family:'Space Mono',monospace;font-size:0.75rem;color:var(--text-muted);">#<%= log.getAuditLogId() %></td>
                                <td>
                                    <span class="badge
                                        <%= log.getAction().contains("LOGIN")  ? "badge-green"  :
                                            log.getAction().contains("LOGOUT") ? "badge-gray"   :
                                            log.getAction().contains("CREATE") ? "badge-cyan"   :
                                            log.getAction().contains("DELETE") ? "badge-red"    :
                                            log.getAction().contains("UPDATE") ? "badge-amber"  : "badge-blue" %>">
                                        <%= log.getAction() %>
                                    </span>
                                </td>
                                <td style="max-width:280px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:0.8rem;color:var(--text-muted);">
                                    <%= log.getDetails() %>
                                </td>
                                <td style="font-family:'Space Mono',monospace;font-size:0.75rem;color:var(--text-muted);">
                                    <%= log.getUserId() %>
                                </td>
                                <td style="font-size:0.75rem;color:var(--text-muted);white-space:nowrap;font-family:'Space Mono',monospace;">
                                    <%= log.getActionDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(log.getActionDate()) : "—" %>
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
</body>
</html>
