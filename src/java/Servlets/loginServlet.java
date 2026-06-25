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

/**
 *
 * @author lunam
 */
@WebServlet("/login")
public class loginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // If already logged in, redirect to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }
    request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
    
     @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String login    = request.getParameter("login");
        String password = request.getParameter("password");

        // Basic validation
        if (login == null || login.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Please fill in all fields.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
                 Users user = Users.authenticate(login.trim(), password.trim());

        if (user != null) {
            // Create session
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("userId",    user.getUserId());
            session.setAttribute("userRole",  user.getRole());
            session.setAttribute("userName",  user.getFirstName() + " " + user.getLastName());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes timeout

            // Log the login action in audit log
            AuditLog log = new AuditLog();
log.setUserId(user.getUserId());
log.setAction("LOGIN");
log.setDetails("User login: " + user.getLogin());
AuditLog.ajouter(log);
            // Redirect based on role
            response.sendRedirect(request.getContextPath() + "/dashboard");

        } else {
            request.setAttribute("error", "Incorrect username or password.");
            request.setAttribute("loginValue", login); // keep login field filled
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
    
    
}
