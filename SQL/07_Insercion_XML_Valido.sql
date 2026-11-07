-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 9.3: Insercion de un documento XML valido
-- Validacion contra el esquema XSD registrado

INSERT INTO HR_XML_VALIDACION (ID, DOCUMENTO)
VALUES (
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
);


COMMIT;

-- PASO 9.4: Verificacion del XML almacenado

SELECT
    ID,
    XMLISVALID(
        DOCUMENTO,
        'http://unir.local/esquema_empleados.xsd',
        'ReporteEmpleados'
    ) AS CUMPLE_XSD
FROM HR_XML_VALIDACION
WHERE ID = 1;