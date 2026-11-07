-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 7: Registro del esquema XML en Oracle

SELECT
    SCHEMA_URL,
    LOCAL
FROM USER_XML_SCHEMAS
WHERE SCHEMA_URL LIKE '%esquema_empleados%';


-- Registramos esquema XSD en Oracle HR

BEGIN
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
END;
/