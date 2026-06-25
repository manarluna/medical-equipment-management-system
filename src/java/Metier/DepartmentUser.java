/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Metier;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author lunam
 */
public class DepartmentUser {
    //declaration
    private int departmentUserId;
    private int userId;
    private int departmentId;

    public DepartmentUser() {
    }

    public DepartmentUser(int departmentUserId, int userId, int departmentId) {
        this.departmentUserId = departmentUserId;
        this.userId = userId;
        this.departmentId = departmentId;
    }

    public int getDepartmentUserId() {
        return departmentUserId;
    }

    public int getUserId() {
        return userId;
    }

    public int getDepartmentId() {
        return departmentId;
    }

    public void setDepartmentUserId(int departmentUserId) {
        this.departmentUserId = departmentUserId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }

      // ── CRUD ─────────────────────────────────────────────────────────────────
    public static boolean ajouter(DepartmentUser du) {
        String sql = "INSERT INTO department_user (userId, department_id) VALUES (?, ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, du.userId);
            ps.setInt(2, du.departmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ajouter DepartmentUser error: " + e.getMessage());
            return false;
        }
    }
       public static boolean supprimer(int departmentUserId) {
        String sql = "DELETE FROM department_user WHERE department_user_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, departmentUserId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer DepartmentUser error: " + e.getMessage());
            return false;
        }
    }
         public static List<DepartmentUser> liste() {
        List<DepartmentUser> list = new ArrayList<>();
        String sql = "SELECT * FROM department_user";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste DepartmentUser error: " + e.getMessage());
        }
        return list;
    }
    
      public static List<DepartmentUser> chercher_par_user(int userId) {
        List<DepartmentUser> list = new ArrayList<>();
        String sql = "SELECT * FROM department_user WHERE userId = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_par_user DepartmentUser error: " + e.getMessage());
        }
        return list;
    }
    public static List<DepartmentUser> chercher_par_departement(int departmentId) {
        List<DepartmentUser> list = new ArrayList<>();
        String sql = "SELECT * FROM department_user WHERE department_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_par_departement DepartmentUser error: " + e.getMessage());
        }
        return list;
    }

    private static DepartmentUser map(ResultSet rs) throws SQLException {
        return new DepartmentUser(
            rs.getInt("department_user_id"),
            rs.getInt("userId"),
            rs.getInt("department_id")
        );
    }
    
    
    
    @Override
    public String toString() {
        return "DepartmentUser{" + "departmentUserId=" + departmentUserId + ", userId=" + userId + ", departmentId=" + departmentId + '}';
    }
    
    
    
    
    
    
    
    
}
