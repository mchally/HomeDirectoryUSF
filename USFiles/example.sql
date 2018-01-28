-- Create a table called students
CREATE TABLE students (id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY, name VARCHAR(15) NOT NULL, username CHAR(5) NOT NULL, graduationDate CHAR(10), GPA FLOAT);

INSERT INTO students (name, username, graduationDate, GPA) VALUES 
('Anita Karp', 'akarp', '05-30-2017', 3.8),
('Joshua Lee', 'jlee2', '05-30-2018', 3.5),
('Alice Chen', 'achen', '12-18-2018', 3.7),
('Bradon Montoya', 'bmont', '12-18-2016', 3.7),
('Deepak Kumar', 'dkuma', '05-30-2019', 3.9),
('Xiaofeng Tan', 'xitan', '05-30-2019', 3.9);

-- Show records that correspond to students with the GPA more than 3.6. Sort these students by GPA in descending order
SELECT * FROM students
WHERE GPA > 3.6
ORDER BY GPA DESC;

-- Create another table: courses
CREATE TABLE courses (id INTEGER AUTO_INCREMENT NOT NULL PRIMARY KEY, name CHAR(5) NOT NULL, department VARCHAR(15) NOT NULL, instructor VARCHAR(15));

-- check that the columns look ok
DESCRIBE courses;

-- Oops, 15 characters were not enough to represent Computer Science - we can change that
ALTER TABLE courses
MODIFY COLUMN department VARCHAR(22);

INSERT INTO courses (name, department, instructor)
VALUES ('CS601', 'Computer Science', 'Karpenko'), ('CS673', 'Computer Science', 'Galles'),
       ('CS690', 'Computer Science', 'Karpenko'), ('CS212', 'Computer Science', 'Engle'),
       ('CS490', 'Computer Science', 'Johnson'), ('CS112', 'Computer Science', 'Rollins'),
       ('MA202', 'Mathematics', 'Pacheco');

-- Select all instructors who are teaching CS courses. Duplicates are not removed here
SELECT instructor FROM courses
WHERE department = 'Computer Science'
ORDER BY instructor;

-- create the enrollment table 
CREATE TABLE enrollment (courseId INTEGER NOT NULL, studentId INTEGER NOT NULL, PRIMARY KEY (courseId, studentId));

INSERT INTO enrollment
VALUES (1, 1), (1, 3), (2, 1), (2, 3), (2, 4), (3, 4), (3, 2), (6, 5), (6, 6);

-- Grouping: show the number of classes for each student
SELECT studentId, COUNT(*) AS numCourses
FROM enrollment
GROUP BY studentId;

-- student ids where students take more than 1 computer science course
SELECT studentId, COUNT(*) AS courseId
FROM enrollment
GROUP BY studentId
HAVING COUNT(*) > 1;

-- Prting name of the student and the name of the course they are taking,  in each row
select students.name, courses.name from students, courses, enrollment
where enrollment.studentId = students.id AND courses.id = enrollment.courseId;

