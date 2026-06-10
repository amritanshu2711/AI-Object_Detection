package com.detection.servlet;

import com.detection.dao.AdminDAO;
import com.detection.dao.UserDAO;
import com.detection.model.Admin;
import com.detection.model.User;
import com.detection.util.SecurityUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/user-login", "/admin-login"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private AdminDAO adminDAO;

    public void init() {
        userDAO = new UserDAO();
        adminDAO = new AdminDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        
        if ("/user-login".equals(path)) {
            handleUserLogin(request, response);
        } else if ("/admin-login".equals(path)) {
            handleAdminLogin(request, response);
        }
    }

    private void handleUserLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = SecurityUtil.sanitizeInput(request.getParameter("email"));
        String password = request.getParameter("password");

        if (email.isEmpty() || password.isEmpty()) {
            request.setAttribute("errorMsg", "Email and Password are required!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        String passwordHash = SecurityUtil.hashPassword(password);
        User user = userDAO.login(email, passwordHash);

        if (user != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            response.sendRedirect("dashboard.jsp");
        } else {
            request.setAttribute("errorMsg", "Invalid Email or Password!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private void handleAdminLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = SecurityUtil.sanitizeInput(request.getParameter("username"));
        String password = request.getParameter("password");

        if (username.isEmpty() || password.isEmpty()) {
            request.setAttribute("errorMsg", "Username and Password are required!");
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
            return;
        }

        String passwordHash = SecurityUtil.hashPassword(password);
        Admin admin = adminDAO.login(username, passwordHash);

        if (admin != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("currentAdmin", admin);
            response.sendRedirect("adminDashboard.jsp");
        } else {
            request.setAttribute("errorMsg", "Invalid Admin Username or Password!");
            request.getRequestDispatcher("adminLogin.jsp").forward(request, response);
        }
    }
}
