/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servlets;

import Metier.AuditLog;
import Metier.Equipment;
import Metier.FaultReport;
import Metier.MaintenanceTicket;
import Metier.Notification;
import Metier.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/maintenance")
public class MaintenanceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String role = currentUser.getRole();

        // Only ADMIN and TECHNICAL_MANAGER
        if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {

            case "list": {
                List<MaintenanceTicket> tickets;

                String status = request.getParameter("status");
                if (status != null && !status.isEmpty()) {
                    tickets = MaintenanceTicket.getByStatus(status);
                } else {
                    tickets = MaintenanceTicket.liste();
                }

                request.setAttribute("tickets", tickets);
                forward(request, response, "/manager/maintenance.jsp");
                break;
            }

            case "view": {
                int id = Integer.parseInt(request.getParameter("id"));
                MaintenanceTicket ticket = MaintenanceTicket.chercher_id(id);
                if (ticket == null) {
                    request.getSession().setAttribute("errorMsg", "Ticket not found.");
                    response.sendRedirect(request.getContextPath() + "/maintenance");
                    return;
                }
                request.setAttribute("ticket", ticket);
                forward(request, response, "/manager/ticket-detail.jsp");
                break;
            }

            case "new": {
                // Load equipment and fault reports for the form
                List<Equipment> equipmentList   = Equipment.liste();
                List<FaultReport> faultReports  = FaultReport.getByStatus("PENDING");
                request.setAttribute("equipmentList", equipmentList);
                request.setAttribute("faultReports",  faultReports);
                forward(request, response, "/manager/maintenance.jsp");
                break;
            }

            case "edit": {
                int id = Integer.parseInt(request.getParameter("id"));
                MaintenanceTicket ticket = MaintenanceTicket.chercher_id(id);
                if (ticket == null) {
                    request.getSession().setAttribute("errorMsg", "Ticket not found.");
                    response.sendRedirect(request.getContextPath() + "/maintenance");
                    return;
                }
                List<Equipment> equipmentList = Equipment.liste();
                request.setAttribute("editTicket",    ticket);
                request.setAttribute("equipmentList", equipmentList);
                forward(request, response, "/manager/maintenance.jsp");
                break;
            }

            case "schedule": {
                // Preventive maintenance schedule form
                List<Equipment> equipmentList = Equipment.liste();
                request.setAttribute("equipmentList", equipmentList);
                forward(request, response, "/manager/maintenance.jsp");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/maintenance");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String role = currentUser.getRole();

        // Only ADMIN and TECHNICAL_MANAGER
        if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            // ── CREATE TICKET MANUALLY ────────────────────────────
            case "create": {
                String equipmentIdStr  = request.getParameter("equipmentId");
                String type            = request.getParameter("type");
                String description     = request.getParameter("description");
                String faultReportStr  = request.getParameter("faultReportId");

                if (isBlank(equipmentIdStr) || isBlank(type)) {
                    request.setAttribute("error", "The equipment and type are required.");
                    request.setAttribute("equipmentList", Equipment.liste());
                    forward(request, response, "/manager/maintenance.jsp");
                    return;
                }

                MaintenanceTicket ticket = new MaintenanceTicket();
                ticket.setEquipmentId(Integer.parseInt(equipmentIdStr));
                ticket.setType(type.trim());
                ticket.setDescription(description != null ? description.trim() : "");
                ticket.setStatus("open");
                ticket.setTechnicianId(currentUser.getUserId());

                if (faultReportStr != null && !faultReportStr.isEmpty()) {
                    ticket.setFaultReportId(Integer.parseInt(faultReportStr));
                }

                boolean ok = MaintenanceTicket.ajouter(ticket);
                if (ok) {
                    // Update equipment status
                    Equipment.updateStatus(Integer.parseInt(equipmentIdStr), "UNDER_MAINTENANCE");

                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("CREATE_MAINTENANCE_TICKET");
                    log.setDetails("Maintenance ticket creation for equipment ID=" + equipmentIdStr);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Ticket created successfully.");
                    response.sendRedirect(request.getContextPath() + "/maintenance");
                } else {
                    request.setAttribute("error", "Error while creating the ticket .");
                    request.setAttribute("equipmentList", Equipment.liste());
                    forward(request, response, "/manager/maintenance.jsp");
                }
                break;
            }

            // ── UPDATE STATUS ─────────────────────────────────────
           case "updateStatus": {
    int ticketId = Integer.parseInt(request.getParameter("ticketId"));
    String newStatus = request.getParameter("status");

    // Check validity
    if (!newStatus.equals("RECEIVED") && !newStatus.equals("in_progress")
            && !newStatus.equals("resolved")) {
        request.getSession().setAttribute("errorMsg", "Invalid status.");
        response.sendRedirect(request.getContextPath() + "/maintenance");
        return;
    }

    // Your original boolean check
    boolean ok = MaintenanceTicket.updateStatus(ticketId, newStatus);
    
    if (ok) {
        // Handle Notification if resolved
        if ("resolved".equalsIgnoreCase(newStatus)) {
            MaintenanceTicket ticket = MaintenanceTicket.chercher_id(ticketId);
            
            // USE getEquipmentId() (Capital I) here:
            if (ticket != null && ticket.getFaultReportId() > 0) {
                FaultReport fault = FaultReport.chercher_id(ticket.getFaultReportId());
                Equipment equip = Equipment.chercher_id(ticket.getEquipmentid()); 
                
                if (fault != null && equip != null) {
                    Notification.notifierReporter_TicketResolu(
                        fault.getReporterId(),
                        fault.getFaultId(),
                        equip.getName()
                    );
                }
            }
        }

        // Your original AuditLog logic
        AuditLog log = new AuditLog();
        log.setUserId(currentUser.getUserId());
        log.setAction("UPDATE_TICKET_STATUS");
        log.setDetails("Ticket ID=" + ticketId + " → " + newStatus);
        AuditLog.ajouter(log);

        request.getSession().setAttribute("successMsg", "Status updated.");
    }
    response.sendRedirect(request.getContextPath() + "/maintenance");
    break;
}

            // ── CLOSE TICKET ──────────────────────────────────────
            case "close": {
                int    ticketId        = Integer.parseInt(request.getParameter("ticketId"));
                String resolutionNotes = request.getParameter("resolutionNotes");
                String equipmentIdStr  = request.getParameter("equipmentId");

                if (isBlank(resolutionNotes)) {
                    request.getSession().setAttribute("errorMsg",
                            "Resolution notes are required to close a ticket.");
                    response.sendRedirect(request.getContextPath() + "/maintenance");
                    return;
                }

                boolean ok = MaintenanceTicket.close(ticketId, resolutionNotes.trim());
                if (ok) {
                    // Set equipment back to ACTIVE
                    if (equipmentIdStr != null && !equipmentIdStr.isEmpty()) {
                        Equipment.updateStatus(Integer.parseInt(equipmentIdStr), "ACTIVE");
                    }

                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("CLOSE_MAINTENANCE_TICKET");
                    log.setDetails("Ticket closure ID=" + ticketId
                            + " | Notes: " + resolutionNotes.trim());
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Ticket closed successfully.");
                }
                response.sendRedirect(request.getContextPath() + "/maintenance");
                break;
            }

            // ── SCHEDULE PREVENTIVE MAINTENANCE ──────────────────
            case "schedule": {
                String equipmentIdStr = request.getParameter("equipmentId");
                String nextDueDate    = request.getParameter("nextDueDate");
                String description    = request.getParameter("description");

                if (isBlank(equipmentIdStr) || isBlank(nextDueDate)) {
                    request.setAttribute("error", "The equipment and date are required.");
                    request.setAttribute("equipmentList", Equipment.liste());
                    forward(request, response, "/manager/maintenance.jsp");
                    return;
                }

                MaintenanceTicket ticket = new MaintenanceTicket();
                ticket.setEquipmentId(Integer.parseInt(equipmentIdStr));
                ticket.setType("Preventive");
                ticket.setDescription(description != null ? description.trim() : "");
                ticket.setStatus("RECEIVED");
                ticket.setTechnicianId(currentUser.getUserId());
                ticket.setNextDueDate(nextDueDate.trim());

                boolean ok = MaintenanceTicket.ajouter(ticket);
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("SCHEDULE_PREVENTIVE_MAINTENANCE");
                    log.setDetails("Preventive maintenance scheduled for equipment ID="
                            + equipmentIdStr + " | Date: " + nextDueDate);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg",
                            "Preventive maintenance scheduled successfully.");
                    response.sendRedirect(request.getContextPath() + "/maintenance");
                } else {
                    request.setAttribute("error", "Error while scheduling.");
                    request.setAttribute("equipmentList", Equipment.liste());
                    forward(request, response, "/manager/maintenance.jsp");
                }
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/maintenance");
        }
    }

    // ── Helpers ───────────────────────────────────────────────
    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void forward(HttpServletRequest req, HttpServletResponse res, String path)
            throws ServletException, IOException {
        req.getRequestDispatcher(path).forward(req, res);
    }
}