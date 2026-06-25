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
public class Equipment {

   public static int countAll() {
    String sql = "SELECT COUNT(*) FROM equipment";
    try (Connection con = Shared.connecter();
         Statement st = con.createStatement();
         ResultSet rs = st.executeQuery(sql)) {
        if (rs.next()) return rs.getInt(1);
    } catch (SQLException e) {
        System.err.println("countAll Equipment error: " + e.getMessage());
    }
    return 0;
}

public static int countByStatus(String status) {
    String sql = "SELECT COUNT(*) FROM equipment WHERE status = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, status);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    } catch (SQLException e) {
        System.err.println("countByStatus Equipment error: " + e.getMessage());
    }
    return 0;
}

public static List<Equipment> getByUser(int userId) {
    List<Equipment> list = new ArrayList<>();
    String sql = "SELECT e.* FROM equipment e "
               + "JOIN department_user du ON e.department_id = du.department_id "
               + "WHERE du.userId = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) list.add(map(rs));
    } catch (SQLException e) {
        System.err.println("getByUser Equipment error: " + e.getMessage());
    }
    return list;
}
    //Declaration
    private int equipmentId;
    private String assetId;      
    private String name;      
    private String brand;
    private String model;
    private String serialNumber;
    private boolean active;
    private String status;
    private Date purchaseDate;
    private int departmentId;
     
    //constructor

    public Equipment() {
        
    }

    public Equipment(int equipmentId, String assetId, String name, String brand, String model, String serialNumber, boolean active, String status,Date purchaseDate, int departmentId) {
        this.equipmentId = equipmentId;
        this.assetId = assetId;
        this.name = name;
        this.brand = brand;
        this.model = model;
        this.serialNumber = serialNumber;
        this.active = active;
        this.status = status;
        this.purchaseDate = purchaseDate;
        this.departmentId = departmentId;
    }
    //Getters
    public int getEquipmentId() {
        return equipmentId; }
    public String getAssetId() {
        return assetId;}
    public String getName() {
        return name;}
    public String getBrand() {
        return brand;}
    public String getModel() {
        return model; }
    public String getSerialNumber() {
        return serialNumber;}
    public boolean isActive() {
        return active;}
    public String getStatus() {
        return status;}
    public Date getPurchaseDate() {
        return purchaseDate;}
    public int getDepartmentId() {
        return departmentId; }
    
    //Setters
    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;  }
    public void setAssetId(String assetId) {
        this.assetId = assetId;}
    public void setName(String name) {
        this.name = name;}
    public void setBrand(String brand) {
        this.brand = brand;}
    public void setModel(String model) {
        this.model = model; }
    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;}
    public void setActive(boolean active) {
        this.active = active;}
    public void setStatus(String status) {
        this.status = status;}
    public void setPurchaseDate(Date purchaseDate) {
        this.purchaseDate = purchaseDate;}
     public void setPurchaseDate(String dateStr) {
        if (dateStr != null && !dateStr.isEmpty()) {
            this.purchaseDate = Date.valueOf(dateStr);
        } else {
            this.purchaseDate = null;
        }
    }
    
    
    
    
    public void setDepartmentId(int departmentId) {
        this.departmentId = departmentId;}
    
   
    
     // ── CRUD ─────────────────────────────────────────────────────────────────
    public static boolean ajouter(Equipment e) {
        String sql = "INSERT INTO equipment (asset_id, name, brand, model, serial_number, "
                   + "active, status, purchase_date, department_id) VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  e.assetId);
            ps.setString(2,  e.name);
            ps.setString(3,  e.brand);
            ps.setString(4,  e.model);
            ps.setString(5,  e.serialNumber);
            ps.setBoolean(6, e.active);
            ps.setString(7,  e.status);
            ps.setDate(8,    e.purchaseDate);
            ps.setInt(9,     e.departmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.err.println("ajouter Equipment error: " + ex.getMessage());
            return false;
        }
    }
    
    public static boolean supprimer(int equipmentId) {
        String sql = "DELETE FROM equipment WHERE equipment_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("supprimer Equipment error: " + e.getMessage());
            return false;
        }
    }
    
     public static boolean save(Equipment e) {
        String sql = "UPDATE equipment SET asset_id=?, name=?, brand=?, model=?, serial_number=?, "
                   + "active=?, status=?, purchase_date=?, department_id=? WHERE equipment_id=?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  e.assetId);
            ps.setString(2,  e.name);
            ps.setString(3,  e.brand);
            ps.setString(4,  e.model);
            ps.setString(5,  e.serialNumber);
            ps.setBoolean(6, e.active);
            ps.setString(7,  e.status);
            ps.setDate(8,    e.purchaseDate);
            ps.setInt(9,     e.departmentId);
            ps.setInt(10,    e.equipmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            System.err.println("save Equipment error: " + ex.getMessage());
            return false;
        }
    }
     public static List<Equipment> liste() {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT * FROM equipment";
        try (Connection con = Shared.connecter();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("liste Equipment error: " + e.getMessage());
        }
        return list;
    }
     public static Equipment chercher_id(int equipmentId) {
        String sql = "SELECT * FROM equipment WHERE equipment_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, equipmentId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) {
            System.err.println("chercher_id Equipment error: " + e.getMessage());
        }
        return null;
    }
     public static List<Equipment> chercher_nom(String name) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT * FROM equipment WHERE name LIKE ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + name + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_nom Equipment error: " + e.getMessage());
        }
        return list;
    }
      public static List<Equipment> chercher_status(String status) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT * FROM equipment WHERE status = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_status Equipment error: " + e.getMessage());
        }
        return list;
    }
           public static List<Equipment> chercher_departement(int departmentId) {
        List<Equipment> list = new ArrayList<>();
        String sql = "SELECT * FROM equipment WHERE department_id = ?";
        try (Connection con = Shared.connecter();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("chercher_departement Equipment error: " + e.getMessage());
        }
        return list;
    }
           public static List<Equipment> getByDepartment(int departmentId) {
    return chercher_departement(departmentId); // reuse existing method
}

public static List<Equipment> getByStatus(String status) {
    return chercher_status(status); // reuse existing method
}

public static boolean assetIdExists(String assetId) {
    String sql = "SELECT COUNT(*) FROM equipment WHERE asset_id = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, assetId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1) > 0;
    } catch (SQLException e) {
        System.err.println("assetIdExists Equipment error: " + e.getMessage());
    }
    return false;
}

public static boolean updateStatus(int equipmentId, String status) {
    String sql = "UPDATE equipment SET status = ? WHERE equipment_id = ?";
    try (Connection con = Shared.connecter();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, status);
        ps.setInt(2,    equipmentId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        System.err.println("updateStatus Equipment error: " + e.getMessage());
        return false;
    }
}
           
                
      private static Equipment map(ResultSet rs) throws SQLException {
        return new Equipment(
            rs.getInt("equipment_id"),
            rs.getString("asset_id"),
            rs.getString("name"),
            rs.getString("brand"),
            rs.getString("model"),
            rs.getString("serial_number"),
            rs.getBoolean("active"),
            rs.getString("status"),
            rs.getDate("purchase_date"),
            rs.getInt("department_id")
        );
    }
     
    //toString

    @Override
    public String toString() {
        return "Equipment{" + "equipmentId=" + equipmentId + ", assetId=" + assetId + ", name=" + name + ", brand=" + brand + ", model=" + model + ", serialNumber=" + serialNumber + ", active=" + active + ", status=" + status + ", purchaseDate=" + purchaseDate + ", departmentId=" + departmentId + '}';
    }
    
   
    
    
    
    
    
    
    
    
    
    
}
