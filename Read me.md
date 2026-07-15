# 🍽️ Swiggy Dataset Analysis using Python, MySQL & SQLAlchemy

## 📌 Project Overview

This project demonstrates an end-to-end data analysis workflow using the Swiggy food delivery dataset. The project focuses on data cleaning, transformation, loading (ETL), and SQL-based exploratory data analysis.

The dataset contains nearly **197,430 food order records** collected across multiple Indian cities, including restaurant details, food categories, pricing, ratings, and order dates.

The project showcases practical Data Analyst skills including:

- Data Cleaning using Python (Pandas)
- Date Transformation
- ETL using SQLAlchemy
- Loading data into MySQL
- SQL Data Analysis
- Data Quality Checks
- Dimensional Modeling Preparation

---

## 🛠️ Tech Stack

- Python
- Pandas
- SQLAlchemy
- PyMySQL
- MySQL Workbench
- SQL

---

## 📂 Dataset Information

| Attribute | Description |
|-----------|-------------|
| State | State where the order was placed |
| City | City |
| Order_Date | Date of Order |
| Restaurant_Name | Restaurant Name |
| Location | Restaurant Location |
| Category | Food Category |
| Dish_Name | Dish Name |
| Price_INR | Price in INR |
| Rating | Customer Rating |
| Rating_Count | Number of Ratings |

Total Records:

```
197,430
```

Total Columns:

```
10
```

---

# 📊 Project Workflow

```
CSV Dataset
      │
      ▼
Python (Pandas)
      │
      ├── Data Inspection
      ├── Null Value Check
      ├── Duplicate Check
      ├── Date Transformation
      │
      ▼
SQLAlchemy
      │
      ▼
MySQL Database
      │
      ▼
SQL Analysis
```

---

# 📁 Project Structure

```
Swiggy_Dataset_Analysis/
│
├── Dataset/
│     ├── Swiggy_Data_1.csv
│
├── Python/
│     ├── Data_Cleaning.ipynb
│     ├── Data_Loading_SQLAlchemy.ipynb
│
├── SQL/
│     ├── Database.sql
│     ├── Analysis.sql
│
├── Images/
│
└── README.md
```

---

# ⚙️ Data Cleaning

Performed using **Pandas**.

### Checked Dataset Information

---

# 🚀 Loading Data into MySQL

Instead of importing CSV directly into MySQL Workbench, the dataset was loaded using **SQLAlchemy**.

### Connection

```python
from sqlalchemy import create_engine

engine = create_engine(
"mysql+pymysql://root:password@localhost/swiggy_db"
)
```

### Load Data

```python
df.to_sql(
    name="swiggy",
    con=engine,
    if_exists="replace",
    index=False
)
```
---

# 🗄️ SQL Analysis Performed

The project includes SQL queries for:

- Data Exploration
- NULL Value Analysis
- Duplicate Detection
- Restaurant Analysis
- Category Analysis
- Rating Analysis
- Average Price Analysis
- Highest Rated Restaurants
- Most Expensive Dishes
- City-wise Analysis
- State-wise Analysis

---

# Example SQL Query

### NULL Value Check

```sql
SELECT
SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date
FROM swiggy;
```

---

# 📈 Skills Demonstrated

- Python
- Pandas
- SQL
- MySQL
- SQLAlchemy
- ETL
- Data Cleaning
- Data Transformation
- Data Validation
- Exploratory Data Analysis

---

# Learning Outcomes

Through this project I learned:

- Cleaning real-world datasets
- Handling date formatting issues
- Detecting duplicate records
- Managing NULL values
- Loading data into MySQL using SQLAlchemy
- Writing analytical SQL queries
- Building an ETL workflow using Python and SQL

---

# Future Improvements

- Power BI Dashboard
- Tableau Dashboard
- Star Schema Data Warehouse
- Stored Procedures
- Views
- Index Optimization
- Advanced SQL Analytics

---

## Author

**HariKumar**

GitHub

https://github.com/kumarhariofficial-collab

LinkedIn

https://www.linkedin.com/in/hari-kumar-p-46a5ab142/
