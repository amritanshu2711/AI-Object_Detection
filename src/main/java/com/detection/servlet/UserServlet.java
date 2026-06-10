package com.detection.servlet;

import com.detection.dao.UserDAO;
import com.detection.model.User;
import com.detection.util.SecurityUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserServlet", urlPatterns = {"/user-register", "/user-profile-update", "/user-password-change"})
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    public void init() {
        userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        
        if ("/user-register".equals(path)) {
            handleRegister(request, response);
        } else if ("/user-profile-update".equals(path)) {
            handleProfileUpdate(request, response);
        } else if ("/user-password-change".equals(path)) {
            handlePasswordChange(request, response);
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String fullName = SecurityUtil.sanitizeInput(request.getParameter("fullName"));
        String email = SecurityUtil.sanitizeInput(request.getParameter("email"));
        String mobileNumber = SecurityUtil.sanitizeInput(request.getParameter("mobileNumber"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (fullName.isEmpty() || email.isEmpty() || mobileNumber.isEmpty() || password.isEmpty()) {
            request.setAttribute("errorMsg", "All fields are required!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMsg", "Passwords do not match!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        List<User> allUsers = userDAO.getAllUsers();
        for (User u : allUsers) {
            if (u.getEmail().equalsIgnoreCase(email)) {
                request.setAttribute("errorMsg", "Email address is already registered!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
        }

        // Register user
        User user = new User();
        user.setFullName(fullName);
        user.setEmail(email);
        user.setMobileNumber(mobileNumber);
        user.setPassword(SecurityUtil.hashPassword(password));

        boolean success = userDAO.register(user);
        if (success) {
            HttpSession session = request.getSession();
            session.setAttribute("successMsg", "Registration successful! Please login.");
            response.sendRedirect("login.jsp");
        } else {
            request.setAttribute("errorMsg", "Registration failed due to a database error. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }

    private void handleProfileUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String fullName = SecurityUtil.sanitizeInput(request.getParameter("fullName"));
        String mobileNumber = SecurityUtil.sanitizeInput(request.getParameter("mobileNumber"));

        if (fullName.isEmpty() || mobileNumber.isEmpty()) {
            session.setAttribute("errorMsg", "Name and Mobile number cannot be empty.");
            response.sendRedirect("profile.jsp");
            return;
        }

        currentUser.setFullName(fullName);
        currentUser.setMobileNumber(mobileNumber);

        boolean success = userDAO.updateProfile(currentUser);
        if (success) {
            session.setAttribute("currentUser", currentUser);
            session.setAttribute("successMsg", "Profile updated successfully!");
        } else {
            session.setAttribute("errorMsg", "Failed to update profile. Please try again.");
        }
        response.sendRedirect("profile.jsp");
    }

    private void handlePasswordChange(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmNewPassword = request.getParameter("confirmNewPassword");

        if (currentPassword.isEmpty() || newPassword.isEmpty() || confirmNewPassword.isEmpty()) {
            session.setAttribute("errorMsg", "All password fields are required.");
            response.sendRedirect("profile.jsp");
            return;
        }

        // Check if current password is correct
        String hashedInputCurrent = SecurityUtil.hashPassword(currentPassword);
        User dbUser = userDAO.login(currentUser.getEmail(), hashedInputCurrent);
        if (dbUser == null) {
            session.setAttribute("errorMsg", "Current password is incorrect.");
            response.sendRedirect("profile.jsp");
            return;
        }

        if (!newPassword.equals(confirmNewPassword)) {
            session.setAttribute("errorMsg", "New passwords do not match.");
            response.sendRedirect("profile.jsp");
            return;
        }

        // Update password
        String hashedNewPassword = SecurityUtil.hashPassword(newPassword);
        boolean success = userDAO.updatePassword(currentUser.getId(), hashedNewPassword);
        if (success) {
            session.setAttribute("successMsg", "Password changed successfully!");
        } else {
            session.setAttribute("errorMsg", "Failed to update password. Please try again.");
        }
        response.sendRedirect("profile.jsp");
    }
}
