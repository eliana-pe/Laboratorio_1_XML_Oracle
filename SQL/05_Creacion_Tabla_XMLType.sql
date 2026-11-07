-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 8: Creacion de tabla XMLType
-- Almacenamiento CLOB asociado al esquema XSD

CREATE TABLE HR_XML_VALIDACION (
    ID NUMBER PRIMARY KEY,
    DOCUMENTO XMLTYPE
)
XMLTYPE COLUMN DOCUMENTO
STORE AS CLOB
XMLSCHEMA "http://unir.local/esquema_empleados.xsd"
ELEMENT "ReporteEmpleados";
