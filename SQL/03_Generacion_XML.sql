-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 3: Generacion de XML con SQL/XML
-- Origen: EMPLOYEES, DEPARTMENTS y JOBS
-- Oracle Database 21c XE

SELECT XMLSERIALIZE(
    DOCUMENT
    XMLELEMENT("ReporteEmpleados",
        XMLAGG(
            XMLELEMENT("Empleado",
                XMLATTRIBUTES(
                    e.employee_id AS "IdEmpleado"
                ),
                XMLFOREST(
                    e.first_name AS "Nombre",
                    e.last_name AS "Apellido",
                    e.salary AS "Salario"
                ),
                XMLELEMENT("Departamento",
                    XMLFOREST(
                        d.department_id AS "IdDepartamento",
                        d.department_name AS "NombreDepartamento"
                    )
                ),
                XMLELEMENT("Cargo",
                    XMLFOREST(
                        j.job_id AS "IdCargo",
                        j.job_title AS "NombreCargo"
                    )
                )
            )
            ORDER BY e.employee_id
        )
    )
    AS CLOB INDENT SIZE = 2
) AS REPORTE_XML
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.department_id
INNER JOIN jobs j
    ON e.job_id = j.job_id
WHERE e.employee_id BETWEEN 100 AND 109;