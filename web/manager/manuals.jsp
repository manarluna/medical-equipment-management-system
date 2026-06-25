<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    request.setAttribute("currentPage", "manuals");

    List<Manual>    manuals       = (List<Manual>)    request.getAttribute("manuals");
    List<Equipment> equipmentList = (List<Equipment>) request.getAttribute("equipmentList");
    if (manuals       == null) manuals       = Manual.liste();
    if (equipmentList == null) equipmentList = Equipment.liste();

    boolean canUpload = role.equals("Administrator") || role.equals("Technical_Manager");

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
<title>ME2MS — Manuals</title>
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
.toolbar-left { display:flex; align-items:center; gap:0.6rem; }
.toolbar-right { display:flex; align-items:center; gap:0.6rem; }

.search-box { position:relative; display:flex; align-items:center; }
.search-box svg { position:absolute; left:10px; width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-box input { height:34px; padding:0 12px 0 32px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:0.8rem; color:var(--text); background:var(--bg-card); outline:none; width:200px; transition:all 0.2s; }
.search-box input:focus { border-color:var(--cyan); box-shadow:0 0 0 3px rgba(45,186,225,0.1); width:240px; }
.result-count { font-size:0.72rem; color:var(--text-muted); font-family:'Space Mono',monospace; padding:4px 10px; background:var(--bg-page); border:1px solid var(--border); border-radius:20px; }

/* Manual cards grid */
.manuals-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1rem; }

.manual-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; overflow:hidden; transition:all 0.25s; animation:card-in 0.3s ease both; }
@keyframes card-in { from{opacity:0;transform:translateY(12px);} to{opacity:1;transform:translateY(0);} }
.manual-card:hover { box-shadow:0 8px 28px rgba(2,27,47,0.12); transform:translateY(-3px); border-color:var(--cyan); }

