SELECT e.full_name AS employee,m.full_name AS manager FROM employees e LEFT JOIN employees m ON m.employee_id=e.manager_id ORDER BY e.employee_id;
