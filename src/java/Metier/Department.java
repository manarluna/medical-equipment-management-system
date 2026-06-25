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
public class Department {

   
public static int countAll() {
    String sql = "SELECT COUNT(*) FROM department";
    try (Connection con = Shared.connecter();
         Statement st = con.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) return rs.getInt(1);
    } catch (SQLException e) {
        System.err.println("countAll Department error: " + e.getMessage());
    }
    return 0;
}

// Replace countActive() stub
public static int countActive() {
    String sql = "SELECT COUNT(*) FROM department WHERE active = TRUE";
    try (Connection con = Shared.connecter();
         Statement st = con.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) return rs.getInt(1);
    } catch (SQLException e) {
        System.err.println("countActive Department error: " + e.getMessage());
    }
    return 0;
}
    //declaration 
     private int departmentId;
     private String name;
     private String description;
     private String code;
     private boolean active;
  //constructors
     
     public Department() {}
     
    public Department(int departmentId, String name, String description, String code, boolean active) {
        this.departmentId = departmentId;
        this.name = name;
        this.description = description;
        this.code = code;
        this.active = active;
    }
    public Department(int departmentId, String name, String description, boolean active) {
        this.departmentId = departmentId;
        this.name = name;
        this.description = description;
        this.active = active;
    }
     //getters 

    public int getDepartmentId() { return departmentId; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public String getCode() {  return code;}
    public boolean isActive() {   return active; }
    
     //Setters

    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;
    }
    public void setName(String name) {
        this.name = name;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public void setCode(String code) {
        this.code = code;
    }
    public void setActive(boolean active) {
        this.active = active;
    }
    // ── CRUD ─────────────────────────────────────────────────────────────────
    public static boolean ajouter(Department d) {
        String sql = "INSERT INTO department (Name, description, code, active) VALUES (?, ?, ?, ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  d.name);
            ps.setString(2,  d.description);
            ps.setString(3,  d.code);
            ps.setBoolean(4, d.active);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ajouter Department error: " + e.getMessage());
            return false;
        }
    }
       public static boolean supprimer(int departmentId) {
        String sql = "DELETE FROM department WHERE department_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer Department error: " + e.getMessage());
            return false;
        }
    }
     public static boolean save(Department d) {
        String sql = "UPDATE department SET Name=?, description=?, code=?, active=? WHERE department_id=?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  d.name);
            ps.setString(2,  d.description);
            ps.setString(3,  d.code);
            ps.setBoolean(4, d.active);
            ps.setInt(5,     d.departmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("save Department error: " + e.getMessage());
            return false;
        }
    }
    
      public static List<Department> liste() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT * FROM department";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste Department error: " + e.getMessage());
        }
        return list;
    }
     public static Department chercher_id(int id) {
        String sql = "SELECT * FROM department WHERE department_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercher_id Department error: " + e.getMessage());
        }
        return null;
    }
       public static Department chercher_code(String code) {
        String sql = "SELECT * FROM department WHERE code = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, code);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercher_code Department error: " + e.getMessage());
        }
        return null;
    }
    public static boolean codeExists(String code) {
    String sql = "SELECT COUNT(*) FROM department WHERE code = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, code);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1) > 0;
    } catch (SQLException e) {
        System.err.println("codeExists Department error: " + e.getMessage());
    }
    return false;
}

public static boolean hasActiveEquipment(int deptId) {
    String sql = "SELECT COUNT(*) FROM equipment WHERE department_id = ? AND active = TRUE";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, deptId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1) > 0;
    } catch (SQLException e) {
        System.err.println("hasActiveEquipment error: " + e.getMessage());
    }
    return false;
}

public static boolean deactivate(int id) {
    String sql = "UPDATE department SET active = FALSE WHERE department_id = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, id);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        System.err.println("deactivate Department error: " + e.getMessage());
        return false;
    }
}

public static boolean reactivate(int id) {
    String sql = "UPDATE department SET active = TRUE WHERE department_id = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, id);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        System.err.println("reactivate Department error: " + e.getMessage());
        return false;
    }
}
    // ── Department-User assignment ────────────────────────────────────────────

    /** Assign a user to a department — replaces any existing assignment */
    public static boolean assignUser(int userId, int departmentId) {
        removeUser(userId); // remove old assignment first
        String sql = "INSERT INTO department_user (userId, department_id) VALUES (?, ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, departmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("assignUser Department error: " + e.getMessage());
            return false;
        }
    }

    /** Remove a user from their department */
    public static boolean removeUser(int userId) {
        String sql = "DELETE FROM department_user WHERE userId = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("removeUser Department error: " + e.getMessage());
            return false;
        }
    }

    private static Department map(ResultSet rs) throws SQLException {
        return new Department(
            rs.getInt("department_id"),
            rs.getString("Name"),
            rs.getString("description"),
            rs.getString("code"),
            rs.getBoolean("active")
        );
    }
   
    //toString
    @Override
    public String toString() {
        return "Department{" + "departmentId=" + departmentId + ", name=" + name + ", description=" + description + ", code=" + code + ", active=" + active + '}';
    }
    
     
     
     
     
}
