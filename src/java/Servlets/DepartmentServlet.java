/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servlets;

import Metier.Department;
import Metier.Users;
import Metier.AuditLog;
import Metier.Shared;
import java.sql.Connection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/departments")
public class DepartmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!hasRole(request, "Administrator")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {

            case "list": {
                List<Department> departments = Department.liste();
                request.setAttribute("departments", departments);
                request.setAttribute("total", departments.size());
                forward(request, response, "/admin/departments.jsp");
                break;
            }

            case "new": {
                forward(request, response, "/admin/department-form.jsp");
                break;
            }

            case "edit": {
                int id = Integer.parseInt(request.getParameter("id"));
                Department dept = Department.chercher_id(id);
                if (dept == null) {
                    request.getSession().setAttribute("errorMsg", "Service not found.");
                    response.sendRedirect(request.getContextPath() + "/departments");
                    return;
                }
                request.setAttribute("editDept", dept);
                forward(request, response, "/admin/department-form.jsp");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/departments");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!hasRole(request, "Administrator")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";
        Users admin = (Users) request.getSession().getAttribute("currentUser");

        switch (action) {

            // ── CREATE ────────────────────────────────────────────
            case "create": {
                String name        = request.getParameter("name");
                String code        = request.getParameter("code");
                String description = request.getParameter("description");

                if (isBlank(name) || isBlank(code)) {
                    request.setAttribute("error", "The service name and code are required.");
                    forward(request, response, "/admin/department-form.jsp");
                    return;
                }

                if (Department.codeExists(code)) {
                    request.setAttribute("error", "This service code already exists. Please choose a unique code.");
                    forward(request, response, "/admin/department-form.jsp");
                    return;
                }

                Department dept = new Department();
                dept.setName(name.trim());
                dept.setCode(code.trim().toUpperCase());
                dept.setDescription(description != null ? description.trim() : "");
                dept.setActive(true);

                Connection con = Shared.connecter();
    System.out.println("CONNECTION: " + (con != null ? "OK" : "FAILED"));
                
                
                boolean ok = Department.ajouter(dept);
                if (ok) {
                    // AuditLog call
                    AuditLog log = new AuditLog();
                    log.setUserId(admin.getUserId());
                    log.setAction("CREATE_DEPARTMENT");
                    log.setDetails("Service creation: " + name + " [" + code.toUpperCase() + "]");
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Service \"" + name + "\" Created successfully.");
                    response.sendRedirect(request.getContextPath() + "/departments");
                } else {
                    request.setAttribute("error", "Error while creating the service.");
                    forward(request, response, "/admin/department-form.jsp");
                }
                break;
            }

            // ── UPDATE ────────────────────────────────────────────
            case "update": {
                int    deptId      = Integer.parseInt(request.getParameter("departmentId"));
                String name        = request.getParameter("name");
                String description = request.getParameter("description");

                if (isBlank(name)) {
                    request.setAttribute("error", "The service name is required.");
                    request.setAttribute("editDept", Department.chercher_id(deptId));
                    forward(request, response, "/admin/department-form.jsp");
                    return;
                }

                Department dept = Department.chercher_id(deptId);
                if (dept == null) {
                    response.sendRedirect(request.getContextPath() + "/departments");
                    return;
                }

                dept.setName(name.trim());
                dept.setDescription(description != null ? description.trim() : "");
                dept.setActive("1".equals(request.getParameter("active")));
                boolean ok = Department.save(dept);
                if (ok) {
                    // ✅ Fixed AuditLog call
                    AuditLog log = new AuditLog();
                    log.setUserId(admin.getUserId());
                    log.setAction("UPDATE_DEPARTMENT");
                    log.setDetails(" Service modification ID=" + deptId);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Service updated.");
                }
                response.sendRedirect(request.getContextPath() + "/departments");
                break;
            }

            // ── DEACTIVATE ────────────────────────────────────────
            case "deactivate": {
                int deptId = Integer.parseInt(request.getParameter("departmentId"));

                if (Department.hasActiveEquipment(deptId)) {
                    request.getSession().setAttribute("errorMsg",
                        "This service cannot be deactivated: it contains active equipment.");
                    response.sendRedirect(request.getContextPath() + "/departments");
                    return;
                }

                boolean ok = Department.deactivate(deptId);
                if (ok) {
                    // ✅ Fixed AuditLog call
                    AuditLog log = new AuditLog();
                    log.setUserId(admin.getUserId());
                    log.setAction("DEACTIVATE_DEPARTMENT");
                    log.setDetails("Service deactivation ID=" + deptId);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Service deactivated.");
                }
                response.sendRedirect(request.getContextPath() + "/departments");
                break;
            }

            // ── REACTIVATE ────────────────────────────────────────
            case "reactivate": {
                int deptId = Integer.parseInt(request.getParameter("departmentId"));
                boolean ok = Department.reactivate(deptId);
                if (ok) {
                    // AuditLog call
                    AuditLog log = new AuditLog();
                    log.setUserId(admin.getUserId());
                    log.setAction("REACTIVATE_DEPARTMENT");
                    log.setDetails(" Service reactivation ID=" + deptId);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Service reactivated.");
                }
                response.sendRedirect(request.getContextPath() + "/departments");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/departments");
        }
    }

    // ── Helpers ───────────────────────────────────────────────
    private boolean hasRole(HttpServletRequest request, String role) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        String userRole = (String) session.getAttribute("userRole");
        return role.equals(userRole);
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void forward(HttpServletRequest req, HttpServletResponse res, String path)
            throws ServletException, IOException {
        req.getRequestDispatcher(path).forward(req, res);
    }
}