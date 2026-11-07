-- LABORATORIO 1 - BASES DE DATOS AVANZADAS
-- PASO 9: Validacion de documentos XML
-- Restriccion para garantizar cumplimiento del XSD

ALTER TABLE HR_XML_VALIDACION
ADD CONSTRAINT CK_HR_XML_VALIDO
CHECK (
    XMLISVALID(
        DOCUMENTO,
        'http://unir.local/esquema_empleados.xsd',
        'ReporteEmpleados'
    ) = 1
);