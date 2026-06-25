<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String role = currentUser.getRole();
    if (!role.equals("Doctor") && !role.equals("Nurse") && !role.equals("Administrator") && !role.equals("Technical_Manager")) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    request.setAttribute("currentPage", "report");
    List<Equipment> equipmentList = (List<Equipment>) request.getAttribute("equipmentList");
    if (equipmentList == null) {
        int deptId = currentUser.getDepartmentId();
        equipmentList = deptId > 0 ? Equipment.getByDepartment(deptId) : Equipment.liste();
    }
    String errorMsg = (String) session.getAttribute("errorMsg");
    session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — Report a Fault</title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
:root { --bg-page: #EEF2F7; }
.page-hero { background:linear-gradient(135deg,#0D1B2A 0%,#1B3A5C 55%,#0096C7 100%); border-radius:14px; padding:1.6rem 2rem; margin-bottom:1.5rem; display:flex; align-items:center; justify-content:space-between; position:relative; overflow:hidden; }
.page-hero::before { content:''; position:absolute; top:-50px; right:-50px; width:200px; height:200px; border-radius:50%; background:radial-gradient(circle,rgba(0,180,216,.15),transparent 70%); }
.page-hero h1 { font-size:1.3rem; font-weight:700; color:#fff; margin-bottom:3px; }
.page-hero p  { font-size:.78rem; color:rgba(186,230,253,.9); font-family:'Space Mono',monospace; }

.form-card { background:var(--bg-card); border:1px solid var(--border); border-radius:14px; overflow:hidden; box-shadow:var(--shadow); max-width:700px; }
.form-card-header { padding:1.2rem 1.6rem; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:.8rem; background:linear-gradient(135deg,rgba(0,180,216,.04),transparent); }
.form-card-header svg { width:20px; height:20px; color:#00B4D8; }
.form-card-header h2 { font-size:1rem; font-weight:700; color:var(--text); }
.form-card-body { padding:1.6rem; }

.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:1.1rem; }
.form-grid .full { grid-column:1/-1; }

.form-group label { display:block; font-size:.78rem; font-weight:600; color:var(--text); margin-bottom:.4rem; }
.form-group label .req { color:#ef4444; margin-left:2px; }
.form-control { width:100%; height:40px; padding:0 12px; border:1.5px solid var(--border); border-radius:8px; font-family:'Sora',sans-serif; font-size:.85rem; color:var(--text); background:#fff; outline:none; transition:border-color .2s,box-shadow .2s; }
.form-control:focus { border-color:#00B4D8; box-shadow:0 0 0 3px rgba(0,180,216,.12); }
textarea.form-control { height:auto; padding:10px 12px; resize:vertical; min-height:110px; }
select.form-control { cursor:pointer; }

/* Urgency selector */
.urgency-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:.6rem; margin-top:.3rem; }
.urg-opt { position:relative; }
.urg-opt input[type="radio"] { position:absolute; opacity:0; width:0; height:0; }
.urg-label { display:flex; flex-direction:column; align-items:center; justify-content:center; gap:4px; padding:.6rem .4rem; border-radius:10px; border:1.5px solid var(--border); cursor:pointer; font-size:.72rem; font-weight:600; text-transform:uppercase; letter-spacing:.5px; transition:all .18s; text-align:center; background:#fff; }
.urg-label:hover { transform:translateY(-1px); box-shadow:0 3px 10px rgba(0,0,0,.08); }
.urg-label svg { width:18px; height:18px; }
.urg-opt input:checked + .urg-label { transform:translateY(-2px); box-shadow:0 4px 14px rgba(0,0,0,.12); }

.urg-low    .urg-label { color:#0096C7; border-color:rgba(0,180,216,.4); }
.urg-low    .urg-label:hover, .urg-low   input:checked + .urg-label { background:rgba(0,180,216,.1); border-color:#00B4D8; color:#0096C7; }
.urg-medium .urg-label { color:#a07a1e; border-color:rgba(222,172,76,.4); }
.urg-medium .urg-label:hover, .urg-medium input:checked + .urg-label { background:rgba(222,172,76,.15); border-color:#DEAC4C; color:#a07a1e; }
.urg-high   .urg-label { color:#dc2626; border-color:rgba(239,68,68,.3); }
.urg-high   .urg-label:hover, .urg-high   input:checked + .urg-label { background:rgba(239,68,68,.08); border-color:#ef4444; color:#dc2626; }
.urg-critical .urg-label { color:#991b1b; border-color:rgba(139,0,0,.3); }
.urg-critical .urg-label:hover, .urg-critical input:checked + .urg-label { background:rgba(139,0,0,.08); border-color:#991b1b; color:#991b1b; }

.btn-submit { display:inline-flex; align-items:center; gap:8px; padding:.65rem 1.5rem; border-radius:9px; font-family:'Sora',sans-serif; font-size:.9rem; font-weight:600; cursor:pointer; border:none; background:#00B4D8; color:#fff; box-shadow:0 3px 12px rgba(0,180,216,.35); transition:all .2s; }
.btn-submit:hover { background:#0096C7; box-shadow:0 5px 18px rgba(0,180,216,.5); transform:translateY(-1px); }
.btn-submit svg { width:16px; height:16px; }
.btn-cancel { display:inline-flex; align-items:center; gap:6px; padding:.65rem 1.2rem; border-radius:9px; font-family:'Sora',sans-serif; font-size:.85rem; font-weight:500; cursor:pointer; border:1.5px solid var(--border); background:transparent; color:var(--text-muted); text-decoration:none; transition:all .2s; }
.btn-cancel:hover { border-color:var(--text-muted); color:var(--text); }
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
                    <a href="<%= request.getContextPath() %>/faultreports" style="color:var(--text-muted);text-decoration:none;">Reports</a>
                    <span class="sep">/</span>
                    <span style="color:var(--text);font-weight:500;">New Report</span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;"><%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %></span>
            </div>
        </div>
        <div class="content">
            <div class="page-hero">
                <div style="position:relative;z-index:2;">
                    <h1>⚠️ Report a Fault</h1>
                    <p>// Fill in the form below to submit a fault report</p>
                </div>
            </div>

            <% if (errorMsg != null) { %>
            <div class="flash flash-error" style="max-width:700px;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg><%= errorMsg %></div>
            <% } %>

            <div class="form-card">
                <div class="form-card-header">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    <h2>Fault Report</h2>
                </div>
                <div class="form-card-body">
                    <form method="post" action="<%= request.getContextPath() %>/faultreports">
                        <input type="hidden" name="action" value="submit"/>
                        <div class="form-grid">
                            <!-- Equipment -->
                            <div class="form-group full">
                                <label>Equipment <span class="req">*</span></label>
                                <select name="equipmentId" class="form-control" required>
                                    <option value="">— Select equipment —</option>
                                    <% for (Equipment eq : equipmentList) { %>
                                    <option value="<%= eq.getEquipmentId() %>"><%= eq.getName() %> — <%= eq.getAssetId() %> (<%= eq.getStatus() %>)</option>
                                    <% } %>
                                </select>
                                <% if (equipmentList.isEmpty()) { %>
                                <p style="font-size:.73rem;color:#a07a1e;margin-top:.4rem;">⚠ No equipment found for your department. Contact the administrator.</p>
                                <% } %>
                            </div>

                            <!-- Room -->
                            <div class="form-group">
                                <label>Room / Ward</label>
                                <input type="text" name="room" class="form-control" placeholder="e.g. Room 204, Block A..." maxlength="100"/>
                            </div>

                            <!-- Description -->
                            <div class="form-group full">
                                <label>Problem Description <span class="req">*</span></label>
                                <textarea name="description" class="form-control" required placeholder="Describe the observed problem in detail…" maxlength="1000"></textarea>
                            </div>

                            <!-- Urgency -->
                            <div class="form-group full">
                                <label>Urgency Level <span class="req">*</span></label>
                                <div class="urgency-grid">
                                    <div class="urg-opt urg-low">
                                        <input type="radio" name="urgency" id="urg-low" value="low" required/>
                                        <label class="urg-label" for="urg-low">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                            Low
                                        </label>
                                    </div>
                                    <div class="urg-opt urg-medium">
                                        <input type="radio" name="urgency" id="urg-medium" value="medium"/>
                                        <label class="urg-label" for="urg-medium">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                            Medium
                                        </label>
                                    </div>
                                    <div class="urg-opt urg-high">
                                        <input type="radio" name="urgency" id="urg-high" value="high"/>
                                        <label class="urg-label" for="urg-high">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/></svg>
                                            High
                                        </label>
                                    </div>
                                    <div class="urg-opt urg-critical">
                                        <input type="radio" name="urgency" id="urg-critical" value="critical"/>
                                        <label class="urg-label" for="urg-critical">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                            Critical
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div style="display:flex;gap:.8rem;margin-top:1.4rem;padding-top:1.2rem;border-top:1px solid var(--border);">
                            <button type="submit" class="btn-submit">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/></svg>
                                Submit Report
                            </button>
                            <a href="<%= request.getContextPath() %>/dashboard" class="btn-cancel">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
