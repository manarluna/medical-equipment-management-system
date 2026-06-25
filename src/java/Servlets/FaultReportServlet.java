package Servlets;

import Metier.AuditLog;
import Metier.Equipment;
import Metier.FaultReport;
import Metier.Notification;
import Metier.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/faultreports")
public class FaultReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String role = currentUser.getRole();

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {

            case "list": {
                List<FaultReport> reports;

                if (role.equals("Doctor") || role.equals("Nurse")) {
                    // FIX BUG 2: use getUserId() directly — reporter_id is stored correctly in DB
                    reports = FaultReport.getByReporter(currentUser.getUserId());
                } else {
                    String status = request.getParameter("status");
                    if (status != null && !status.isEmpty()) {
                        reports = FaultReport.getByStatus(status);
                    } else {
                        reports = FaultReport.liste();
                    }
                }

                request.setAttribute("reports", reports);

                if (role.equals("Doctor") || role.equals("Nurse")) {
                    forward(request, response, "/doctor/my-reports.jsp");
                } else {
                    forward(request, response, "/manager/fault-tickets.jsp");
                }
                break;
            }

            case "view": {
                int id = Integer.parseInt(request.getParameter("id"));
                FaultReport report = FaultReport.chercher_id(id);
                if (report == null) {
                    request.getSession().setAttribute("errorMsg", "Report not found.");
                    response.sendRedirect(request.getContextPath() + "/faultreports");
                    return;
                }
                request.setAttribute("report", report);
                if (role.equals("Doctor") || role.equals("Nurse")) {
                    forward(request, response, "/doctor/my-reports.jsp");
                } else {
                    forward(request, response, "/manager/ticket-detail.jsp");
                }
                break;
            }

            case "new": {
                if (!role.equals("Doctor") && !role.equals("Nurse")
                        && !role.equals("Administrator") && !role.equals("Technical_Manager")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }

                
                List<Equipment> equipmentList = buildEquipmentList(role, currentUser.getUserId());
                request.setAttribute("equipmentList", equipmentList);
                forward(request, response, "/doctor/fault-report.jsp");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/faultreports");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String role = currentUser.getRole();

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "submit": {
                if (!role.equals("Doctor") && !role.equals("Nurse")
                        && !role.equals("Administrator") && !role.equals("Technical_Manager")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }

                String equipmentIdStr = request.getParameter("equipmentId");
                String room           = request.getParameter("room");
                String description    = request.getParameter("description");
                String urgency        = request.getParameter("urgency");

                if (isBlank(equipmentIdStr) || isBlank(description) || isBlank(urgency)) {
                    request.getSession().setAttribute("errorMsg", "All required fields must be filled in.");
                    
                    List<Equipment> equipmentList = buildEquipmentList(role, currentUser.getUserId());
                    request.setAttribute("equipmentList", equipmentList);
                    forward(request, response, "/doctor/fault-report.jsp");
                    return;
                }

                FaultReport report = new FaultReport();
                report.setEquipmentId(Integer.parseInt(equipmentIdStr));
                report.setRoom(room != null ? room.trim() : "");
                report.setDescription(description.trim());
                report.setUrgency(urgency.trim());
                report.setStatus("pending");
                report.setReporterId(currentUser.getUserId());

                boolean ok = FaultReport.ajouter(report);
                if (ok) {
                    List<FaultReport> latestReports = FaultReport.getByReporter(currentUser.getUserId());
                    if (latestReports != null && !latestReports.isEmpty()) {
                        Notification.notifierManagers_NouveauRapport(
                            latestReports.get(0).getFaultId(),
                            report.getDescription()
                        );
                    }
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("SUBMIT_FAULT_REPORT");
                    log.setDetails("New breakdown report submitted for equipment ID=" + equipmentIdStr
                            + " | Urgence: " + urgency);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg",
                            "Breakdown report submitted successfully.");
                    response.sendRedirect(request.getContextPath() + "/faultreports");
                } else {
                    request.getSession().setAttribute("errorMsg", "Error while submitting the report.");
                    
                    List<Equipment> equipmentList = buildEquipmentList(role, currentUser.getUserId());
                    request.setAttribute("equipmentList", equipmentList);
                    forward(request, response, "/doctor/fault-report.jsp");
                }
                break;
            }

            case "updateStatus": {
                if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }

                int    reportId  = Integer.parseInt(request.getParameter("reportId"));
                String newStatus = request.getParameter("status");

                if (!newStatus.equals("pending") && !newStatus.equals("in_progress")
                        && !newStatus.equals("resolved")) {
                    request.getSession().setAttribute("errorMsg", "Invalid status.");
                    response.sendRedirect(request.getContextPath() + "/faultreports");
                    return;
                }

                boolean ok = FaultReport.updateStatus(reportId, newStatus);
                if (ok) {
                    if ("resolved".equalsIgnoreCase(newStatus)) {
                        FaultReport resolvedReport = FaultReport.chercher_id(reportId);
                        if (resolvedReport != null) {
                            Equipment eq = Equipment.chercher_id(resolvedReport.getEquipmentId());
                            if (eq != null) {
                                Notification.notifierReporter_TicketResolu(
                                    resolvedReport.getReporterId(),
                                    reportId,
                                    eq.getName()
                                );
                            }
                          
                            Notification.marquerLuParReference(reportId);
                        }
                    }
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("UPDATE_FAULT_REPORT_STATUS");
                    log.setDetails("Rapport ID=" + reportId + " → " + newStatus);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Report status updated.");
                }
                response.sendRedirect(request.getContextPath() + "/faultreports");
                break;
            }

            case "delete": {
                if (!role.equals("Administrator")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }

                int reportId = Integer.parseInt(request.getParameter("reportId"));
                boolean ok = FaultReport.supprimer(reportId);
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("DELETE_FAULT_REPORT");
                    log.setDetails("Report deletion ID=" + reportId);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg", "Delete report.");
                }
                response.sendRedirect(request.getContextPath() + "/faultreports");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/faultreports");
        }
    }

  
    private List<Equipment> buildEquipmentList(String role, int userId) {
        if (role.equals("Doctor") || role.equals("Nurse")) {
            List<Equipment> list = Equipment.getByUser(userId);
            if (list == null || list.isEmpty()) {
                // Safety fallback: no department assigned, show all equipment
                return Equipment.liste();
            }
            return list;
        } else {
            return Equipment.liste();
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private void forward(HttpServletRequest req, HttpServletResponse res, String path)
            throws ServletException, IOException {
        req.getRequestDispatcher(path).forward(req, res);
    }
}