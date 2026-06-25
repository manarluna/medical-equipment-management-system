<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Metier.*,java.util.*" %>
<%
    Users currentUser = (Users) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser.getRole().equals("Administrator")) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    request.setAttribute("currentPage", "users");

    // Are we editing an existing user?
    Users editUser = (Users) request.getAttribute("editUser");
    boolean isEdit = (editUser != null);

    List<Department> departments = (List<Department>) request.getAttribute("departments");
    if (departments == null) departments = new ArrayList<>();

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>ME2MS — <%= isEdit ? "Edit User" : "New User" %></title>
<link rel="preconnect" href="https://fonts.googleapis.com"/>
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet"/>
<link rel="stylesheet" href="<%= request.getContextPath() %>/admin/style.css"/>
<style>
/* ── USER FORM PAGE ─────────────────────────────── */

.form-hero {
    background: linear-gradient(135deg, #021B2F 0%, #0B385A 60%, #1C8BC0 100%);
    border-radius: 14px;
    padding: 1.6rem 2rem;
    margin-bottom: 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: relative;
    overflow: hidden;
}

.form-hero::before {
    content: '';
    position: absolute;
    top: -50px; right: -50px;
    width: 180px; height: 180px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(45,186,225,0.18), transparent 70%);
}

.form-hero h1 {
    font-size: 1.3rem;
    font-weight: 700;
    color: #fff;
    margin-bottom: 3px;
}

.form-hero p {
    font-size: 0.78rem;
    color: rgba(144,230,255,0.7);
    font-family: 'Space Mono', monospace;
}

/* Form card */
.form-card {
    background: var(--bg-card);
    border: 1px solid var(--border);
    border-radius: 14px;
    box-shadow: var(--shadow);
    overflow: hidden;
    max-width: 720px;
}

.form-card-header {
    padding: 1.2rem 1.6rem;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    gap: 10px;
    background: #f8fafc;
}

.form-card-header svg {
    width: 18px; height: 18px;
    color: var(--cyan);
}

.form-card-header h3 {
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--text);
}

.form-card-body {
    padding: 1.8rem;
}

/* Two-column grid */
.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem 1.4rem;
}

.form-grid .span-2 {
    grid-column: span 2;
}

/* Role selector cards */
.role-selector {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 0.6rem;
    margin-top: 0.4rem;
}

.role-option {
    position: relative;
}

.role-option input[type="radio"] {
    position: absolute;
    opacity: 0;
    width: 0; height: 0;
}

.role-option label {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    padding: 0.8rem 0.5rem;
    border: 2px solid var(--border);
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.2s;
    font-size: 0.72rem;
    font-weight: 600;
    color: var(--text-muted);
    text-align: center;
    background: var(--bg-page);
}

.role-option label svg {
    width: 20px; height: 20px;
    opacity: 0.5;
    transition: opacity 0.2s;
}

.role-option input:checked + label {
    border-color: var(--cyan);
    background: rgba(45,186,225,0.06);
    color: var(--text);
    box-shadow: 0 0 0 3px rgba(45,186,225,0.1);
}

.role-option input:checked + label svg { opacity: 1; color: var(--cyan); }

.role-option label:hover {
    border-color: var(--cyan);
    color: var(--text);
    background: rgba(45,186,225,0.04);
}

