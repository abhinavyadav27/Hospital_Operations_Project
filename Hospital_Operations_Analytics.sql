CREATE DATABASE IF NOT EXISTS hospital_operations;
USE hospital_operations;
SHOW DATABASES;
-- 3.1 PATIENTS TABLE
CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    patient_name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(20),
    city VARCHAR(50),
    patient_type VARCHAR(30),
    preferred_time_slot VARCHAR(30),
    registration_date DATE
);
-- 3.2 DOCTORS TABLE
CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    hire_date DATE,
    rating DECIMAL(3,2),
    employment_type VARCHAR(30),
    is_active VARCHAR(10)
);
-- 3.3 ROOMS TABLE
CREATE TABLE rooms (
    room_id VARCHAR(10) PRIMARY KEY,
    room_type VARCHAR(50),
    floor INT,
    equipment_type VARCHAR(50),
    capacity INT,
    last_maintenance_date DATE,
    is_available VARCHAR(10)
);
-- 3.4 APPOINTMENTS TABLE

CREATE TABLE appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    appointment_date DATE,
    doctor_id VARCHAR(10),
    service_type VARCHAR(50),
    priority VARCHAR(20),
    estimated_cost DECIMAL(10,2),
    booking_channel VARCHAR(30),

    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
);
-- 3.5 TREATMENTS TABLE
CREATE TABLE treatments (
    treatment_id VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR(10) NOT NULL,
    doctor_id VARCHAR(10),
    room_id VARCHAR(10),
    actual_treatment_date DATE,
    status VARCHAR(30),
    treatment_attempt INT,
    treatment_duration_min INT,
    waiting_time_min INT,
    treatment_cost DECIMAL(10,2),

    FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
);
-- SECTION 4 : VERIFY TABLES
SHOW TABLES;
DESCRIBE patients;
DESCRIBE doctors;
DESCRIBE rooms;
DESCRIBE appointments;
DESCRIBE treatments;
-- ============================================================
-- SPRINT 1 : BUSINESS UNDERSTANDING & DATA UNDERSTANDING
-- ============================================================
-- SECTION 6 : ER DIAGRAM INTERPRETATION
-- QUESTION 1 Identify patients who have booked multiple appointments.
SELECT
    patient_id,
    COUNT(*) AS appointment_count
FROM appointments
GROUP BY patient_id
HAVING COUNT(*) > 1;
-- QUESTION 2 — Multiple treatment attempts
SELECT
    appointment_id,
    MAX(treatment_attempt) AS treatment_attempts
FROM treatments
GROUP BY appointment_id
HAVING MAX(treatment_attempt) > 1;
-- QUESTION 3 — Patient type vs appointment activity
SELECT
    p.patient_type,
    COUNT(a.appointment_id) AS appointment_count
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_type
ORDER BY appointment_count DESC;
-- QUESTION 4 — Service type, duration and waiting time
 SELECT
    a.service_type,
    AVG(t.treatment_duration_min) AS avg_treatment_duration,
    AVG(t.waiting_time_min) AS avg_waiting_time
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY a.service_type
ORDER BY avg_waiting_time DESC;
-- QUESTION 5 — Doctors and treatment ratings
 SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialty,
    d.rating,
    COUNT(t.treatment_id) AS treatments_handled
FROM doctors d
JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY
    d.doctor_id,
    d.doctor_name,
    d.specialty,
    d.rating
ORDER BY treatments_handled DESC;
 -- QUESTION 6 — Room/equipment vs service type
  SELECT
    a.service_type,
    r.room_type,
    r.equipment_type,
    COUNT(t.treatment_id) AS treatment_count
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
JOIN rooms r
    ON t.room_id = r.room_id
GROUP BY
    a.service_type,
    r.room_type,
    r.equipment_type
ORDER BY treatment_count DESC;
-- QUESTION 7 — Treatment performance by city
  SELECT
    p.city,
    COUNT(t.treatment_id) AS total_treatments,
    AVG(t.treatment_duration_min) AS avg_treatment_duration,
    AVG(t.waiting_time_min) AS avg_waiting_time
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY p.city
ORDER BY total_treatments DESC;
-- QUESTION 8 — Priority vs waiting time/outcomes
  SELECT
    a.priority,
    t.status,
    COUNT(*) AS treatment_count,
    AVG(t.waiting_time_min) AS avg_waiting_time
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY
    a.priority,
    t.status
