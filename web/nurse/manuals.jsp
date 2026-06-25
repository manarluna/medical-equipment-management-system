<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    // ── FIX: use "currentUser" (not "role") ─────────────────
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    request.setAttribute("currentPage", "manuals");

    // ── Data set by ManualServlet ────────────────────────────
    List<Manual>    manuals       = (List<Manual>)    request.getAttribute("manuals");
    List<Equipment> equipmentList = (List<Equipment>) request.getAttribute("equipmentList");
    Equipment       filterEquip   = (Equipment)       request.getAttribute("filterEquipment");

    if (manuals       == null) manuals       = new ArrayList<>();
    if (equipmentList == null) equipmentList = new ArrayList<>();

    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg   = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg"); session.removeAttribute("errorMsg");

    boolean isManager = role.equals("Administrator") || role.equals("Technical_Manager");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Bibliothèque des manuels</title>
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

/* ── Toolbar ── */
.doc-toolbar { display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1.2rem; flex-wrap:wrap; }
.search-wrap { position:relative; }
.search-wrap svg { position:absolute; left:10px; top:50%; transform:translateY(-50%); width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-wrap input { height:36px; padding:0 12px 0 34px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:.82rem; color:var(--text); background:#fff; outline:none; width:220px; transition:all .2s; }
.search-wrap input:focus { border-color:#00B4D8; box-shadow:0 0 0 3px rgba(0,180,216,.12); width:260px; }

.btn-upload { display:inline-flex; align-items:center; gap:6px; padding:.5rem 1.1rem; border-radius:8px; font-family:'Sora',sans-serif; font-size:.82rem; font-weight:600; cursor:pointer; border:none; background:#00B4D8; color:#fff; text-decoration:none; box-shadow:0 2px 10px rgba(0,180,216,.3); transition:all .2s; }
.btn-upload:hover { background:#0096C7; transform:translateY(-1px); }
.btn-upload svg { width:13px; height:13px; }

/* ── Filter bar ── */
.filter-bar { background:#fff; border:1px solid var(--border); border-radius:10px; padding:.8rem 1rem; margin-bottom:1.2rem; display:flex; align-items:center; gap:.8rem; flex-wrap:wrap; }
.filter-bar label { font-size:.78rem; font-weight:600; color:var(--text-muted); }
.filter-bar select { height:34px; padding:0 10px; border:1px solid var(--border); border-radius:7px; font-family:'Sora',sans-serif; font-size:.82rem; color:var(--text); background:#fff; outline:none; cursor:pointer; }
.filter-bar select:focus { border-color:#00B4D8; }
.filter-chip { display:inline-flex; align-items:center; gap:5px; padding:4px 10px; border-radius:20px; background:rgba(0,180,216,.1); border:1px solid rgba(0,180,216,.2); color:#0096C7; font-size:.72rem; font-weight:600; }
.filter-chip a { color:inherit; text-decoration:none; margin-left:4px; opacity:.6; }
.filter-chip a:hover { opacity:1; }

/* ── Manual cards ── */
.manuals-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:1rem; }
.manual-card { background:#fff; border:1px solid var(--border); border-radius:14px; overflow:hidden; transition:all .25s; }
.manual-card:hover { box-shadow:0 6px 24px rgba(0,180,216,.13); transform:translateY(-3px); border-color:rgba(0,180,216,.25); }

.manual-card-band { background:linear-gradient(135deg,#0D1B2A,#1B3A5C); padding:.75rem 1rem; display:flex; align-items:center; justify-content:space-between; }
.manual-card-icon { width:32px; height:32px; border-radius:8px; background:rgba(0,180,216,.12); color:rgba(186,230,253,.8); display:flex; align-items:center; justify-content:center; }
.manual-card-icon svg { width:16px; height:16px; }
.manual-type-tag { font-family:'Space Mono',monospace; font-size:.6rem; color:rgba(186,230,253,.75); background:rgba(255,255,255,.07); padding:2px 8px; border-radius:20px; letter-spacing:.5px; text-transform:uppercase; }

.manual-card-body { padding:.9rem 1rem; }
.manual-title { font-size:.9rem; font-weight:700; color:var(--text); margin-bottom:3px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.manual-equip { font-size:.73rem; color:var(--text-muted); margin-bottom:.75rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; display:flex; align-items:center; gap:4px; }
.manual-equip svg { width:11px; height:11px; flex-shrink:0; color:#00B4D8; }

.manual-card-footer { display:flex; align-items:center; justify-content:space-between; padding-top:.75rem; border-top:1px solid var(--border); gap:.4rem; }
.btn-view-pdf { display:inline-flex; align-items:center; gap:4px; padding:5px 11px; border-radius:7px; background:#00B4D8; color:#fff; font-size:.72rem; font-weight:600; text-decoration:none; transition:all .18s; }
.btn-view-pdf:hover { background:#0096C7; }
.btn-view-pdf svg { width:11px; height:11px; }
.btn-del-manual { display:inline-flex; align-items:center; gap:4px; padding:5px 9px; border-radius:7px; background:rgba(239,68,68,.08); border:1px solid rgba(239,68,68,.2); color:#dc2626; font-size:.69rem; font-weight:600; cursor:pointer; border:none; font-family:'Sora',sans-serif; transition:all .18s; }
.btn-del-manual:hover { background:#ef4444; color:#fff; }
.btn-del-manual svg { width:11px; height:11px; }

/* ── Empty state ── */
.empty-state { background:#fff; border:1px solid var(--border); border-radius:14px; padding:4rem 1rem; text-align:center; color:var(--text-muted); }
.empty-state svg { opacity:.25; display:block; margin:0 auto .8rem; }
.empty-state p { font-size:.85rem; }
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
                    <h1>📚 Manuals Library</h1>
                    <p>// <%= manuals.size() %> document<%= manuals.size()!=1?"s":"" %> available</p>
                </div>
                <% if (isManager) { %>
                <div style="position:relative;z-index:2;">
                    <a href="<%= request.getContextPath() %>/manuals?action=new" class="btn-upload">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Upload Manual
                    </a>
                </div>
                <% } %>
            </div>

            <!-- FILTER BAR -->
            <div class="filter-bar">
                <label>Filter by equipment:</label>
                <select onchange="if(this.value) window.location='<%= request.getContextPath() %>/manuals?equipmentId='+this.value; else window.location='<%= request.getContextPath() %>/manuals';">
                    <option value="">— All equipment —</option>
                    <% for (Equipment eq : equipmentList) { %>
                    <option value="<%= eq.getEquipmentId() %>"
                        <%= (filterEquip != null && filterEquip.getEquipmentId() == eq.getEquipmentId()) ? "selected" : "" %>>
                        <%= eq.getName() %> — <%= eq.getAssetId() %>
                    </option>
                    <% } %>
                </select>
                <% if (filterEquip != null) { %>
                <span class="filter-chip">
                    📌 <%= filterEquip.getName() %>
                    <a href="<%= request.getContextPath() %>/manuals">✕</a>
                </span>
                <% } %>
            </div>

            <!-- TOOLBAR -->
            <div class="doc-toolbar">
                <div style="display:flex;align-items:center;gap:.7rem;">
                    <div class="search-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Search by title…" oninput="searchManuals(this.value)"/>
                    </div>
                    <span id="manualCount" style="font-size:.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;padding:4px 10px;background:var(--bg-page);border:1px solid var(--border);border-radius:20px;"><%= manuals.size() %> result<%= manuals.size()!=1?"s":"" %></span>
                </div>
            </div>

            <!-- GRID -->
            <% if (manuals.isEmpty()) { %>
            <div class="empty-state">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="48" height="48">
                    <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
                </svg>
                <p>No manuals available<% if (filterEquip != null) { %> for this equipment<% } %>.</p>
                <% if (isManager) { %>
                <p style="font-size:.75rem;margin-top:.4rem;">Use the "Upload Manual" button to add one.</p>
                <% } else { %>
                <p style="font-size:.75rem;margin-top:.4rem;">Contact the technical manager if you need one.</p>
                <% } %>
            </div>
            <% } else { %>
            <div class="manuals-grid" id="manualsGrid">
            <% for (Manual m : manuals) {
                // Fetch equipment name for display
                Equipment meq = null;
                try { meq = Equipment.chercher_id(m.getEquipmentId()); } catch(Exception ignored) {}
                String meqName = meq != null ? meq.getName() + " — " + meq.getAssetId() : "Equipment #" + m.getEquipmentId();
                String typeDoc = m.getTypeDoc() != null && !m.getTypeDoc().isEmpty() ? m.getTypeDoc() : "Manuel";
            %>
            <div class="manual-card" data-title="<%= m.getTitle().toLowerCase() %>">
                <div class="manual-card-band">
                    <div class="manual-card-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    </div>
                    <span class="manual-type-tag"><%= typeDoc %></span>
                </div>
                <div class="manual-card-body">
                    <div class="manual-title" title="<%= m.getTitle() %>"><%= m.getTitle() %></div>
                    <div class="manual-equip">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                        <%= meqName %>
                    </div>
                    <div class="manual-card-footer">
                        <a href="<%= request.getContextPath() %>/pdf/<%= m.getFilePath() %>" target="_blank" class="btn-view-pdf">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            View PDF
                        </a>
                        <% if (isManager) { %>
                        <form method="post" action="<%= request.getContextPath() %>/manuals" style="display:inline;" onsubmit="return confirm('Delete this manual?');">
                            <input type="hidden" name="action" value="delete"/>
                            <input type="hidden" name="manualId" value="<%= m.getManualId() %>"/>
                            <button type="submit" class="btn-del-manual">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/></svg>
                                Delete
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
            </div>
            <% } %>

        </div>
    </div>
</div>
<script>
function searchManuals(q) {
    const v = q.toLowerCase().trim();
    const cards = document.querySelectorAll('.manual-card');
    let count = 0;
    cards.forEach(card => {
        const show = !v || card.dataset.title.includes(v);
        card.style.display = show ? '' : 'none';
        if (show) count++;
    });
    document.getElementById('manualCount').textContent = count + ' result' + (count !== 1 ? 's' : '');
}
</script>
</body>
</html>
