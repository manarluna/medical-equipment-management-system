package Servlets;

import Metier.Notification;
import Metier.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        // FIX: was "user" — the rest of the app uses "currentUser"
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Users user   = (Users) session.getAttribute("currentUser"); // FIX
        String action = req.getParameter("action");
        if (action == null) action = "list";

        switch (action) {

            case "count": {
                // Returns unread count as JSON (used for AJAX badge updates)
                int unread = Notification.compterNonLus(user.getUserId());
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                PrintWriter out = resp.getWriter();
                out.print("{\"unread\":" + unread + "}");
                break;
            }

            case "markAllRead": {
                // Mark all as read then go back to wherever user came from
                Notification.marquerTousLus(user.getUserId());
                String referer = req.getHeader("Referer");
                if (referer != null && !referer.isEmpty()) {
                    resp.sendRedirect(referer);
                } else {
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                }
                break;
            }

            case "list":
            default: {
                // No notifications page yet — just go to dashboard
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                break;
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Users user   = (Users) session.getAttribute("currentUser"); // FIX
        String action = req.getParameter("action");

        if ("markOne".equals(action)) {
            int id = Integer.parseInt(req.getParameter("notificationId"));
            Notification.marquerLu(id);

        } else if ("markAll".equals(action)) {
            Notification.marquerTousLus(user.getUserId());
        }

        resp.sendRedirect(req.getContextPath() + "/NotificationServlet?action=list");
    }
}