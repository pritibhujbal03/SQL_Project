-- View all records from the blinkit_db table
SELECT * 
FROM blinkit_db;

-- ---------------- Data Cleaning ----------------

-- Standardize inconsistent values in the 'Item_Fat_Content' column using CASE for multiple replacements
UPDATE blinkit_db
SET Item_Fat_Content = CASE
    WHEN Item_Fat_Content IN ('LF','low fat') THEN 'Low Fat'
    WHEN Item_Fat_Content = 'reg' THEN 'Regular'
    ELSE Item_Fat_Content
END;

-- Verify the unique values in 'Item_Fat_Content' after cleaning
SELECT DISTINCT Item_Fat_Content
FROM blinkit_db;

-- ---------------- Business KPIs ----------------

-- Calculate total sales (overall revenue)
SELECT SUM(Sales) AS Total_Sales 
FROM blinkit_db;

-- Show total sales in millions for better readability
SELECT CAST(SUM(Sales)/1000000 AS DECIMAL(10,2)) AS TotalSales_inMillions
FROM blinkit_db;

-- Calculate average sales (average revenue per transaction)
SELECT AVG(Sales) AS Avg_Sales
FROM blinkit_db;

-- Show average sales in millions
SELECT CAST(AVG(Sales) AS DECIMAL(10,2)) AS AvgSales_inMillions
FROM blinkit_db;

-- Round off average sales to the nearest whole number
SELECT ROUND(AVG(Sales), 0) AS Rounded_Average_Sales
FROM blinkit_db;

-- Count the total number of items sold (records)
SELECT COUNT(*) AS No_of_Items
FROM blinkit_db;

-- Calculate total sales for items with 'Low Fat' content only (in millions)
SELECT CAST(SUM(Sales)/1000000 AS DECIMAL(10,2)) AS Total_LowFat_Sales_Millions
FROM blinkit_db
WHERE Item_Fat_Content = 'Low Fat';

-- Round off 'Low Fat' total sales
SELECT ROUND(SUM(Sales), 0) AS Rounded_LowFat_Sales
FROM blinkit_db
WHERE Item_Fat_Content = 'Low Fat';

-- ---------------- Customer Ratings ----------------

-- Calculate the average customer rating across all items
SELECT AVG(Rating) AS Avg_Rating
FROM blinkit_db;

-- Calculate the average rating rounded to two decimal places using CAST
SELECT CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating_Cast
FROM blinkit_db;

-- Calculate the average rating rounded to the nearest whole number using ROUND
SELECT ROUND(AVG(Rating), 0) AS Avg_Rating_Rounded
FROM blinkit_db;

-- ---------------- Granular Analysis ----------------

-- Analyze total sales grouped by fat content
SELECT
    Item_Fat_Content,
    SUM(Sales) AS Total_Sales
FROM 
    blinkit_db
GROUP BY 
    Item_Fat_Content
ORDER BY 
    Total_Sales DESC;

-- Detailed metrics by fat content
SELECT
    Item_Fat_Content,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Sales) AS DECIMAL(10,2)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM
    blinkit_db
GROUP BY
    Item_Fat_Content
ORDER BY
    Total_Sales DESC;

-- Detailed metrics by item type
SELECT
    Item_Type,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM
    blinkit_db
GROUP BY
    Item_Type
ORDER BY
    Total_Sales DESC;

-- Top 5 item types by total sales
SELECT TOP 5
    Item_Type,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM
    blinkit_db
GROUP BY
    Item_Type
ORDER BY
    Total_Sales DESC;

-- Bottom 5 item types by total sales
SELECT TOP 5
    Item_Type,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM
    blinkit_db
GROUP BY
    Item_Type
ORDER BY
    Total_Sales ASC;

-- Analyze sales by outlet location type segmented by fat content
SELECT 
    Outlet_Location_Type,
    Item_Fat_Content,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM
    blinkit_db
GROUP BY
    Outlet_Location_Type, Item_Fat_Content
ORDER BY
    Total_Sales ASC;

-- Pivot fat content values into columns to compare across outlet locations
SELECT
    Outlet_Location_Type,
    ISNULL([Low Fat], 0) AS Low_Fat,
    ISNULL([Regular], 0) AS Regular
FROM (
    SELECT 
        Outlet_Location_Type,
        Item_Fat_Content,
        CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
    FROM 
        blinkit_db
    GROUP BY 
        Outlet_Location_Type, Item_Fat_Content
) AS SourceTable
PIVOT (
    SUM(Total_Sales)
    FOR Item_Fat_Content IN ([Low Fat], [Regular])
) AS PivotTable
ORDER BY Outlet_Location_Type;

-- ---------------- Temporal Analysis ----------------

-- Total sales by outlet establishment year
SELECT
    Outlet_Establishment_Year,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales
FROM
    blinkit_db
GROUP BY 
    Outlet_Establishment_Year
ORDER BY
    Outlet_Establishment_Year ASC;

-- Multiple metrics by outlet establishment year
SELECT
    Outlet_Establishment_Year,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST(AVG(Sales) AS DECIMAL(10,2)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM 
    blinkit_db
GROUP BY 
    Outlet_Establishment_Year
ORDER BY
    Total_Sales DESC;

-- ---------------- Business Insights ----------------

-- Percentage of total sales by outlet size
SELECT
    Outlet_Size,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM
    blinkit_db
GROUP BY
    Outlet_Size
ORDER BY
    Total_Sales DESC;

-- Sales and contribution percentage by outlet location
SELECT
    Outlet_Location_Type,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage
FROM
    blinkit_db
GROUP BY
    Outlet_Location_Type
ORDER BY
    Total_Sales DESC;

-- Full summary of sales metrics by outlet type
SELECT
    Outlet_Type,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS Total_Sales,
    CAST((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)) AS Sales_Percentage,
    CAST(AVG(Sales) AS DECIMAL(10,2)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM
    blinkit_db
GROUP BY
    Outlet_Type
ORDER BY
    Total_Sales DESC;
