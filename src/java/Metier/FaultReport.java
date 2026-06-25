package Metier;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FaultReport {

    // ── Fields ───────────────────────────────────────────────────────────────
    private int faultId;
    private String room;
    private String description;
    private String urgency;        // 'low' | 'medium' | 'high' | 'critical'
    private String status;         // 'pending' | 'in_progress' | 'resolved'
    private Timestamp reportDate;
    private Timestamp resolutionDate;
    private int equipmentId;
    private int reporterId;

    // ── Constructors ─────────────────────────────────────────────────────────
    public FaultReport() {}

    public FaultReport(int faultId, String room, String description, String urgency,
                       String status, Timestamp reportDate, Timestamp resolutionDate,
                       int equipmentId, int reporterId) {
        this.faultId        = faultId;
        this.room           = room;
        this.description    = description;
        this.urgency        = urgency;
        this.status         = status;
        this.reportDate     = reportDate;
        this.resolutionDate = resolutionDate;
        this.equipmentId    = equipmentId;
        this.reporterId     = reporterId;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public int       getFaultId()        { return faultId; }
    public String    getRoom()           { return room; }
    public String    getDescription()    { return description; }
    public String    getUrgency()        { return urgency; }
    public String    getStatus()         { return status; }
    public Timestamp getReportDate()     { return reportDate; }
    public Timestamp getResolutionDate() { return resolutionDate; }
    public int       getEquipmentId()    { return equipmentId; }
    public int       getReporterId()     { return reporterId; }

    // ── Setters ───────────────────────────────────────────────────────────────
    public void setFaultId(int faultId)                    { this.faultId        = faultId; }
    public void setRoom(String room)                        { this.room           = room; }
    public void setDescription(String description)          { this.description    = description; }
    public void setUrgency(String urgency)                  { this.urgency        = urgency; }
    public void setStatus(String status)                    { this.status         = status; }
    public void setReportDate(Timestamp reportDate)         { this.reportDate     = reportDate; }
    public void setResolutionDate(Timestamp resolutionDate) { this.resolutionDate = resolutionDate; }
    public void setEquipmentId(int equipmentId)             { this.equipmentId    = equipmentId; }
    public void setReporterId(int reporterId)               { this.reporterId     = reporterId; }

    // ── CRUD ──────────────────────────────────────────────────────────────────

    /**
     * FIX 1: room is NOT NULL in DB — send 'N/A' when user leaves it blank.
     * FIX 2: DB primary key is fault_report_id not fault_id (handled in map()).
     */
    public static boolean ajouter(FaultReport f) {
        String sql = "INSERT INTO fault_report "
                   + "(room, description, urgency, status, report_date, equipment_id, reporter_id) "
                   + "VALUES (?, ?, ?, ?, NOW(), ?, ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {

            // room is NOT NULL in DB — never send empty string or null
            String room = (f.room != null && !f.room.trim().isEmpty()) ? f.room.trim() : "N/A";
            ps.setString(1, room);
            ps.setString(2, f.description);
            ps.setString(3, f.urgency);
            ps.setString(4, f.status != null ? f.status : "pending");
            ps.setInt(5,    f.equipmentId);
            ps.setInt(6,    f.reporterId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("ajouter FaultReport error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public static boolean supprimer(int faultId) {
        String sql = "DELETE FROM fault_report WHERE fault_report_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, faultId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer FaultReport error: " + e.getMessage());
            return false;
        }
    }

    public static boolean save(FaultReport f) {
        String sql = "UPDATE fault_report "
                   + "SET room=?, description=?, urgency=?, status=?, "
                   + "resolution_date=?, equipment_id=?, reporter_id=? "
                   + "WHERE fault_report_id=?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            String room = (f.room != null && !f.room.trim().isEmpty()) ? f.room.trim() : "N/A";
            ps.setString(1, room);
            ps.setString(2,    f.description);
            ps.setString(3,    f.urgency);
            ps.setString(4,    f.status);
            ps.setTimestamp(5, f.resolutionDate);
            ps.setInt(6,       f.equipmentId);
            ps.setInt(7,       f.reporterId);
            ps.setInt(8,       f.faultId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("save FaultReport error: " + e.getMessage());
            return false;
        }
    }

    public static List<FaultReport> liste() {
        List<FaultReport> list = new ArrayList<>();
        String sql = "SELECT * FROM fault_report ORDER BY report_date DESC";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste FaultReport error: " + e.getMessage());
        }
        return list;
    }

    public static FaultReport chercher_id(int faultId) {
        String sql = "SELECT * FROM fault_report WHERE fault_report_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, faultId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercher_id FaultReport error: " + e.getMessage());
        }
        return null;
    }

    public static List<FaultReport> chercher_status(String status) {
        List<FaultReport> list = new ArrayList<>();
        String sql = "SELECT * FROM fault_report WHERE status = ? ORDER BY report_date DESC";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_status FaultReport error: " + e.getMessage());
        }
        return list;
    }

    public static List<FaultReport> chercher_reporter(int reporterId) {
        List<FaultReport> list = new ArrayList<>();
        String sql = "SELECT * FROM fault_report WHERE reporter_id = ? ORDER BY report_date DESC";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reporterId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_reporter FaultReport error: " + e.getMessage());
        }
        return list;
    }

    // ── Convenience aliases ───────────────────────────────────────────────────
    public static List<FaultReport> getByReporter(int userId)  { return chercher_reporter(userId); }
    public static List<FaultReport> getByStatus(String status) { return chercher_status(status); }

    // ── Aggregate / dashboard helpers ─────────────────────────────────────────
    public static int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM fault_report WHERE status = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("countByStatus FaultReport error: " + e.getMessage());
        }
        return 0;
    }

    public static int countByUrgency(String urgency) {
        String sql = "SELECT COUNT(*) FROM fault_report WHERE urgency = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, urgency);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("countByUrgency FaultReport error: " + e.getMessage());
        }
        return 0;
    }

    public static List<FaultReport> getRecent(int limit) {
        List<FaultReport> list = new ArrayList<>();
        String sql = "SELECT * FROM fault_report ORDER BY report_date DESC LIMIT ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("getRecent FaultReport error: " + e.getMessage());
        }
        return list;
    }

    // ── Status update ─────────────────────────────────────────────────────────
    public static boolean updateStatus(int faultId, String status) {
        String sql = "UPDATE fault_report "
                   + "SET status = ?, "
                   + "resolution_date = CASE WHEN ? = 'resolved' THEN NOW() ELSE resolution_date END "
                   + "WHERE fault_report_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setInt(3,    faultId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("updateStatus FaultReport error: " + e.getMessage());
            return false;
        }
    }

    // ── Mapper ────────────────────────────────────────────────────────────────
    private static FaultReport map(ResultSet rs) throws SQLException {
        return new FaultReport(
            rs.getInt("fault_report_id"),  // FIX: was "fault_id" — real column is fault_report_id
            rs.getString("room"),
            rs.getString("description"),
            rs.getString("urgency"),
            rs.getString("status"),
            rs.getTimestamp("report_date"),
            rs.getTimestamp("resolution_date"),
            rs.getInt("equipment_id"),
            rs.getInt("reporter_id")
        );
    }

    // ── toString ──────────────────────────────────────────────────────────────
    @Override
    public String toString() {
        return "FaultReport{faultId=" + faultId + ", room=" + room
             + ", description=" + description + ", urgency=" + urgency
             + ", status=" + status + ", reportDate=" + reportDate
             + ", resolutionDate=" + resolutionDate
             + ", equipmentId=" + equipmentId + ", reporterId=" + reporterId + '}';
    }
}