<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
    }
    request.setAttribute("currentPage", "manuals");

    List<Equipment> equipmentList = (List<Equipment>) request.getAttribute("equipmentList");
    if (equipmentList == null) equipmentList = Equipment.liste();

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Upload Manual</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
.page-hero { background:linear-gradient(135deg,#021B2F 0%,#0B385A 60%,#1C8BC0 100%); border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-50px; right:-50px; width:180px; height:180px; border-radius:50%; background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%); }
.page-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.page-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }

.form-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; box-shadow:var(--shadow); overflow:hidden; max-width:620px; }
.form-card-header { padding:1.2rem 1.6rem; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:10px; background:#f8fafc; }
.form-card-header svg { width:18px; height:18px; color:var(--cyan); }
.form-card-header h3 { font-size:0.9rem; font-weight:600; color:var(--text); }
.form-card-body { padding:1.8rem; }

.form-section-title { font-size:0.68rem; font-weight:600; text-transform:uppercase; letter-spacing:1.5px; color:var(--text-muted); margin:1.4rem 0 0.8rem; display:flex; align-items:center; gap:8px; }
.form-section-title::after { content:''; flex:1; height:1px; background:var(--border); }
.form-section-title:first-child { margin-top:0; }

/* Drop zone */
.drop-zone {
    border:2px dashed var(--border);
    border-radius:12px;
    padding:2.5rem 1rem;
    text-align:center;
    cursor:pointer;
    transition:all 0.2s;
    background:var(--bg-page);
    position:relative;
}
.drop-zone:hover, .drop-zone.drag-over {
    border-color:var(--cyan);
    background:rgba(45,186,225,0.04);
}
.drop-zone input[type="file"] {
    position:absolute; inset:0; opacity:0; cursor:pointer; width:100%; height:100%;
}
.drop-zone-icon { width:48px; height:48px; background:rgba(45,186,225,0.1); border-radius:12px; display:flex; align-items:center; justify-content:center; margin:0 auto 0.8rem; }
.drop-zone-icon svg { width:24px; height:24px; color:var(--cyan); }
.drop-zone-text { font-size:0.85rem; color:var(--text); font-weight:500; margin-bottom:4px; }
.drop-zone-hint { font-size:0.72rem; color:var(--text-muted); }
.drop-zone-file { font-size:0.8rem; color:var(--cyan); font-weight:600; margin-top:0.5rem; }

.form-footer { padding:1.2rem 1.8rem; border-top:1px solid var(--border); background:#f8fafc; display:flex; align-items:center; justify-content:space-between; gap:1rem; }
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
                    <a href="<%= request.getContextPath() %>/manuals" style="color:var(--text-muted);text-decoration:none;">Manuals</a>
                    <span class="sep">/</span>
                    <span style="color:var(--text);font-weight:500;">Upload</span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:0.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                    <%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %>
                </span>
            </div>
        </div>
        <div class="content">

            <div class="page-hero">
                <div>
                    <h1>📤 Upload Manual</h1>
                    <p>// Add a PDF document to the equipment library</p>
                </div>
                <a href="<%= request.getContextPath() %>/manuals" class="btn btn-outline" style="border-color:rgba(144,230,255,0.3);color:rgba(144,230,255,0.8);background:rgba(0,0,0,0.2);position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                    Back
                </a>
            </div>

            <% if (error != null) { %>
            <div class="flash flash-error" style="max-width:620px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
                <%= error %>
            </div>
            <% } %>

            <div class="form-card">
                <div class="form-card-header">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                    <h3>Manual Information</h3>
                </div>
                <div class="form-card-body">
                    <form method="post" action="<%= request.getContextPath() %>/manuals" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="upload"/>

                        <div class="form-section-title">Document Details</div>

                        <div class="form-group">
                            <label>Title <span class="req">*</span></label>
                            <input type="text" name="title" class="form-control"
                                   placeholder="e.g. User Manual, Maintenance Guide, Technical Sheet..." required/>
                        </div>

                        <div class="form-group">
                            <label>Document Type</label>
                            <select name="typeDoc" class="form-control">
                                <option value="User Manual">User Manual</option>
                                <option value="Maintenance Guide">Maintenance Guide</option>
                                <option value="Technical Sheet">Technical Sheet</option>
                                <option value="Safety Guide">Safety Guide</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Equipment <span class="req">*</span></label>
                            <select name="equipmentId" class="form-control" required>
                                <option value="">— Select equipment —</option>
                                <% for (Equipment eq : equipmentList) { %>
                                <option value="<%= eq.getEquipmentId() %>">
                                    <%= eq.getAssetId() %> — <%= eq.getName() %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="form-section-title">PDF File</div>

                        <div class="drop-zone" id="dropZone">
                            <input type="file" name="file" id="fileInput" accept=".pdf" onchange="showFileName(this)"/>
                            <div class="drop-zone-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            </div>
                            <div class="drop-zone-text">Click to choose a PDF file</div>
                            <div class="drop-zone-hint">Only PDF files accepted — max 20MB</div>
                            <div class="drop-zone-file" id="fileName"></div>
                        </div>

                        <div class="form-footer" style="margin:1.8rem -1.8rem -1.8rem;padding:1.2rem 1.8rem;">
                            <a href="<%= request.getContextPath() %>/manuals" class="btn btn-outline">Cancel</a>
                            <button type="submit" class="btn btn-cyan">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                                Upload Manual
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
function showFileName(input) {
    const el = document.getElementById('fileName');
    if (input.files && input.files[0]) {
        el.textContent = '✓ ' + input.files[0].name;
        document.getElementById('dropZone').style.borderColor = 'var(--cyan)';
        document.getElementById('dropZone').style.background  = 'rgba(45,186,225,0.04)';
    }
}
</script>
</body>
</html>