ORDER BY
    a.priority,
    avg_waiting_time DESC;
-- QUESTION 9 — Treatment outcomes by service type
 SELECT
    a.service_type,
    t.status,
    COUNT(*) AS treatment_count
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY
    a.service_type,
    t.status
ORDER BY
    a.service_type,
    treatment_count DESC;
-- QUESTION 10 — Patient → Appointment → Treatment
  SELECT
    p.patient_id,
    p.patient_name,
    a.appointment_id,
    a.service_type,
    a.priority,
    t.treatment_id,
    t.status,
    t.treatment_attempt,
    t.treatment_duration_min,
    t.waiting_time_min
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
ORDER BY p.patient_id;
-- ============================================================
-- END OF SPRINT 1
-- ============================================================
-- ============================================================
-- SPRINT 2 : DATABASE SETUP
-- ============================================================
-- SPRINT 2 - Show tables
SHOW TABLES;

-- SPRINT 2 - Patient count verification
SELECT COUNT(*) AS patients FROM patients;

-- SPRINT 2 - Appointment count verification
SELECT COUNT(*) AS appointments FROM appointments;

-- SPRINT 2 - Treatment count verification
SELECT COUNT(*) AS treatments FROM treatments;

-- SPRINT 2 - Doctor/room verification
SELECT 'doctors' AS table_name,COUNT(*) AS rows_count FROM doctors UNION ALL SELECT 'rooms',COUNT(*) FROM rooms;

-- ============================================================
-- END OF SPRINT 2
-- ============================================================
-- ============================================================
-- SPRINT 3 : BASIC ANALYSIS / DATA EXPLORATION
-- ============================================================
-- SPRINT 3 - Q1
SELECT COUNT(*) AS total_patients FROM patients;

-- SPRINT 3 - Q2
SELECT COUNT(*) AS total_appointments FROM appointments;

-- SPRINT 3 - Q3
SELECT COUNT(*) AS total_treatment_records FROM treatments;

-- SPRINT 3 - Q4
SELECT DISTINCT service_type FROM appointments ORDER BY service_type;

-- SPRINT 3 - Q5
SELECT COUNT(*) AS active_doctors FROM doctors WHERE is_active='Yes';

-- SPRINT 3 - Q6
SELECT DISTINCT room_type FROM rooms ORDER BY room_type;

-- SPRINT 3 - Q7
SELECT ROUND(SUM(estimated_cost),2) AS total_estimated_appointment_value FROM appointments;

-- SPRINT 3 - Q8
SELECT ROUND(AVG(treatment_duration_min),2) AS average_treatment_duration_minutes FROM treatments;

-- ============================================================
-- SPRINT 3 : FINAL SUMMARY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM patients) AS total_patients,
    (SELECT COUNT(*) FROM appointments) AS total_appointments,
    (SELECT COUNT(*) FROM treatments) AS total_treatments,
    (SELECT COUNT(*) FROM doctors WHERE is_active = 'Yes') AS active_doctors,
    (SELECT ROUND(SUM(estimated_cost), 2) FROM appointments)
        AS total_estimated_appointment_value,
    (SELECT ROUND(AVG(treatment_duration_min), 2) FROM treatments)
        AS average_treatment_duration_minutes;
-- ============================================================
-- SPRINT 4 : OBJECTIVE-BASED ANALYSIS
-- ============================================================

-- ================= 4.1 PATIENT & APPOINTMENT DEMAND =================
-- Q1. Which cities have the highest appointment demand?
SELECT p.city,COUNT(*) appointments FROM patients p JOIN appointments a ON p.patient_id=a.patient_id GROUP BY p.city ORDER BY appointments DESC;
-- Q2. Which service and priority combinations are most demanded?
SELECT service_type,priority,COUNT(*) appointments FROM appointments GROUP BY service_type,priority ORDER BY appointments DESC;
-- Q3. How does appointment demand change over time?
SELECT YEAR(appointment_date) year,MONTH(appointment_date) month,COUNT(*) appointments FROM appointments GROUP BY YEAR(appointment_date),MONTH(appointment_date) ORDER BY year,month;
-- Q4. Which patient type has the highest estimated appointment value?
SELECT p.patient_type,ROUND(SUM(a.estimated_cost),2) total_value FROM patients p JOIN appointments a ON p.patient_id=a.patient_id GROUP BY p.patient_type ORDER BY total_value DESC;
-- Q5. Which booking channel contributes most to demand?
SELECT booking_channel,COUNT(*) appointments,ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM appointments),2) percentage FROM appointments GROUP BY booking_channel ORDER BY appointments DESC;