/* Role label colors */
.role-option.admin input:checked + label    { border-color: #8b5cf6; background: rgba(139,92,246,0.06); box-shadow: 0 0 0 3px rgba(139,92,246,0.1); }
.role-option.admin input:checked + label svg { color: #8b5cf6; }
.role-option.manager input:checked + label  { border-color: var(--blue); background: rgba(28,139,192,0.06); box-shadow: 0 0 0 3px rgba(28,139,192,0.1); }
.role-option.manager input:checked + label svg { color: var(--blue); }
.role-option.doctor input:checked + label   { border-color: #22c55e; background: rgba(34,197,94,0.06); box-shadow: 0 0 0 3px rgba(34,197,94,0.1); }
.role-option.doctor input:checked + label svg { color: #22c55e; }
.role-option.nurse input:checked + label    { border-color: #f59e0b; background: rgba(245,158,11,0.06); box-shadow: 0 0 0 3px rgba(245,158,11,0.1); }
.role-option.nurse input:checked + label svg { color: #f59e0b; }

/* Password strength bar */
.password-wrap { position: relative; }
.password-wrap .toggle-pw {
    position: absolute;
    right: 10px; top: 50%;
    transform: translateY(-50%);
    background: none; border: none;
    cursor: pointer;
    color: var(--text-muted);
    padding: 0;
    display: flex;
}
.password-wrap .toggle-pw svg { width: 15px; height: 15px; }

.strength-bar {
    height: 3px;
    border-radius: 10px;
    background: var(--border);
    margin-top: 6px;
    overflow: hidden;
    display: none;
}

.strength-bar-fill {
    height: 100%;
    border-radius: 10px;
    transition: width 0.3s, background 0.3s;
    width: 0%;
}

.strength-label {
    font-size: 0.68rem;
    margin-top: 3px;
    color: var(--text-muted);
    display: none;
}

/* Avatar preview */
.avatar-preview {
    width: 52px; height: 52px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.3rem;
    font-weight: 700;
    color: #fff;
    background: linear-gradient(135deg, var(--navy), var(--blue));
    flex-shrink: 0;
    transition: background 0.3s;
    font-family: 'Space Mono', monospace;
}

.user-preview-row {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem 1.2rem;
    background: var(--bg-page);
    border-radius: 10px;
    margin-bottom: 1.5rem;
    border: 1px solid var(--border);
}

.preview-info .preview-name {
    font-weight: 600;
    font-size: 0.9rem;
    color: var(--text);
}

.preview-info .preview-role {
    font-size: 0.72rem;
    color: var(--text-muted);
    font-family: 'Space Mono', monospace;
}

/* Section divider */
.form-section-title {
    font-size: 0.68rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    color: var(--text-muted);
    margin: 1.4rem 0 0.8rem;
    display: flex;
    align-items: center;
    gap: 8px;
}

.form-section-title::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--border);
}

/* Form footer */
.form-footer {
    padding: 1.2rem 1.8rem;
    border-top: 1px solid var(--border);
    background: #f8fafc;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
}

.form-footer-right { display: flex; gap: 0.6rem; }

/* Edit mode — password reset section */
.password-reset-box {
    background: rgba(45,186,225,0.04);
    border: 1px dashed rgba(45,186,225,0.3);
    border-radius: 10px;
    padding: 1rem 1.2rem;
    margin-top: 0.5rem;
}

.password-reset-box p {
    font-size: 0.78rem;
    color: var(--text-muted);
    margin-bottom: 0.8rem;
}

/* Active toggle */
.toggle-wrap {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 0.6rem 0;
}

.toggle-switch {
    position: relative;
    width: 40px; height: 22px;
    flex-shrink: 0;
}

.toggle-switch input { opacity: 0; width: 0; height: 0; }

.toggle-slider {
    position: absolute;
    inset: 0;
    background: var(--border);
    border-radius: 22px;
    cursor: pointer;
    transition: background 0.2s;
}

.toggle-slider::before {
    content: '';
    position: absolute;
    width: 16px; height: 16px;
    left: 3px; top: 3px;
    background: #fff;
    border-radius: 50%;
    transition: transform 0.2s;
    box-shadow: 0 1px 4px rgba(0,0,0,0.15);
}

.toggle-switch input:checked + .toggle-slider { background: var(--success); }
.toggle-switch input:checked + .toggle-slider::before { transform: translateX(18px); }

.toggle-text {
    font-size: 0.82rem;
    font-weight: 500;
    color: var(--text);
}

.toggle-desc {
    font-size: 0.72rem;
    color: var(--text-muted);
}
</style>
</head>
<body>
<div class="app">

    <%@ include file="sidebar.jsp" %>

    <div class="main">

        <!-- TOP BAR -->
        <div class="topbar">
            <div class="topbar-left">
                <div class="topbar-breadcrumb">
                    <span>ME2MS</span>
                    <span class="sep">/</span>
                    <a href="<%= request.getContextPath() %>/users" style="color:var(--text-muted);text-decoration:none;">Users</a>
                    <span class="sep">/</span>
                    <span style="color:var(--text);font-weight:500;"><%= isEdit ? "Edit User" : "New User" %></span>
                </div>
            </div>
            <div class="topbar-right">
                <span style="font-size:0.75rem;color:var(--text-muted);font-family:'Space Mono',monospace;">
                    <%= new java.text.SimpleDateFormat("EEE, dd MMM yyyy").format(new java.util.Date()) %>
                </span>
            </div>
        </div>

        <!-- CONTENT -->
        <div class="content">

            <!-- HERO -->
            <div class="form-hero">
                <div>
                    <h1><%= isEdit ? "✏️ Edit User" : "➕ New User" %></h1>
                    <p><%= isEdit ? "// Modify account details for " + editUser.getFirstName() + " " + editUser.getLastName() : "// Create a new staff account" %></p>
                </div>
                <a href="<%= request.getContextPath() %>/users" class="btn btn-outline" style="border-color:rgba(144,230,255,0.3);color:rgba(144,230,255,0.8);background:rgba(0,0,0,0.2);">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
                    Back to Users
                </a>
            </div>

            <!-- Error message -->
            <% if (error != null) { %>
            <div class="flash flash-error" style="max-width:720px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <%= error %>
            </div>
            <% } %>

            <!-- FORM CARD -->
            <div class="form-card">
                <div class="form-card-header">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    <h3><%= isEdit ? "Edit Account Details" : "Create New Account" %></h3>
                </div>

                <div class="form-card-body">

                    <!-- Live preview -->
                    <div class="user-preview-row">
                        <div class="avatar-preview" id="avatarPreview">?</div>
                        <div class="preview-info">
                            <div class="preview-name" id="previewName">Full name will appear here</div>
                            <div class="preview-role" id="previewRole">Select a role below</div>
                        </div>
                    </div>

                    <!-- ═══ CREATE FORM ═══ -->
                    <% if (!isEdit) { %>
                    <form method="post" action="<%= request.getContextPath() %>/users" id="userForm">
                        <input type="hidden" name="action" value="create"/>

                        <div class="form-section-title">Personal Information</div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label>First Name <span class="req">*</span></label>
                                <input type="text" name="firstName" class="form-control"
                                       placeholder="e.g. Karim"
                                       oninput="updatePreview()" required/>
                            </div>
                            <div class="form-group">
                                <label>Last Name <span class="req">*</span></label>
                                <input type="text" name="lastName" class="form-control"
                                       placeholder="e.g. Boudiaf"
                                       oninput="updatePreview()" required/>
                            </div>
                            <div class="form-group span-2">
                                <label>Email Address</label>
                                <input type="email" name="email" class="form-control"
                                       placeholder="e.g. k.boudiaf@hospital.dz"/>
                            </div>
                        </div>

                        <div class="form-section-title">Login Credentials</div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Username (Login) <span class="req">*</span></label>
                                <input type="text" name="login" class="form-control"
                                       placeholder="e.g. k.boudiaf" required/>
                            </div>
                            <div class="form-group">
                                <label>Password <span class="req">*</span></label>
                                <div class="password-wrap">
                                    <input type="password" name="password" id="passwordField"
                                           class="form-control" placeholder="Min. 6 characters"
                                           oninput="checkStrength(this.value)" required
                                           style="padding-right:36px;"/>
                                    <button type="button" class="toggle-pw" onclick="togglePassword()">
                                        <svg id="eyeIcon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                    </button>
                                </div>
                                <div class="strength-bar" id="strengthBar">
                                    <div class="strength-bar-fill" id="strengthFill"></div>
                                </div>
                                <div class="strength-label" id="strengthLabel"></div>
                            </div>
                        </div>

                        <div class="form-section-title">Role</div>
                        <div class="role-selector">
                            <div class="role-option admin">
                                <input type="radio" name="role" id="role-admin" value="Administrator" onchange="updatePreview()"/>
                                <label for="role-admin">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                    Administrator
                                </label>
                            </div>
                            <div class="role-option manager">
                                <input type="radio" name="role" id="role-manager" value="Technical_Manager" onchange="updatePreview()"/>
                                <label for="role-manager">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                                    Tech Manager
                                </label>
                            </div>
                            <div class="role-option doctor">
                                <input type="radio" name="role" id="role-doctor" value="Doctor" onchange="updatePreview()"/>
                                <label for="role-doctor">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                                    Doctor
                                </label>
                            </div>
                            <div class="role-option nurse">
                                <input type="radio" name="role" id="role-nurse" value="Nurse" onchange="updatePreview()"/>
                                <label for="role-nurse">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                                    Nurse
                                </label>
                            </div>
                        </div>

                        <div class="form-section-title">Department Assignment</div>
                        <div class="form-group" id="deptGroup">
                            <label>Department <span class="req" id="deptReq">*</span></label>
                            <select name="departmentId" id="departmentSelect" class="form-control">
                                <option value="">— No department (Admin / Tech Manager) —</option>
                                <% for (Department d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>"><%= d.getName() %></option>
                                <% } %>
                            </select>
                            <div style="font-size:0.72rem;color:var(--text-muted);margin-top:4px;" id="deptHint">
                                Required for Doctors and Nurses. They will only see equipment from this department.
                            </div>
                        </div>

                        <div class="form-footer" style="margin: 1.8rem -1.8rem -1.8rem; padding: 1.2rem 1.8rem;">
                            <a href="<%= request.getContextPath() %>/users" class="btn btn-outline">Cancel</a>
                            <button type="submit" class="btn btn-cyan">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                Create User
                            </button>
                        </div>
                    </form>

                    <!-- ═══ EDIT FORM ═══ -->
                    <% } else { %>
                    <form method="post" action="<%= request.getContextPath() %>/users" id="userForm">
                        <input type="hidden" name="action" value="update"/>
                        <input type="hidden" name="userId" value="<%= editUser.getUserId() %>"/>

                        <div class="form-section-title">Personal Information</div>
                        <div class="form-grid">
                            <div class="form-group">
                                <label>First Name <span class="req">*</span></label>
                                <input type="text" name="firstName" class="form-control"
                                       value="<%= editUser.getFirstName() %>"
                                       oninput="updatePreview()" required/>
                            </div>
                            <div class="form-group">
                                <label>Last Name <span class="req">*</span></label>
                                <input type="text" name="lastName" class="form-control"
                                       value="<%= editUser.getLastName() %>"
                                       oninput="updatePreview()" required/>
                            </div>
                            <div class="form-group span-2">
                                <label>Email Address</label>
                                <input type="email" name="email" class="form-control"
                                       value="<%= editUser.getEmail() != null ? editUser.getEmail() : "" %>"/>
                            </div>
                        </div>

                        <div class="form-section-title">Login</div>
                        <div class="form-grid">
                            <div class="form-group span-2">
                                <label>Username (Login) <span class="req">*</span></label>
                                <input type="text" name="login" class="form-control"
                                       value="<%= editUser.getLogin() %>" required/>
                            </div>
                        </div>

                        <div class="form-section-title">Role</div>
                        <div class="role-selector">
                            <div class="role-option admin">
                                <input type="radio" name="role" id="role-admin" value="Administrator"
                                       <%= "Administrator".equals(editUser.getRole()) ? "checked" : "" %>
                                       onchange="updatePreview()"/>
                                <label for="role-admin">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                    Administrator
                                </label>
                            </div>
                            <div class="role-option manager">
                                <input type="radio" name="role" id="role-manager" value="Technical_Manager"
                                       <%= "Technical_Manager".equals(editUser.getRole()) ? "checked" : "" %>
                                       onchange="updatePreview()"/>
                                <label for="role-manager">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
                                    Tech Manager
                                </label>
                            </div>
                            <div class="role-option doctor">
                                <input type="radio" name="role" id="role-doctor" value="Doctor"
                                       <%= "Doctor".equals(editUser.getRole()) ? "checked" : "" %>
                                       onchange="updatePreview()"/>
                                <label for="role-doctor">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                                    Doctor
                                </label>
                            </div>
                            <div class="role-option nurse">
                                <input type="radio" name="role" id="role-nurse" value="Nurse"
                                       <%= "Nurse".equals(editUser.getRole()) ? "checked" : "" %>
                                       onchange="updatePreview()"/>
                                <label for="role-nurse">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                                    Nurse
                                </label>
                            </div>
                        </div>

                        <div class="form-section-title">Department Assignment</div>
                        <div class="form-group">
                            <label>Department</label>
                            <select name="departmentId" class="form-control">
                                <option value="">— No department (Admin / Tech Manager) —</option>
                                <% for (Department d : departments) { %>
                                <option value="<%= d.getDepartmentId() %>"><%= d.getName() %></option>
                                <% } %>
                            </select>
                            <div style="font-size:0.72rem;color:var(--text-muted);margin-top:4px;">
                                Changing this will update the user's department assignment.
                            </div>
                        </div>

                        <div class="form-section-title">Account Status</div>
                        <div class="toggle-wrap">
                            <label class="toggle-switch">
                                <input type="checkbox" name="activeStatus" id="activeToggle"
                                       <%= editUser.isActive() ? "checked" : "" %>
                                       onchange="document.getElementById('activeHidden').value = this.checked ? '1' : '0'"/>
                                <span class="toggle-slider"></span>
                            </label>
                            <input type="hidden" name="active" id="activeHidden" value="<%= editUser.isActive() ? "1" : "0" %>"/>
                            <div>
                                <div class="toggle-text">Account Active</div>
                                <div class="toggle-desc">Inactive users cannot log in to the system</div>
                            </div>
                        </div>

                        <div class="form-footer" style="margin: 1.8rem -1.8rem -1.8rem; padding: 1.2rem 1.8rem;">
                            <a href="<%= request.getContextPath() %>/users" class="btn btn-outline">Cancel</a>
                            <div style="display:flex;gap:0.6rem;">
                                <button type="button" class="btn btn-outline"
                                        onclick="document.getElementById('resetSection').style.display = document.getElementById('resetSection').style.display === 'none' ? 'block' : 'none'">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="14" height="14"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                    Reset Password
                                </button>
                                <button type="submit" class="btn btn-cyan">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                                    Save Changes
                                </button>
                            </div>
                        </div>
                    </form>

                    <!-- Reset Password Section (shown on demand) -->
                    <div id="resetSection" style="display:none;padding:1.2rem 1.8rem 1.4rem;border-top:1px solid var(--border);">
                        <div class="password-reset-box">
                            <p>Set a new password for <strong><%= editUser.getFirstName() %> <%= editUser.getLastName() %></strong>. They will need to use this password on their next login.</p>
                            <form method="post" action="<%= request.getContextPath() %>/users" style="display:flex;gap:0.8rem;align-items:flex-end;">
                                <input type="hidden" name="action" value="resetPassword"/>
                                <input type="hidden" name="userId" value="<%= editUser.getUserId() %>"/>
                                <div class="form-group" style="flex:1;margin:0;">
                                    <label>New Password <span class="req">*</span></label>
                                    <div class="password-wrap">
                                        <input type="password" name="newPassword" id="newPwField"
                                               class="form-control" placeholder="Enter new password"
                                               style="padding-right:36px;" required/>
                                        <button type="button" class="toggle-pw" onclick="toggleNewPassword()">
                                            <svg id="eyeIcon2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                        </button>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary"
                                        onclick="return confirm('Reset password for <%= editUser.getFirstName() %>?')"
                                        style="margin-bottom:1.1rem;">
                                    Confirm Reset
                                </button>
                            </form>
                        </div>
                    </div>
                    <% } %>

                </div><!-- /form-card-body -->
            </div><!-- /form-card -->

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /app -->

<script>
// ── Live preview ──────────────────────────────────
const roleColors = {
    'Administrator':    'linear-gradient(135deg,#7c3aed,#a78bfa)',
    'Technical_Manager':'linear-gradient(135deg,#0B385A,#1C8BC0)',
    'Doctor':           'linear-gradient(135deg,#15803d,#22c55e)',
    'Nurse':            'linear-gradient(135deg,#b45309,#f59e0b)'
};

const roleLabels = {
    'Administrator':    'Administrator',
    'Technical_Manager':'Technical Manager',
    'Doctor':           'Doctor',
    'Nurse':            'Nurse'
};

function updatePreview() {
    const fn = document.querySelector('[name="firstName"]')?.value || '';
    const ln = document.querySelector('[name="lastName"]')?.value  || '';
    const roleEl = document.querySelector('[name="role"]:checked');
    const role = roleEl ? roleEl.value : null;

    const initials = (fn.charAt(0) + ln.charAt(0)).toUpperCase() || '?';
    document.getElementById('avatarPreview').textContent = initials;

    const fullName = (fn + ' ' + ln).trim();
    document.getElementById('previewName').textContent = fullName || 'Full name will appear here';
    document.getElementById('previewRole').textContent = role ? roleLabels[role] : 'Select a role below';

    if (role) {
        document.getElementById('avatarPreview').style.background = roleColors[role];
    } else {
        document.getElementById('avatarPreview').style.background = 'linear-gradient(135deg,#0B385A,#1C8BC0)';
    }

    // Highlight department field for Doctor/Nurse
    const deptGroup = document.getElementById('deptGroup');
    const deptSelect = document.getElementById('departmentSelect');
    const deptReq = document.getElementById('deptReq');
    if (deptGroup) {
        const needsDept = (role === 'Doctor' || role === 'Nurse');
        deptGroup.style.background = needsDept ? 'rgba(45,186,225,0.04)' : '';
        deptGroup.style.border = needsDept ? '2px solid var(--cyan)' : '';
        deptGroup.style.borderRadius = needsDept ? '10px' : '';
        deptGroup.style.padding = needsDept ? '0.8rem' : '';
        if (deptReq) deptReq.style.display = needsDept ? 'inline' : 'none';
        if (deptSelect) deptSelect.required = needsDept;
    }
}

// ── Password strength ─────────────────────────────
function checkStrength(val) {
    const bar = document.getElementById('strengthBar');
    const fill = document.getElementById('strengthFill');
    const label = document.getElementById('strengthLabel');

    if (!bar) return;

    if (val.length === 0) {
        bar.style.display = 'none';
        label.style.display = 'none';
        return;
    }

    bar.style.display = 'block';
    label.style.display = 'block';

    let score = 0;
    if (val.length >= 6)  score++;
    if (val.length >= 10) score++;
    if (/[A-Z]/.test(val)) score++;
    if (/[0-9]/.test(val)) score++;
    if (/[^A-Za-z0-9]/.test(val)) score++;

    const levels = [
        { w: '20%',  bg: '#ef4444', txt: 'Very weak' },
        { w: '40%',  bg: '#f97316', txt: 'Weak' },
        { w: '60%',  bg: '#f59e0b', txt: 'Fair' },
        { w: '80%',  bg: '#22c55e', txt: 'Strong' },
        { w: '100%', bg: '#16a34a', txt: 'Very strong' },
    ];

    const lvl = levels[Math.max(0, score - 1)];
    fill.style.width = lvl.w;
    fill.style.background = lvl.bg;
    label.textContent = lvl.txt;
    label.style.color = lvl.bg;
}

// ── Toggle password visibility ────────────────────
function togglePassword() {
    const f = document.getElementById('passwordField');
    const showing = f.type === 'text';
    f.type = showing ? 'password' : 'text';
    document.getElementById('eyeIcon').innerHTML = showing
        ? '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>'
        : '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/>';
}

function toggleNewPassword() {
    const f = document.getElementById('newPwField');
    const showing = f.type === 'text';
    f.type = showing ? 'password' : 'text';
}

// ── Init preview on page load (edit mode) ────────
window.addEventListener('load', updatePreview);
</script>
</body>
</html>
