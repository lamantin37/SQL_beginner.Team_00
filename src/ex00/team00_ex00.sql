CREATE TABLE nodes (
 point1 CHAR(1),
 point2 CHAR(2),
 cost INTEGER
);

INSERT INTO nodes (point1, point2, cost) VALUES
('a', 'b', 10),
('b', 'a', 10),
('a', 'c', 15),
('c', 'a', 15),
('a', 'd', 20),
('d', 'a', 20),
('b', 'c', 35),
('c', 'b', 35),
('b', 'd', 25),
('d', 'b', 25),
('d', 'c', 30),
('c', 'd', 30);

WITH RECURSIVE tours AS (
  SELECT 
    point1 AS start_city,
    '{' || point1 || ',' || point2 AS tour,
    point2 AS current_city,
    cost AS total_cost,
    ARRAY[point1, point2] AS cities_visited
  FROM nodes
  WHERE point1 = 'a'
  
  UNION ALL
  
  SELECT 
    tours.start_city,
    tours.tour || ',' || nodes.point2,
    nodes.point2 AS current_city,
    tours.total_cost + nodes.cost AS total_cost,
    tours.cities_visited || nodes.point2 AS cities_visited
  FROM tours
  JOIN nodes ON tours.current_city = nodes.point1
  WHERE 
    nodes.point2 NOT IN (SELECT unnest(tours.cities_visited)) AND
    ARRAY_LENGTH(tours.cities_visited, 1) < 4
),
all_tours AS (
  SELECT 
    tours.total_cost + nodes.cost AS total_cost,
    CASE 
      WHEN nodes.point2 = tours.start_city THEN tours.tour || ',' || nodes.point2 || '}'
      ELSE tours.tour || ',' || nodes.point2 || ',' || tours.start_city
    END AS tour
  FROM tours
  JOIN nodes ON tours.current_city = nodes.point1 AND nodes.point2 = tours.start_city
  WHERE ARRAY_LENGTH(tours.cities_visited, 1) = 4
)
SELECT 
  total_cost,
  tour
FROM all_tours
WHERE total_cost = (SELECT MIN(total_cost) FROM all_tours)
ORDER BY total_cost, tour;