-- ============================================================
-- HR XML STORAGE AND VALIDATION
-- BASES DE DATOS AVANZADAS - UNIR
-- Oracle Database 21c XE
-- ============================================================
-- DESCRIPCION:
-- Integracion de datos relacionales del esquema HR.
-- Generacion y almacenamiento de documentos XML.
-- Registro de esquemas XSD y validacion de documentos.
-- Pruebas de insercion valida e invalida.
-- ============================================================


-- ============================================================
-- 1. VERIFICACION DEL ENTORNO ORACLE HR
-- ============================================================
-- Identificar usuario, contenedor y registros disponibles
-- en las tablas EMPLOYEES, DEPARTMENTS y JOBS.

SELECT
    USER AS USUARIO,
    SYS_CONTEXT('USERENV', 'CON_NAME') AS CONTENEDOR,
    (SELECT COUNT(*) FROM EMPLOYEES) AS EMPLEADOS,
    (SELECT COUNT(*) FROM DEPARTMENTS) AS DEPARTAMENTOS,
    (SELECT COUNT(*) FROM JOBS) AS CARGOS
FROM DUAL;


-- ============================================================
-- 2. CONSULTA RELACIONAL DEL ESQUEMA HR
-- ============================================================
-- Integracion de EMPLOYEES, DEPARTMENTS y JOBS.
-- Recuperacion de los primeros 10 empleados.

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


-- ============================================================
-- 3. GENERACION DEL DOCUMENTO XML
-- ============================================================
-- Transformacion de datos relacionales del esquema HR.
-- Generacion del reporte de empleados mediante SQL/XML.
-- Estructura compatible con esquema_empleados.xsd.
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


-- ============================================================
-- 4. REGISTRO Y VERIFICACION DEL ESQUEMA XSD
-- ============================================================
-- Comprobar si el esquema ya esta registrado en Oracle.
-- Evitar registros duplicados.

SELECT
    SCHEMA_URL,
    LOCAL
FROM USER_XML_SCHEMAS
WHERE SCHEMA_URL =
    'http://unir.local/esquema_empleados.xsd';
    
-- Registro automatico del esquema XSD en Oracle HR.
-- Verificar su existencia para evitar registros duplicados.
-- Si el esquema no existe, se registra mediante DBMS_XMLSCHEMA.
DECLARE
    v_registrado NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_registrado
    FROM USER_XML_SCHEMAS
    WHERE SCHEMA_URL =
        'http://unir.local/esquema_empleados.xsd';

    IF v_registrado = 0 THEN

    DBMS_XMLSCHEMA.registerSchema(
        schemaURL => 'http://unir.local/esquema_empleados.xsd',
        schemaDoc => q'~
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xs:simpleType name="TextoObligatorio">
    <xs:restriction base="xs:string">
      <xs:minLength value="1"/>
    </xs:restriction>
  </xs:simpleType>

  <xs:simpleType name="SalarioValido">
    <xs:restriction base="xs:decimal">
      <xs:minInclusive value="0"/>
    </xs:restriction>
  </xs:simpleType>

  <xs:element name="ReporteEmpleados">
    <xs:complexType>
      <xs:sequence>
        <xs:element name="Empleado"
                    minOccurs="1"
                    maxOccurs="unbounded">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="Nombre"
                          type="TextoObligatorio"/>
              <xs:element name="Apellido"
                          type="TextoObligatorio"/>
              <xs:element name="Salario"
                          type="SalarioValido"/>
              <xs:element name="Departamento">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="IdDepartamento"
                                type="xs:positiveInteger"/>
                    <xs:element name="NombreDepartamento"
                                type="TextoObligatorio"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
              <xs:element name="Cargo">
                <xs:complexType>
                  <xs:sequence>
                    <xs:element name="IdCargo"
                                type="TextoObligatorio"/>
                    <xs:element name="NombreCargo"
                                type="TextoObligatorio"/>
                  </xs:sequence>
                </xs:complexType>
              </xs:element>
            </xs:sequence>
            <xs:attribute name="IdEmpleado"
                          type="xs:positiveInteger"
                          use="required"/>
          </xs:complexType>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
</xs:schema>
~',
    local     => TRUE,
    genTypes  => FALSE,
    genTables => FALSE,
    force     => FALSE
  );
  END IF;
END;
/


-- ============================================================
-- 5. CREACION DE LA TABLA XMLTYPE
-- ============================================================
-- Verificar si existe la tabla HR_XML_VALIDACION.
-- Crear la tabla solo cuando no exista.
-- Almacenamiento XMLTYPE mediante CLOB.

DECLARE
    v_tabla NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_tabla
    FROM USER_TABLES
    WHERE TABLE_NAME = 'HR_XML_VALIDACION';

    IF v_tabla = 0 THEN

        EXECUTE IMMEDIATE q'[
            CREATE TABLE HR_XML_VALIDACION (
                ID NUMBER PRIMARY KEY,
                DOCUMENTO XMLTYPE
            )
            XMLTYPE COLUMN DOCUMENTO
            STORE AS CLOB
            XMLSCHEMA "http://unir.local/esquema_empleados.xsd"
            ELEMENT "ReporteEmpleados"
        ]';

    END IF;
