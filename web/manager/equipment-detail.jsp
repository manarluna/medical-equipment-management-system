<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    request.setAttribute("currentPage", "equipment");

    Equipment equipment = (Equipment) request.getAttribute("equipment");
    if (equipment == null) { response.sendRedirect(request.getContextPath() + "/equipment"); return; }

    boolean canEdit = role.equals("Administrator") || role.equals("Technical_Manager");

    // Load maintenance history and manuals for this equipment
    List<MaintenanceTicket> history = MaintenanceTicket.chercher_equipement(equipment.getEquipmentId());
    List<Manual>            manuals = Manual.chercher_equipement(equipment.getEquipmentId());
    Department dept = Department.chercher_id(equipment.getDepartmentId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — <%= equipment.getName() %></title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
.page-hero { background:linear-gradient(135deg,#021B2F 0%,#0B385A 55%,#1C8BC0 100%); border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-60px; right:-60px; width:200px; height:200px; border-radius:50%; background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%); }
.page-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.page-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }

.two-col { display:grid; grid-template-columns:1fr 1.6fr; gap:1rem; }
@media(max-width:900px){ .two-col { grid-template-columns:1fr; } }

.info-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; box-shadow:var(--shadow); overflow:hidden; }
.info-card-header { padding:1rem 1.4rem; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:8px; background:#f8fafc; }
.info-card-header svg { width:16px; height:16px; color:var(--cyan); }
.info-card-header h3 { font-size:0.88rem; font-weight:600; color:var(--text); }

.info-row { display:flex; align-items:flex-start; gap:1rem; padding:0.8rem 1.4rem; border-bottom:1px solid #f0f4f8; }
.info-row:last-child { border-bottom:none; }
.info-label { font-size:0.72rem; font-weight:600; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-muted); min-width:110px; padding-top:1px; }
.info-value { font-size:0.85rem; color:var(--text); font-weight:500; }

.asset-tag { font-family:'Space Mono',monospace; font-size:0.8rem; color:var(--cyan); background:rgba(45,186,225,0.08); border:1px solid rgba(45,186,225,0.15); padding:3px 10px; border-radius:6px; display:inline-block; }

.eq-status { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:0.72rem; font-weight:600; }
.eq-status::before { content:''; width:7px; height:7px; border-radius:50%; }
.eq-active      { background:rgba(34,197,94,0.1);   color:#15803d; }
.eq-active::before      { background:#22c55e; }
.eq-maintenance { background:rgba(245,158,11,0.1);  color:#b45309; }
.eq-maintenance::before { background:#f59e0b; }
.eq-out         { background:rgba(239,68,68,0.1);   color:#dc2626; }
.eq-out::before { background:#ef4444; }
.eq-decom       { background:rgba(100,116,139,0.1); color:#475569; }
.eq-decom::before { background:#94a3b8; }

.ticket-status { display:inline-flex; align-items:center; gap:5px; padding:2px 8px; border-radius:20px; font-size:0.67rem; font-weight:600; }
.ticket-status::before { content:''; width:5px; height:5px; border-radius:50%; }
.ts-open,.ts-received { background:rgba(100,116,139,0.1); color:#475569; }
.ts-open::before,.ts-received::before { background:#94a3b8; }
.ts-in_progress { background:rgba(28,139,192,0.1); color:var(--blue); }
.ts-in_progress::before { background:var(--blue); }
.ts-resolved { background:rgba(34,197,94,0.1); color:#15803d; }
.ts-resolved::before { background:#22c55e; }

.section-label { font-size:0.68rem; font-weight:600; text-transform:uppercase; letter-spacing:1.5px; color:var(--text-muted); margin:1.4rem 0 0.8rem; display:flex; align-items:center; gap:8px; }
.section-label::after { content:''; flex:1; height:1px; background:var(--border); }
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
                    <a href="<%= request.getContextPath() %>/equipment" style="color:var(--text-muted);text-decoration:none;">Equipment</a>
                    <span class="sep">/</span>
                    <span style="color:var(--text);font-weight:500;"><%= equipment.getName() %></span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:0.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                    <%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %>
                </span>
            </div>
        </div>
        <div class="content">

            <%
                String st = equipment.getStatus() != null ? equipment.getStatus().toLowerCase() : "";
                String statusClass = st.contains("active") ? "eq-active" :
                                     st.contains("maintenance") ? "eq-maintenance" :
                                     st.contains("out") ? "eq-out" : "eq-decom";
            %>

            <div class="page-hero">
                <div>
                    <h1>⚙️ <%= equipment.getName() %></h1>
                    <p>// <%= equipment.getAssetId() %> · <%= dept != null ? dept.getName() : "Unknown department" %></p>
                </div>
                <div style="display:flex;gap:0.5rem;position:relative;z-index:2;">
                    <% if (canEdit) { %>
                    <a href="<%= request.getContextPath() %>/equipment?action=edit&id=<%= equipment.getEquipmentId() %>" class="btn btn-cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                        Edit
                    </a>
                    <% } %>
                    <a href="<%= request.getContextPath() %>/equipment" class="btn btn-outline" style="border-color:rgba(144,230,255,0.3);color:rgba(144,230,255,0.8);background:rgba(0,0,0,0.2);">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                        Back
                    </a>
                </div>
            </div>

            <div class="two-col">
                <!-- Equipment Info -->
                <div class="info-card">
                    <div class="info-card-header">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77"/></svg>
                        <h3>Equipment Details</h3>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Asset ID</span>
                        <span class="asset-tag"><%= equipment.getAssetId() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Name</span>
                        <span class="info-value"><%= equipment.getName() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Brand</span>
                        <span class="info-value"><%= equipment.getBrand() != null && !equipment.getBrand().isEmpty() ? equipment.getBrand() : "—" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Model</span>
                        <span class="info-value"><%= equipment.getModel() != null && !equipment.getModel().isEmpty() ? equipment.getModel() : "—" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Serial No.</span>
                        <span class="info-value" style="font-family:'Space Mono',monospace;font-size:0.78rem;"><%= equipment.getSerialNumber() != null && !equipment.getSerialNumber().isEmpty() ? equipment.getSerialNumber() : "—" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Department</span>
                        <span class="info-value"><%= dept != null ? dept.getName() : "—" %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Purchase Date</span>
                        <span class="info-value" style="font-family:'Space Mono',monospace;font-size:0.78rem;">
                            <%= equipment.getPurchaseDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(equipment.getPurchaseDate()) : "—" %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Status</span>
                        <span class="eq-status <%= statusClass %>"><%= equipment.getStatus() %></span>
                    </div>
                </div>

                <!-- Right column: history + manuals -->
                <div>
                    <!-- Maintenance History -->
                    <div class="section-label">Maintenance History</div>
                    <div class="info-card" style="margin-bottom:1rem;">
                        <div class="table-wrap">
                            <% if (history.isEmpty()) { %>
                            <div class="empty-state" style="padding:2rem 1rem;">
                                <p>No maintenance history yet.</p>
                            </div>
                            <% } else { %>
                            <table>
                                <thead><tr><th>#</th><th>Type</th><th>Status</th><th>Date</th></tr></thead>
                                <tbody>
                                    <% for (MaintenanceTicket t : history) {
                                        String ts = t.getStatus() != null ? t.getStatus().toLowerCase().replace(" ","_") : "open";
                                    %>
                                    <tr>
                                        <td style="font-family:'Space Mono',monospace;font-size:0.72rem;color:var(--text-muted);">#<%= t.getMaintenanceId() %></td>
                                        <td><span class="badge <%= "Preventive".equals(t.getType()) ? "badge-cyan" : "badge-amber" %>"><%= t.getType() %></span></td>
                                        <td><span class="ticket-status ts-<%= ts.contains("progress") ? "in_progress" : ts %>"><%= t.getStatus() %></span></td>
                                        <td style="font-size:0.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                                            <%= t.getCreationDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(t.getCreationDate()) : "—" %>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                            <% } %>
                        </div>
                    </div>

                    <!-- Manuals -->
                    <div class="section-label">Documents & Manuals</div>
                    <div class="info-card">
                        <div class="table-wrap">
                            <% if (manuals.isEmpty()) { %>
                            <div class="empty-state" style="padding:2rem 1rem;">
                                <p>No manuals uploaded for this equipment.</p>
                            </div>
                            <% } else { %>
                            <table>
                                <thead><tr><th>Title</th><th>Type</th><th>Date</th><th>View</th></tr></thead>
                                <tbody>
                                    <% for (Manual m : manuals) { %>
                                    <tr>
                                        <td style="font-size:0.82rem;font-weight:600;"><%= m.getTitle() %></td>
                                        <td style="font-size:0.75rem;color:var(--text-muted);"><%= m.getTypeDoc() != null ? m.getTypeDoc() : "—" %></td>
                                        <td style="font-size:0.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                                            <%= m.getDateUpload() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(m.getDateUpload()) : "—" %>
                                        </td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/<%= m.getFilePath() %>" target="_blank" class="btn btn-outline btn-sm">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                                PDF
                                            </a>
                                        </td>
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
    </div>
</div>
</body>
</html>
