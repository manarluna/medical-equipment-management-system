/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servlets;

import Metier.AuditLog;
import Metier.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/audit-log")
public class AuditLogServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!hasRole(request, "Administrator")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé.");
            return;
        }

        List<AuditLog> logs = AuditLog.liste();
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/admin/audit-log.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!hasRole(request, "Administrator")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            // ── DELETE ONE LOG ────────────────────────────────────
            case "delete": {
                int logId = Integer.parseInt(request.getParameter("logId"));
                AuditLog.supprimer(logId);
                request.getSession().setAttribute("successMsg", "Entrée supprimée.");
                response.sendRedirect(request.getContextPath() + "/audit-log");
                break;
            }

            // ── DELETE ALL LOGS ───────────────────────────────────
            case "deleteAll": {
                List<AuditLog> all = AuditLog.liste();
                for (AuditLog log : all) {
                    AuditLog.supprimer(log.getAuditLogId());
                }
                request.getSession().setAttribute("successMsg", "Tous les logs supprimés.");
                response.sendRedirect(request.getContextPath() + "/audit-log");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/audit-log");
        }
    }

    private boolean hasRole(HttpServletRequest request, String role) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        String userRole = (String) session.getAttribute("userRole");
        return role.equals(userRole);
    }
}