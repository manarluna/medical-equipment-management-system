<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    request.setAttribute("currentPage", "equipment");

    List<Equipment>  equipmentList = (List<Equipment>)  request.getAttribute("equipmentList");
    List<Department> departments   = (List<Department>) request.getAttribute("departments");
    if (equipmentList == null) equipmentList = Equipment.liste();
    if (departments   == null) departments   = Department.liste();

    boolean canEdit = role.equals("Administrator") || role.equals("Technical_Manager");

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    long activeCount   = equipmentList.stream().filter(e -> "active".equalsIgnoreCase(e.getStatus())).count();
    long maintCount    = equipmentList.stream().filter(e -> e.getStatus() != null && e.getStatus().toLowerCase().contains("maintenance")).count();
    long outCount      = equipmentList.stream().filter(e -> e.getStatus() != null && e.getStatus().toLowerCase().contains("out")).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Equipment</title>
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
.toolbar-left  { display:flex; align-items:center; gap:0.6rem; flex-wrap:wrap; }
.toolbar-right { display:flex; align-items:center; gap:0.6rem; }

.filter-pill { display:inline-flex; align-items:center; gap:5px; padding:5px 12px; border-radius:20px; border:1px solid var(--border); background:var(--bg-card); font-size:0.73rem; font-weight:600; color:var(--text-muted); cursor:pointer; transition:all 0.18s; }
.filter-pill:hover        { border-color:var(--cyan); color:var(--cyan); }
.filter-pill.active       { background:var(--cyan); border-color:var(--cyan); color:#fff; }
.filter-pill.green.active { background:#22c55e; border-color:#22c55e; color:#fff; }
.filter-pill.amber.active { background:#f59e0b; border-color:#f59e0b; color:#fff; }
.filter-pill.red.active   { background:#ef4444; border-color:#ef4444; color:#fff; }

.search-box { position:relative; display:flex; align-items:center; }
.search-box svg { position:absolute; left:10px; width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-box input { height:34px; padding:0 12px 0 32px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:0.8rem; color:var(--text); background:var(--bg-card); outline:none; width:200px; transition:all 0.2s; }
.search-box input:focus { border-color:var(--cyan); box-shadow:0 0 0 3px rgba(45,186,225,0.1); width:240px; }

.result-count { font-size:0.72rem; color:var(--text-muted); font-family:'Space Mono',monospace; padding:4px 10px; background:var(--bg-page); border:1px solid var(--border); border-radius:20px; }

/* Equipment table card */
.eq-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; overflow:hidden; box-shadow:var(--shadow); }
.eq-card-header { padding:1rem 1.4rem; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; background:#f8fafc; }
.eq-card-header h3 { font-size:0.88rem; font-weight:600; color:var(--text); display:flex; align-items:center; gap:8px; }
.eq-card-header h3 svg { width:16px; height:16px; color:var(--cyan); }

.eq-status { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:0.68rem; font-weight:600; white-space:nowrap; }
.eq-status::before { content:''; width:6px; height:6px; border-radius:50%; }
.eq-active         { background:rgba(34,197,94,0.1);   color:#15803d; }
.eq-active::before { background:#22c55e; }
.eq-maintenance    { background:rgba(245,158,11,0.1);  color:#b45309; }
.eq-maintenance::before { background:#f59e0b; }
.eq-out            { background:rgba(239,68,68,0.1);   color:#dc2626; }
.eq-out::before    { background:#ef4444; }
.eq-decommissioned { background:rgba(100,116,139,0.1); color:#475569; }
.eq-decommissioned::before { background:#94a3b8; }

.asset-id { font-family:'Space Mono',monospace; font-size:0.7rem; color:var(--cyan); background:rgba(45,186,225,0.08); border:1px solid rgba(45,186,225,0.15); padding:2px 7px; border-radius:5px; }

.icon-btn { width:30px; height:30px; border-radius:7px; display:flex; align-items:center; justify-content:center; border:1px solid var(--border); background:transparent; color:var(--text-muted); cursor:pointer; transition:all 0.18s; text-decoration:none; }
.icon-btn svg { width:13px; height:13px; }
.icon-btn:hover { border-color:var(--cyan); color:var(--cyan); background:rgba(45,186,225,0.06); }
.icon-btn.danger:hover { border-color:var(--danger); color:var(--danger); background:rgba(239,68,68,0.06); }

.eq-row[data-hidden="true"] { display:none; }
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
                    <span style="color:var(--text);font-weight:500;">Equipment</span>
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
                    <h1>⚙️ Equipment Registry</h1>
                    <p>// <%= equipmentList.size() %> total · <%= activeCount %> active · <%= maintCount %> in maintenance · <%= outCount %> out of service</p>
                </div>
                <% if (canEdit) { %>
                <a href="<%= request.getContextPath() %>/equipment?action=new" class="btn btn-cyan" style="position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add Equipment
                </a>
                <% } %>
            </div>

            <!-- Stats -->
            <div style="display:flex;gap:0.8rem;margin-bottom:1.5rem;flex-wrap:wrap;">
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;box-shadow:var(--shadow);">
                    <div style="width:34px;height:34px;border-radius:8px;background:rgba(45,186,225,0.1);color:var(--cyan);display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg></div>
                    <div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= equipmentList.size() %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Total</div></div>
                </div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;box-shadow:var(--shadow);">
                    <div style="width:34px;height:34px;border-radius:8px;background:rgba(34,197,94,0.1);color:#22c55e;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><polyline points="20 6 9 17 4 12"/></svg></div>
                    <div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= activeCount %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Active</div></div>
                </div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;box-shadow:var(--shadow);">
                    <div style="width:34px;height:34px;border-radius:8px;background:rgba(245,158,11,0.1);color:#f59e0b;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><circle cx="12" cy="12" r="3"/></svg></div>
                    <div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= maintCount %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Maintenance</div></div>
                </div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;box-shadow:var(--shadow);">
                    <div style="width:34px;height:34px;border-radius:8px;background:rgba(239,68,68,0.1);color:#ef4444;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg></div>
                    <div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= outCount %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Out of Service</div></div>
                </div>
            </div>

            <!-- Toolbar -->
            <div class="toolbar">
                <div class="toolbar-left">
                    <button class="filter-pill active" onclick="filterEq('all',this)">All</button>
                    <button class="filter-pill green"  onclick="filterEq('active',this)">Active</button>
                    <button class="filter-pill amber"  onclick="filterEq('maintenance',this)">Maintenance</button>
                    <button class="filter-pill red"    onclick="filterEq('out',this)">Out of Service</button>
                </div>
                <div class="toolbar-right">
                    <div class="search-box">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Search equipment..." oninput="searchEq(this.value)"/>
                    </div>
                    <span class="result-count" id="resultCount"><%= equipmentList.size() %> items</span>
                </div>
            </div>

            <!-- Table -->
            <div class="eq-card">
                <div class="eq-card-header">
                    <h3>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                        Equipment List
                    </h3>
                </div>
                <div class="table-wrap">
                    <% if (equipmentList.isEmpty()) { %>
                    <div class="empty-state" style="padding:4rem 1rem;">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="40" height="40"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                        <p>No equipment registered yet.</p>
                    </div>
                    <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Asset ID</th>
                                <th>Name</th>
                                <th>Brand / Model</th>
                                <th>Department</th>
                                <th>Status</th>
                                <th>Purchase Date</th>
                                <% if (canEdit) { %><th style="text-align:right;">Actions</th><% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Equipment eq : equipmentList) {
                                String st = eq.getStatus() != null ? eq.getStatus().toLowerCase() : "";
                                String statusClass = st.contains("active") ? "eq-active" :
                                                     st.contains("maintenance") ? "eq-maintenance" :
                                                     st.contains("out") ? "eq-out" : "eq-decommissioned";
                                String filterKey = st.contains("active") ? "active" :
                                                   st.contains("maintenance") ? "maintenance" :
                                                   st.contains("out") ? "out" : "other";
                                // Find department name
                                String deptName = "—";
                                for (Department d : departments) {
                                    if (d.getDepartmentId() == eq.getDepartmentId()) {
                                        deptName = d.getName(); break;
                                    }
                                }
                            %>
                            <tr class="eq-row"
                                data-status="<%= filterKey %>"
                                data-name="<%= eq.getName() != null ? eq.getName().toLowerCase() : "" %>"
                                data-asset="<%= eq.getAssetId() != null ? eq.getAssetId().toLowerCase() : "" %>">
                                <td><span class="asset-id"><%= eq.getAssetId() %></span></td>
                                <td style="font-weight:600;font-size:0.85rem;"><%= eq.getName() %></td>
                                <td style="font-size:0.78rem;color:var(--text-muted);">
                                    <%= eq.getBrand() != null && !eq.getBrand().isEmpty() ? eq.getBrand() : "—" %>
                                    <% if (eq.getModel() != null && !eq.getModel().isEmpty()) { %>
                                    / <%= eq.getModel() %>
                                    <% } %>
                                </td>
                                <td style="font-size:0.8rem;"><%= deptName %></td>
                                <td><span class="eq-status <%= statusClass %>"><%= eq.getStatus() %></span></td>
                                <td style="font-size:0.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                                    <%= eq.getPurchaseDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(eq.getPurchaseDate()) : "—" %>
                                </td>
                                <% if (canEdit) { %>
                                <td>
                                    <div style="display:flex;align-items:center;gap:0.35rem;justify-content:flex-end;">
                                        <a href="<%= request.getContextPath() %>/equipment?action=view&id=<%= eq.getEquipmentId() %>" class="icon-btn" title="View">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                        </a>
                                        <a href="<%= request.getContextPath() %>/equipment?action=edit&id=<%= eq.getEquipmentId() %>" class="icon-btn" title="Edit">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                        </a>
                                    </div>
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
function filterEq(status, btn) {
    currentFilter = status;
    document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    applyFilters();
}
function searchEq(q) { applyFilters(q); }
function applyFilters(query) {
    const q = (query !== undefined ? query : document.querySelector('.search-box input').value).toLowerCase().trim();
    const rows = document.querySelectorAll('.eq-row');
    let count = 0;
    rows.forEach(row => {
        const statusMatch = currentFilter === 'all' || row.dataset.status === currentFilter;
        const searchMatch = !q || row.dataset.name.includes(q) || row.dataset.asset.includes(q);
        const show = statusMatch && searchMatch;
        row.style.display = show ? '' : 'none';
        if (show) count++;
    });
    document.getElementById('resultCount').textContent = count + ' item' + (count !== 1 ? 's' : '');
}
</script>
</body>
</html>
