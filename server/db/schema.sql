CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    course_type ENUM('gateway', 'core', 'concentration'),
    prereqs JSON,
    coreqs JSON
); 