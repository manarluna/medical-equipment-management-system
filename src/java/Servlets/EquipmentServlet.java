/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servlets;

import Metier.AuditLog;
import Metier.Department;
import Metier.Equipment;
import Metier.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/equipment")
public class EquipmentServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = currentUser.getRole();

        // 1. Standardize access control using case-insensitive checks
        boolean isMedical = role.equalsIgnoreCase("Doctor") || role.equalsIgnoreCase("Nurse");
        boolean isManager = role.equalsIgnoreCase("Administrator") || role.equalsIgnoreCase("Technical_Manager");

        if (!isMedical && !isManager) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {
            case "list": {
                List<Equipment> equipmentList;

                if (isMedical) {
                    // 2. Fetch equipment via department_user junction table
                    equipmentList = Equipment.getByUser(currentUser.getUserId());
                } else {
                    // Managers/Admins see filtered or full list
                    String deptId = request.getParameter("deptId");
                    String status = request.getParameter("status");

                    if (deptId != null && !deptId.isEmpty()) {
                        equipmentList = Equipment.getByDepartment(Integer.parseInt(deptId));
                    } else if (status != null && !status.isEmpty()) {
                        equipmentList = Equipment.getByStatus(status);
                    } else {
                        equipmentList = Equipment.liste();
                    }
                }

                List<Department> departments = Department.liste();
                request.setAttribute("equipmentList", equipmentList);
                request.setAttribute("departments", departments);

                // 3. CRITICAL FIX: Route to the correct JSP based on the role
                if (isMedical) {
                    forward(request, response, "/doctor/equipment.jsp");
                } else {
                    forward(request, response, "/manager/equipment.jsp");
                }
                break;
            }

            case "view": {
                int id = Integer.parseInt(request.getParameter("id"));
                Equipment equipment = Equipment.chercher_id(id);
                if (equipment == null) {
                    request.getSession().setAttribute("errorMsg", "Equipment not found.");
                    response.sendRedirect(request.getContextPath() + "/equipment");
                    return;
                }
                request.setAttribute("equipment", equipment);
                
                // View detail routing
                if (isMedical) {
                    forward(request, response, "/doctor/equipment-detail.jsp");
                } else {
                    forward(request, response, "/manager/equipment-detail.jsp");
                }
                break;
            }

            case "new":
            case "edit": {
                if (!isManager) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }
                if (action.equals("edit")) {
                    int id = Integer.parseInt(request.getParameter("id"));
                    request.setAttribute("editEquipment", Equipment.chercher_id(id));
                }
                request.setAttribute("departments", Department.liste());
                forward(request, response, "/manager/equipment-form.jsp");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/equipment");
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
        boolean isManager = role.equalsIgnoreCase("Administrator") || role.equalsIgnoreCase("Technical_Manager");

        if (!isManager) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "create": {
                String name         = request.getParameter("name");
                String assetId      = request.getParameter("assetId");
                String brand        = request.getParameter("brand");
                String model        = request.getParameter("model");
                String serialNumber = request.getParameter("serialNumber");
                String purchaseDate = request.getParameter("purchaseDate");
                String status       = request.getParameter("status");
                String deptIdStr    = request.getParameter("deptId");

                if (isBlank(name) || isBlank(assetId) || isBlank(deptIdStr)) {
                    request.setAttribute("error", "The name, identifier and service are required.");
                    request.setAttribute("departments", Department.liste());
                    forward(request, response, "/manager/equipment-form.jsp");
                    return;
                }

                if (Equipment.assetIdExists(assetId.trim().toUpperCase())) {
                    request.setAttribute("error", "This Asset ID already exists. Please choose a unique identifier.");
                    request.setAttribute("departments", Department.liste());
                    forward(request, response, "/manager/equipment-form.jsp");
                    return;
                }

                Equipment eq = new Equipment();
                eq.setName(name.trim());
                eq.setAssetId(assetId.trim().toUpperCase());
                eq.setBrand(brand != null ? brand.trim() : "");
                eq.setModel(model != null ? model.trim() : "");
                eq.setSerialNumber(serialNumber != null ? serialNumber.trim() : "");
                eq.setPurchaseDate(purchaseDate);
                eq.setStatus(status != null ? status : "ACTIVE");
                eq.setActive(true);
                eq.setDepartmentId(Integer.parseInt(deptIdStr));

                boolean ok = Equipment.ajouter(eq);
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("CREATE_EQUIPMENT");
                    log.setDetails("equipment creation : " + name + " [" + assetId.toUpperCase() + "]");
                    AuditLog.ajouter(log);
                    request.getSession().setAttribute("successMsg", "Équipement \"" + name + "\" Created successfully.");
                    response.sendRedirect(request.getContextPath() + "/equipment");
                } else {
                    request.setAttribute("error", "Error while creating the equipment.");
                    request.setAttribute("departments", Department.liste());
                    forward(request, response, "/manager/equipment-form.jsp");
                }
                break;
            }

            case "update": {
                int    equipmentId  = Integer.parseInt(request.getParameter("equipmentId"));
                String name         = request.getParameter("name");
                String brand        = request.getParameter("brand");
                String model        = request.getParameter("model");
                String serialNumber = request.getParameter("serialNumber");
                String purchaseDate = request.getParameter("purchaseDate");
                String status       = request.getParameter("status");
                String deptIdStr    = request.getParameter("deptId");

                if (isBlank(name)) {
                    request.setAttribute("error", "The equipment name is required.");
                    request.setAttribute("editEquipment", Equipment.chercher_id(equipmentId));
                    request.setAttribute("departments", Department.liste());
                    forward(request, response, "/manager/equipment-form.jsp");
                    return;
                }

                Equipment eq = Equipment.chercher_id(equipmentId);
                if (eq == null) {
                    response.sendRedirect(request.getContextPath() + "/equipment");
                    return;
                }

                eq.setName(name.trim());
                eq.setBrand(brand != null ? brand.trim() : "");
                eq.setModel(model != null ? model.trim() : "");
                eq.setSerialNumber(serialNumber != null ? serialNumber.trim() : "");
                eq.setPurchaseDate(purchaseDate);
                eq.setStatus(status != null ? status : "ACTIVE");
                if (!isBlank(deptIdStr)) {
                    eq.setDepartmentId(Integer.parseInt(deptIdStr));
                }

                boolean ok = Equipment.save(eq);
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("UPDATE_EQUIPMENT");
                    log.setDetails("Equipment modification ID=" + equipmentId);
                    AuditLog.ajouter(log);
                    request.getSession().setAttribute("successMsg", "Equipment updated.");
                }
                response.sendRedirect(request.getContextPath() + "/equipment");
                break;
            }

            case "delete": {
                int equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
                boolean ok = Equipment.supprimer(equipmentId);
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("DELETE_EQUIPMENT");
                    log.setDetails("Suppression équipement ID=" + equipmentId);
                    AuditLog.ajouter(log);
                    request.getSession().setAttribute("successMsg", "Equipment deleted.");
                }
                response.sendRedirect(request.getContextPath() + "/equipment");
                break;
            }

            case "updateStatus": {
                int    equipmentId = Integer.parseInt(request.getParameter("equipmentId"));
                String status      = request.getParameter("status");
                boolean ok = Equipment.updateStatus(equipmentId, status);
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("UPDATE_EQUIPMENT_STATUS");
                    log.setDetails("equipment status ID=" + equipmentId + " -> " + status);
                    AuditLog.ajouter(log);
                    request.getSession().setAttribute("successMsg", "Status updated.");
                }
                response.sendRedirect(request.getContextPath() + "/equipment");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/equipment");
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