-- ================= 4.2 PATIENT APPOINTMENT BEHAVIOUR =================
-- Q1. Which patients have the most appointments?
SELECT p.patient_id,p.patient_name,COUNT(*) appointments FROM patients p JOIN appointments a ON p.patient_id=a.patient_id GROUP BY p.patient_id,p.patient_name ORDER BY appointments DESC;
-- Q2. Which patients have the highest cumulative estimated value?
SELECT p.patient_id,p.patient_name,ROUND(SUM(a.estimated_cost),2) total_value FROM patients p JOIN appointments a ON p.patient_id=a.patient_id GROUP BY p.patient_id,p.patient_name ORDER BY total_value DESC;
-- Q3. Which cities have the most active patients?
SELECT p.city,COUNT(DISTINCT p.patient_id) patients,COUNT(a.appointment_id) appointments FROM patients p LEFT JOIN appointments a ON p.patient_id=a.patient_id GROUP BY p.city ORDER BY appointments DESC;
-- Q4. How do General, Corporate and Insurance patients differ in activity?
SELECT p.patient_type,COUNT(DISTINCT p.patient_id) patients,COUNT(a.appointment_id) appointments FROM patients p LEFT JOIN appointments a ON p.patient_id=a.patient_id GROUP BY p.patient_type;
-- Q5. How do patient booking patterns change over time?
SELECT YEAR(a.appointment_date) year,MONTH(a.appointment_date) month,p.patient_type,COUNT(*) appointments FROM appointments a JOIN patients p ON a.patient_id=p.patient_id GROUP BY YEAR(a.appointment_date),MONTH(a.appointment_date),p.patient_type ORDER BY year,month;

-- ================= 4.3 TREATMENT PERFORMANCE =================
-- Q1. How do treatment outcomes differ across cities?
SELECT p.city,t.status,COUNT(*) treatments FROM patients p JOIN appointments a ON p.patient_id=a.patient_id JOIN treatments t ON a.appointment_id=t.appointment_id GROUP BY p.city,t.status ORDER BY treatments DESC;
-- Q2. What are the average treatment duration and waiting time?
SELECT ROUND(AVG(treatment_duration_min),2) avg_duration,ROUND(AVG(waiting_time_min),2) avg_waiting FROM treatments;
-- Q3. What is the distribution of treatment outcomes?
SELECT status,COUNT(*) treatments,ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM treatments),2) percentage FROM treatments GROUP BY status ORDER BY treatments DESC;
-- Q4. Which service types show more activity or poorer outcomes?
SELECT a.service_type,COUNT(*) treatments,SUM(t.status IN ('Cancelled','No-Show','Rescheduled')) problem_cases FROM appointments a JOIN treatments t ON a.appointment_id=t.appointment_id GROUP BY a.service_type ORDER BY treatments DESC;
-- Q5. How does treatment performance change over time?
SELECT YEAR(actual_treatment_date) year,MONTH(actual_treatment_date) month,COUNT(*) treatments,ROUND(AVG(waiting_time_min),2) avg_waiting FROM treatments GROUP BY YEAR(actual_treatment_date),MONTH(actual_treatment_date) ORDER BY year,month;

-- ================= 4.4 DOCTOR & ROOM PERFORMANCE =================
-- Q1. Which doctors handle the most treatments?
SELECT d.doctor_name,COUNT(*) treatments FROM doctors d JOIN treatments t ON d.doctor_id=t.doctor_id GROUP BY d.doctor_name ORDER BY treatments DESC;
-- Q2. How do doctor outcomes differ?
SELECT d.doctor_name,t.status,COUNT(*) treatments FROM doctors d JOIN treatments t ON d.doctor_id=t.doctor_id GROUP BY d.doctor_name,t.status ORDER BY d.doctor_name;
-- Q3. Which doctors have longer treatment durations?
SELECT d.doctor_name,ROUND(AVG(t.treatment_duration_min),2) avg_duration FROM doctors d JOIN treatments t ON d.doctor_id=t.doctor_id GROUP BY d.doctor_name ORDER BY avg_duration DESC;
-- Q4. Which room and equipment types are used most?
SELECT r.room_type,r.equipment_type,COUNT(*) treatments FROM rooms r JOIN treatments t ON r.room_id=t.room_id GROUP BY r.room_type,r.equipment_type ORDER BY treatments DESC;
-- Q5. Which rooms show higher treatment activity and waiting time?
SELECT r.room_id,r.room_type,COUNT(*) treatments,ROUND(AVG(t.waiting_time_min),2) avg_waiting FROM rooms r JOIN treatments t ON r.room_id=t.room_id GROUP BY r.room_id,r.room_type ORDER BY treatments DESC;

