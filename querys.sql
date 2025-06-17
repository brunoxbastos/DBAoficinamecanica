
-- 1. Ordem de serviço completa de um carro (substitua 'ABC-1234' pela placa do veículo)
SELECT
    so.service_order_id,
    c.full_name AS customer_name,
    c.phone AS customer_phone,
    c.address AS customer_address,
    c.cpf_cnpj,
    v.plate,
    v.model AS vehicle_model,
    v.chassis,
    v.mileage,
    v.fuel_level,
    t.team_name,
    so.issue_date,
    so.delivery_date,
    so.total_value,
    GROUP_CONCAT(DISTINCT p.part_type ORDER BY p.part_type SEPARATOR ", ") AS parts_used_types,
    GROUP_CONCAT(DISTINCT CONCAT(p.material, " ", p.vehicle_system, " ", p.part_type, " (qtd: ", sop.quantity, ")") ORDER BY p.part_type SEPARATOR "; ") AS parts_details,
    GROUP_CONCAT(DISTINCT s.description_sevice ORDER BY s.description_sevice SEPARATOR ", ") AS services_performed,
    GROUP_CONCAT(DISTINCT l.labor_type ORDER BY l.labor_type SEPARATOR ", ") AS labor_types
FROM
    service_order so
JOIN
    customer c ON so.customer_id = c.customer_id
JOIN
    vehicle v ON so.vehicle_id = v.vehicle_id
LEFT JOIN
    team t ON so.team_id = t.team_id
LEFT JOIN
    service_order_part sop ON so.service_order_id = sop.service_order_id
LEFT JOIN
    part p ON sop.part_id = p.part_id
LEFT JOIN
    service_order_service sos ON so.service_order_id = sos.service_order_id
LEFT JOIN
    service s ON sos.service_id = s.service_id
LEFT JOIN
    labor l ON s.labor_id = l.labor_id
WHERE
    v.plate = 'HYK-7A08' -- Substitua pela placa do veículo desejado
GROUP BY
    so.service_order_id, c.full_name, c.phone, c.address, c.cpf_cnpj, v.plate, v.model, v.chassis, v.mileage, v.fuel_level, t.team_name, so.issue_date, so.delivery_date, so.total_value;

-- 2. Ordem de serviço de uma frota completa de carros de uma empresa (substitua 'Nome da Empresa' pelo nome do cliente/empresa)
SELECT
    so.service_order_id,
    c.full_name AS customer_name,
    v.plate,
    v.model AS vehicle_model,
    so.issue_date,
    so.total_value,
    GROUP_CONCAT(DISTINCT s.description_sevice ORDER BY s.description_sevice SEPARATOR ", ") AS services_performed
FROM
    service_order so
JOIN
    customer c ON so.customer_id = c.customer_id
JOIN
    vehicle v ON so.vehicle_id = v.vehicle_id
LEFT JOIN
    service_order_service sos ON so.service_order_id = sos.service_order_id
LEFT JOIN
    service s ON sos.service_id = s.service_id
WHERE
    c.full_name = 'Dra. Clara da Cunha' -- Substitua pelo nome completo do cliente/empresa
GROUP BY
    so.service_order_id, c.full_name, v.plate, v.model, so.issue_date, so.total_value
ORDER BY
    c.full_name, v.plate, so.issue_date;

-- 3. Quantos clientes foram atendidos em um ano (substitua '2023' pelo ano desejado)
SELECT
    COUNT(DISTINCT c.customer_id) AS total_customers_attended
FROM
    service_order so
JOIN
    customer c ON so.customer_id = c.customer_id
WHERE
    year(so.issue_date) = '2023'; -- Para MySQL/PostgreSQL use YEAR(so.issue_date)

-- 4. Qual valor médio recebido em um ano (substitua '2023' pelo ano desejado)
SELECT
    AVG(total_value) AS average_value_received
FROM
    service_order
WHERE
    year(issue_date) = '2023'; -- Para MySQL/PostgreSQL use YEAR(issue_date)

-- 5. Quais tipos de serviços foram mais realizados
SELECT
    l.labor_type,
    COUNT(sos.service_id) AS times_performed
FROM
    service_order_service sos
JOIN
    service s ON sos.service_id = s.service_id
JOIN
    labor l ON s.labor_id = l.labor_id
GROUP BY
    l.labor_type
ORDER BY
    times_performed DESC;
--6 Veículos que tiveram serviços de "reparo" e "troca" no mesmo ano, ordenados pela data da última ordem de serviço
SELECT
    v.plate,
    v.model,
    c.full_name AS customer_name,
    MAX(so.delivery_date) AS last_service_date
FROM
    vehicle v
JOIN customer c ON v.customer_id = c.customer_id
JOIN service_order so ON v.vehicle_id = so.vehicle_id
JOIN service_order_service sos ON so.service_order_id = sos.service_order_id
JOIN service s ON sos.service_id = s.service_id
JOIN labor l ON s.labor_id = l.labor_id
WHERE
    l.labor_type IN ('reparo', 'troca')
    AND YEAR(so.issue_date) = 2023
GROUP BY
    v.vehicle_id, v.plate, v.model, c.full_name
HAVING
    COUNT(DISTINCT CASE WHEN l.labor_type = 'reparo' THEN 1 END) > 0
    AND COUNT(DISTINCT CASE WHEN l.labor_type = 'troca' THEN 1 END) > 0
ORDER BY
    last_service_date DESC;
--7 Clientes que tiveram mais de 3 ordens de serviço e o valor total gasto por eles, ordenado pelo valor total gasto (maior para menor)
SELECT
    c.full_name AS customer_name,
    COUNT(so.service_order_id) AS total_service_orders,
    SUM(so.total_value) AS total_spent
FROM
    customer c
JOIN
    service_order so ON c.customer_id = so.customer_id
GROUP BY
    c.customer_id, c.full_name
HAVING
    COUNT(so.service_order_id) > 3
ORDER BY
    total_spent DESC;

