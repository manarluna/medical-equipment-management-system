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
public class MaintenanceTicket {

    public static int countByStatus(String status) {
    String sql = "SELECT COUNT(*) FROM maintenance_ticket WHERE status = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, status);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    } catch (SQLException e) {
        System.err.println("countByStatus MaintenanceTicket error: " + e.getMessage());
    }
    return 0;
}

public static int countResolvedThisMonth() {
    String sql = "SELECT COUNT(*) FROM maintenance_ticket "
               + "WHERE status = 'RESOLVED' "
               + "AND MONTH(closure_date) = MONTH(NOW()) "
               + "AND YEAR(closure_date) = YEAR(NOW())";
    try (Connection con = Shared.connecter();
         Statement st = con.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) return rs.getInt(1);
    } catch (SQLException e) {
        System.err.println("countResolvedThisMonth error: " + e.getMessage());
    }
    return 0;
}

public static List<MaintenanceTicket> getDueWithinDays(int days) {
    List<MaintenanceTicket> list = new ArrayList<>();
    String sql = "SELECT * FROM maintenance_ticket "
               + "WHERE type = 'Preventive' "
               + "AND status != 'resolved' "
               + "AND closure_date <= DATE_ADD(NOW(), INTERVAL ? DAY) "
               + "ORDER BY closure_date ASC";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, days);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(map(rs));
    } catch (SQLException e) {
        System.err.println("getDueWithinDays error: " + e.getMessage());
    }
    return list;
}

public static List<MaintenanceTicket> getRecent(int limit) {
    List<MaintenanceTicket> list = new ArrayList<>();
    String sql = "SELECT * FROM maintenance_ticket ORDER BY creation_date DESC LIMIT ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, limit);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(map(rs));
    } catch (SQLException e) {
        System.err.println("getRecent MaintenanceTicket error: " + e.getMessage());
    }
    return list;
}
    
    

    private int maintenanceId;
    private String type;    // 'preventive' | 'corrective'
    private String status ;   // 'open' | 'in_progress' | 'resolved' | 'closed'
    private String description;
    private String resolutionNotes;
    private String interventionId;
    private Timestamp creationDate;
    private Timestamp closureDate;
    private int equipmentId;
    private int faultReportId;   
    private int technicianId;  
          
    //constructor

    public MaintenanceTicket() {
    }

    public MaintenanceTicket(int maintenanceId, String type, String status, String description, String resolutionNotes, String interventionId, Timestamp creationDate, Timestamp closureDate, int equipmentId, int faultReportId, int technicianId) {
        this.maintenanceId = maintenanceId;
        this.type = type;
        this.status = status;
        this.description = description;
        this.resolutionNotes = resolutionNotes;
        this.interventionId = interventionId;
        this.creationDate = creationDate;
        this.closureDate = closureDate;
        this.equipmentId = equipmentId;
        this.faultReportId = faultReportId;
        this.technicianId = technicianId;
    }
    //Getters

    public int getMaintenanceId() {
        return maintenanceId;
    }

    public String getType() {
        return type;
    }

    public String getStatus() {
        return status;
    }

    public String getDescription() {
        return description;
    }

    public String getResolutionNotes() {
        return resolutionNotes;
    }

    public String getInterventionId() {
        return interventionId;
    }

    public Timestamp getCreationDate() {
        return creationDate;
    }

    public Timestamp getClosureDate() {
        return closureDate;
    }

    public int getEquipmentid() {
        return equipmentId;
    }

    public int getFaultReportId() {
        return faultReportId;
    }

    public int getTechnicianId() {
        return technicianId;
    }
    // setters

    public void setMaintenanceId(int maintenanceId) {
        this.maintenanceId = maintenanceId;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setResolutionNotes(String resolutionNotes) {
        this.resolutionNotes = resolutionNotes;
    }

    public void setInterventionId(String interventionId) {
        this.interventionId = interventionId;
    }

    public void setCreationDate(Timestamp creationDate) {
        this.creationDate = creationDate;
    }

    public void setClosureDate(Timestamp closureDate) {
        this.closureDate = closureDate;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public void setFaultReportId(int faultReportId) {
        this.faultReportId = faultReportId;
    }

    public void setTechnicianId(int technicianId) {
        this.technicianId = technicianId;
    }
    
    // ── CRUD ─────────────────────────────────────────────────────────────────
    public static boolean ajouter(MaintenanceTicket m) {
        String sql = "INSERT INTO maintenance_ticket (type, status, description, resolution_notes, "
                   + "intervention_id, creation_date, closure_date, equipment_id, fault_report_id, technician_id) "
                   + "VALUES (?,?,?,?,?,NOW(),?,?,?,?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,    m.type);
            ps.setString(2,    m.status != null ? m.status : "open");
            ps.setString(3,    m.description);
            ps.setString(4,    m.resolutionNotes);
            ps.setString(5,    m.interventionId);
            ps.setTimestamp(6, m.closureDate);
            ps.setInt(7,       m.equipmentId);
            if (m.faultReportId > 0) ps.setInt(8, m.faultReportId);
else ps.setNull(8, java.sql.Types.INTEGER);

if (m.technicianId > 0) ps.setInt(9, m.technicianId);
else ps.setNull(9, java.sql.Types.INTEGER);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ajouter MaintenanceTicket error: " + e.getMessage());
            return false;
        }
    }
       public static boolean save(MaintenanceTicket m) {
        String sql = "UPDATE maintenance_ticket SET type=?, status=?, description=?, "
                   + "resolution_notes=?, intervention_id=?, closure_date=?, "
                   + "equipment_id=?, fault_report_id=?, technician_id=? "
                   + "WHERE maintenance_id=?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,    m.type);
            ps.setString(2,    m.status);
            ps.setString(3,    m.description);
            ps.setString(4,    m.resolutionNotes);
            ps.setString(5,    m.interventionId);
            ps.setTimestamp(6, m.closureDate);
            ps.setInt(7,       m.equipmentId);
            ps.setInt(8,       m.faultReportId);
            ps.setInt(9,       m.technicianId);
            ps.setInt(10,      m.maintenanceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("save MaintenanceTicket error: " + e.getMessage());
            return false;
        }
    }
    
    public static List<MaintenanceTicket> liste() {
        List<MaintenanceTicket> list = new ArrayList<>();
        String sql = "SELECT * FROM maintenance_ticket ORDER BY creation_date DESC";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste MaintenanceTicket error: " + e.getMessage());
        }
        return list;
    }

    public static MaintenanceTicket chercher_id(int maintenanceId) {
        String sql = "SELECT * FROM maintenance_ticket WHERE maintenance_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, maintenanceId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercher_id MaintenanceTicket error: " + e.getMessage());
        }
        return null;
    }
     public static List<MaintenanceTicket> chercher_status(String status) {
        List<MaintenanceTicket> list = new ArrayList<>();
        String sql = "SELECT * FROM maintenance_ticket WHERE status = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_status MaintenanceTicket error: " + e.getMessage());
        }
        return list;
    }

    public static List<MaintenanceTicket> chercher_equipement(int equipmentId) {
        List<MaintenanceTicket> list = new ArrayList<>();
        String sql = "SELECT * FROM maintenance_ticket WHERE equipment_id = ? ORDER BY creation_date DESC";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_equipement MaintenanceTicket error: " + e.getMessage());
        }
        return list;
    }
    
    public static List<MaintenanceTicket> getByStatus(String status) {
    return chercher_status(status); // reuse existing method
}

