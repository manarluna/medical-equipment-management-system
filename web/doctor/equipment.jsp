<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    request.setAttribute("currentPage", "equipment");

    List<Equipment>  equipmentList = (List<Equipment>)  request.getAttribute("equipmentList");
    List<Department> departments   = (List<Department>) request.getAttribute("departments");
    if (equipmentList == null) equipmentList = Equipment.getByDepartment(currentUser.getDepartmentId());
    if (departments   == null) departments   = Department.liste();

    // Group by department
    Map<Integer, List<Equipment>> byDept = new LinkedHashMap<>();
    for (Equipment eq : equipmentList) {
        byDept.computeIfAbsent(eq.getDepartmentId(), k -> new ArrayList<>()).add(eq);
    }

    long activeCount = equipmentList.stream().filter(e -> "active".equalsIgnoreCase(e.getStatus())).count();
    long otherCount  = equipmentList.size() - activeCount;
%>
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Equipment</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
/* ════════════════════════════════════════
   DOCTOR EQUIPMENT — pure read-only view
   No edit, no status change, no add btn
   ════════════════════════════════════════ */
:root { --bg-page: #EEF2F7; }

.page-hero { background:linear-gradient(135deg,#0D1B2A 0%,#1B3A5C 55%,#0096C7 100%); border-radius:14px; padding:1.8rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-60px; right:-50px; width:220px; height:220px; border-radius:50%; background:radial-gradient(circle,rgba(0,180,216,.15),transparent 70%); animation:ph 4s ease-in-out infinite; }
.page-hero::after  { content:''; position:absolute; bottom:-40px; left:25%; width:160px; height:160px; border-radius:50%; background:radial-gradient(circle,rgba(0,180,216,.1),transparent 70%); animation:ph 4s ease-in-out infinite reverse; }
@keyframes ph { 0%,100%{transform:scale(1);opacity:.6} 50%{transform:scale(1.15);opacity:1} }
.page-hero h1 { font-size:1.35rem; font-weight:700; color:#fff; margin-bottom:4px; }
.page-hero p  { font-size:.78rem; color:rgba(186,230,253,.9); font-family:'Space Mono',monospace; }

.info-pill         { display:inline-flex; align-items:center; gap:6px; padding:5px 12px; border-radius:20px; font-size:.72rem; font-weight:600; }
.info-pill.teal    { background:rgba(0,180,216,.12); color:#0096C7; border:1px solid rgba(0,180,216,.25); }
.info-pill.gold    { background:rgba(222,172,76,.12);  color:#a07a1e; border:1px solid rgba(222,172,76,.25); }
.info-pill::before { content:''; width:6px; height:6px; border-radius:50%; }
.info-pill.teal::before { background:#00B4D8; }
.info-pill.gold::before { background:#DEAC4C; }

/* Toolbar */
.doc-toolbar { display:flex; align-items:center; justify-content:space-between; gap:1rem; margin-bottom:1.2rem; flex-wrap:wrap; }
.search-wrap { position:relative; }
.search-wrap svg { position:absolute; left:10px; top:50%; transform:translateY(-50%); width:14px; height:14px; color:var(--text-muted); pointer-events:none; }
.search-wrap input { height:36px; padding:0 12px 0 34px; border:1px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:.82rem; color:var(--text); background:#fff; outline:none; width:220px; transition:all .2s; }
.search-wrap input:focus { border-color:#00B4D8; box-shadow:0 0 0 3px rgba(0,180,216,.12); width:260px; }

.readonly-badge { display:inline-flex; align-items:center; gap:6px; padding:5px 12px; border-radius:20px; background:rgba(0,180,216,.08); border:1px solid rgba(0,180,216,.2); font-size:.72rem; font-weight:600; color:#0096C7; }
.readonly-badge svg { width:13px; height:13px; }

/* Dept grouping */
.dept-block { margin-bottom:2rem; }
.dept-heading { display:flex; align-items:center; gap:.7rem; margin-bottom:.9rem; padding-bottom:.5rem; border-bottom:2px solid rgba(0,180,216,.2); }
.dept-dot { width:10px; height:10px; border-radius:50%; background:#00B4D8; flex-shrink:0; }
.dept-name-lbl { font-size:.88rem; font-weight:700; color:var(--text); }
.dept-count-lbl { font-size:.67rem; font-family:'Space Mono',monospace; color:var(--text-muted); background:var(--bg-page); border:1px solid var(--border); padding:2px 9px; border-radius:20px; }

/* Card grid */
.eq-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(255px,1fr)); gap:.9rem; }

/* Individual card */
.eq-card { background:#fff; border-radius:14px; overflow:hidden; transition:all .25s; position:relative; border-left:4px solid transparent; border-top:1px solid var(--border); border-right:1px solid var(--border); border-bottom:1px solid var(--border); }
.eq-card:hover { box-shadow:0 6px 24px rgba(0,180,216,.13); transform:translateY(-3px); }
.eq-card.is-active   { border-left-color:#00B4D8; }
.eq-card.is-maint    { border-left-color:#DEAC4C; }
.eq-card.is-danger   { border-left-color:#ef4444; }
.eq-card.is-unknown  { border-left-color:#89B3D8; }

/* Card header band */
.eq-band { background:linear-gradient(135deg,#0D1B2A,#1B3A5C); padding:.8rem 1.1rem; display:flex; align-items:center; justify-content:space-between; }
.eq-band-icon { width:34px; height:34px; border-radius:8px; background:rgba(0,180,216,.12); color:rgba(186,230,253,.75); display:flex; align-items:center; justify-content:center; }
.eq-band-icon svg { width:17px; height:17px; }
.eq-asset-tag { font-family:'Space Mono',monospace; font-size:.6rem; color:rgba(186,230,253,.75); background:rgba(255,255,255,.07); padding:2px 8px; border-radius:20px; letter-spacing:.5px; }

/* Card body */
.eq-body { padding:.9rem 1rem .85rem; }
.eq-name { font-size:.9rem; font-weight:700; color:var(--text); margin-bottom:1px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.eq-brand-model { font-size:.72rem; color:var(--text-muted); margin-bottom:.75rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }

.eq-meta { display:flex; flex-direction:column; gap:3px; margin-bottom:.75rem; }
.eq-meta-row { display:flex; align-items:center; gap:.4rem; font-size:.72rem; color:var(--text-muted); }
.eq-meta-row svg { width:11px; height:11px; flex-shrink:0; color:#00B4D8; }
.eq-meta-row b { color:var(--text); font-weight:600; }

/* Status + actions bottom row */
.eq-bottom { display:flex; align-items:center; justify-content:space-between; padding-top:.7rem; border-top:1px solid var(--border); gap:.5rem; flex-wrap:wrap; }

.eq-status-tag { display:inline-flex; align-items:center; gap:5px; font-size:.69rem; font-weight:700; padding:3px 9px; border-radius:20px; }
.eq-status-tag::before { content:''; width:6px; height:6px; border-radius:50%; }
.s-active   { background:rgba(0,180,216,.1);  color:#0096C7; }
.s-active::before   { background:#00B4D8; animation:blink 2s ease-in-out infinite; }
.s-maint    { background:rgba(222,172,76,.1);  color:#a07a1e; }
.s-maint::before    { background:#DEAC4C; }
.s-danger   { background:rgba(239,68,68,.08); color:#dc2626; }
.s-danger::before   { background:#ef4444; }
.s-unknown  { background:rgba(0,180,216,.08); color:#0096C7; }
.s-unknown::before  { background:#89B3D8; }
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.35} }

/* Action buttons — ONLY report + manuals, nothing else */
.eq-actions { display:flex; align-items:center; gap:.4rem; }
.btn-report-sm { display:inline-flex; align-items:center; gap:4px; padding:4px 10px; border-radius:7px; background:rgba(0,180,216,.08); border:1px solid rgba(0,180,216,.2); color:#0096C7; font-size:.69rem; font-weight:600; text-decoration:none; transition:all .18s; white-space:nowrap; }
.btn-report-sm:hover { background:#00B4D8; color:#fff; }
.btn-report-sm svg { width:11px; height:11px; }
.btn-manual-sm { display:inline-flex; align-items:center; gap:4px; padding:4px 10px; border-radius:7px; background:rgba(0,180,216,.06); border:1px solid rgba(0,180,216,.15); color:#0096C7; font-size:.69rem; font-weight:600; text-decoration:none; transition:all .18s; white-space:nowrap; }
.btn-manual-sm:hover { background:#0096C7; color:#fff; }
.btn-manual-sm svg { width:11px; height:11px; }
</style>
</head>
<body>
<div class="app">
    <%@ include file="../admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <div class="topbar-left">
                <div class="topbar-breadcrumb"><span>ME2MS</span><span class="sep">/</span><span style="color:var(--text);font-weight:500;">Equipment</span></div>
            </div>
            <div class="topbar-right">
                <span style="font-size:.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;"><%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %></span>
            </div>
        </div>

        <div class="content">

            <!-- HERO -->
            <div class="page-hero">
                <div style="position:relative;z-index:2;">
                    <h1>🔬 Department equipment</h1>
                    <p>// <%= equipmentList.size() %> Equipment<%= equipmentList.size()!=1?"s":"" %> · View only</p>
                </div>
                <div style="display:flex;align-items:center;gap:.5rem;position:relative;z-index:2;">
                    <span class="info-pill teal"><%= activeCount %> active<%= activeCount!=1?"s":"" %></span>
                    <% if (otherCount > 0) { %><span class="info-pill gold"><%= otherCount %> inactive<%= otherCount!=1?"s":"" %></span><% } %>
                </div>
            </div>

            <!-- TOOLBAR -->
            <div class="doc-toolbar">
                <div style="display:flex;align-items:center;gap:.7rem;">
                    <div class="search-wrap">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" placeholder="Rechercher par nom, marque…" oninput="searchEq(this.value)"/>
                    </div>
                    <span id="eqCount" style="font-size:.72rem;color:var(--text-muted);font-family:'Space Mono',monospace;padding:4px 10px;background:var(--bg-page);border:1px solid var(--border);border-radius:20px;"><%= equipmentList.size() %> Result<%= equipmentList.size()!=1?"s":"" %></span>
                </div>
                <span class="readonly-badge">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                   Read-only — no modifications allowed
                </span>
            </div>

            <!-- EMPTY STATE -->
            <% if (equipmentList.isEmpty()) { %>
            <div style="background:#fff;border:1px solid var(--border);border-radius:14px;padding:4rem 1rem;text-align:center;color:var(--text-muted);">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="42" height="42" style="opacity:.3;display:block;margin:0 auto .8rem;"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                <p style="font-size:.85rem;">No equipment associated with your department.</p>
                <p style="font-size:.75rem;margin-top:.3rem;">Think this is an error? Contact the administrator.</p>
            </div>

            <% } else { %>
            <div id="eqGrid">
            <%
                if (!byDept.isEmpty()) {
                    for (Map.Entry<Integer, List<Equipment>> entry : byDept.entrySet()) {
                        int deptId = entry.getKey();
                        List<Equipment> deptEqs = entry.getValue();
                        String deptName = "Service #" + deptId;
                        for (Department d : departments) { if (d.getDepartmentId() == deptId) { deptName = d.getName(); break; } }
            %>
            <div class="dept-block">
                <div class="dept-heading">
                    <div class="dept-dot"></div>
                    <span class="dept-name-lbl"><%= deptName %></span>
                    <span class="dept-count-lbl"><%= deptEqs.size() %> Equipment<%= deptEqs.size()!=1?"s":"" %></span>
                </div>
                <div class="eq-grid">
                <% for (Equipment eq : deptEqs) {
                    String st = eq.getStatus() != null ? eq.getStatus().toLowerCase() : "unknown";
                    String cardCls  = st.equals("active") ? "is-active"  : (st.contains("maintenance") ? "is-maint" : (st.contains("out")||st.contains("decom") ? "is-danger" : "is-unknown"));
                    String tagCls   = st.equals("active") ? "s-active"   : (st.contains("maintenance") ? "s-maint"  : (st.contains("out")||st.contains("decom") ? "s-danger"  : "s-unknown"));
                %>
                <div class="eq-card <%= cardCls %>"
                     data-name="<%= eq.getName().toLowerCase() %>"
                     data-asset="<%= eq.getAssetId()!=null?eq.getAssetId().toLowerCase():"" %>"
                     data-brand="<%= eq.getBrand()!=null?eq.getBrand().toLowerCase():"" %>">

                    <div class="eq-band">
                        <div class="eq-band-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                        </div>
                        <span class="eq-asset-tag"><%= eq.getAssetId()!=null?eq.getAssetId():"—" %></span>
                    </div>

                    <div class="eq-body">
                        <div class="eq-name" title="<%= eq.getName() %>"><%= eq.getName() %></div>
                        <div class="eq-brand-model">
                            <%= (eq.getBrand()!=null&&!eq.getBrand().isEmpty()) ? eq.getBrand() : "" %>
                            <% if (eq.getBrand()!=null&&!eq.getBrand().isEmpty()&&eq.getModel()!=null&&!eq.getModel().isEmpty()) { %> · <% } %>
                            <%= (eq.getModel()!=null&&!eq.getModel().isEmpty()) ? eq.getModel() : "" %>
                            <% if ((eq.getBrand()==null||eq.getBrand().isEmpty())&&(eq.getModel()==null||eq.getModel().isEmpty())) { %>—<% } %>
                        </div>

                        <div class="eq-meta">
                            <% if (eq.getSerialNumber()!=null&&!eq.getSerialNumber().isEmpty()) { %>
                            <div class="eq-meta-row">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                                N° Serie : <b><%= eq.getSerialNumber() %></b>
                            </div>
                            <% } %>
                            <% if (eq.getPurchaseDate()!=null) { %>
                            <div class="eq-meta-row">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                               Purchased on  : <b><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(eq.getPurchaseDate()) %></b>
                            </div>
                            <% } %>
                        </div>

                        <div class="eq-bottom">
                            <span class="eq-status-tag <%= tagCls %>"><%= eq.getStatus() != null ? eq.getStatus() : "Inconnu" %></span>
                            <div class="eq-actions">
                                <a href="<%= request.getContextPath() %>/faultreports?action=new" class="btn-report-sm" title="Soumettre un rapport de panne">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>
                                    Report
                                </a>
                                <a href="<%= request.getContextPath() %>/manuals?equipmentId=<%= eq.getEquipmentId() %>" class="btn-manual-sm" title="Voir les manuels">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                                    Manual
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                </div>
            </div>
            <% } } else { /* no dept grouping — flat grid */ %>
            <div class="eq-grid">
            <% for (Equipment eq : equipmentList) {
                String st = eq.getStatus() != null ? eq.getStatus().toLowerCase() : "unknown";
                String cardCls = st.equals("active") ? "is-active" : (st.contains("maintenance") ? "is-maint" : (st.contains("out")||st.contains("decom") ? "is-danger" : "is-unknown"));
                String tagCls  = st.equals("active") ? "s-active"  : (st.contains("maintenance") ? "s-maint"  : (st.contains("out")||st.contains("decom") ? "s-danger"  : "s-unknown"));
            %>
            <div class="eq-card <%= cardCls %>" data-name="<%= eq.getName().toLowerCase() %>" data-asset="<%= eq.getAssetId()!=null?eq.getAssetId().toLowerCase():"" %>" data-brand="<%= eq.getBrand()!=null?eq.getBrand().toLowerCase():"" %>">
                <div class="eq-band">
                    <div class="eq-band-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg></div>
                    <span class="eq-asset-tag"><%= eq.getAssetId()!=null?eq.getAssetId():"—" %></span>
                </div>
                <div class="eq-body">
                    <div class="eq-name"><%= eq.getName() %></div>
                    <div class="eq-brand-model"><%= eq.getBrand()!=null?eq.getBrand():"—" %> · <%= eq.getModel()!=null?eq.getModel():"—" %></div>
                    <div class="eq-bottom">
                        <span class="eq-status-tag <%= tagCls %>"><%= eq.getStatus()!=null?eq.getStatus():"Inconnu" %></span>
                        <div class="eq-actions">
                            <a href="<%= request.getContextPath() %>/faultreports?action=new" class="btn-report-sm"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="11" height="11"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>Report</svg></a>
                            <a href="<%= request.getContextPath() %>/manuals?equipmentId=<%= eq.getEquipmentId() %>" class="btn-manual-sm"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="11" height="11"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>Manual</a>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
            </div>
            <% } %>
            </div>
            <% } %>

        </div>
    </div>
</div>
<script>
function searchEq(q) {
    const v = q.toLowerCase().trim();
    const cards = document.querySelectorAll('.eq-card');
    let count = 0;
    cards.forEach(card => {
        const match = !v || card.dataset.name.includes(v) || card.dataset.asset.includes(v) || card.dataset.brand.includes(v);
        card.style.display = match ? '' : 'none';
        if (match) count++;
    });
    document.getElementById('eqCount').textContent = count + ' résultat' + (count !== 1 ? 's' : '');
    document.querySelectorAll('.dept-block').forEach(block => {
        const hasVisible = [...block.querySelectorAll('.eq-card')].some(c => c.style.display !== 'none');
        block.style.display = hasVisible ? '' : 'none';
    });
}
</script>
</body>
</html>
