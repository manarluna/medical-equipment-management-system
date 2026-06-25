<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN); return;
    }
    request.setAttribute("currentPage", "equipment");

    Equipment editEquipment = (Equipment) request.getAttribute("editEquipment");
    boolean isEdit = (editEquipment != null);

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    if (departments == null) departments = Department.liste();

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — <%= isEdit ? "Edit Equipment" : "New Equipment" %></title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
.page-hero { background:linear-gradient(135deg,#021B2F 0%,#0B385A 60%,#1C8BC0 100%); border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-50px; right:-50px; width:180px; height:180px; border-radius:50%; background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%); }
.page-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.page-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }

.form-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; box-shadow:var(--shadow); overflow:hidden; max-width:760px; }
.form-card-header { padding:1.2rem 1.6rem; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:10px; background:#f8fafc; }
.form-card-header svg { width:18px; height:18px; color:var(--cyan); }
.form-card-header h3 { font-size:0.9rem; font-weight:600; color:var(--text); }
.form-card-body { padding:1.8rem; }

.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1rem 1.4rem; }
.form-grid .span-2 { grid-column:span 2; }

.form-section-title { font-size:0.68rem; font-weight:600; text-transform:uppercase; letter-spacing:1.5px; color:var(--text-muted); margin:1.4rem 0 0.8rem; display:flex; align-items:center; gap:8px; }
.form-section-title::after { content:''; flex:1; height:1px; background:var(--border); }
.form-section-title:first-child { margin-top:0; }