public static boolean updateStatus(int maintenanceId, String status) {
    String sql = "UPDATE maintenance_ticket SET status = ? WHERE maintenance_id = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, status);
        ps.setInt(2,    maintenanceId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        System.err.println("updateStatus MaintenanceTicket error: " + e.getMessage());
        return false;
    }
}

public static boolean close(int maintenanceId, String resolutionNotes) {
    String sql = "UPDATE maintenance_ticket SET status = 'resolved', "
               + "resolution_notes = ?, closure_date = NOW() "
               + "WHERE maintenance_id = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, resolutionNotes);
        ps.setInt(2,    maintenanceId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        System.err.println("close MaintenanceTicket error: " + e.getMessage());
        return false;
    }
}

public void setNextDueDate(String dateStr) {
    if (dateStr != null && !dateStr.isEmpty()) {
        this.closureDate = Timestamp.valueOf(dateStr + " 00:00:00");
    }
}
    
    
    
    private static MaintenanceTicket map(ResultSet rs) throws SQLException {
        return new MaintenanceTicket(
            rs.getInt("maintenance_id"),
            rs.getString("type"),
            rs.getString("status"),
            rs.getString("description"),
            rs.getString("resolution_notes"),
            rs.getString("intervention_id"),
            rs.getTimestamp("creation_date"),
            rs.getTimestamp("closure_date"),
            rs.getInt("equipment_id"),
            rs.getInt("fault_report_id"),
            rs.getInt("technician_id")
        );
    }

  
    
    //toString

    @Override
    public String toString() {
        return "MaintenanceTicket{" + "maintenanceId=" + maintenanceId + ", "
                + "type=" + type + ", status=" + status + ", description=" + description + ","
                + " resolutionNotes=" + resolutionNotes + ", interventionId=" + interventionId + ","
                + " creationDate=" + creationDate + ", closureDate=" + closureDate + ", "
                + "equipmentId=" + equipmentId + ", faultReportId=" + faultReportId + ", "
                + "technicianId=" + technicianId + '}';
    }
    
   
  
    
}
