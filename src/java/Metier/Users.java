/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Metier;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * @author lunam
 */
public class Users {

    // --- Static Logic for Dashboards ---
    public static int countAll() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("countAll error: " + e.getMessage());
        }
        return 0;
    }

    public static int countByRole(String role) {
        String sql = "SELECT COUNT(*) FROM users WHERE role = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("countByRole error: " + e.getMessage());
        }
        return 0;
    }

    // --- Attributes ---
    private int userId;
    private String login;
    private String password;
    private String firstName;
    private String lastName;
    private String role; // 'admin' | 'technical_manager' | 'doctor' | 'nurse'
    private String email;
    private boolean active;

    // --- Constructor ---
    public Users(int userId, String login, String password, String firstName, String lastName, String role, String email, boolean active) {
        this.userId = userId;
        this.login = login;
        this.password = password;
        this.firstName = firstName;
        this.lastName = lastName;
        this.role = role;
        this.email = email;
        this.active = active;
    }

    public Users() {}

    // --- SMART HELPER METHOD ---
    /**
     * This method fixes the Servlet error by fetching the department ID 
     * from the association table without changing the User table schema.
     */
    public int getDepartmentId() {
        // Calls your DepartmentUser association class to find the link on the fly
        List<DepartmentUser> links = DepartmentUser.chercher_par_user(this.userId);
        
        if (links != null && !links.isEmpty()) {
            // Returns the first department linked to this user
            return links.get(0).getDepartmentId();
        }
        return 0; // Return 0 if no department is assigned
    }

    // --- Getters & Setters ---
    public int getUserId() { return userId; }
    public String getLogin() { return login; }
    public String getPassword() { return password; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getRole() { return role; }
    public String getEmail() { return email; }
    public boolean isActive() { return active; }

    public void setUserId(int userId) { this.userId = userId; }
    public void setLogin(String login) { this.login = login; }
    public void setPassword(String password) { this.password = password; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public void setRole(String role) { this.role = role; }
    public void setEmail(String email) { this.email = email; }
    public void setActive(boolean active) { this.active = active; }

    // --- Authentication ---
    public static Users authenticate(String login, String password) {
        Users user = null;
        String hashed = Shared.hashPassword(password);
        String sql = "SELECT * FROM users WHERE login = ? AND password = ? AND active = TRUE";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, login);
            ps.setString(2, hashed);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                user = map(rs);
            }
        } catch (SQLException e) {
            System.err.println("authenticate error: " + e.getMessage());
        }
        return user;
    }

    // --- CRUD Operations ---
    public static boolean ajouter(Users u) {
        String sql = "INSERT INTO users (login, password, firstName, lastName, role, email, active) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.login);
            ps.setString(2, Shared.hashPassword(u.password));
            ps.setString(3, u.firstName);
            ps.setString(4, u.lastName);
            ps.setString(5, u.role);
            ps.setString(6, u.email);
            ps.setBoolean(7, u.active);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ajouter Users error: " + e.getMessage());
            return false;
        }
    }

    public static boolean supprimer(int userId) {
        String sql = "DELETE FROM users WHERE userId = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer Users error: " + e.getMessage());
            return false;
        }
    }

    public static boolean save(Users u) {
        String sql = "UPDATE users SET login=?, firstName=?, lastName=?, role=?, email=?, active=? WHERE userId=?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.login);
            ps.setString(2, u.firstName);
            ps.setString(3, u.lastName);
            ps.setString(4, u.role);
            ps.setString(5, u.email);
            ps.setBoolean(6, u.active);
            ps.setInt(7, u.userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("save Users error: " + e.getMessage());
            return false;
        }
    }

    public static List<Users> liste() {
        List<Users> list = new ArrayList<>();
        String sql = "SELECT * FROM users";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste Users error: " + e.getMessage());
        }
        return list;
    }

    public static Users chercher_id(int userId) {
        String sql = "SELECT * FROM users WHERE userId = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercherId Users error: " + e.getMessage());
        }
        return null;
    }
      public static boolean updatePassword(int userId, String newPassword) {
    String sql = "UPDATE users SET password = ? WHERE userId = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, Shared.hashPassword(newPassword));
        ps.setInt(2, userId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        System.err.println("updatePassword error: " + e.getMessage());
        return false;
    }
}
    public static List<Users> chercher_role(String role) {
        List<Users> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("chercher_role Users error: " + e.getMessage());
        }
        return list;
    }
    
    
    /** Returns the userId of the most recently inserted user */
    public static int getLastInsertedId() {
        String sql = "SELECT MAX(userId) FROM users";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("getLastInsertedId Users error: " + e.getMessage());
        }
        return -1;
    }

    // --- Helper Method ---
    private static Users map(ResultSet rs) throws SQLException {
        return new Users(
            rs.getInt("userId"),
            rs.getString("login"),
            rs.getString("password"),
            rs.getString("firstName"),
            rs.getString("lastName"),
            rs.getString("role"),
            rs.getString("email"),
            rs.getBoolean("active")
        );
    }

    @Override
    public String toString() {
        return "User{" + "userId=" + userId + ", login=" + login + ", role=" + role + ", active=" + active + '}';
    }
}