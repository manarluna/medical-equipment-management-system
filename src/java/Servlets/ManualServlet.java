package Servlets;

import Metier.AuditLog;
import Metier.Equipment;
import Metier.Manual;
import Metier.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;

@WebServlet("/manuals")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 1024 * 1024 * 20,
    maxRequestSize    = 1024 * 1024 * 25
)
public class ManualServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "manuals";
    private static final String UPLOAD_BASE = System.getProperty("user.home") + File.separator + "Me2ms1_uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String role = currentUser.getRole();

        String action = request.getParameter("action");
        if (action == null) action = "list";

        switch (action) {

            case "list": {
                List<Manual> manuals;

                String equipmentIdStr = request.getParameter("equipmentId");
                if (equipmentIdStr != null && !equipmentIdStr.isEmpty()) {
                    int equipmentId = Integer.parseInt(equipmentIdStr);
                    manuals = Manual.getByEquipment(equipmentId);
                    Equipment eq = Equipment.chercher_id(equipmentId);
                    request.setAttribute("filterEquipment", eq);
                } else {
                    manuals = Manual.liste();
                }

                List<Equipment> equipmentList = Equipment.liste();
                request.setAttribute("manuals",       manuals);
                request.setAttribute("equipmentList", equipmentList);

                // ── Route to the correct JSP based on role ──
                if (role.equals("Doctor") || role.equals("Nurse")) {
                    forward(request, response, "/doctor/manuals.jsp");
                } else {
                    forward(request, response, "/manager/manuals.jsp");
                }
                break;
            }

            case "view": {
                int id = Integer.parseInt(request.getParameter("id"));
                Manual manual = Manual.chercher_id(id);
                if (manual == null) {
                    request.getSession().setAttribute("errorMsg", "Manual not found.");
                    response.sendRedirect(request.getContextPath() + "/manuals");
                    return;
                }
                request.setAttribute("manual", manual);
                if (role.equals("Doctor") || role.equals("Nurse")) {
                    forward(request, response, "/doctor/manuals.jsp");
                } else {
                    forward(request, response, "/manager/manuals.jsp");
                }
                break;
            }

            case "new": {
                if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }
                List<Equipment> equipmentList = Equipment.liste();
                request.setAttribute("equipmentList", equipmentList);
                forward(request, response, "/manager/manual-upload.jsp");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/manuals");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        String role = currentUser.getRole();

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "upload": {
                if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }

                String equipmentIdStr = request.getParameter("equipmentId");
                String title          = request.getParameter("title");
                String typeDoc        = request.getParameter("typeDoc");
                Part   filePart       = request.getPart("file");

                if (isBlank(equipmentIdStr) || isBlank(title) || filePart == null
                        || filePart.getSize() == 0) {
                    request.setAttribute("error", "The equipment, title and file are required.");
                    request.setAttribute("equipmentList", Equipment.liste());
                    forward(request, response, "/manager/manuals.jsp");
                    return;
                }

                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                if (!fileName.toLowerCase().endsWith(".pdf")) {
                    request.setAttribute("error", "Only PDF files are accepted.");
                    request.setAttribute("equipmentList", Equipment.liste());
                    forward(request, response, "/manager/manual-upload.jsp");
                    return;
                }

                String uploadPath = UPLOAD_BASE + File.separator + UPLOAD_DIR;
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                String filePath = uploadPath + File.separator + uniqueFileName;

                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                }

                Manual manual = new Manual();
                manual.setEquipmentId(Integer.parseInt(equipmentIdStr));
                manual.setTitle(title.trim());
                manual.setTypeDoc(typeDoc != null ? typeDoc.trim() : "");
                manual.setFilePath(UPLOAD_DIR + "/" + uniqueFileName);
                manual.setUploaderId(currentUser.getUserId());

                boolean ok = Manual.ajouter(manual);
                if (ok) {
                    AuditLog log = new AuditLog();
                    log.setUserId(currentUser.getUserId());
                    log.setAction("UPLOAD_MANUAL");
                    log.setDetails("Manual upload : " + title + " for equipment ID=" + equipmentIdStr);
                    AuditLog.ajouter(log);

                    request.getSession().setAttribute("successMsg",
                            "Manuel \"" + title + "\" Uploaded successfully.");
                    response.sendRedirect(request.getContextPath() + "/manuals");
                } else {
                    request.setAttribute("error", "Error while saving the manual.");
                    request.setAttribute("equipmentList", Equipment.liste());
                    forward(request, response, "/manager/manual-upload.jsp");
                }
                break;
            }

            case "delete": {
                if (!role.equals("Administrator") && !role.equals("Technical_Manager")) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }

                int manualId = Integer.parseInt(request.getParameter("manualId"));
                Manual manual = Manual.chercher_id(manualId);

                if (manual != null) {
                    String uploadPath = UPLOAD_BASE + File.separator
                            + manual.getFilePath();
                    File file = new File(uploadPath);
                    if (file.exists()) file.delete();

                    boolean ok = Manual.supprimer(manualId);
                    if (ok) {
                        AuditLog log = new AuditLog();
                        log.setUserId(currentUser.getUserId());
                        log.setAction("DELETE_MANUAL");
                        log.setDetails("Manual deletion ID=" + manualId
                                + " | Fichier: " + manual.getTitle());
                        AuditLog.ajouter(log);

                        request.getSession().setAttribute("successMsg", "Manual deleted.");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/manuals");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/manuals");
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
