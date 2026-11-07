-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 9.5: Insercion de un documento XML invalido
-- Prueba: salario negativo no permitido por el XSD

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