<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="Metier.Notification" %>
<%
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";
    Metier.Users sidebarUser = (Metier.Users) session.getAttribute("currentUser");
    String sidebarRole = sidebarUser != null ? sidebarRole = sidebarUser.getRole() : "";
    
    // Calculate unread count using the existing sidebarUser object
    int unreadCount = (sidebarUser != null) ? Notification.compterNonLus(sidebarUser.getUserId()) : 0;
%>
<!-- ── SIDEBAR ── -->
<aside class="sidebar" id="sidebar">
    <div class="sb-logo">
        <div class="sb-logo-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="22" height="22">
                <path d="M12 2v20M2 12h20"/>
                <circle cx="12" cy="12" r="5" stroke-opacity="0.4"/>
            </svg>
        </div>
        <div class="sb-logo-text">ME<span>2</span>MS</div>
    </div>

    <div class="sb-user">
        <div class="sb-avatar"><%= sidebarUser != null ? sidebarUser.getFirstName().substring(0,1).toUpperCase() : "?" %></div>
        <div class="sb-user-info">
            <div class="sb-user-name"><%= sidebarUser != null ? sidebarUser.getFirstName() + " " + sidebarUser.getLastName() : "" %></div>
            <div class="sb-user-role"><%= sidebarRole.replace("_"," ") %></div>
        </div>
        
        <!-- 🔔 NOTIFICATION BELL -->
        <div style="position:relative; display:inline-block; margin-left: auto; padding-right: 10px;">
            <a href="<%= request.getContextPath() %>/NotificationServlet?action=markAllRead" style="text-decoration:none; font-size:20px;">🔔</a>
            <% if (unreadCount > 0) { %>
                <span style="position:absolute; top:-5px; right:2px; background:#ff4757; color:white; border-radius:50%; font-size:10px; min-width:16px; height:16px; display:flex; align-items:center; justify-content:center; font-weight:bold; border: 2px solid #fff;">
                    <%= unreadCount %>
                </span>
            <% } %>
        </div>
    </div>

    <nav class="sb-nav">
        <div class="sb-section-label">Main</div>

        <% if (sidebarRole.equals("Administrator")) { %>
        <a href="<%= request.getContextPath() %>/dashboard" class="sb-link <%= currentPage.equals("dashboard") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Dashboard
        </a>
        <a href="<%= request.getContextPath() %>/users" class="sb-link <%= currentPage.equals("users") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            Users
        </a>
        <a href="<%= request.getContextPath() %>/departments" class="sb-link <%= currentPage.equals("departments") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            Departments
        </a>
        <a href="<%= request.getContextPath() %>/audit-log" class="sb-link <%= currentPage.equals("audit-log") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
            Audit Log
        </a>
        <% } %>

        <% if (sidebarRole.equals("Technical_Manager")) { %>
        <a href="<%= request.getContextPath() %>/dashboard" class="sb-link <%= currentPage.equals("dashboard") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Dashboard
        </a>
        <a href="<%= request.getContextPath() %>/equipment" class="sb-link <%= currentPage.equals("equipment") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
            Equipment
        </a>
        <a href="<%= request.getContextPath() %>/faultreports" class="sb-link <%= currentPage.equals("faultreports") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            Fault Reports
        </a>
        <a href="<%= request.getContextPath() %>/maintenance" class="sb-link <%= currentPage.equals("maintenance") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93l-1.41 1.41M4.93 4.93l1.41 1.41M19.07 19.07l-1.41-1.41M4.93 19.07l1.41-1.41M12 2v2M12 20v2M2 12h2M20 12h2"/></svg>
            Maintenance
        </a>
        <a href="<%= request.getContextPath() %>/manuals" class="sb-link <%= currentPage.equals("manuals") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            Manuals
        </a>
        <% } %>

        <% if (sidebarRole.equals("Doctor") || sidebarRole.equals("Nurse")) { %>
        <a href="<%= request.getContextPath() %>/dashboard" class="sb-link <%= currentPage.equals("dashboard") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Dashboard
        </a>
        <a href="<%= request.getContextPath() %>/faultreports?action=new" class="sb-link <%= currentPage.equals("report") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/></svg>
            Report Fault
        </a>
        <a href="<%= request.getContextPath() %>/faultreports" class="sb-link <%= currentPage.equals("myreports") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            My Reports
        </a>
        <a href="<%= request.getContextPath() %>/equipment" class="sb-link <%= currentPage.equals("equipment") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
            Equipment
        </a>
        <a href="<%= request.getContextPath() %>/manuals" class="sb-link <%= currentPage.equals("manuals") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            Manuals
        </a>
        <% } %>
    </nav>

    <a href="<%= request.getContextPath() %>/logout" class="sb-logout">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        Sign Out
    </a>
</aside>