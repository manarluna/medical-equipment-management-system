/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servlets;


import Metier.AuditLog;
import Metier.Department;
import Metier.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/users")
public class UserServlet extends HttpServlet {

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
                List<Users> users = Users.liste();
                request.setAttribute("users", users);
                forward(request, response, "/admin/users.jsp");
                break;
            }

            case "new": {
                List<Department> departments = Department.liste();
                request.setAttribute("departments", departments);
                forward(request, response, "/admin/user-form.jsp");
                break;
            }

            case "edit": {
                int id = Integer.parseInt(request.getParameter("id"));
                Users user = Users.chercher_id(id);
                if (user == null) {
                    request.getSession().setAttribute("errorMsg", "User not found.");
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }
                List<Department> departments = Department.liste();
                request.setAttribute("editUser", user);
                request.setAttribute("departments", departments);
                forward(request, response, "/admin/user-form.jsp");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/users");
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
                String login     = request.getParameter("login");
                String password  = request.getParameter("password");
                String firstName = request.getParameter("firstName");
                String lastName  = request.getParameter("lastName");
                String role      = request.getParameter("role");
                String email     = request.getParameter("email");

                if (isBlank(login) || isBlank(password) || isBlank(firstName)
                        || isBlank(lastName) || isBlank(role)) {
                    request.setAttribute("error", "All required fields must be filled in.");
                    request.setAttribute("departments", Department.liste());
                    forward(request, response, "/admin/user-form.jsp");
                    return;
                }

                Users newUser = new Users(0, login.trim(), password.trim(),
                        firstName.trim(), lastName.trim(),
                        role.trim(), email != null ? email.trim() : "", true);

                boolean ok = Users.ajouter(newUser);
                if (ok) {
                    // Save department assignment if provided
                    String departmentIdStr = request.getParameter("departmentId");
                    if (departmentIdStr != null && !departmentIdStr.trim().isEmpty()) {
                        try {
                            int deptId = Integer.parseInt(departmentIdStr.trim());
                            int newUserId = Users.getLastInsertedId(); // get the new user's ID
                            Department.assignUser(newUserId, deptId);
                        } catch (NumberFormatException ignored) {}
                    }

                    AuditLog log = new AuditLog();
                    log.setUserId(admin.getUserId());
                    log.setAction("CREATE_USER");
                    log.setDetails("Création utilisateur: " + login + " [" + role + "]");
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg",
                            "User \"" + login + "\" Created successfully.");
                    response.sendRedirect(request.getContextPath() + "/users");
                } else {
                    request.setAttribute("error", "Error while creating. Login already exists?");
                    request.setAttribute("departments", Department.liste());
                    forward(request, response, "/admin/user-form.jsp");
                }
                break;
            }

            // ── UPDATE ────────────────────────────────────────────
            case "update": {
                int    userId    = Integer.parseInt(request.getParameter("userId"));
                String login     = request.getParameter("login");
                String firstName = request.getParameter("firstName");
                String lastName  = request.getParameter("lastName");
                String role      = request.getParameter("role");
                String email     = request.getParameter("email");

                if (isBlank(login) || isBlank(firstName) || isBlank(lastName) || isBlank(role)) {
                    request.setAttribute("error", "All required fields must be filled in.");
                    request.setAttribute("editUser", Users.chercher_id(userId));
                    request.setAttribute("departments", Department.liste());
                    forward(request, response, "/admin/user-form.jsp");
                    return;
                }

                Users user = Users.chercher_id(userId);
                if (user == null) {
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }

                user.setLogin(login.trim());
                user.setFirstName(firstName.trim());
                user.setLastName(lastName.trim());
                user.setRole(role.trim());
                user.setEmail(email != null ? email.trim() : "");

                boolean ok = Users.save(user);
                if (ok) {
                    // Update department assignment
                    String departmentIdStr = request.getParameter("departmentId");
                    if (departmentIdStr != null && !departmentIdStr.trim().isEmpty()) {
                        try {
                            int deptId = Integer.parseInt(departmentIdStr.trim());
                            Department.assignUser(userId, deptId);
                        } catch (NumberFormatException ignored) {}
                    } else {
                        Department.removeUser(userId); // remove from department if none selected
                    }

                    AuditLog log = new AuditLog();
                    log.setUserId(admin.getUserId());
                    log.setAction("UPDATE_USER");
                    log.setDetails("User Modification ID=" + userId);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "User updated.");
                }
                response.sendRedirect(request.getContextPath() + "/users");
                break;
            }

            // ── RESET PASSWORD ────────────────────────────────────
            case "resetPassword": {
                int    userId      = Integer.parseInt(request.getParameter("userId"));
                String newPassword = request.getParameter("newPassword");

                if (isBlank(newPassword)) {
                    request.getSession().setAttribute("errorMsg", "Password cannot be empty.");
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }

                boolean ok = Users.updatePassword(userId, newPassword.trim());
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(admin.getUserId());
                    log.setAction("RESET_PASSWORD");
                    log.setDetails("User password reset ID=" + userId);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Password reset successfully.");
                }
                response.sendRedirect(request.getContextPath() + "/users");
                break;
            }

            // ── DEACTIVATE ────────────────────────────────────────
            case "deactivate": {
                int userId = Integer.parseInt(request.getParameter("userId"));

                // Cannot deactivate yourself
                Users currentUser = (Users) request.getSession().getAttribute("currentUser");
                if (currentUser.getUserId() == userId) {
                    request.getSession().setAttribute("errorMsg",
                            "You cannot deactivate your own account.");
                    response.sendRedirect(request.getContextPath() + "/users");
                    return;
                }

                Users user = Users.chercher_id(userId);
                if (user != null) {
                    user.setActive(false);
                    boolean ok = Users.save(user);
                    if (ok) {
                        AuditLog log = new AuditLog();
                        log.setUserId(admin.getUserId());
                        log.setAction("DEACTIVATE_USER");
                        log.setDetails("User deactivation ID=" + userId);
                        AuditLog.ajouter(log);

                        request.getSession().setAttribute("successMsg", "User deactivated.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/users");
                break;
            }

            // ── REACTIVATE ────────────────────────────────────────
            case "reactivate": {
                int userId = Integer.parseInt(request.getParameter("userId"));
                Users user = Users.chercher_id(userId);
                if (user != null) {
                    user.setActive(true);
                    boolean ok = Users.save(user);
                    if (ok) {
                        AuditLog log = new AuditLog();
                        log.setUserId(admin.getUserId());
                        log.setAction("REACTIVATE_USER");
                        log.setDetails("User reactivation ID=" + userId);
                        AuditLog.ajouter(log);

                        request.getSession().setAttribute("successMsg", "User reactivated.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/users");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/users");
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