.form-footer { padding:1.2rem 1.8rem; border-top:1px solid var(--border); background:#f8fafc; display:flex; align-items:center; justify-content:space-between; gap:1rem; }

/* Preview */
.eq-preview { display:flex; align-items:center; gap:1rem; padding:1rem 1.2rem; background:var(--bg-page); border-radius:10px; margin-bottom:1.5rem; border:1px solid var(--border); }
.eq-preview-icon { width:48px; height:48px; border-radius:11px; background:linear-gradient(135deg,var(--navy),var(--blue)); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.eq-preview-icon svg { width:22px; height:22px; color:var(--cyan-light); }
.eq-preview-name { font-weight:700; font-size:0.95rem; color:var(--text); margin-bottom:2px; }
.eq-preview-asset { font-size:0.68rem; font-family:'Space Mono',monospace; color:var(--cyan); background:rgba(45,186,225,0.08); border:1px solid rgba(45,186,225,0.15); padding:2px 8px; border-radius:6px; display:inline-block; }

/* Status selector */
.status-selector { display:grid; grid-template-columns:repeat(4,1fr); gap:0.5rem; }
.status-option { position:relative; }
.status-option input { position:absolute; opacity:0; width:0; height:0; }
.status-option label { display:flex; flex-direction:column; align-items:center; gap:5px; padding:0.7rem 0.4rem; border:2px solid var(--border); border-radius:10px; cursor:pointer; transition:all 0.2s; font-size:0.68rem; font-weight:600; color:var(--text-muted); background:var(--bg-page); text-align:center; }
.status-option label svg { width:18px; height:18px; opacity:0.4; }
.status-option input:checked + label { border-color:var(--cyan); background:rgba(45,186,225,0.06); color:var(--text); }
.status-option input:checked + label svg { opacity:1; color:var(--cyan); }
.status-option.s-active input:checked + label   { border-color:#22c55e; background:rgba(34,197,94,0.06); }
.status-option.s-active input:checked + label svg { color:#22c55e; }
.status-option.s-maint input:checked + label    { border-color:#f59e0b; background:rgba(245,158,11,0.06); }
.status-option.s-maint input:checked + label svg { color:#f59e0b; }
.status-option.s-out input:checked + label      { border-color:#ef4444; background:rgba(239,68,68,0.06); }
.status-option.s-out input:checked + label svg  { color:#ef4444; }
.status-option.s-decom input:checked + label    { border-color:#94a3b8; background:rgba(100,116,139,0.06); }
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
                    <span style="color:var(--text);font-weight:500;"><%= isEdit ? "Edit" : "New" %></span>
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
                    <h1><%= isEdit ? "✏️ Edit Equipment" : "➕ New Equipment" %></h1>
                    <p><%= isEdit ? "// Modify details for " + editEquipment.getName() : "// Register new medical equipment" %></p>
                </div>
                <a href="<%= request.getContextPath() %>/equipment" class="btn btn-outline" style="border-color:rgba(144,230,255,0.3);color:rgba(144,230,255,0.8);background:rgba(0,0,0,0.2);position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                    Back
                </a>
            </div>

            <% if (error != null) { %>
            <div class="flash flash-error" style="max-width:760px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
                <%= error %>
            </div>
            <% } %>

            <div class="form-card">
                <div class="form-card-header">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                    <h3><%= isEdit ? "Edit Equipment Details" : "Equipment Information" %></h3>
                </div>
                <div class="form-card-body">

                    <!-- Preview -->
                    <div class="eq-preview">
                        <div class="eq-preview-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                        </div>
                        <div>
                            <div class="eq-preview-name" id="previewName"><%= isEdit ? editEquipment.getName() : "Equipment name" %></div>
                            <div class="eq-preview-asset" id="previewAsset"><%= isEdit && editEquipment.getAssetId() != null ? editEquipment.getAssetId() : "ASSET-ID" %></div>
                        </div>
                    </div>

                    <form method="post" action="<%= request.getContextPath() %>/equipment">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>"/>
                        <% if (isEdit) { %><input type="hidden" name="equipmentId" value="<%= editEquipment.getEquipmentId() %>"/><% } %>

                        <div class="form-section-title">Identification</div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Equipment Name <span class="req">*</span></label>
                                <input type="text" name="name" class="form-control"
                                       value="<%= isEdit ? editEquipment.getName() : "" %>"
                                       placeholder="e.g. ECG Monitor, X-Ray Machine..."
                                       oninput="updatePreview()" required/>
                            </div>
                            <div class="form-group">
                                <label>Asset ID <span class="req">*</span></label>
                                <input type="text" name="assetId" id="assetField" class="form-control"
                                       value="<%= isEdit && editEquipment.getAssetId() != null ? editEquipment.getAssetId() : "" %>"
                                       placeholder="e.g. ECG-001"
                                       style="font-family:'Space Mono',monospace;text-transform:uppercase;"
                                       oninput="updatePreview()" <%= isEdit ? "readonly" : "required" %>/>
                                <% if (isEdit) { %><small style="font-size:0.68rem;color:var(--text-muted);">Asset ID cannot be changed after creation.</small><% } %>
                            </div>
                        </div>

                        <div class="form-section-title">Technical Details</div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Brand</label>
                                <input type="text" name="brand" class="form-control"
                                       value="<%= isEdit && editEquipment.getBrand() != null ? editEquipment.getBrand() : "" %>"
                                       placeholder="e.g. Philips, GE, Siemens..."/>
                            </div>
                            <div class="form-group">
                                <label>Model</label>
                                <input type="text" name="model" class="form-control"
                                       value="<%= isEdit && editEquipment.getModel() != null ? editEquipment.getModel() : "" %>"
                                       placeholder="e.g. PageWriter TC30"/>
                            </div>
                            <div class="form-group">
                                <label>Serial Number</label>
                                <input type="text" name="serialNumber" class="form-control"
                                       value="<%= isEdit && editEquipment.getSerialNumber() != null ? editEquipment.getSerialNumber() : "" %>"
                                       placeholder="e.g. SN-2024-00123"
                                       style="font-family:'Space Mono',monospace;"/>
                            </div>
                            <div class="form-group">
                                <label>Purchase Date</label>
                                <input type="date" name="purchaseDate" class="form-control"
                                       value="<%= isEdit && editEquipment.getPurchaseDate() != null ? editEquipment.getPurchaseDate().toString() : "" %>"/>
                            </div>
                        </div>

                        <div class="form-section-title">Assignment</div>
                        <div class="form-grid">
                            <div class="form-group span-2">
                                <label>Department <span class="req">*</span></label>
                                <select name="deptId" class="form-control" required>
                                    <option value="">— Select a department —</option>
                                    <% for (Department d : departments) {
                                        if (!d.isActive()) continue;
                                        boolean selected = isEdit && d.getDepartmentId() == editEquipment.getDepartmentId();
                                    %>
                                    <option value="<%= d.getDepartmentId() %>" <%= selected ? "selected" : "" %>>
                                        <%= d.getName() %> (<%= d.getCode() %>)
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>

                        <% if (isEdit) { %>
                        <div class="form-section-title">Status</div>
                        <div class="status-selector">
                            <div class="status-option s-active">
                                <input type="radio" name="status" id="s-active" value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(editEquipment.getStatus()) ? "checked" : "" %>/>
                                <label for="s-active">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                    Active
                                </label>
                            </div>
                            <div class="status-option s-maint">
                                <input type="radio" name="status" id="s-maint" value="UNDER_MAINTENANCE" <%= "UNDER_MAINTENANCE".equalsIgnoreCase(editEquipment.getStatus()) || (editEquipment.getStatus() != null && editEquipment.getStatus().toLowerCase().contains("maintenance")) ? "checked" : "" %>/>
                                <label for="s-maint">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93l-1.41 1.41M4.93 4.93l1.41 1.41"/></svg>
                                    Maintenance
                                </label>
                            </div>
                            <div class="status-option s-out">
                                <input type="radio" name="status" id="s-out" value="OUT_OF_SERVICE" <%= "OUT_OF_SERVICE".equalsIgnoreCase(editEquipment.getStatus()) || (editEquipment.getStatus() != null && editEquipment.getStatus().toLowerCase().contains("out")) ? "checked" : "" %>/>
                                <label for="s-out">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                                    Out of Service
                                </label>
                            </div>
                            <div class="status-option s-decom">
                                <input type="radio" name="status" id="s-decom" value="DECOMMISSIONED" <%= "DECOMMISSIONED".equalsIgnoreCase(editEquipment.getStatus()) ? "checked" : "" %>/>
                                <label for="s-decom">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/></svg>
                                    Decommissioned
                                </label>
                            </div>
                        </div>
                        <% } %>

                        <div class="form-footer" style="margin:1.8rem -1.8rem -1.8rem;padding:1.2rem 1.8rem;">
                            <a href="<%= request.getContextPath() %>/equipment" class="btn btn-outline">Cancel</a>
                            <button type="submit" class="btn btn-cyan">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <% if (isEdit) { %><polyline points="20 6 9 17 4 12"/>
                                    <% } else { %><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/><% } %>
                                </svg>
                                <%= isEdit ? "Save Changes" : "Register Equipment" %>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
function updatePreview() {
    const name  = document.querySelector('[name="name"]')?.value.trim() || 'Equipment name';
    const asset = document.getElementById('assetField')?.value.trim().toUpperCase() || 'ASSET-ID';
    document.getElementById('previewName').textContent  = name;
    document.getElementById('previewAsset').textContent = asset;
    if (document.getElementById('assetField')) {
        document.getElementById('assetField').value = document.getElementById('assetField').value.toUpperCase();
    }
}
window.addEventListener('load', updatePreview);
</script>
</body>
</html>
