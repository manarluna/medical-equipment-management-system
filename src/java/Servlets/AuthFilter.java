/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Servlets;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;



/**
 *
 * @author lunam
 */
@WebFilter("/*")
public class AuthFilter implements Filter {
     @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String contextPath = request.getContextPath(); // e.g. "/ME2MS"
        String requestURI  = request.getRequestURI();  // e.g. "/ME2MS/dashboard"

        // ── 1. Always allow login and logout ──────────────────────
        if (requestURI.equals(contextPath + "/login")
                || requestURI.equals(contextPath + "/logout")
                || requestURI.endsWith("login.jsp")){
            chain.doFilter(request, response);
            return;
        }

     
       
        if (requestURI.contains("/css/")
                || requestURI.contains("/js/")
                || requestURI.contains("/images/")
                || requestURI.contains("/fonts/")
                || requestURI.endsWith(".css")
                || requestURI.endsWith(".js")
                || requestURI.endsWith(".png")
                || requestURI.endsWith(".jpg")
                || requestURI.endsWith(".ico")
                || requestURI.endsWith(".gif")
                || requestURI.endsWith(".woff")
                || requestURI.endsWith(".woff2")) {
            chain.doFilter(request, response);
            return;
        }

    // ── 3. Check if the user has an active session ────────────
        HttpSession session  = request.getSession(false);
        boolean     loggedIn = (session != null && session.getAttribute("currentUser") != null);

        if (!loggedIn) {
            // Not logged in → save the originally requested URL so we can
            // redirect back to it after successful login (optional UX improvement)
            String originalURL = requestURI;
            String queryString = request.getQueryString();
            if (queryString != null) originalURL += "?" + queryString;

            request.getSession(true).setAttribute("redirectAfterLogin", originalURL);

            // Redirect to login page
            response.sendRedirect(contextPath + "/login");
            return;
        }
         // ── 4. Session exists → allow the request through ─────────
        // Prevent browser from caching sensitive pages
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma",        "no-cache");
        response.setDateHeader("Expires",    0);

        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Nothing to initialize
    }

    @Override
    public void destroy() {
        // Nothing to clean up
    }
   
    
}
