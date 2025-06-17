use oficina_mecanica;

-- Customer
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone VARCHAR(24),
    address VARCHAR(30),
    cpf_cnpj CHAR(14)
);

-- Vehicle
CREATE TABLE vehicle (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    plate CHAR(7) NOT NULL,
    model VARCHAR(50),
    chassis VARCHAR(50),
    mileage INT,
    fuel_level ENUM('vazio', '1/4', '1/2', '3/4', 'cheio'),
    CONSTRAINT fk_vehicle_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Employee
CREATE TABLE employee (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone VARCHAR(24),
    address VARCHAR(60),
    cpf CHAR(11) NOT NULL,
    remployee_type ENUM('administrativo', 'mecanico') NOT NULL,
    tier VARCHAR(50),
    specialty VARCHAR(50),
    salary DECIMAL(10,2)
);

-- Team
CREATE TABLE team (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(20)
);

-- Team-Employee relationship (many-to-many)
CREATE TABLE team_employee (
    team_id INT NOT NULL,
    employee_id INT NOT NULL,
    PRIMARY KEY (team_id, employee_id),
    CONSTRAINT fk_team_employee_team FOREIGN KEY (team_id) REFERENCES team(team_id),
    CONSTRAINT fk_team_employee_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

-- Part
CREATE TABLE part (
    part_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_system ENUM('carro', 'moto', 'caminhão'),
    material ENUM('aço', 'aluminio', 'plastico', 'vidro'),
    part_type ENUM('motor', 'chassi', 'carroceria', 'eletrico', 'decoração'),
    box_quantity INT
);

-- Stock
CREATE TABLE stock (
    part_id INT PRIMARY KEY,
    quantity_available INT,
    CONSTRAINT fk_stock_part FOREIGN KEY (part_id) REFERENCES part(part_id)
);

-- Labor
CREATE TABLE labor (
    labor_id INT AUTO_INCREMENT PRIMARY KEY,
    labor_type ENUM('revisão', 'reparo', 'troca', 'outro'),
    price DECIMAL(10,2)
);

-- Service
CREATE TABLE service (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    description_sevice VARCHAR(100),
    labor_id INT,
    CONSTRAINT fk_service_labor FOREIGN KEY (labor_id) REFERENCES labor(labor_id)
);

-- Service Order (header)
CREATE TABLE service_order (
    service_order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    team_id INT,
    issue_date DATE,
    delivery_date DATE,
    total_value DECIMAL(10,2),
    CONSTRAINT fk_service_order_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_service_order_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle(vehicle_id),
    CONSTRAINT fk_service_order_team FOREIGN KEY (team_id) REFERENCES team(team_id)
);

-- Service Order - Part (many-to-many)
CREATE TABLE service_order_part (
    service_order_id INT NOT NULL,
    part_id INT NOT NULL,
    quantity INT,
    PRIMARY KEY (service_order_id, part_id),
    CONSTRAINT fk_service_order_part_order FOREIGN KEY (service_order_id) REFERENCES service_order(service_order_id),
    CONSTRAINT fk_service_order_part_part FOREIGN KEY (part_id) REFERENCES part(part_id)
);

-- Service Order - Service (many-to-many)
CREATE TABLE service_order_service (
    service_order_id INT NOT NULL,
    service_id INT NOT NULL,
    service_value DECIMAL(10,2),
    PRIMARY KEY (service_order_id, service_id),
    CONSTRAINT fk_service_order_service_order FOREIGN KEY (service_order_id) REFERENCES service_order(service_order_id),
    CONSTRAINT fk_service_order_service_service FOREIGN KEY (service_id) REFERENCES service(service_id)
);
