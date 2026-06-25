/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servlets;

import Metier.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * DashboardServlet – Every logged-in user lands here after login.
 *                    Content shown depends on the user's role.
 *
 * Admin Dashboard shows:
 *   - Total users per role
 *   - Recent system activity (audit log)
 *   - Department count
 *
 * Technical Manager Dashboard shows:
 *   - Total equipment count
 *   - Open fault tickets count
 *   - Upcoming preventive maintenance (due within 7 days)
 *   - Recent activity relevant to equipment
 *
 * Doctor / Nurse Dashboard shows:
 *   - Their submitted fault reports and statuses
 *   - Equipment list for their departments (quick access)
 *   - Link to manual library
/**
 *
 * @author lunam
 */





@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
     @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Guard: if not logged in, go to login
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
    
        Users  currentUser = (Users) session.getAttribute("currentUser");
        String role       = currentUser.getRole();

        switch (role) {

            // ── ADMIN DASHBOARD ───────────────────────────────────
            case "Administrator": {
                // User statistics
                int totalUsers        = Users.countAll();
                int totalAdmins       = Users.countByRole("Administrator");
                int totalManagers     = Users.countByRole("Technical_Manager");
                int totalDoctors      = Users.countByRole("Doctor");
                int totalNurses       = Users.countByRole("Nurse");

                // Department statistics
                int totalDepartments  = Department.countAll();
                int activeDepartments = Department.countActive();

                // Recent audit log (last 20 entries)
                List<AuditLog> recentActivity = AuditLog.getRecent(20);

         // Pass all data to the JSP
                request.setAttribute("totalUsers",        totalUsers);
                request.setAttribute("totalAdmins",       totalAdmins);
                request.setAttribute("totalManagers",     totalManagers);
                request.setAttribute("totalDoctors",      totalDoctors);
                request.setAttribute("totalNurses",       totalNurses);
                request.setAttribute("totalDepartments",  totalDepartments);
                request.setAttribute("activeDepartments", activeDepartments);
                request.setAttribute("recentActivity",    recentActivity);
                request.setAttribute("currentUser",       currentUser);

                request.getRequestDispatcher("/admin/dashboard.jsp")
                        .forward(request, response);
                break;
            }
        
        // ── TECHNICAL MANAGER DASHBOARD ───────────────────────
            case "Technical_Manager": {
                // Equipment statistics
                int totalEquipment        = Equipment.countAll();
                int activeEquipment       = Equipment.countByStatus("active");
                int underMaintenance      = Equipment.countByStatus("under_maintenance");
                int outOfService          = Equipment.countByStatus("out_of_service");

                // Ticket statistics
                int openTickets           = MaintenanceTicket.countByStatus("open");
                int inProgressTickets     = MaintenanceTicket.countByStatus("in_progress");
                int resolvedThisMonth     = MaintenanceTicket.countResolvedThisMonth();
        
        // Fault report statistics
                int pendingFaultReports   = FaultReport.countByStatus("pending");
                int criticalFaultReports  = FaultReport.countByUrgency("critical");

                // Upcoming preventive maintenance (due in next 7 days)
                List<MaintenanceTicket> upcomingMaintenance = MaintenanceTicket.getDueWithinDays(7);

                // Recent fault reports (last 10)
                List<FaultReport> recentFaultReports = FaultReport.getRecent(10);

                // Recent tickets (last 10)
                List<MaintenanceTicket> recentTickets = MaintenanceTicket.getRecent(10);

                request.setAttribute("totalEquipment",       totalEquipment);
                request.setAttribute("activeEquipment",      activeEquipment);
                request.setAttribute("underMaintenance",     underMaintenance);
                request.setAttribute("outOfService",         outOfService);
                request.setAttribute("openTickets",          openTickets);
                request.setAttribute("inProgressTickets",    inProgressTickets);
                request.setAttribute("resolvedThisMonth",    resolvedThisMonth);
                request.setAttribute("pendingFaultReports",  pendingFaultReports);
                request.setAttribute("criticalFaultReports", criticalFaultReports);
                request.setAttribute("upcomingMaintenance",  upcomingMaintenance);
                request.setAttribute("recentFaultReports",   recentFaultReports);
                request.setAttribute("recentTickets",        recentTickets);
                request.setAttribute("currentUser",          currentUser);

                request.getRequestDispatcher("/manager/dashboard.jsp")
                        .forward(request, response);
                break;
            }
        
         // ── DOCTOR / NURSE DASHBOARD ──────────────────────────
           case "Doctor": {
    List<FaultReport> myReports     = FaultReport.getByReporter(currentUser.getUserId());
    List<Equipment>   myEquipment   = Equipment.getByUser(currentUser.getUserId());

    int pendingCount    = (int) myReports.stream().filter(r -> "pending".equals(r.getStatus())).count();
    int inProgressCount = (int) myReports.stream().filter(r -> "in_progress".equals(r.getStatus())).count();
    int resolvedCount   = (int) myReports.stream().filter(r -> "resolved".equals(r.getStatus())).count();

    request.setAttribute("myReports",      myReports);
    request.setAttribute("myEquipment",    myEquipment);
    request.setAttribute("pendingCount",   pendingCount);
    request.setAttribute("inProgressCount",inProgressCount);
    request.setAttribute("resolvedCount",  resolvedCount);
    request.setAttribute("currentUser",    currentUser);

    request.getRequestDispatcher("/doctor/dashboard.jsp").forward(request, response);
    break;
}

case "Nurse": {
    List<FaultReport> myReports     = FaultReport.getByReporter(currentUser.getUserId());
    List<Equipment>   myEquipment   = Equipment.getByUser(currentUser.getUserId());

    int pendingCount    = (int) myReports.stream().filter(r -> "pending".equals(r.getStatus())).count();
    int inProgressCount = (int) myReports.stream().filter(r -> "in_progress".equals(r.getStatus())).count();
    int resolvedCount   = (int) myReports.stream().filter(r -> "resolved".equals(r.getStatus())).count();

    request.setAttribute("myReports",      myReports);
    request.setAttribute("myEquipment",    myEquipment);
    request.setAttribute("pendingCount",   pendingCount);
    request.setAttribute("inProgressCount",inProgressCount);
    request.setAttribute("resolvedCount",  resolvedCount);
    request.setAttribute("currentUser",    currentUser);

    request.getRequestDispatcher("/nurse/dashboard.jsp").forward(request, response);
    break;
}

            // Fallback — unknown role
            default:
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
        
}
}