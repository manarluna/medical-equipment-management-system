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
public class AuditLog {

    /**
     *
     * @param i
     * @return
     */
    
    //declaration 
    private int auditLogId;
    private String action;
    private String details;
    private Timestamp actionDate;
    private int userId;
    
    //constructor

    public AuditLog() {
    }

    public AuditLog(int auditLogId, String action, String details, Timestamp actionDate, int userId) {
        this.auditLogId = auditLogId;
        this.action = action;
        this.details = details;
        this.actionDate = actionDate;
        this.userId = userId;
    }
//getters
    public int getAuditLogId() {
        return auditLogId;
    }

    public String getAction() {
        return action;
    }

    public String getDetails() {
        return details;
    }

    public Timestamp getActionDate() {
        return actionDate;
    }

    public int getUserId() {
        return userId;
    }
    //setters

    public void setAuditLogId(int auditLogId) {
        this.auditLogId = auditLogId;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public void setActionDate(Timestamp actionDate) {
        this.actionDate = actionDate;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    
    // ── CRUD ─────────────────────────────────────────────────────────────────
    public static boolean ajouter(AuditLog a) {
        String sql = "INSERT INTO audit_log (action, details, action_date, userId) VALUES (?, ?, NOW(), ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, a.action);
            ps.setString(2, a.details);
            ps.setInt(3,    a.userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ajouter AuditLog error: " + e.getMessage());
            return false;
        }
    }
    
     public static boolean supprimer(int auditLogId) {
        String sql = "DELETE FROM audit_log WHERE audit_log_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, auditLogId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer AuditLog error: " + e.getMessage());
            return false;
        }
    }
public static List<AuditLog> liste() {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT * FROM audit_log ORDER BY action_date DESC";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste AuditLog error: " + e.getMessage());
        }
        return list;
    }

      public static AuditLog chercher_id(int auditLogId) {
        String sql = "SELECT * FROM audit_log WHERE audit_log_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, auditLogId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercher_id AuditLog error: " + e.getMessage());
        }
        return null;
    }
    
     public static List<AuditLog> chercher_par_user(int userId) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT * FROM audit_log WHERE userId = ? ORDER BY action_date DESC";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_par_user AuditLog error: " + e.getMessage());
        }
        return list;
    }
     public static List<AuditLog> getRecent(int limit) {
    List<AuditLog> list = new ArrayList<>();
    String sql = "SELECT * FROM audit_log ORDER BY action_date DESC LIMIT ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, limit);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(map(rs));
    } catch (SQLException e) {
        System.err.println("getRecent AuditLog error: " + e.getMessage());
    }
    return list;
}
     
     
     
     private static AuditLog map(ResultSet rs) throws SQLException {
        return new AuditLog(
            rs.getInt("audit_log_id"),
            rs.getString("action"),
            rs.getString("details"),
            rs.getTimestamp("action_date"),
            rs.getInt("userId")
        );
    }
   
    
    //toString

    @Override
    public String toString() {
        return "AuditLog{" + "auditLogId=" + auditLogId + ", action=" + action + ", details=" + details + ", actionDate=" + actionDate + ", userId=" + userId + '}';
    }
    
    
  
    
}
