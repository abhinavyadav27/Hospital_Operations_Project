# 🏥 Hospital Operations SQL Analytics Project

A SQL-based project that designs a connected **hospital operations database** and builds analytical queries on patient demand, treatment performance, doctor workload, and room/equipment utilization.

---

## 📌 Table of Contents
- [Project Overview](#-project-overview)
- [Business Scenario](#-business-scenario)
- [Business Objectives](#-business-objectives)
- [Database Design](#-database-design)
- [ER Diagram](#-er-diagram)
- [Project Sprints](#-project-sprints)
- [Sample Queries](#-sample-queries)
- [Business Recommendations](#-business-recommendations)
- [Data Availability Note](#-data-availability-note)
- [How to Run](#-how-to-run)
- [Project Structure](#-project-structure)
- [Author](#-author)

---

## 📖 Project Overview

Hospitals generate large amounts of operational data across patient registration, appointment booking, doctor assignment, and treatment delivery. This project models that workflow in a relational MySQL database and uses SQL to answer management questions such as:

- Where is appointment demand concentrated?
- Which services and priorities create longer waits or more non-completion?
- How do doctors, rooms, and equipment contribute to throughput?
- Where do repeated treatment attempts point to operational friction?

## 🔄 Business Scenario

```
Patient Registration → Appointment Booking → Doctor Assignment → Treatment Execution → Outcome & Status
```

| Stage | What is captured |
|---|---|
| Patient | Profile, city, patient type (General / Corporate / Insurance) |
| Appointment | Service type, priority, booking channel, estimated cost |
| Doctor | Specialty, rating, employment type, active status |
| Treatment | Room, duration, waiting time, attempts, cost |
| Outcome | Completed / In Progress / Rescheduled / Cancelled / No-Show |

## 🎯 Business Objectives

1. **Understand patient demand** – patients with multiple appointments, activity by patient type
2. **Measure service demand** – service types, priorities, booking channels
3. **Monitor treatment performance** – duration, waiting time, attempts, status
4. **Evaluate doctors** – treatment volume vs. specialty and rating
5. **Understand room utilization** – activity by room type and equipment
6. **Find exception patterns** – repeated attempts and non-completion by city/service

## 🗄 Database Design

**Database:** `hospital_operations` | **Tables:** 5

| Table | Primary Key | Role |
|---|---|---|
| `patients` | `patient_id` | Patient profile and segmentation |
| `doctors` | `doctor_id` | Provider and quality context |
| `rooms` | `room_id` | Physical resource inventory |
| `appointments` | `appointment_id` | Demand and booking behavior |
| `treatments` | `treatment_id` | Service delivery and outcome |

**Relationships (Foreign Keys)**
- `appointments.patient_id` → `patients.patient_id`
- `appointments.doctor_id` → `doctors.doctor_id`
- `treatments.appointment_id` → `appointments.appointment_id`
- `treatments.doctor_id` → `doctors.doctor_id`
- `treatments.room_id` → `rooms.room_id`

## 🧩 ER Diagram

The diagram shows the patient → appointment → treatment traceability, with doctors and rooms linked to the delivery of care.

<img width="670" height="781" alt="SQL ER diagram" src="https://github.com/user-attachments/assets/e61c7342-a445-4dfd-a7e3-106cfed34197" />


## 🏃 Project Sprints

All queries are in [`Hospital_Operations_Analytics.sql`](Hospital_Operations_Analytics.sql).

| Sprint | Focus | What it covers |
|---|---|---|
| **Sprint 1** | Business & data understanding | Schema creation, ER interpretation, 10 relationship-based questions |
| **Sprint 2** | Database setup | Table verification and row-count checks |
| **Sprint 3** | Basic analysis | Totals, distinct services/rooms, active doctors, total estimated value, average treatment duration |
| **Sprint 4** | Objective-based analysis | 5 focus areas with 5 questions each (see below) |

**Sprint 4 focus areas**
- **4.1 Patient & appointment demand** – cities, service/priority combinations, monthly trends, patient-type value, booking channels
- **4.2 Patient appointment behaviour** – most active patients, cumulative value, city activity, patient-type differences
- **4.3 Treatment performance** – outcomes by city, duration and waiting time, status distribution, service problem cases, monthly trends
- **4.4 Doctor & room performance** – treatments per doctor, outcomes, durations, room/equipment usage, waiting time per room
- **4.5 Treatment & appointment problems** – multiple attempts, problem statuses (Cancelled / No-Show / Rescheduled), priority vs. waiting time

## 💻 Sample Queries

**Patients with multiple appointments**
```sql
SELECT patient_id, COUNT(*) AS appointment_count
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 1;
```

**Average duration and waiting time by service type**
```sql
SELECT a.service_type,
       AVG(t.treatment_duration_min) AS avg_treatment_duration,
       AVG(t.waiting_time_min)       AS avg_waiting_time
FROM appointments a
JOIN treatments t ON a.appointment_id = t.appointment_id
GROUP BY a.service_type
ORDER BY avg_waiting_time DESC;
```

**Treatment outcome distribution**
```sql
SELECT status,
       COUNT(*) AS treatments,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM treatments), 2) AS percentage
FROM treatments
GROUP BY status
ORDER BY treatments DESC;
```

## 💡 Business Recommendations

1. **Prioritize wait-time monitoring** by service, priority, city, and treatment attempts.
2. **Review repeat-attempt cases** with a dedicated workflow.
3. **Monitor non-completion** (Cancelled, No-Show, Rescheduled) to spot access issues.
4. **Balance workforce and resources** by comparing doctor workload with room/equipment utilization.
5. **Strengthen data quality** with NOT NULL / CHECK constraints, valid ranges, FK indexes, and controlled Yes/No values.
6. **Load real operational data** and convert query outputs into dashboards/KPIs.

## ⚠️ Data Availability Note

This repository contains the **database schema and analytical queries only**. It does not include `INSERT` statements or a dataset, so no numeric results are reported here. Numeric findings can be confirmed once data is loaded into the tables and the queries are run.

## ▶️ How to Run

**Requirements:** MySQL 8.x and MySQL Workbench (or any MySQL client)

1. Clone the repository
   ```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
   cd <your-repo-name>
   ```
2. Open `Hospital_Operations_Analytics.sql` in MySQL Workbench.
3. Run the first section to create the `hospital_operations` database and its 5 tables.
4. Import your data into the tables (Table Data Import Wizard or `INSERT` / `LOAD DATA`).
5. Run the Sprint 1–4 queries section by section and review the outputs.

## 📁 Project Structure

```
├── Hospital_Operations_Analytics.sql    # Schema + all sprint queries
├── Hospital_Operations SQL ppt.pptx     # Project presentation
├── images/
│   └── er_diagram.png                   # ER diagram
└── README.md
```

## 🛠 Tech Stack

- **Database:** MySQL
- **Tool:** MySQL Workbench
- **Skills:** Database design, primary/foreign keys, joins, aggregations, GROUP BY / HAVING, subqueries, business analysis

## 👤 Author

**Abhinav Yadav**
Aspiring Data Analyst | Hyderabad, India


---

⭐ If you found this project useful, consider giving it a star!
