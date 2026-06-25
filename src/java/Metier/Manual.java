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
public class Manual {
     //declaration
     private int manualId;
     private String title;
     private String typeDoc;
     private Timestamp dateUpload;
     private String filePath;
     private int equipmentId;
     private int uploaderId;
    
    //constroctur

    public Manual() {
    }

    public Manual(int manualId, String title, String typeDoc, Timestamp dateUpload, String filePath, int equipmentId, int uploaderId) {
        this.manualId = manualId;
        this.title = title;
        this.typeDoc = typeDoc;
        this.dateUpload = dateUpload;
        this.filePath = filePath;
        this.equipmentId = equipmentId;
        this.uploaderId = uploaderId;
    }
    //Getters

    public int getManualId() {
        return manualId;
    }

    public String getTitle() {
        return title;
    }

    public String getTypeDoc() {
        return typeDoc;
    }

    public Timestamp getDateUpload() {
        return dateUpload;
    }

    public String getFilePath() {
        return filePath;
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public int getUploaderId() {
        return uploaderId;
    }
 
    //Setters
    
    public void setManualId(int manualId) {
        this.manualId = manualId;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setTypeDoc(String typeDoc) {
        this.typeDoc = typeDoc;
    }

    public void setDateUpload(Timestamp dateUpload) {
        this.dateUpload = dateUpload;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public void setUploaderId(int uploaderId) {
        this.uploaderId = uploaderId;
    }
      // ── CRUD ─────────────────────────────────────────────────────────────────
    public static boolean ajouter(Manual m) {
        String sql = "INSERT INTO manual (title, type_doc, date_upload, file_path, equipment_id, uploader_id) "
                   + "VALUES (?, ?, NOW(), ?, ?, ?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, m.title);
            ps.setString(2, m.typeDoc);
            ps.setString(3, m.filePath);
            ps.setInt(4,    m.equipmentId);
            ps.setInt(5,    m.uploaderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ajouter Manual error: " + e.getMessage());
            return false;
        }
    }
    public static boolean supprimer(int manualId) {
        String sql = "DELETE FROM manual WHERE manual_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, manualId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer Manual error: " + e.getMessage());
            return false;
        }
    }
     public static boolean save(Manual m) {
        String sql = "UPDATE manual SET title=?, type_doc=?, file_path=?, equipment_id=?, uploader_id=? "
                   + "WHERE manual_id=?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, m.title);
            ps.setString(2, m.typeDoc);
            ps.setString(3, m.filePath);
            ps.setInt(4,    m.equipmentId);
            ps.setInt(5,    m.uploaderId);
            ps.setInt(6,    m.manualId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("save Manual error: " + e.getMessage());
            return false;
        }
    }

    public static List<Manual> liste() {
        List<Manual> list = new ArrayList<>();
        String sql = "SELECT * FROM manual ORDER BY date_upload DESC";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste Manual error: " + e.getMessage());
        }
        return list;
    }
      public static Manual chercher_id(int manualId) {
        String sql = "SELECT * FROM manual WHERE manual_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, manualId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercher_id Manual error: " + e.getMessage());
        }
        return null;
    }

    public static List<Manual> chercher_nom(String title) {
        List<Manual> list = new ArrayList<>();
        String sql = "SELECT * FROM manual WHERE title LIKE ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + title + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_nom Manual error: " + e.getMessage());
        }
        return list;
    }
    public static List<Manual> chercher_equipement(int equipmentId) {
        List<Manual> list = new ArrayList<>();
        String sql = "SELECT * FROM manual WHERE equipment_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_equipement Manual error: " + e.getMessage());
        }
        return list;
    }
public static List<Manual> getByEquipment(int equipmentId) {
    return chercher_equipement(equipmentId); // reuse existing method
}
    private static Manual map(ResultSet rs) throws SQLException {
        return new Manual(
            rs.getInt("manual_id"),
            rs.getString("title"),
            rs.getString("type_doc"),
            rs.getTimestamp("date_upload"),
            rs.getString("file_path"),
            rs.getInt("equipment_id"),
            rs.getInt("uploader_id")
        );
    }
    
    //toString 

    @Override
    public String toString() {
        return "Manual{" + "manualId=" + manualId + ", title=" + title + ", typeDoc=" + typeDoc + ", dateUpload=" + dateUpload + ", filePath=" + filePath + ", equipmentId=" + equipmentId + ", uploaderId=" + uploaderId + '}';
    }
    
  
    
    
    
    
}