.manual-card-top { height:80px; background:linear-gradient(135deg,#021B2F,#0B385A); display:flex; align-items:center; justify-content:center; position:relative; }
.manual-card-top svg { width:36px; height:36px; color:rgba(144,230,255,0.5); }
.doc-type-tag { position:absolute; top:8px; right:8px; font-size:0.62rem; font-weight:700; text-transform:uppercase; padding:2px 8px; border-radius:20px; background:rgba(45,186,225,0.2); color:var(--cyan-light); font-family:'Space Mono',monospace; }

.manual-card-body { padding:1rem; }
.manual-title { font-size:0.88rem; font-weight:700; color:var(--text); margin-bottom:4px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.manual-equip { font-size:0.72rem; color:var(--text-muted); margin-bottom:0.7rem; display:flex; align-items:center; gap:5px; }
.manual-equip svg { width:12px; height:12px; }
.manual-date { font-size:0.68rem; color:var(--text-muted); font-family:'Space Mono',monospace; }

.manual-card-footer { padding:0.7rem 1rem; border-top:1px solid var(--border); display:flex; gap:0.4rem; }
.manual-card-footer .btn { flex:1; justify-content:center; font-size:0.72rem; padding:0.35rem 0.5rem; }

.manual-card[data-hidden="true"] { display:none; }

.empty-manuals { text-align:center; padding:5rem 1rem; grid-column:1/-1; }
.empty-manuals .empty-icon { width:72px; height:72px; background:linear-gradient(135deg,rgba(45,186,225,0.1),rgba(28,139,192,0.05)); border-radius:18px; display:flex; align-items:center; justify-content:center; margin:0 auto 1rem; border:1px solid rgba(45,186,225,0.15); }
.empty-manuals .empty-icon svg { width:32px; height:32px; color:var(--cyan); opacity:0.5; }
.empty-manuals h3 { font-size:1rem; font-weight:600; color:var(--text); margin-bottom:4px; }
.empty-manuals p  { font-size:0.82rem; color:var(--text-muted); margin-bottom:1rem; }
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
                    <span style="color:var(--text);font-weight:500;">Manuals Library</span>
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
                    <h1>📚 Manuals Library</h1>
                    <p>// <%= manuals.size() %> documents available</p>
                </div>
                <% if (canUpload) { %>
                <a href="<%= request.getContextPath() %>/manuals?action=new" class="btn btn-cyan" style="position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    Upload Manual
                </a>
                <% } %>
            </div>

            <!-- Filter by equipment -->
            <div class="toolbar">
                <div class="toolbar-left">
                    <select class="form-control" style="height:34px;width:220px;font-size:0.8rem;" onchange="filterByEquipment(this.value)">
                        <option value="">All Equipment</option>
                        <% for (Equipment eq : equipmentList) { %>
                        <option value="<%= eq.getEquipmentId() %>"><%= eq.getAssetId() %> — <%= eq.getName() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="toolbar-right">
                    <div class="search-box">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Search manuals..." oninput="searchManuals(this.value)"/>
                    </div>
                    <span class="result-count" id="resultCount"><%= manuals.size() %> manuals</span>
                </div>
            </div>

            <!-- Cards -->
            <div class="manuals-grid" id="manualsGrid">
                <% if (manuals.isEmpty()) { %>
                <div class="empty-manuals">
                    <div class="empty-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    </div>
                    <h3>No manuals yet</h3>
                    <p>Upload the first equipment manual to get started.</p>
                    <% if (canUpload) { %>
                    <a href="<%= request.getContextPath() %>/manuals?action=new" class="btn btn-cyan">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        Upload Manual
                    </a>
                    <% } %>
                </div>
                <% } else { int delay = 0; for (Manual m : manuals) { %>
                <div class="manual-card"
                     data-equipment="<%= m.getEquipmentId() %>"
                     data-title="<%= m.getTitle() != null ? m.getTitle().toLowerCase() : "" %>"
                     style="animation-delay:<%= delay * 50 %>ms">
                    <div class="manual-card-top">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        <% if (m.getTypeDoc() != null && !m.getTypeDoc().isEmpty()) { %>
                        <span class="doc-type-tag"><%= m.getTypeDoc() %></span>
                        <% } %>
                    </div>
                    <div class="manual-card-body">
                        <div class="manual-title" title="<%= m.getTitle() %>"><%= m.getTitle() %></div>
                        <div class="manual-equip">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77"/></svg>
                            Equipment #<%= m.getEquipmentId() %>
                        </div>
                        <div class="manual-date">
                            📅 <%= m.getDateUpload() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(m.getDateUpload()) : "—" %>
                        </div>
                    </div>
                    <div class="manual-card-footer">
                       <a href="<%= request.getContextPath() %>/pdf/<%= m.getFilePath() %>" target="_blank" class="btn btn-cyan btn-sm">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            View PDF
                        </a>
                        <% if (canUpload) { %>
                        <form method="post" action="<%= request.getContextPath() %>/manuals" style="flex:1;">
                            <input type="hidden" name="action"   value="delete"/>
                            <input type="hidden" name="manualId" value="<%= m.getManualId() %>"/>
                            <button type="submit" class="btn btn-danger btn-sm" style="width:100%;justify-content:center;"
                                    onclick="return confirm('Delete this manual?')">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/></svg>
                                Delete
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
                <% delay++; } } %>
            </div>

        </div>
    </div>
</div>
<script>
let currentEquipment = '';
function filterByEquipment(val) {
    currentEquipment = val;
    applyFilters();
}
function searchManuals(q) { applyFilters(q); }
function applyFilters(query) {
    const q = (query !== undefined ? query : document.querySelector('.search-box input').value).toLowerCase().trim();
    const cards = document.querySelectorAll('.manual-card');
    let count = 0;
    cards.forEach(card => {
        const eqMatch = !currentEquipment || card.dataset.equipment === currentEquipment;
        const sMatch  = !q || card.dataset.title.includes(q);
        const show = eqMatch && sMatch;
        card.style.display = show ? '' : 'none';
        if (show) count++;
    });
    document.getElementById('resultCount').textContent = count + ' manual' + (count !== 1 ? 's' : '');
}
</script>
</body>
</html>