-- ================= 4.5 TREATMENT & APPOINTMENT PROBLEMS =================
-- Q1. Which appointments required multiple treatment attempts?
SELECT appointment_id,MAX(treatment_attempt) max_attempt FROM treatments GROUP BY appointment_id HAVING MAX(treatment_attempt)>1 ORDER BY max_attempt DESC;
-- Q2. What are the most common problem statuses?
SELECT status,COUNT(*) cases FROM treatments WHERE status IN ('Cancelled','No-Show','Rescheduled') GROUP BY status ORDER BY cases DESC;
-- Q3. Do multiple attempts have longer waiting times?
SELECT CASE WHEN treatment_attempt>1 THEN 'Multiple' ELSE 'Single' END attempt_group,COUNT(*) treatments,ROUND(AVG(waiting_time_min),2) avg_waiting FROM treatments GROUP BY attempt_group;
-- Q4. Which cities/service types have more problems?
SELECT p.city,a.service_type,COUNT(*) problem_cases FROM patients p JOIN appointments a ON p.patient_id=a.patient_id JOIN treatments t ON a.appointment_id=t.appointment_id WHERE t.status IN ('Cancelled','No-Show','Rescheduled') GROUP BY p.city,a.service_type ORDER BY problem_cases DESC;
-- Q5. Is priority associated with waiting time or treatment outcomes?
SELECT a.priority,t.status,COUNT(*) treatments,ROUND(AVG(t.waiting_time_min),2) avg_waiting FROM appointments a JOIN treatments t ON a.appointment_id=t.appointment_id GROUP BY a.priority,t.status ORDER BY a.priority;

-- ================= SQL DELIVERABLES =================
-- Verify imported data
SELECT 'patients' table_name,COUNT(*) rows_count FROM patients UNION ALL SELECT 'appointments',COUNT(*) FROM appointments UNION ALL SELECT 'treatments',COUNT(*) FROM treatments UNION ALL SELECT 'doctors',COUNT(*) FROM doctors UNION ALL SELECT 'rooms',COUNT(*) FROM rooms;
-- Overall treatment outcome summary
SELECT status,COUNT(*) treatments FROM treatments GROUP BY status ORDER BY treatments DESC;
-- Overall operational timing
SELECT ROUND(AVG(treatment_duration_min),2) avg_duration,ROUND(AVG(waiting_time_min),2) avg_waiting FROM treatments;

-- ================= FINAL OUTCOME =================
-- Overall project totals
SELECT (SELECT COUNT(*) FROM patients) patients,(SELECT COUNT(*) FROM appointments) appointments,(SELECT COUNT(*) FROM treatments) treatments,(SELECT COUNT(*) FROM doctors) doctors,(SELECT COUNT(*) FROM rooms) rooms;
-- Highest-demand service
SELECT service_type,COUNT(*) appointments FROM appointments GROUP BY service_type ORDER BY appointments DESC LIMIT 1;
-- Highest-demand city
SELECT p.city,COUNT(*) appointments FROM patients p JOIN appointments a ON p.patient_id=a.patient_id GROUP BY p.city ORDER BY appointments DESC LIMIT 1;
-- Most active doctor
SELECT d.doctor_name,COUNT(*) treatments FROM doctors d JOIN treatments t ON d.doctor_id=t.doctor_id GROUP BY d.doctor_name ORDER BY treatments DESC LIMIT 1;
-- Priority with highest waiting time
SELECT a.priority,ROUND(AVG(t.waiting_time_min),2) avg_waiting FROM appointments a JOIN treatments t ON a.appointment_id=t.appointment_id GROUP BY a.priority ORDER BY avg_waiting DESC LIMIT 1;
