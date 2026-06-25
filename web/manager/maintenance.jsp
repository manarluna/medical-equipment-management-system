<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
    }
    request.setAttribute("currentPage", "maintenance");

    List<MaintenanceTicket> tickets = (List<MaintenanceTicket>) request.getAttribute("tickets");
    List<Equipment> equipmentList   = (List<Equipment>) request.getAttribute("equipmentList");
    if (tickets       == null) tickets       = MaintenanceTicket.liste();
    if (equipmentList == null) equipmentList = Equipment.liste();

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");

    long openCount     = tickets.stream().filter(t -> "open".equalsIgnoreCase(t.getStatus()) || "received".equalsIgnoreCase(t.getStatus())).count();
    long progressCount = tickets.stream().filter(t -> t.getStatus() != null && t.getStatus().toLowerCase().contains("progress")).count();
    long resolvedCount = tickets.stream().filter(t -> "resolved".equalsIgnoreCase(t.getStatus())).count();
    long preventiveCount = tickets.stream().filter(t -> "Preventive".equalsIgnoreCase(t.getType())).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Maintenance</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
.page-hero { background:linear-gradient(135deg,#021B2F 0%,#0B385A 55%,#1C8BC0 100%); border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-60px; right:-60px; width:200px; height:200px; border-radius:50%; background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%); }
.page-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.page-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }
.hero-btns { display:flex; gap:0.5rem; position:relative; z-index:2; }

.toolbar { display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1rem; flex-wrap:wrap; }
.toolbar-left { display:flex; align-items:center; gap:0.6rem; flex-wrap:wrap; }
.toolbar-right { display:flex; align-items:center; gap:0.6rem; }

.filter-pill { display:inline-flex; align-items:center; gap:5px; padding:5px 12px; border-radius:20px; border:1px solid var(--border); background:var(--bg-card); font-size:0.73rem; font-weight:600; color:var(--text-muted); cursor:pointer; transition:all 0.18s; }
.filter-pill:hover        { border-color:var(--cyan); color:var(--cyan); }
.filter-pill.active       { background:var(--cyan); border-color:var(--cyan); color:#fff; }
.filter-pill.amber.active { background:#f59e0b; border-color:#f59e0b; color:#fff; }
.filter-pill.blue.active  { background:var(--blue); border-color:var(--blue); color:#fff; }
.filter-pill.green.active { background:#22c55e; border-color:#22c55e; color:#fff; }
.filter-pill.purple.active{ background:#8b5cf6; border-color:#8b5cf6; color:#fff; }

.search-box { position:relative; display:flex; align-items:center; }
.search-box svg { position:absolute; left:10px; width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-box input { height:34px; padding:0 12px 0 32px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:0.8rem; color:var(--text); background:var(--bg-card); outline:none; width:200px; transition:all 0.2s; }
.search-box input:focus { border-color:var(--cyan); box-shadow:0 0 0 3px rgba(45,186,225,0.1); width:240px; }
.result-count { font-size:0.72rem; color:var(--text-muted); font-family:'Space Mono',monospace; padding:4px 10px; background:var(--bg-page); border:1px solid var(--border); border-radius:20px; }

.type-badge { display:inline-flex; align-items:center; padding:2px 9px; border-radius:20px; font-size:0.67rem; font-weight:700; text-transform:uppercase; }
.type-preventive { background:rgba(45,186,225,0.1); color:var(--blue); }
.type-corrective  { background:rgba(245,158,11,0.1); color:#b45309; }

.status-pill { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:0.68rem; font-weight:600; }
.status-pill::before { content:''; width:6px; height:6px; border-radius:50%; }
.s-open,.s-received { background:rgba(100,116,139,0.1); color:#475569; }
.s-open::before,.s-received::before { background:#94a3b8; }
.s-in_progress { background:rgba(28,139,192,0.1); color:var(--blue); }
.s-in_progress::before { background:var(--blue); }
.s-resolved { background:rgba(34,197,94,0.1); color:#15803d; }
.s-resolved::before { background:#22c55e; }

.status-select { height:28px; padding:0 8px; border:1px solid var(--border); border-radius:6px; font-family:'Sora',sans-serif; font-size:0.75rem; color:var(--text); background:var(--bg-card); cursor:pointer; outline:none; }
.status-select:focus { border-color:var(--cyan); }

/* New ticket modal */
.modal-overlay { display:none; position:fixed; inset:0; background:rgba(2,27,47,0.6); z-index:1000; align-items:center; justify-content:center; backdrop-filter:blur(2px); }
.modal-overlay.open { display:flex; }
.modal { background:var(--bg-card); border-radius:16px; width:100%; max-width:500px; margin:1rem; box-shadow:0 20px 60px rgba(2,27,47,0.3); overflow:hidden; animation:modal-in 0.25s ease; }
@keyframes modal-in { from{opacity:0;transform:translateY(-20px);} to{opacity:1;transform:translateY(0);} }
.modal-header { padding:1.2rem 1.5rem; border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; }
.modal-header h3 { font-size:0.95rem; font-weight:600; color:var(--text); }
.modal-close { width:30px; height:30px; border-radius:7px; border:none; background:var(--bg-page); color:var(--text-muted); cursor:pointer; display:flex; align-items:center; justify-content:center; font-size:1.1rem; }
.modal-body { padding:1.5rem; }
.modal-footer { padding:1rem 1.5rem; border-top:1px solid var(--border); display:flex; justify-content:flex-end; gap:0.6rem; background:#f8fafc; }

/* Close ticket inline form */
.resolve-form { background:rgba(34,197,94,0.04); border:1px solid rgba(34,197,94,0.2); border-radius:8px; padding:0.8rem; margin-top:0.5rem; display:none; }
.resolve-form textarea { width:100%; height:70px; resize:none; }

.ticket-row[data-hidden="true"] { display:none; }
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
                    <span style="color:var(--text);font-weight:500;">Maintenance</span>
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
                    <h1>🔧 Maintenance Tickets</h1>
                    <p>// <%= tickets.size() %> total · <%= openCount %> open · <%= progressCount %> in progress · <%= resolvedCount %> resolved</p>
                </div>
                <div class="hero-btns">
                    <button class="btn btn-cyan" onclick="document.getElementById('newTicketModal').classList.add('open')">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        New Ticket
                    </button>
                </div>
            </div>

            <!-- Stats -->
            <div style="display:flex;gap:0.8rem;margin-bottom:1.5rem;flex-wrap:wrap;">
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(100,116,139,0.1);color:#64748b;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= openCount %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Open</div></div></div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(28,139,192,0.1);color:var(--blue);display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93l-1.41 1.41"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= progressCount %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">In Progress</div></div></div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(34,197,94,0.1);color:#22c55e;display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><polyline points="20 6 9 17 4 12"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= resolvedCount %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Resolved</div></div></div>
                <div style="background:var(--bg-card);border:1px solid var(--border);border-radius:10px;padding:0.8rem 1.2rem;display:flex;align-items:center;gap:10px;"><div style="width:34px;height:34px;border-radius:8px;background:rgba(45,186,225,0.1);color:var(--cyan);display:flex;align-items:center;justify-content:center;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div><div><div style="font-size:1.1rem;font-weight:700;font-family:'Space Mono',monospace;"><%= preventiveCount %></div><div style="font-size:0.67rem;color:var(--text-muted);text-transform:uppercase;">Preventive</div></div></div>
            </div>

            <!-- Toolbar -->
            <div class="toolbar">
                <div class="toolbar-left">
                    <button class="filter-pill active" onclick="filterTickets('all',this)">All</button>
                    <button class="filter-pill amber"  onclick="filterTickets('open',this)">Open</button>
                    <button class="filter-pill blue"   onclick="filterTickets('in_progress',this)">In Progress</button>
                    <button class="filter-pill green"  onclick="filterTickets('resolved',this)">Resolved</button>
                    <button class="filter-pill purple" onclick="filterTickets('preventive',this)">Preventive</button>
                </div>
                <div class="toolbar-right">
                    <div class="search-box">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Search tickets..." oninput="searchTickets(this.value)"/>
                    </div>
                    <span class="result-count" id="resultCount"><%= tickets.size() %> tickets</span>
                </div>
            </div>

            <!-- Table -->
            <div class="card">
                <div class="table-wrap">
                    <% if (tickets.isEmpty()) { %>
                    <div class="empty-state" style="padding:4rem 1rem;">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="40" height="40"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93l-1.41 1.41M4.93 4.93l1.41 1.41M19.07 19.07l-1.41-1.41M4.93 19.07l1.41-1.41M12 2v2M12 20v2M2 12h2M20 12h2"/></svg>
                        <p>No maintenance tickets yet.</p>
                    </div>
                    <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Type</th>
                                <th>Equipment</th>
                                <th>Description</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th style="text-align:right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (MaintenanceTicket t : tickets) {
                                String st  = t.getStatus() != null ? t.getStatus().toLowerCase().replace(" ","_") : "open";
                                String typ = t.getType()   != null ? t.getType().toLowerCase() : "corrective";
                                String filterKey = st.contains("progress") ? "in_progress" :
                                                   st.contains("resolved") ? "resolved" : "open";
                            %>
                            <tr class="ticket-row"
                                data-status="<%= filterKey %>"
                                data-type="<%= typ %>"
                                data-desc="<%= t.getDescription() != null ? t.getDescription().toLowerCase() : "" %>">
                                <td style="font-family:'Space Mono',monospace;font-size:0.72rem;color:var(--text-muted);">#<%= t.getMaintenanceId() %></td>
                                <td><span class="type-badge type-<%= typ %>"><%= t.getType() %></span></td>
                                <td style="font-size:0.8rem;font-weight:600;">Equip. #<%= t.getEquipmentid() %></td>
                                <td style="font-size:0.78rem;color:var(--text-muted);max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<%= t.getDescription() %>">
                                    <%= t.getDescription() != null && !t.getDescription().isEmpty() ? t.getDescription() : "—" %>
                                </td>
                                <td><span class="status-pill s-<%= filterKey %>"><%= t.getStatus() %></span></td>
                                <td style="font-size:0.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;white-space:nowrap;">
                                    <%= t.getCreationDate() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(t.getCreationDate()) : "—" %>
                                </td>
                                <td>
                                    <div style="display:flex;align-items:center;gap:0.4rem;justify-content:flex-end;">
                                        <% if (!"resolved".equals(filterKey)) { %>
                                        <!-- Update status -->
                                        <form method="post" action="<%= request.getContextPath() %>/maintenance" style="display:inline;">
                                            <input type="hidden" name="action"   value="updateStatus"/>
                                            <input type="hidden" name="ticketId" value="<%= t.getMaintenanceId() %>"/>
                                            <select name="status" class="status-select" onchange="this.form.submit()">
                                                <option value="RECEIVED"    <%= "received".equals(st) || "open".equals(st) ? "selected" : "" %>>Received</option>
                                                <option value="in_progress" <%= "in_progress".equals(filterKey) ? "selected" : "" %>>In Progress</option>
                                                <option value="resolved"    <%= "resolved".equals(filterKey) ? "selected" : "" %>>Resolved</option>
                                            </select>
                                        </form>
                                        <!-- Close with notes -->
                                        <button class="btn btn-sm btn-outline" style="white-space:nowrap;"
                                                onclick="toggleResolve(<%= t.getMaintenanceId() %>, <%= t.getEquipmentid() %>)">
                                            Close
                                        </button>
                                        <% } else { %>
                                        <span style="font-size:0.72rem;color:#15803d;font-weight:600;">✓ Done</span>
                                        <% } %>
                                    </div>
                                    <!-- Close form -->
                                    <div class="resolve-form" id="resolve-<%= t.getMaintenanceId() %>">
                                        <form method="post" action="<%= request.getContextPath() %>/maintenance">
                                            <input type="hidden" name="action"      value="close"/>
                                            <input type="hidden" name="ticketId"    value="<%= t.getMaintenanceId() %>"/>
                                            <input type="hidden" name="equipmentId" value="<%= t.getEquipmentid() %>"/>
                                            <div class="form-group" style="margin-bottom:0.6rem;">
                                                <label style="font-size:0.72rem;">Resolution Notes <span class="req">*</span></label>
                                                <textarea name="resolutionNotes" class="form-control" placeholder="Describe what was done, parts replaced, time spent..." required></textarea>
                                            </div>
                                            <div style="display:flex;gap:0.5rem;">
                                                <button type="submit" class="btn btn-sm btn-cyan">Confirm Close</button>
                                                <button type="button" class="btn btn-sm btn-outline" onclick="toggleResolve(<%= t.getMaintenanceId() %>, 0)">Cancel</button>
                                            </div>
                                        </form>
                                    </div>
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

<!-- NEW TICKET MODAL -->
<div class="modal-overlay" id="newTicketModal">
    <div class="modal">
        <div class="modal-header">
            <h3>🔧 New Maintenance Ticket</h3>
            <button class="modal-close" onclick="document.getElementById('newTicketModal').classList.remove('open')">✕</button>
        </div>
        <form method="post" action="<%= request.getContextPath() %>/maintenance">
            <input type="hidden" name="action" value="create"/>
            <div class="modal-body">
                <div class="form-group">
                    <label>Equipment <span class="req">*</span></label>
                    <select name="equipmentId" class="form-control" required>
                        <option value="">— Select equipment —</option>
                        <% for (Equipment eq : equipmentList) { %>
                        <option value="<%= eq.getEquipmentId() %>"><%= eq.getAssetId() %> — <%= eq.getName() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Type <span class="req">*</span></label>
                    <select name="type" class="form-control" required>
                        <option value="Corrective">Corrective (fault repair)</option>
                        <option value="Preventive">Preventive (scheduled)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" class="form-control" rows="3" placeholder="Describe the issue or maintenance task..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="document.getElementById('newTicketModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-cyan">Create Ticket</button>
            </div>
        </form>
    </div>
</div>

<script>
let currentFilter = 'all';
function filterTickets(f, btn) {
    currentFilter = f;
    document.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
    btn.classList.add('active');
    applyFilters();
}
function searchTickets(q) { applyFilters(q); }
function applyFilters(query) {
    const q = (query !== undefined ? query : document.querySelector('.search-box input').value).toLowerCase().trim();
    const rows = document.querySelectorAll('.ticket-row');
    let count = 0;
    rows.forEach(row => {
        const fMatch = currentFilter === 'all' ||
                       row.dataset.status === currentFilter ||
                       (currentFilter === 'preventive' && row.dataset.type === 'preventive');
        const sMatch = !q || row.dataset.desc.includes(q);
        const show = fMatch && sMatch;
        row.style.display = show ? '' : 'none';
        if (show) count++;
    });
    document.getElementById('resultCount').textContent = count + ' ticket' + (count !== 1 ? 's' : '');
}
function toggleResolve(id, eqId) {
    const el = document.getElementById('resolve-' + id);
    el.style.display = el.style.display === 'block' ? 'none' : 'block';
}
// Close modal on overlay click
document.getElementById('newTicketModal').addEventListener('click', function(e) {
    if (e.target === this) this.classList.remove('open');
});
</script>
</body>
</html>
