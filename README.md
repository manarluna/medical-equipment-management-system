# 🏥 Medical Equipment and maintenance Management System

A web-based application for managing medical equipment, maintenance scheduling, fault reporting, and user roles in a hospital environment.

> ⚠️ This project is currently under active development.
---
## 📋 Description

The Medical Equipment Management System is a full-stack Java EE web application designed to help hospitals and medical facilities track and manage their equipment inventory, maintenance schedules, and fault reports. It supports multiple user roles with different levels of access and functionality.
---
## 🚀 Features
- **Admin Panel** — Manage users, departments, and audit logs
- **Manager Dashboard** — Track equipment, maintenance, manuals, and fault tickets
- **Doctor & Nurse Portals** — View equipment, submit fault reports, and access manuals
- **Role-based Access Control** — Different views and permissions per user role
- **Fault Reporting System** — Staff can report equipment faults directly
- **Maintenance Scheduling** — Track and manage equipment maintenance records
- **Manual Upload & Access** — Upload and view equipment manuals
---
## 🛠️ Technologies Used

| Layer | Technology |
|-------|------------|
| Language | Java |
| Framework | Jakarta EE |
| Frontend | JSP, HTML, CSS |
| Server | Payara Server |
| Database | MySQL |
| IDE | NetBeans |
---
## 🗂️ Project Structure

```
Me2ms1/
├── web/
│   ├── admin/          # Admin pages (users, departments, audit log)
│   ├── manager/        # Manager pages (equipment, maintenance, manuals)
│   ├── doctor/         # Doctor pages (equipment view, fault report)
│   ├── nurse/          # Nurse pages (dashboard, fault report)
│   ├── index.jsp       # Landing page
│   └── login.jsp       # Login page
├── src/                # Java source files (Servlets, Models, DAOs)
└── web/WEB-INF/        # Configuration files
```
---

## ⚙️ How to Run
### Prerequisites
- [NetBeans IDE](https://netbeans.apache.org/)
- [Payara Server](https://www.payara.fish/)
- [MySQL](https://www.mysql.com/)
- JDK 11 or higher

### Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/manarluna/medical-equipment-management-system.git
   ```
2. **Open in NetBeans**
   - File → Open Project → select the cloned folder

3. **Set up the database**
   - Create a MySQL database
   - Import the provided SQL schema

4. **Configure the server**
   - Add Payara Server in NetBeans
   - Link the project to Payara

5. **Run the project**
   - Right-click the project → Run

---
## 👤 Author
**Manarluna**  
GitHub: [@manarluna](https://github.com/manarluna)
---

## 📌 Status
🔧 Currently in development — features are being actively added and improved.