END;
/


-- ============================================================
-- 6. RESTRICCION DE VALIDACION XMLISVALID
-- ============================================================
-- Verificar si existe la restriccion CK_HR_XML_VALIDO.
-- Crear la restriccion solo cuando no exista.
-- Validar los documentos XML contra el esquema XSD.

DECLARE
    v_restriccion NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_restriccion
    FROM USER_CONSTRAINTS
    WHERE TABLE_NAME = 'HR_XML_VALIDACION'
      AND CONSTRAINT_NAME = 'CK_HR_XML_VALIDO';

    IF v_restriccion = 0 THEN

        EXECUTE IMMEDIATE q'[
            ALTER TABLE HR_XML_VALIDACION
            ADD CONSTRAINT CK_HR_XML_VALIDO
            CHECK (
                XMLISVALID(
                    DOCUMENTO,
                    'http://unir.local/esquema_empleados.xsd',
                    'ReporteEmpleados'
                ) = 1
            )
        ]';

    END IF;
END;
/


-- ============================================================
-- 7. INSERCION Y VALIDACION DE UN DOCUMENTO XML VALIDO
-- ============================================================
-- Insertar un documento XML conforme al esquema XSD.
-- Evitar duplicar el registro si ya existe.
-- Verificar su validez mediante XMLISVALID.

INSERT INTO HR_XML_VALIDACION (ID, DOCUMENTO)
SELECT
    1,
    XMLTYPE.createXML(
        q'~
<ReporteEmpleados>
  <Empleado IdEmpleado="100">
    <Nombre>Steven</Nombre>
    <Apellido>King</Apellido>
    <Salario>24000</Salario>
    <Departamento>
      <IdDepartamento>90</IdDepartamento>
      <NombreDepartamento>Executive</NombreDepartamento>
    </Departamento>
    <Cargo>
      <IdCargo>AD_PRES</IdCargo>
      <NombreCargo>President</NombreCargo>
    </Cargo>
  </Empleado>
</ReporteEmpleados>
~',
        'http://unir.local/esquema_empleados.xsd'
    )
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1
    FROM HR_XML_VALIDACION
    WHERE ID = 1
);

COMMIT;

-- Comprobar que el documento cumple el esquema XSD.

SELECT
    ID,
    XMLISVALID(
        DOCUMENTO,
        'http://unir.local/esquema_empleados.xsd',
        'ReporteEmpleados'
    ) AS CUMPLE_XSD
FROM HR_XML_VALIDACION
WHERE ID = 1;


-- ============================================================
-- 8. PRUEBA DE INSERCION DE UN DOCUMENTO XML INVALIDO
-- ============================================================
-- Intentar insertar un XML con salario negativo.
-- El esquema XSD establece un salario minimo de cero.
-- Capturar el error ORA-02290 como resultado esperado.
-- Evitar almacenar datos invalidos durante la prueba.

SET SERVEROUTPUT ON

DECLARE
    e_xml_invalido EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_xml_invalido, -2290);
BEGIN
    SAVEPOINT prueba_xml_invalido;

    BEGIN
        INSERT INTO HR_XML_VALIDACION (ID, DOCUMENTO)
        VALUES (
            2,
            XMLTYPE.createXML(
                q'~
<ReporteEmpleados>
  <Empleado IdEmpleado="100">
    <Nombre>Steven</Nombre>
    <Apellido>King</Apellido>
    <Salario>-5000</Salario>
    <Departamento>
      <IdDepartamento>90</IdDepartamento>
      <NombreDepartamento>Executive</NombreDepartamento>
    </Departamento>
    <Cargo>
      <IdCargo>AD_PRES</IdCargo>
      <NombreCargo>President</NombreCargo>
    </Cargo>
  </Empleado>
</ReporteEmpleados>
~',
                'http://unir.local/esquema_empleados.xsd'
            )
        );

        DBMS_OUTPUT.PUT_LINE(
            'ADVERTENCIA: El XML invalido fue aceptado.'
        );

        ROLLBACK TO prueba_xml_invalido;

    EXCEPTION
        WHEN e_xml_invalido THEN
            DBMS_OUTPUT.PUT_LINE(
                'PRUEBA CORRECTA: XML invalido rechazado.'
            );
            DBMS_OUTPUT.PUT_LINE(
                'Error esperado: ORA-02290.'
            );

            ROLLBACK TO prueba_xml_invalido;
    END;
END;
/


-- ============================================================
-- 9. VERIFICACION FINAL DE DOCUMENTOS XML
-- ============================================================
-- Comprobar los registros almacenados en Oracle.
-- Verificar el cumplimiento del esquema XSD.
-- Confirmar que el XML invalido no fue almacenado.

SELECT
    ID,
    XMLISVALID(
        DOCUMENTO,
        'http://unir.local/esquema_empleados.xsd',
        'ReporteEmpleados'
    ) AS CUMPLE_XSD
FROM HR_XML_VALIDACION
WHERE ID IN (1, 2)
ORDER BY ID;