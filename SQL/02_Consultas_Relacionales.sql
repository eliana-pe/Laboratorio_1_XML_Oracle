-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 2: Consulta relacional de tres tablas
-- Objetivo: Recuperar empleados, departamentos y cargos

SELECT
    e.employee_id AS ID_EMPLEADO,
    e.first_name AS NOMBRE,
    e.last_name AS APELLIDO,
    e.salary AS SALARIO,
    d.department_id AS ID_DEPARTAMENTO,
    d.department_name AS DEPARTAMENTO,
    j.job_id AS ID_CARGO,
    j.job_title AS CARGO
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.department_id
INNER JOIN jobs j
    ON e.job_id = j.job_id
ORDER BY e.employee_id
FETCH FIRST 10 ROWS ONLY;