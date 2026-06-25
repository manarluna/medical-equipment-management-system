package Metier;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 
 * Notification types used in this project:
 *   "FAULT_REPORT"     – sent to every Technical Manager when a new fault
 *                        report is submitted (F-20)
 *   "TICKET_RESOLVED"  – sent to the original reporter when their fault ticket
 *                        is resolved (F-21)
 *   "MAINTENANCE_DUE"  – sent to every Technical Manager when a preventive
 *                        maintenance task is due within N days (F-28)
 *

 */
public class Notification {

    // ── Fields ────────────────────────────────────────────────────────────────
    private int    notificationId;
    private String type;          // 'FAULT_REPORT' | 'TICKET_RESOLVED' | 'MAINTENANCE_DUE'
    private String message;
    private boolean isRead;
    private Timestamp createdAt;
    private int    userId;        // recipient
    private int    referenceId;   // related fault_id or maintenance_id (0 = none)

    // ── Constructors ──────────────────────────────────────────────────────────
    public Notification() {}

    public Notification(int notificationId, String type, String message,
                        boolean isRead, Timestamp createdAt,
                        int userId, int referenceId) {
        this.notificationId = notificationId;
        this.type           = type;
        this.message        = message;
        this.isRead         = isRead;
        this.createdAt      = createdAt;
        this.userId         = userId;
        this.referenceId    = referenceId;
    }

    // ── Getters ───────────────────────────────────────────────────────────────
    public int       getNotificationId() { return notificationId; }
    public String    getType()           { return type;           }
    public String    getMessage()        { return message;        }
    public boolean   isRead()            { return isRead;         }
    public Timestamp getCreatedAt()      { return createdAt;      }
    public int       getUserId()         { return userId;         }
    public int       getReferenceId()    { return referenceId;    }

    // ── Setters ───────────────────────────────────────────────────────────────
    public void setNotificationId(int notificationId) { this.notificationId = notificationId; }
    public void setType(String type)                   { this.type           = type;           }
    public void setMessage(String message)             { this.message        = message;        }
    public void setRead(boolean read)                  { this.isRead         = read;           }
    public void setCreatedAt(Timestamp createdAt)      { this.createdAt      = createdAt;      }
    public void setUserId(int userId)                  { this.userId         = userId;         }
    public void setReferenceId(int referenceId)        { this.referenceId    = referenceId;    }

    // ── CRUD ──────────────────────────────────────────────────────────────────

    /** Insert one notification row for a single user. */
    public static boolean ajouter(Notification n) {
        String sql = "INSERT INTO notification (type, message, is_read, created_at, userId, reference_id) "
                   + "VALUES (?, ?, FALSE, NOW(), ?, ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.type);
            ps.setString(2, n.message);
            ps.setInt(3,    n.userId);
            ps.setInt(4,    n.referenceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ajouter Notification error: " + e.getMessage());
            return false;
        }
    }

