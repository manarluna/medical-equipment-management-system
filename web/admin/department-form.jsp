<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("Administrator")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "departments");

    Department editDept = (Department) request.getAttribute("editDept");
    boolean isEdit = (editDept != null);
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
.form-hero { background:linear-gradient(135deg,#021B2F 0%,#0B385A 60%,#1C8BC0 100%); border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.form-hero::before { content:''; position:absolute; top:-50px; right:-50px; width:180px; height:180px; border-radius:50%; background:radial-gradient(circle,rgba(45,186,225,0.18),transparent 70%); }
.form-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.form-hero p  { font-size:0.78rem; color:rgba(144,230,255,0.7); font-family:'Space Mono',monospace; }
.form-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; box-shadow:var(--shadow); overflow:hidden; max-width:620px; }
.form-card-header { padding:1.2rem 1.6rem; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:10px; background:#f8fafc; }
.form-card-header svg { width:18px; height:18px; color:var(--cyan); }
.form-card-header h3 { font-size:0.9rem; font-weight:600; color:var(--text); }
.form-card-body { padding:1.8rem; }
.form-section-title { font-size:0.68rem; font-weight:600; text-transform:uppercase; letter-spacing:1.5px; color:var(--text-muted); margin:1.4rem 0 0.8rem; display:flex; align-items:center; gap:8px; }
.form-section-title::after { content:''; flex:1; height:1px; background:var(--border); }
.form-section-title:first-child { margin-top:0; }
.dept-preview { display:flex; align-items:center; gap:1rem; padding:1rem 1.2rem; background:var(--bg-page); border-radius:10px; margin-bottom:1.5rem; border:1px solid var(--border); }
.dept-preview-icon { width:48px; height:48px; border-radius:11px; background:linear-gradient(135deg,var(--navy),var(--blue)); display:flex; align-items:center; justify-content:center; flex-shrink:0; }
.dept-preview-icon svg { width:22px; height:22px; color:var(--cyan-light); }
.dept-preview-name { font-weight:700; font-size:0.95rem; color:var(--text); margin-bottom:3px; }
.dept-preview-code { font-size:0.68rem; font-family:'Space Mono',monospace; color:var(--cyan); background:rgba(45,186,225,0.08); border:1px solid rgba(45,186,225,0.15); padding:2px 8px; border-radius:6px; display:inline-block; }
.field-footer { display:flex; justify-content:space-between; align-items:center; margin-top:4px; }
.field-hint { font-size:0.68rem; color:var(--text-muted); }
.char-count { font-size:0.68rem; color:var(--text-muted); font-family:'Space Mono',monospace; }
#codeField { text-transform:uppercase; font-family:'Space Mono',monospace; letter-spacing:1px; }
.toggle-wrap { display:flex; align-items:center; gap:10px; padding:0.6rem 0; }
.toggle-switch { position:relative; width:40px; height:22px; flex-shrink:0; }
.toggle-switch input { opacity:0; width:0; height:0; }
.toggle-slider { position:absolute; inset:0; background:var(--border); border-radius:22px; cursor:pointer; transition:background 0.2s; }
.toggle-slider::before { content:''; position:absolute; width:16px; height:16px; left:3px; top:3px; background:#fff; border-radius:50%; transition:transform 0.2s; box-shadow:0 1px 4px rgba(0,0,0,0.15); }
.toggle-switch input:checked + .toggle-slider { background:var(--success); }
.toggle-switch input:checked + .toggle-slider::before { transform:translateX(18px); }
.toggle-text { font-size:0.82rem; font-weight:500; color:var(--text); }
.toggle-desc { font-size:0.72rem; color:var(--text-muted); }
.form-footer { padding:1.2rem 1.8rem; border-top:1px solid var(--border); background:#f8fafc; display:flex; align-items:center; justify-content:space-between; gap:1rem; }
</style>
</head>
<body>
<div class="app">
    <%@ include file="sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <div class="topbar-left">
                <div class="topbar-breadcrumb">
                    <span>ME2MS</span><span class="sep">/</span>
                    <a href="<%= request.getContextPath() %>/departments" style="color:var(--text-muted);text-decoration:none;">Departments</a>
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

            <div class="form-hero">
                <div>
                    <h1><%= isEdit ? "Edit Department" : "New Department" %></h1>
                    <p><%= isEdit ? "// Modify details for " + editDept.getName() : "// Add a new hospital department or service" %></p>
                </div>
                <a href="<%= request.getContextPath() %>/departments" class="btn btn-outline" style="border-color:rgba(144,230,255,0.3);color:rgba(144,230,255,0.8);background:rgba(0,0,0,0.2);position:relative;z-index:2;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                    Back
                </a>
            </div>

            <% if (error != null) { %>
            <div class="flash flash-error" style="max-width:620px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <%= error %>
            </div>
            <% } %>

            <div class="form-card">
                <div class="form-card-header">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                    <h3><%= isEdit ? "Edit Department Details" : "Department Information" %></h3>
                </div>
                <div class="form-card-body">

                    <div class="dept-preview">
                        <div class="dept-preview-icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                        </div>
                        <div>
                            <div class="dept-preview-name" id="previewName"><%= isEdit ? editDept.getName() : "Department name" %></div>
                            <div class="dept-preview-code" id="previewCode"><%= isEdit && editDept.getCode() != null ? editDept.getCode() : "CODE" %></div>
                        </div>
                    </div>

                    <form method="post" action="<%= request.getContextPath() %>/departments">
                        <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>"/>
                        <% if (isEdit) { %><input type="hidden" name="departmentId" value="<%= editDept.getDepartmentId() %>"/><% } %>

                        <div class="form-section-title">Basic Information</div>

                        <div class="form-group">
                            <label>Department Name <span class="req">*</span></label>
                            <input type="text" name="name" id="nameField" class="form-control"
                                   value="<%= isEdit ? editDept.getName() : "" %>"
                                   placeholder="e.g. Cardiology, Radiology, ICU..."
                                   maxlength="100" oninput="updatePreview()" required/>
                            <div class="field-footer">
                                <span class="field-hint">Full name of the hospital department</span>
                                <span class="char-count" id="nameCount">0/100</span>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Department Code <span class="req">*</span></label>
                            <input type="text" name="code" id="codeField" class="form-control"
                                   value="<%= isEdit && editDept.getCode() != null ? editDept.getCode() : "" %>"
                                   placeholder="e.g. CARD, RAD, ICU"
                                   maxlength="20" oninput="updatePreview()" required/>
                            <div class="field-footer">
                                <span class="field-hint">Short unique identifier — auto uppercased</span>
                                <span class="char-count" id="codeCount">0/20</span>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Description</label>
                            <textarea name="description" class="form-control" rows="3"
                                      maxlength="300"
                                      placeholder="Brief description of this department..."
                                      oninput="countChars(this,'descCount',300)"><%= isEdit && editDept.getDescription() != null ? editDept.getDescription() : "" %></textarea>
                            <div class="field-footer">
                                <span class="field-hint">Optional</span>
                                <span class="char-count" id="descCount">0/300</span>
                            </div>
                        </div>

                        <% if (isEdit) { %>
                        <div class="form-section-title">Status</div>
                        <div class="toggle-wrap">
                            <label class="toggle-switch">
                                <input type="checkbox" id="activeToggle" <%= editDept.isActive() ? "checked" : "" %>
                                       onchange="document.getElementById('activeHidden').value=this.checked?'1':'0'"/>
                                <span class="toggle-slider"></span>
                            </label>
                            <input type="hidden" name="active" id="activeHidden" value="<%= editDept.isActive() ? "1" : "0" %>"/>
                            <div>
                                <div class="toggle-text">Department Active</div>
                                <div class="toggle-desc">Inactive departments are hidden from selection lists</div>
                            </div>
                        </div>
                        <% } %>

                        <div class="form-footer" style="margin:1.8rem -1.8rem -1.8rem;padding:1.2rem 1.8rem;">
                            <a href="<%= request.getContextPath() %>/departments" class="btn btn-outline">Cancel</a>
                            <button type="submit" class="btn btn-cyan">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <% if (isEdit) { %><polyline points="20 6 9 17 4 12"/>
                                    <% } else { %><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/><% } %>
                                </svg>
                                <%= isEdit ? "Save Changes" : "Create Department" %>
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
    const name = document.getElementById('nameField').value.trim();
    const code = document.getElementById('codeField').value.trim().toUpperCase();
    document.getElementById('previewName').textContent = name || 'Department name';
    document.getElementById('previewCode').textContent = code || 'CODE';
    document.getElementById('codeField').value = document.getElementById('codeField').value.toUpperCase();
    countChars(document.getElementById('nameField'), 'nameCount', 100);
    countChars(document.getElementById('codeField'), 'codeCount', 20);
}
function countChars(el, id, max) {
    const el2 = document.getElementById(id);
    if (!el2) return;
    el2.textContent = el.value.length + '/' + max;
    el2.style.color = el.value.length > max * 0.9 ? '#ef4444' : 'var(--text-muted)';
}
window.addEventListener('load', function() {
    updatePreview();
    const desc = document.querySelector('[name="description"]');
    if (desc) countChars(desc, 'descCount', 300);
});
</script>
</body>
</html>