    /** Delete a single notification by its ID. */
    public static boolean supprimer(int notificationId) {
        String sql = "DELETE FROM notification WHERE notification_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer Notification error: " + e.getMessage());
            return false;
        }
    }

    /** Mark a single notification as read. */
    public static boolean marquerLu(int notificationId) {
        String sql = "UPDATE notification SET is_read = TRUE WHERE notification_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("marquerLu Notification error: " + e.getMessage());
            return false;
        }
    }

    /** Mark all notifications related to a specific fault/ticket as read.
     *  Call this when a fault report is resolved. */
    public static boolean marquerLuParReference(int referenceId) {
        String sql = "UPDATE notification SET is_read = TRUE WHERE reference_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, referenceId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("marquerLuParReference Notification error: " + e.getMessage());
            return false;
        }
    }

    /** Mark ALL notifications of one user as read (e.g. when they open the inbox). */
    public static boolean marquerTousLus(int userId) {
        String sql = "UPDATE notification SET is_read = TRUE WHERE userId = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("marquerTousLus Notification error: " + e.getMessage());
            return false;
        }
    }

    /** All notifications for one user, newest first. */
    public static List<Notification> chercher_par_user(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notification WHERE userId = ? ORDER BY created_at DESC";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_par_user Notification error: " + e.getMessage());
        }
        return list;
    }

    /** Unread notifications only – used for the badge counter in the navbar. */
    public static List<Notification> chercher_non_lus(int userId) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notification WHERE userId = ? AND is_read = FALSE "
                   + "ORDER BY created_at DESC";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_non_lus Notification error: " + e.getMessage());
        }
        return list;
    }

    /** Count of unread notifications – used for the red badge in the navbar. */
    public static int compterNonLus(int userId) {
        String sql = "SELECT COUNT(*) FROM notification WHERE userId = ? AND is_read = FALSE";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("compterNonLus Notification error: " + e.getMessage());
        }
        return 0;
    }

    // ── High-level helper methods (call these from your Servlets) ─────────────

    /**
     * F-20 – Called in your FaultReportServlet (doPost, after saving the report).
     * Creates one notification for every Technical Manager in the database.
     *
     * Usage:
     *   Notification.notifierManagers_NouveauRapport(savedFaultReport.getFaultId(),
     *       savedFaultReport.getDescription());
     */
    public static void notifierManagers_NouveauRapport(int faultId, String description) {
        List<Users> managers = Users.chercher_role("Technical_Manager"); // FIX: correct case
        String message = "Nouveau rapport de panne soumis : " + description;
        for (Users manager : managers) {
            Notification n = new Notification();
            n.setType("FAULT_REPORT");
            n.setMessage(message);
            n.setUserId(manager.getUserId());
            n.setReferenceId(faultId);
            ajouter(n);
        }
    }

    /**
     * F-21 – Called in your MaintenanceTicketServlet when a ticket is resolved.
     * Notifies the original reporter (doctor/nurse) that their fault was fixed.
     *
     * Usage:
     *   Notification.notifierReporter_TicketResolu(faultReport.getReporterId(),
     *       faultReport.getFaultId(), equipmentName);
     */
    public static void notifierReporter_TicketResolu(int reporterId, int faultId,
                                                      String equipmentName) {
        Notification n = new Notification();
        n.setType("TICKET_RESOLVED");
        n.setMessage("Votre rapport de panne pour « " + equipmentName
                   + " » a été résolu.");
        n.setUserId(reporterId);
        n.setReferenceId(faultId);
        ajouter(n);
    }

    /**
     * F-28 – Called by a scheduled check (e.g. a servlet called on login,
     * or a Timer task). Notifies all Technical Managers about tickets due
     * within the given number of days.
     *
     * Usage (call once per login of a Technical Manager, or on a timer):
     *   Notification.notifierManagers_MaintenancePrevue(7);
     */
    public static void notifierManagers_MaintenancePrevue(int daysAhead) {
        List<MaintenanceTicket> dueSoon = MaintenanceTicket.getDueWithinDays(daysAhead);
        if (dueSoon.isEmpty()) return;

        List<Users> managers = Users.chercher_role("technical_manager");
        for (MaintenanceTicket ticket : dueSoon) {
            String message = "Maintenance préventive due dans " + daysAhead
                           + " jours – ticket #" + ticket.getMaintenanceId()
                           + " : " + ticket.getDescription();
            for (Users manager : managers) {
                // Avoid duplicate notifications: only create if none exists today
                // for this ticket + user combination.
                if (!existeDejaujourdhui(manager.getUserId(), ticket.getMaintenanceId(),
                                         "MAINTENANCE_DUE")) {
                    Notification n = new Notification();
                    n.setType("MAINTENANCE_DUE");
                    n.setMessage(message);
                    n.setUserId(manager.getUserId());
                    n.setReferenceId(ticket.getMaintenanceId());
                    ajouter(n);
                }
            }
        }
    }

    /**
     * Prevents the same maintenance-due alert from being created more than
     * once on the same calendar day for the same user + reference pair.
     */
    private static boolean existeDejaujourdhui(int userId, int referenceId, String type) {
        String sql = "SELECT COUNT(*) FROM notification "
                   + "WHERE userId = ? AND reference_id = ? AND type = ? "
                   + "AND DATE(created_at) = CURDATE()";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1,    userId);
            ps.setInt(2,    referenceId);
            ps.setString(3, type);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            System.err.println("existeDejaujourdhui Notification error: " + e.getMessage());
        }
        return false;
    }

    // ── Mapping helper ────────────────────────────────────────────────────────
    private static Notification map(ResultSet rs) throws SQLException {
        return new Notification(
            rs.getInt("notification_id"),
            rs.getString("type"),
            rs.getString("message"),
            rs.getBoolean("is_read"),
            rs.getTimestamp("created_at"),
            rs.getInt("userId"),
            rs.getInt("reference_id")
        );
    }

    // ── toString ──────────────────────────────────────────────────────────────
    @Override
    public String toString() {
        return "Notification{" +
               "notificationId=" + notificationId +
               ", type=" + type +
               ", message=" + message +
               ", isRead=" + isRead +
               ", createdAt=" + createdAt +
               ", userId=" + userId +
               ", referenceId=" + referenceId + '}';
    }
}